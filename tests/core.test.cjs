const { test } = require('node:test');
const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');
const vm = require('node:vm');
const ts = require(process.env.CORE_TYPESCRIPT_PATH || 'typescript');
const root = path.resolve(__dirname, '..');

// Run the production data layer on the host, substituting only platform APIs.
function loader(stubs = {}) {
  const cache = new Map();
  function load(file) {
    file = path.resolve(root, file);
    if (cache.has(file)) return cache.get(file).exports;
    const module = { exports: {} };
    cache.set(file, module);
    const code = ts.transpileModule(fs.readFileSync(file, 'utf8'), {
      compilerOptions: { module: ts.ModuleKind.CommonJS, target: ts.ScriptTarget.ES2020 }
    }).outputText;
    const requireSource = name => {
      if (name in stubs) return stubs[name];
      if (!name.startsWith('.')) throw new Error(`Unexpected platform dependency: ${name}`);
      const base = path.resolve(path.dirname(file), name);
      return load(['.ts', '.ets', ''].map(ext => base + ext).find(candidate => fs.existsSync(candidate)));
    };
    const quietConsole = { debug() {}, info() {}, warn() {}, error() {} };
    vm.runInNewContext(code, { module, exports: module.exports, require: requireSource,
      console: quietConsole, Date, Number, Promise, Error, Intl }, { filename: file });
    return module.exports;
  }
  return load;
}

const repoPath = 'data/src/main/ets/repository/WeatherRepository.ts';
function fixture(ageMinutes, offline = false) {
  const load = loader();
  const { WeatherRepository } = load(repoPath);
  const currentWeather = { current: { temperature_2m: 12, weather_code: 3, is_day: 1 }, last_update: new Date() };
  const forecast = { daily: { time: [1] } };
  const cached = ageMinutes === null ? { currentWeather: null, forecast: null, lastUpdated: null } :
    { currentWeather, forecast, lastUpdated: new Date(Date.now() - ageMinutes * 60000) };
  let fetches = 0;
  let saves = 0;
  const remote = {
    async getCurrentWeather() { fetches++; if (offline) throw new Error('offline'); return currentWeather; },
    async getForecast() { if (offline) throw new Error('offline'); return forecast; }
  };
  const local = {
    async saveCity() { return 1; },
    async getWeatherData() { return cached; },
    async saveWeatherData() { saves++; }
  };
  const repository = new WeatherRepository(remote, local, { async getCurrentLocation() { return { latitude: 52, longitude: 21 }; } });
  return { repository, cached, currentWeather, forecast, fetches: () => fetches, saves: () => saves };
}
const city = { place_id: 1, name: 'Warsaw', lat: 52, lon: 21 };

test('cache stays fresh for 15 minutes', async () => {
  const f = fixture(10);
  assert.strictEqual(await f.repository.getWeatherData(city), f.cached);
  assert.equal(f.fetches(), 0);
});
test('stale cache is refreshed and saved', async () => {
  const f = fixture(16);
  const result = await f.repository.getWeatherData(city);
  assert.strictEqual(result.currentWeather, f.currentWeather);
  assert.equal(f.fetches(), 1);
  assert.equal(f.saves(), 1);
});
test('offline refresh returns complete stale cache', async () => {
  const f = fixture(16, true);
  assert.strictEqual(await f.repository.getWeatherData(city), f.cached);
  assert.equal(f.saves(), 0);
});
test('offline without cached weather reports an error', async () => {
  const f = fixture(null, true);
  await assert.rejects(f.repository.getWeatherData(city), /offline/);
});
test('missing or invalid city never reaches API', async () => {
  const f = fixture(null);
  await assert.rejects(f.repository.getWeatherData(null), /Invalid city/);
  await assert.rejects(f.repository.getWeatherData({ place_id: 1, lat: NaN, lon: 21 }), /Invalid city/);
  assert.equal(f.fetches(), 0);
});
test('invalid cache timestamp forces a refresh', async () => {
  const f = fixture(10);
  f.cached.lastUpdated = new Date(NaN);
  await f.repository.getWeatherData(city);
  assert.equal(f.fetches(), 1);
});
test('cache mapping preserves day/night and weather icon code', () => {
  const load = loader({ '@ohos.data.relationalStore': { default: { SecurityLevel: { S1: 1 } } } });
  const mapper = load('data/src/main/ets/database/mapper/WeatherMapper.ts');
  const weather = { current: { temperature_2m: -5, weather_code: 71, is_day: 0 }, last_update: new Date() };
  const row = mapper.entityToRecord(mapper.currentWeatherToEntity(1, weather));
  assert.equal(row.weather_code, 71);
  assert.equal(row.is_day, 0);
  assert.equal(row.temperature, -5);
});

for (const scenario of ['success', 'network', 'status', 'json']) {
  test(`HTTP ${scenario}: resources are destroyed`, async () => {
    let destroyed = 0;
    const platform = { createHttp: () => ({
      async request(url, options) {
        assert.equal(options.connectTimeout, 10000);
        assert.equal(options.readTimeout, 10000);
        if (scenario === 'network') throw new Error('offline');
        return { responseCode: scenario === 'status' ? 503 : 200, result: scenario === 'json' ? 'invalid' : '{"ok":true}' };
      },
      destroy() { destroyed++; }
    }) };
    const load = loader({ '@ohos.net.http': { default: platform } });
    const { makeHttpRequest } = load('data/src/main/ets/net/makeHttpRequest.ts');
    if (scenario === 'success') assert.equal((await makeHttpRequest('https://example.com', 'GET')).ok, true);
    else await assert.rejects(makeHttpRequest('https://example.com', 'GET'), error =>
      error.code === ({ network: 1001, status: 1002, json: 1003 })[scenario]);
    assert.equal(destroyed, 1);
  });
}
test('watch ViewModel uses repository injected after construction and propagates GPS errors', async () => {
  const load = loader();
  const { AppError } = load('data/src/main/ets/common/AppError.ts');
  const watchLoad = loader({ '@mymeteo/data': { AppError } });
  const { WeatherViewModel } = watchLoad('watch/src/main/ets/viewmodel/WeatherViewModel.ts');
  const model = new WeatherViewModel();
  await assert.rejects(model.getLocation(), error => error.code === 1100);
  model.setRepository({
    async getCurrentLocation() { return { latitude: 52, longitude: 21 }; },
    async searchCityByCoordinates(lat, lon) { assert.equal(lat, 52); assert.equal(lon, 21); return city; }
  });
  assert.strictEqual(await model.getLocation(), city);
  model.setRepository({ async getCurrentLocation() { throw new AppError(1201, 'GPS disabled'); } });
  await assert.rejects(model.getLocation(), /GPS disabled/);
});

test('Nominatim string coordinates become numeric DTOs for search and reverse geocoding', async () => {
  const apiCity = { ...city, lat: '52.2297', lon: '21.0122' };
  const http = { RequestMethod: { GET: 'GET' }, createHttp: () => ({
    async request(url) { return { responseCode: 200, result: JSON.stringify(url.includes('/search?') ? [apiCity] : apiCity) }; },
    destroy() {}
  }) };
  const load = loader({ '@ohos.net.http': { default: http } });
  const { WeatherAPI } = load('data/src/main/ets/net/WeatherAPI.ts');
  const api = new WeatherAPI();
  const results = await api.searchCity('Warsaw');
  assert.equal(results[0].lat, 52.2297);
  assert.equal(results[0].lon, 21.0122);
  const result = await api.reverseGeocoding(52.2297, 21.0122);
  assert.equal(result.lat, 52.2297);
  assert.equal(result.lon, 21.0122);
});
test('reverse geocoding errors are reported before weather fetch', async () => {
  const http = { RequestMethod: { GET: 'GET' }, createHttp: () => ({
    async request() { return { responseCode: 200, result: '{"error":"Unable to geocode"}' }; }, destroy() {}
  }) };
  const load = loader({ '@ohos.net.http': { default: http } });
  const { WeatherAPI } = load('data/src/main/ets/net/WeatherAPI.ts');
  await assert.rejects(new WeatherAPI().reverseGeocoding(0, 0), error => error.code === 1003);
});
test('database result sets close when row mapping fails', async () => {
  class RdbPredicates {}
  const load = loader({ '@ohos.data.relationalStore': { default: { RdbPredicates } } });
  const { BaseRelationalDatabase } = load('data/src/main/ets/database/db/BaseRelationalDatabase.ts');
  let closed = 0;
  const db = new BaseRelationalDatabase({ async query() { return { rowCount: 1, close() { closed++; } }; } });
  await assert.rejects(db.query('weather', [], predicates => predicates, () => { throw new Error('bad row'); }),
    error => error.code === 1102);
  assert.equal(closed, 1);
});
test('permission denial is returned without terminating the app', async () => {
  let grant = false;
  const platform = { GrantStatus: { PERMISSION_GRANTED: 0 }, createAtManager: () => ({
    async requestPermissionsFromUser(context, permissions) { return { permissions, authResults: [grant ? 0 : -1] }; }
  }) };
  const load = loader({ '@kit.AbilityKit': { abilityAccessCtrl: platform } });
  const { PermissionManager } = load('common/src/main/ets/permissions/PermissionManager.ets');
  const manager = new PermissionManager();
  const context = { terminateSelf() { assert.fail('Permission denial must not terminate the app'); } };
  assert.equal(await manager.requestPermissions(context, ['location']), false);
  grant = true;
  assert.equal(await manager.requestPermissions(context, ['location']), true);
});
test('location request uses bounded timeout and reports disabled GPS', async () => {
  let enabled = true;
  const geoLocationManager = {
    isLocationEnabled: () => enabled,
    LocationRequestPriority: { FIRST_FIX: 1 }, LocationRequestScenario: { UNSET: 0 },
    async getCurrentLocation(request) { assert.equal(request.timeoutMs, 10000); return { latitude: 52, longitude: 21 }; }
  };
  const load = loader({ '@kit.LocationKit': { geoLocationManager } });
  const { LocationProvider } = load('data/src/main/ets/datasource/local/LocationProvider.ts');
  const provider = new LocationProvider();
  const location = await provider.getCurrentLocation();
  assert.equal(location.latitude, 52);
  assert.equal(location.longitude, 21);
  enabled = false;
  await assert.rejects(provider.getCurrentLocation(), error => error.code === 1201);
});

test('products compile at API 23, require API 20 and build separate entry modules', () => {
  const profile = vm.runInNewContext('(' + fs.readFileSync(path.join(root, 'build-profile.json5'), 'utf8') + ')');
  assert.equal(profile.app.products.length, 2);
  for (const product of profile.app.products) {
    assert.equal(product.compileSdkVersion, 23);
    assert.equal(product.compatibleSdkVersion, 20);
    assert.equal(product.targetSdkVersion, 23);
    assert.equal(product.runtimeOS, 'OpenHarmony');
    const entries = profile.modules.filter(module => ['entry', 'watch'].includes(module.name) &&
      module.targets.some(target => target.applyToProducts.includes(product.name)));
    assert.equal(entries.length, 1);
    assert.equal(entries[0].name, product.name === 'watch' ? 'watch' : 'entry');
  }
});
test('mobile ViewModel reports initialization and network failures to its UI', async () => {
  const load = loader();
  const { AppError } = load('data/src/main/ets/common/AppError.ts');
  const mobileLoad = loader({ '@mymeteo/data': { AppError } });
  const { WeatherViewModel } = mobileLoad('entry/src/main/ets/viewmodel/WeatherViewModel.ts');
  const model = new WeatherViewModel();
  await assert.rejects(model.getSavedCities(), error => error.code === 1100);
  model.setRepository({ async getWeatherData() { throw new AppError(1001, 'offline'); } });
  await assert.rejects(model.getWeatherData(city), error => error.code === 1001);
});


test('forced refresh bypasses fresh cache and saves new data', async () => {
  const f = fixture(10);
  const result = await f.repository.getWeatherData(city, true);
  assert.notStrictEqual(result, f.cached);
  assert.equal(f.fetches(), 1);
  assert.equal(f.saves(), 1);
  assert.ok(result.lastUpdated > f.cached.lastUpdated);
});
test('failed forced refresh leaves cached weather and its timestamp untouched', async () => {
  for (const age of [10, 16]) {
    const f = fixture(age, true);
    const timestamp = f.cached.lastUpdated.getTime();
    const weather = f.cached.currentWeather;
    await assert.rejects(f.repository.getWeatherData(city, true), /offline/);
    assert.equal(f.fetches(), 1);
    assert.equal(f.saves(), 0);
    assert.strictEqual(f.cached.currentWeather, weather);
    assert.equal(f.cached.lastUpdated.getTime(), timestamp);
  }
});
test('mobile ViewModel forwards explicit refresh and defaults to cache', async () => {
  const mobileLoad = loader({ '@mymeteo/data': {} });
  const { WeatherViewModel } = mobileLoad('entry/src/main/ets/viewmodel/WeatherViewModel.ts');
  const model = new WeatherViewModel();
  const flags = [];
  model.setRepository({ async getWeatherData(selectedCity, force) {
    assert.strictEqual(selectedCity, city);
    flags.push(force);
    return {};
  } });
  await model.getWeatherData(city);
  await model.getWeatherData(city, true);
  assert.deepEqual(flags, [false, true]);
});


// Execute the production refresh handler without requiring ArkUI on the host.
const timeLoad = loader({ '@kit.LocalizationKit': { i18n: {
  System: { getSystemLocale: () => 'pl-PL' },
  getTimeZone: () => ({ getID: () => 'Europe/Warsaw' })
} } });
const { formatWeatherUpdate } = timeLoad('entry/src/main/ets/common/WeatherTime.ts');

function mobileRefreshPage(fetch) {
  const file = path.join(root, 'entry/src/main/ets/pages/Index.ets');
  const source = ts.createSourceFile('Index.ts', fs.readFileSync(file, 'utf8').replace('struct Index', 'class Index'),
    ts.ScriptTarget.ES2020, true);
  const page = source.statements.find(node => ts.isClassDeclaration(node) && node.name.text === 'Index');
  const handler = page.members.find(node => ts.isMethodDeclaration(node) && node.name.getText(source) === 'refreshWeather');
  assert.ok(handler, 'Production refresh handler must exist');
  const code = ts.transpileModule('class RefreshPage {' + handler.getText(source) + '} module.exports = RefreshPage;', {
    compilerOptions: { target: ts.ScriptTarget.ES2020 }
  }).outputText;
  const module = { exports: {} };
  vm.runInNewContext(code, { module, ViewState: { SHOW_CITY: 4 }, console: { warn() {} }, formatWeatherUpdate });
  return Object.assign(new module.exports(), {
    selectedCity: city, viewState: 4, refreshGeneration: 0, refreshing: true,
    currentWeather: { temperature: 12 }, forecast: { days: [1] }, updatedAt: 'previous update',
    viewModel: { getWeatherData: fetch }
  });
}
test('mobile refresh failure stops spinner while keeping weather screen and timestamp', async () => {
  const page = mobileRefreshPage(async () => { throw new Error('offline'); });
  const weather = page.currentWeather;
  const forecast = page.forecast;
  await page.refreshWeather();
  assert.strictEqual(page.currentWeather, weather);
  assert.strictEqual(page.forecast, forecast);
  assert.equal(page.updatedAt, 'previous update');
  assert.equal(page.viewState, 4);
  assert.equal(page.refreshing, false);
});
test('mobile refresh success replaces both panels and update time', async () => {
  const fresh = { currentWeather: {}, forecast: {}, lastUpdated: new Date() };
  const page = mobileRefreshPage(async (selectedCity, force) => {
    assert.strictEqual(selectedCity, city);
    assert.equal(force, true);
    return fresh;
  });
  await page.refreshWeather();
  assert.strictEqual(page.currentWeather, fresh.currentWeather);
  assert.strictEqual(page.forecast, fresh.forecast);
  assert.equal(page.updatedAt, formatWeatherUpdate(fresh.lastUpdated));
  assert.equal(page.refreshing, false);
});
test('late mobile refresh cannot overwrite a different screen or its refresh state', async () => {
  let finish;
  const page = mobileRefreshPage(() => new Promise(resolve => { finish = resolve; }));
  const weather = page.currentWeather;
  const pending = page.refreshWeather();
  page.refreshGeneration++;
  finish({ currentWeather: {}, forecast: {}, lastUpdated: new Date() });
  await pending;
  assert.strictEqual(page.currentWeather, weather);
  assert.equal(page.updatedAt, 'previous update');
  assert.equal(page.refreshing, true);
});

test('weather update time uses device time zone and omits invalid dates', () => {
  const text = formatWeatherUpdate(new Date('2026-10-13T12:40:47Z'));
  assert.match(text, /13\.10\.2026/);
  assert.match(text, /14:40:47/);
  assert.equal(formatWeatherUpdate(null), '');
  assert.equal(formatWeatherUpdate(new Date(NaN)), '');
});

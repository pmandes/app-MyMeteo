const { test } = require('node:test');
const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');
const vm = require('node:vm');
const ts = require(process.env.CORE_TYPESCRIPT_PATH || 'typescript');
const root = path.resolve(__dirname, '..');

// Run the production data layer on the host, substituting only platform APIs.
function loader(stubs = {}, globals = {}) {
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
      console: quietConsole, Date, Number, Promise, Error, Intl, ...globals }, { filename: file });
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
        return { responseCode: scenario === 'status' ? 404 : 200, result: scenario === 'json' ? 'invalid' : '{"ok":true}' };
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

// Replays the given responses; the fake timer records retry delays instead of waiting.
function scriptedHttp(responses) {
  const http = { requests: 0, destroyed: 0, delays: [] };
  const platform = { createHttp: () => ({
    async request() { http.requests++; return responses.shift(); },
    destroy() { http.destroyed++; }
  }) };
  const load = loader({ '@ohos.net.http': { default: platform } },
    { setTimeout: (resolve, ms) => { http.delays.push(ms); resolve(); } });
  http.makeHttpRequest = load('data/src/main/ets/net/makeHttpRequest.ts').makeHttpRequest;
  return http;
}
const httpOk = { responseCode: 200, result: '{"ok":true}' };

test('HTTP 503 is retried with backoff until it succeeds', async () => {
  const http = scriptedHttp([{ responseCode: 503, result: '' }, httpOk]);
  assert.equal((await http.makeHttpRequest('https://example.com', 'GET')).ok, true);
  assert.equal(http.requests, 2);
  assert.equal(http.destroyed, 2);
  assert.deepEqual(http.delays, [1000]);
});
test('HTTP 503 gives up after three attempts with a readable error', async () => {
  const http = scriptedHttp([503, 503, 503].map(responseCode => ({ responseCode, result: '' })));
  await assert.rejects(http.makeHttpRequest('https://example.com', 'GET'),
    error => error.code === 1002 && /temporarily unavailable/.test(error.msg));
  assert.equal(http.destroyed, 3);
  assert.deepEqual(http.delays, [1000, 2000]);
});
test('HTTP Retry-After is honoured up to the retry cap', async () => {
  const http = scriptedHttp([{ responseCode: 429, result: '', header: { 'Retry-After': '30' } }, httpOk]);
  assert.equal((await http.makeHttpRequest('https://example.com', 'GET')).ok, true);
  assert.deepEqual(http.delays, [5000]);
});
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

function mobilePageHandler(methodName, globals = {}, pagePath = 'entry/src/main/ets/pages/Index.ets') {
  const file = path.join(root, pagePath);
  const source = ts.createSourceFile('Index.ts', fs.readFileSync(file, 'utf8').replace('struct Index', 'class Index'),
    ts.ScriptTarget.ES2020, true);
  const page = source.statements.find(node => ts.isClassDeclaration(node) && node.name.text === 'Index');
  const handler = page.members.find(node => ts.isMethodDeclaration(node) && node.name.getText(source) === methodName);
  assert.ok(handler, 'Production page handler must exist: ' + methodName);
  const code = ts.transpileModule('class RefreshPage {' + handler.getText(source) + '} module.exports = RefreshPage;', {
    compilerOptions: { target: ts.ScriptTarget.ES2020 }
  }).outputText;
  const module = { exports: {} };
  vm.runInNewContext(code, { module, ViewState: { IDLE: 0, LOADING: 1, SHOW_CITY: 4 }, console: { warn() {} }, formatWeatherUpdate, ...globals });
  return new module.exports();
}

function mobileRefreshPage(fetch) {
  return Object.assign(mobilePageHandler('refreshWeather'), {
    selectedCity: city, viewState: 4, refreshGeneration: 0, refreshing: true, refreshDragging: true,
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
  assert.equal(page.refreshDragging, false);
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
  assert.equal(page.refreshDragging, false);
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
  assert.equal(page.refreshDragging, true);
});

test('weather update time uses device time zone and omits invalid dates', () => {
  const text = formatWeatherUpdate(new Date('2026-10-13T12:40:47Z'));
  assert.match(text, /13\.10\.2026/);
  assert.match(text, /14:40:47/);
  assert.equal(formatWeatherUpdate(null), '');
  assert.equal(formatWeatherUpdate(new Date(NaN)), '');
});


function startupModel(repository) {
  const { WeatherViewModel } = loader({ '@mymeteo/data': {} })(
    'entry/src/main/ets/viewmodel/WeatherViewModel.ts');
  const model = new WeatherViewModel();
  model.setRepository(repository);
  return model;
}
const startupWeather = { currentWeather: { current: { weather_code: 3 } },
  forecast: { daily: { time: [1] } }, lastUpdated: new Date() };
const startupSaved = { city, weather: startupWeather };
test('mobile startup obtains location, resolves city and displays both weather panels', async () => {
  const events = [];
  const model = startupModel({
    async getCurrentLocation() { events.push('location'); return { latitude: 52, longitude: 21 }; },
    async searchCityByCoordinates(lat, lon, zoom) {
      assert.equal(lat, 52); assert.equal(lon, 21); assert.equal(zoom, 13);
      events.push('city'); return city;
    },
    async getWeatherData(selected) { assert.strictEqual(selected, city); events.push('weather'); return startupWeather; },
    async getLastSavedWeatherData() { assert.fail('Location weather succeeded'); }
  });
  const result = await model.getStartupWeather(true);
  assert.strictEqual(result.city, city);
  assert.strictEqual(result.weather, startupWeather);
  assert.deepEqual(events, ['location', 'city', 'weather']);
});
test('mobile startup skips GPS on permission denial and displays saved weather', async () => {
  const model = startupModel({
    async getCurrentLocation() { assert.fail('GPS requires permission'); },
    async getLastSavedWeatherData() { return startupSaved; }
  });
  assert.strictEqual(await model.getStartupWeather(false), startupSaved);
});
for (const failedStep of ['location', 'city', 'weather', 'incomplete']) {
  test(`mobile startup falls back to saved weather after ${failedStep} failure`, async () => {
    const model = startupModel({
      async getCurrentLocation() {
        if (failedStep === 'location') throw new Error('GPS disabled');
        return { latitude: 52, longitude: 21 };
      },
      async searchCityByCoordinates() {
        if (failedStep === 'city') throw new Error('geocoding offline');
        return city;
      },
      async getWeatherData() {
        if (failedStep === 'weather') throw new Error('API offline');
        return { currentWeather: null, forecast: null, lastUpdated: null };
      },
      async getLastSavedWeatherData() { return startupSaved; }
    });
    assert.strictEqual(await model.getStartupWeather(true), startupSaved);
  });
}
test('mobile startup returns empty search when no saved weather or database is unavailable', async () => {
  assert.equal(await startupModel({ async getLastSavedWeatherData() { return null; } }).getStartupWeather(false), null);
  assert.equal(await startupModel({ async getLastSavedWeatherData() { throw new Error('DB unavailable'); } })
    .getStartupWeather(false), null);
});
test('last saved weather uses retrieval time and ignores incomplete, invalid or unreadable records', async () => {
  const { WeatherRepository } = loader()(repoPath);
  const cities = Array.from({ length: 5 }, (_, id) => ({ ...city, place_id: id }));
  const saved = [
    { ...startupWeather, lastUpdated: new Date(2000) },
    { ...startupWeather, lastUpdated: new Date(3000) },
    { ...startupWeather, forecast: null, lastUpdated: new Date(9000) },
    { ...startupWeather, lastUpdated: new Date(NaN) }
  ];
  const repo = new WeatherRepository({}, {
    async getAllCities() { return cities; },
    async getWeatherData(id) { if (id === 4) throw new Error('bad row'); return saved[id]; }
  }, {});
  const result = await repo.getLastSavedWeatherData();
  assert.strictEqual(result.city, cities[1]);
  assert.strictEqual(result.weather, saved[1]);
  const empty = new WeatherRepository({}, { async getAllCities() { return []; } }, {});
  assert.equal(await empty.getLastSavedWeatherData(), null);
});
function mobileStartupPage(model, permission) {
  class PermissionManager { async requestPermissions() { return permission(); } }
  return Object.assign(mobilePageHandler('loadInitialWeather', { PermissionManager }), {
    viewState: 0, refreshGeneration: 0, viewModel: model,
    getUIContext: () => ({ getHostContext: () => ({}) })
  });
}
test('mobile page displays saved weather even when the permission API throws', async () => {
  const page = mobileStartupPage({ async getSavedCities() { return [city]; },
    async getStartupWeather(allowed) { assert.equal(allowed, false); return startupSaved; }
  }, () => { throw new Error('permission unavailable'); });
  await page.loadInitialWeather();
  assert.equal(page.viewState, 4);
  assert.strictEqual(page.selectedCity, city);
  assert.strictEqual(page.currentWeather, startupWeather.currentWeather);
  assert.strictEqual(page.forecast, startupWeather.forecast);
});
test('mobile page ends on empty search after denied location without saved weather', async () => {
  const page = mobileStartupPage({ async getSavedCities() { return [city]; },
    async getStartupWeather() { return null; }
  }, () => false);
  await page.loadInitialWeather();
  assert.equal(page.viewState, 0);
  assert.equal(page.savedCities.length, 0);
});
test('late startup cannot overwrite a manual search', async () => {
  let finish;
  const page = mobileStartupPage({ async getSavedCities() { return []; },
    async getStartupWeather() { return new Promise(resolve => { finish = resolve; }); }
  }, () => true);
  const pending = page.loadInitialWeather();
  // Wait until permission and the startup request have started.
  while (!finish) await Promise.resolve();
  page.refreshGeneration++;
  page.viewState = 3;
  finish(startupSaved);
  await pending;
  assert.equal(page.viewState, 3);
  assert.equal(page.selectedCity, undefined);
});
test('weather code selects clear, cloudy, rain and snow background families', () => {
  const { backgroundForWeather } = loader()('common/src/main/ets/utils/WeatherBackground.ts');
  for (const code of [0, 1]) assert.equal(backgroundForWeather(code), 'clear');
  for (const code of [2, 3, 45, 48]) assert.equal(backgroundForWeather(code), 'cloudy');
  for (const code of [51, 53, 55, 56, 57, 61, 63, 65, 66, 67, 80, 81, 82, 95, 96, 99])
    assert.equal(backgroundForWeather(code), 'rain');
  for (const code of [71, 73, 75, 77, 85, 86]) assert.equal(backgroundForWeather(code), 'snow');
  assert.equal(backgroundForWeather(undefined), '');
  assert.equal(backgroundForWeather(999), '');
});

function backgroundPage(code, pagePath) {
  const { WeatherBackground, backgroundForWeather } = loader()('common/src/main/ets/utils/WeatherBackground.ts');
  const globals = { WeatherBackground, backgroundForWeather, Curve: { EaseInOut: 'ease-in-out' } };
  const page = mobilePageHandler('onWeatherChange', globals, pagePath);
  page.fadeInBackground = mobilePageHandler('fadeInBackground', globals, pagePath).fadeInBackground;
  return Object.assign(page, {
    currentWeather: { current: { weather_code: code } },
    currentBackground: '', previousBackground: '', backgroundOpacity: 0,
    backgroundPending: false, backgroundGeneration: 0,
    getUIContext: () => ({ animateTo(options, change) { page.animation = options; change(); } })
  });
}

for (const product of ['entry', 'watch']) {
const pagePath = `${product}/src/main/ets/pages/Index.ets`;
test(`${product} background waits for the image before fading from gradient and preserves duration`, () => {
  const page = backgroundPage(0, pagePath);
  page.onWeatherChange();
  assert.equal(page.currentBackground, 'clear');
  assert.equal(page.backgroundOpacity, 0);
  assert.equal(page.animation, undefined);
  page.fadeInBackground();
  assert.equal(page.backgroundOpacity, 1);
  assert.equal(page.animation.duration, 2400);
  assert.equal(page.animation.curve, 'ease-in-out');
});

test(`${product} transition keeps the previous image until completion and does not repeat for the same family`, () => {
  const page = backgroundPage(61, pagePath);
  page.currentBackground = 'clear';
  page.onWeatherChange();
  assert.equal(page.previousBackground, 'clear');
  assert.equal(page.currentBackground, 'rain');
  page.fadeInBackground();
  assert.equal(page.previousBackground, 'clear');
  page.animation.onFinish();
  assert.equal(page.previousBackground, '');
  const generation = page.backgroundGeneration;
  page.currentWeather.current.weather_code = 63;
  page.onWeatherChange();
  assert.equal(page.backgroundGeneration, generation);
  assert.equal(page.backgroundOpacity, 1);
});

test(`${product} late animation completion cannot clear a newer weather transition`, () => {
  const page = backgroundPage(61, pagePath);
  page.currentBackground = 'clear';
  page.onWeatherChange();
  page.fadeInBackground();
  const first = page.animation;
  page.currentWeather.current.weather_code = 71;
  page.onWeatherChange();
  assert.equal(page.previousBackground, 'rain');
  first.onFinish();
  assert.equal(page.previousBackground, 'rain');
  page.fadeInBackground();
  page.animation.onFinish();
  assert.equal(page.previousBackground, '');
});
}

# MyMeteo
## Description

MyMeteo is a weather forecast application that allows users to search for and view weather information for different cities, including both current conditions and future predictions.
The application fetches data from the OpenMeteo API and displays it in a user-friendly format.

![MyMeteo](images/MyMeteo.png)

## Application functionality

- Search for weather forecasts by city name.
- Display current weather conditions.
- Show weather forecasts for the upcoming days.
- Saving the list of searched cities in a local database.
- Caching weather data for the searched city in the DB.
- Displaying weather data stored in the database if they are not older than 15 minutes. Otherwise, data is refreshed from the API.
- The application works offline; if there is no connection, it displays cached data.

## Technology Stack

- **Open Harmony:** The app is built for the Open Harmony, an open-source, distributed operating system designed for smart devices and IoT applications.
- **SDK v4.1 (API 11)**
- **AktTS:** ArkTS is OpenHarmony's high-level programming language that simplifies development with a declarative UI paradigm and enhanced static analysis while maintaining familiar TypeScript syntax for improved robustness and performance.
- **ArkUI:** ArkUI is a declarative UI framework in the OpenHarmony SDK that simplifies the creation of intuitive and responsive interfaces for smart devices.
- **ArkData:** ArkData is a data management and synchronization framework in OpenHarmony that supports secure storage, data sharing, backup, and synchronization across devices, including capabilities for unified data definitions, key-value stores, and relational databases.

**OH SDK Documentation:**

https://docs.openharmony.cn/pages/v4.1/en/application-dev/application-dev-guide.md


## APIs Used

- **OpenMeteo API**: Provides weather data.

  (https://open-meteo.com/en/docs)
- **Nominatim OpenStreetMap API**: Allows searching for geolocation data of cities.

  (https://nominatim.org/release-docs/develop/api/Overview/)

---

# WeatherAPI Documentation

## Base URLs

- **OpenStreetMap API:**  
  `http://nominatim.openstreetmap.org`

- **OpenMeteo API:**  
  `http://api.open-meteo.com`

## Endpoints & Methods

The `WeatherAPI` class provides methods to search for cities and retrieve both current weather conditions and weather forecasts using external APIs. It combines data from the OpenStreetMap and OpenMeteo services.

### 1. Search City

**Endpoint URL Template:** 
```bash
http://nominatim.openstreetmap.org/search?city={city}&format=jsonv2&addressdetails=1
```

**Method Signature:**
```typescript
async searchCity(query: string): Promise<City[]>
```

**Description:**
Searches for city information by replacing the `{city}` placeholder in the URL with the URL-encoded city name provided in the `query` parameter. The API returns an array of `City` objects containing geolocation and address details.

**Parameters:**

- `query` (`string`): The name of the city to search for.
**Returns:**
A promise that resolves to an array of `City` objects.

**Example Usage:**

```typescript
const cities = await weatherAPI.searchCity("Warsaw");
console.log(JSON.stringify(cities));
```

### 2. Get Current Weather
**Endpoint URL Template:**

```bash
http://api.open-meteo.com/v1/forecast?latitude={latitude}&longitude={longitude}&current=temperature_2m,relative_humidity_2m,apparent_temperature,is_day,precipitation,rain,showers,snowfall,weather_code,cloud_cover,pressure_msl,surface_pressure,wind_speed_10m,wind_direction_10m,wind_gusts_10m&forecast_days=1
```

**Method Signature:**

```typescript
async getCurrentWeather(latitude: number, longitude: number): Promise<CurrentWeather>
```

**Description:**
Retrieves the current weather for a specified location using latitude and longitude coordinates. Although the method includes a cityId parameter, it is not used to build the URL. After fetching the weather data, the method sets a last_update property with the current date/time.

**Parameters:**

- `latitude` (`number`): The latitude of the location.
- `longitude` (`number`): The longitude of the location.

**Returns:**
A promise that resolves to a `CurrentWeather` object containing details such as temperature, humidity, wind speed, etc., along with a `last_update` timestamp.

**Example Usage:**

```typescript
const currentWeather = await weatherAPI.getCurrentWeather(52.2297, 21.0122);
console.log(JSON.stringify(currentWeather));
```

### 3.Get Forecast ###
**Endpoint URL Template:**

```bash
http://api.open-meteo.com/v1/forecast?latitude={latitude}&longitude={longitude}&daily=weather_code,temperature_2m_max,temperature_2m_min,apparent_temperature_max,apparent_temperature_min,sunrise,sunset,daylight_duration,sunshine_duration,uv_index_max,uv_index_clear_sky_max,precipitation_sum,rain_sum,showers_sum,snowfall_sum,precipitation_hours,precipitation_probability_max,wind_speed_10m_max,wind_gusts_10m_max,wind_direction_10m_dominant,shortwave_radiation_sum,et0_fao_evapotranspiration&timeformat=unixtime&timezone=auto
```

**Method Signature:**

```typescript
async getForecast(latitude: number, longitude: number): Promise<Forecast>
```
**Description:**
Retrieves the daily weather forecast for a given location specified by its latitude and longitude. The forecast includes various parameters such as temperature extremes, precipitation details, sunrise/sunset times, and more. The response is formatted in Unix time and automatically adjusted to the local timezone.

**Parameters:**

- `latitude` (`number`): The latitude of the location.
- `longitude` (`number`): The longitude of the location.
**Returns:**
A promise that resolves to a `Forecast` object containing the daily forecast details.

**Example Usage:**

```typescript
const forecast = await weatherAPI.getForecast(52.2297, 21.0122);
console.log(JSON.stringify(forecast));
```

### HTTP Request Details ###

All API calls are performed using the helper function:
```typescript
makeHttpRequest<T>(url: string, method: http.RequestMethod)
```
which:

- Constructs and sends an HTTP GET request to the specified URL.
- Parses and returns the response as a promise with the expected data type (e.g., `City[]`, `CurrentWeather`, or `Forecast`).

## Key Classes and Structure

- `makeHttpRequest`: A utility function for making HTTP requests.

### Purpose:
The `makeHttpRequest` function is used to make asynchronous HTTP requests to external APIs. It handles various HTTP methods and ensures proper error handling and response parsing.

### Functionality:
- Parameters:
  - `url: string`: The URL to which the request is made.
  - `method: http.RequestMethod`: The HTTP method (e.g., GET, POST) to be used for the request.
- Returns:
  - A Promise that resolves with the parsed response data of type `T`, or rejects with an `AppError`.
- Implementation:
  - Creates an HTTP request using the `http.createHttp()` method.
  - Configures the request with the provided URL and method.
  - Sets the `Content-Type` header to `application/json`.
  - Handles the request's response, including error handling and response parsing.
  - If the response status code is not 200, it rejects the promise with an appropriate `AppError`.
  - Parses the response data as JSON and resolves the promise with the parsed data.
  - Handles any parsing errors by rejecting the promise with an appropriate `AppError`.

```typescript
import http from '@ohos.net.http';
import { AppError } from '../common/AppError';

export async function makeHttpRequest<T>(url: string, method: http.RequestMethod): Promise<T> {
  return new Promise((resolve, reject) => {
    const httpRequest = http.createHttp();
    httpRequest.request(url, {
      method: method,
      header: {
        'Content-Type': 'application/json'
      }
    }, (err, data: http.HttpResponse) => {
      
      console.debug('HTTP request: ' + method + ' ' + url);
      
      if (err) {
        console.error('An error occurred:', JSON.stringify(err));
        reject(new AppError(1001, 'Unable to fetch data'));
        return;
      }
      try {
        console.debug('Response code:' + data.responseCode);

        if (data.responseCode != 200) {
          reject(new AppError(1002, 'HTTP error ' + data.responseCode));
        }

        const response: T = JSON.parse(data.result as string);
        resolve(response);

      } catch (parseError) {
        console.error('Error parsing data:', parseError);
        reject(new AppError(1003, 'Invalid response format'));
      }
    });
  });
}
```

To use the `makeHttpRequest` function, you can follow this example:

```TypeScript
import { makeHttpRequest } from './path/to/makeHttpRequest';
import http from '@ohos.net.http';

async function searchCity(city: string) {
  const url = `http://nominatim.openstreetmap.org/search?city={city}${city}&formmat=jsonv2`;
  try {
    const data = await makeHttpRequest(url, http.RequestMethod.GET);
    console.log('Cities:', JSON.stringify(data));
  } catch (error) {
    console.error('Error fetching cities data:', error);
  }
}

searchCity('Warszawa');
```

---
# Implementation of Database Access #

In this project, access to a relational database (`RDB`) is provided using the `@ohos.data.relationalStore` module. The system is divided into several layers, which facilitates easy extension, testing, and maintenance of the code.

A basic `ORM` framework has been created that simplifies the implementation of database handling in other projects.

Here is how to implement database access step by step using the `City` object as an example:

- Preparing the Library – Copying the essential files from the `db` folder
- Configuring the database and creating the `MyMeteoDB` singleton
- Defining the `Entity` – Example: `CityEntity`
- Explaining the `DAO` interface and its implementation with an example (`CityDAORdb`)
- Implementing the `Mappers`
- Usage example in code

## Step 1: Preparing the framework (folder `db`)

To work with abstract database operations, you must copy (or create) the essential classes and interfaces that define the structure of our library. These include:

- `BaseEntity`

  This class serves as the foundation for all entities (models) that represent records in the database. It allows each entity (for example, CityEntity) to easily provide information about the corresponding table.

  **Key methods:**

  - `static getTableName()`: Returns the table name.
  - `static getTableColumns()`: Returns the list of table columns.
  
- `DbTable`

   An interface that defines the structure for a table configuration. It contains:

  - `tableName`: The table name.
  - `sqlCreate`: The SQL statement to create the table.
  - `columns`: The list of table columns.

- `BaseRelationalDatabase`

   An abstract class that provides `CRUD` methods (`insert`, `query`, `update`, `delete`) for database operations. This class centralizes error handling, asynchronous operations, and mapping between layers.

- `Entity`

   An interface that enforces the implementation of getTableName() and getTableColumns() for each entity. This ensures that all entities provide the required table information in a consistent manner.

**Why is this needed?**

**Moving the common logic into base classes (such as `BaseEntity` and `BaseRelationalDatabase`) centralizes the handling of database operations. This way, every entity or `CRUD` operation uses a unified approach, which simplifies future modifications, testing, and maintenance of the code.**

## Step 2: Configuring the Database and creating the MyMeteoDB singleton ##

### Database Configuration ###
In the project, the database configuration is stored in the `DBConfig` class. For example, for the `City` table, we define:

```typescript
export class DBConfig {

  static readonly STORE_CONFIG: relationalStore.StoreConfig = {
    name: 'database.db',
    securityLevel: relationalStore.SecurityLevel.S1
  };

  static readonly CITY_TABLE: DbTable = {
    tableName: 'tbl_city',
    sqlCreate: 'CREATE TABLE IF NOT EXISTS tbl_city(' +
      'id INTEGER PRIMARY KEY,' +
      'name TEXT, ' +
      'display_name TEXT,' +
      'latitude REAL,' +
      'longitude REAL,' +
      'timestamp DATETIME)',
    columns: ['id', 'name', 'display_name', 'latitude', 'longitude', 'timestamp']
  };

  // Other table configurations...
}
```

### Creating the `MyMeteoDB` Singleton ###

The `MyMeteoDB` class is responsible for establishing the connection to the database and initializing the tables. It uses the `Singleton` pattern to ensure that all database operations use a single connection instance.

```typescript
export class MyMeteoDB extends BaseRelationalDatabase {
  private static instance: MyMeteoDB | null = null;

  private constructor(rdbStore: relationalStore.RdbStore) {
    super(rdbStore);
  }

  public static async getInstance(context: Context): Promise<MyMeteoDB> {
    if (!MyMeteoDB.instance) {
      const store = await relationalStore.getRdbStore(context, DBConfig.STORE_CONFIG);
      await MyMeteoDB.initializeTables(store);
      MyMeteoDB.instance = new MyMeteoDB(store);
      console.debug('DB initialized: ' + DBConfig.STORE_CONFIG.name);
    }
    return MyMeteoDB.instance;
  }

  private static async initializeTables(store: relationalStore.RdbStore): Promise<void> {
    await store.executeSql(DBConfig.CITY_TABLE.sqlCreate);
    console.debug(`DB Table created: ${DBConfig.CITY_TABLE.tableName}[${DBConfig.CITY_TABLE.columns}]`);
    
    // Initialization of other tables...
    
  }
}
```

**Important**:

**Creating a singleton ensures that all database operations are executed using one consistent connection instance, preventing issues that may arise from multiple connections.**

## Step 3: Defining the Entity – Example: `CityEntity` ##


An entity represents a record in the database table. For the `City` object, we create the `CityEntity` class, which extends `BaseEntity` and implements the `Entity` interface.

```typescript
export class CityEntity extends BaseEntity implements Entity {

  protected static readonly TABLE: DbTable = DBConfig.CITY_TABLE;

  cityId: number; // Primary Key
  cityName: string;
  cityDisplayName: string;
  latitude: number;
  longitude: number;
  lastUpdate: Date;

  constructor(id: number, name: string, displayName: string, latitude: number, longitude: number, lastUpdate: Date) {
    super();
    this.cityId = id;
    this.cityName = name;
    this.cityDisplayName = displayName;
    this.latitude = latitude;
    this.longitude = longitude;
    this.lastUpdate = lastUpdate;
  }
}
```

**Why this solution?**

**By storing the table configuration in the static TABLE property and implementing the methods provided by BaseEntity, each entity (including CityEntity) can be used by CRUD methods without manually specifying the table name and columns.**

## Step 4: DAO Interface and Implementation - Example: `CityDAORdb` ##

### DAO Interface ###

Define the `ICityDAO` interface that outlines the contract for operations on `City` data. This ensures that all implementations provide a consistent set of methods.

```typescript
export interface ICityDAO {
  getAllCities(): Promise<City[]>;
  insertCity(city: City): Promise<number>;
  updateCity(city: City): Promise<number>;
  deleteCity(city: City): Promise<number>;
  getCityById(cityId: number): Promise<City[]>;
}
```

### DAO Implementation – `CityDAORdb` ###

The `CityDAORdb` class implements the `ICityDAO` interface and uses the methods from `BaseRelationalDatabase` (accessed via the `MyMeteoDB` singleton) to perform operations on the `City` table.

```typescript
export class CityDAORdb implements ICityDAO {
  private db: BaseRelationalDatabase;

  constructor(dbInstance: BaseRelationalDatabase) {
    this.db = dbInstance;
  }

  async getAllCities(): Promise<City[]> {
    return this.db.query(
      CityEntity.getTableName(),
      CityEntity.getTableColumns(),
      (predicates) => predicates,
      (resultSet: relationalStore.ResultSet) => resultSetToCities(resultSet)
    );
  }

  async getCityById(cityId: number): Promise<City[]> {
    return this.db.query(
      CityEntity.getTableName(),
      CityEntity.getTableColumns(),
      (predicates) => predicates.equalTo(CityEntity.getTableColumns()[0], cityId),
      (resultSet: relationalStore.ResultSet) => resultSetToCities(resultSet)
    );
  }

  async insertCity(city: City): Promise<number> {
    city.last_update = new Date();
    return this.db.insert<CityEntity>(
      CityEntity.getTableName(),
      cityToEntity(city),
      (entity) => entityToRecord(entity),
      true
    );
  }

  async updateCity(city: City): Promise<number> {
    city.last_update = new Date();
    return this.db.update<CityEntity>(
      CityEntity.getTableName(),
      cityToEntity(city),
      (predicates) => predicates.equalTo(CityEntity.getTableColumns()[0], city.place_id),
      (entity) => entityToRecord(entity)
    );
  }

  async deleteCity(city: City): Promise<number> {
    return this.db.delete<CityEntity>(
      CityEntity.getTableName(),
      (predicates) => predicates.equalTo(CityEntity.getTableColumns()[0], city.place_id)
    );
  }
}
```

**Explanation:**

**This class uses the previously defined table configuration and `CRUD` methods from `BaseRelationalDatabase`. With the help of mappers (explained in the next step), operations on `City` objects are straightforward, and the database logic remains separated from the business logic.**

## Step 5: Implementing the Mappers ##

Mappers are used to convert between different representations of data—such as the DTO layer (e.g., the `City` object), the entity layer (`CityEntity`), and the format required by the `@ohos.data.relationalStore` module.

### Example Mapper Functions: ###
- `cityToEntity` – Converts a `City` object to a `CityEntity` object:

  ```typescript
  export function cityToEntity(city: City): CityEntity {
    return new CityEntity(
      city.place_id,
      city.name,
      city.display_name,
      city.lat,
      city.lon,
      city.last_update
    );
  }
  ```
- `entityToCity` – Converts a `CityEntity` object to a `City` object:

  ```typescript
  export function entityToCity(entity: CityEntity): City {
    return {
      place_id: entity.cityId,
      name: entity.cityName,
      display_name: entity.cityDisplayName,
      lat: entity.latitude,
      lon: entity.longitude,
      last_update: entity.lastUpdate
    };
  }
  ```

- `entityToRecord` – Prepares a `CityEntity` object for database operations by converting it to a `relationalStore.ValuesBucket`:

  ```typescript
  export function entityToRecord(entity: CityEntity): relationalStore.ValuesBucket {
    return {
      id: entity.cityId,
      name: entity.cityName,
      display_name: entity.cityDisplayName,
      latitude: entity.latitude,
      longitude: entity.longitude,
      timestamp: entity.lastUpdate.getTime()
    };
  }
  ```

- `resultSetToCities` – Maps a query result (`ResultSet`) to an array of `City` objects:

  ```typescript
  export function resultSetToCities(resultSet: relationalStore.ResultSet): City[] {
    const cities: City[] = [];
    while(resultSet.goToNextRow()) {
      const city: City = {
        place_id: resultSet.getLong(resultSet.getColumnIndex('id')),
        name: resultSet.getString(resultSet.getColumnIndex('name')),
        display_name: resultSet.getString(resultSet.getColumnIndex('display_name')),
        lat: resultSet.getDouble(resultSet.getColumnIndex('latitude')),
        lon: resultSet.getDouble(resultSet.getColumnIndex('longitude')),
        last_update: new Date(resultSet.getDouble(resultSet.getColumnIndex('timestamp')))
      }
      cities.push(city);
    }
    return cities;
  }
  ```
## Step 6: Usage Example in Code ##

Finally, below is an example demonstrating how to use the previously defined components to perform operations on `City` objects in the database:

  ```typescript
  import { MyMeteoDB } from './db/MyMeteoDB';
  import { CityDAORdb } from './dao/CityDAORdb';
  import { City } from './net/dto/WeatherDTO';
  
  // Example function to initiate database operations
  async function runCityOperations(context: Context) {
    try {
      // 1. Obtain the database instance (singleton)
      const dbInstance = await MyMeteoDB.getInstance(context);
      
      // 2. Create a DAO instance for City
      const cityDAO = new CityDAORdb(dbInstance);
  
      // 3. Insert a new city record
      const newCity: City = {
        place_id: 164566061,
        name: 'Warsaw',
        display_name: 'Warsaw, Masovian Voivodeship, Poland',
        lat: 52.2297,
        lon: 21.0122,
        last_update: new Date()
      };
      const insertId = await cityDAO.insertCity(newCity);
      console.log('Inserted City with ID:', insertId);
  
      // 4. Retrieve all cities
      const cities = await cityDAO.getAllCities();
      console.log('All cities:', JSON.stringify(cities));
  
      // 5. Retrieve a city by a specific ID
      const cityById = await cityDAO.getCityById(164566061);
      console.log('City with ID 164566061:', cityById);
  
      // 6. Update the city record
      newCity.name = 'Warsaw - Updated';
      const updatedRows = await cityDAO.updateCity(newCity);
      console.log('Number of rows updated:', updatedRows);
  
      // 7. Delete the city record
      const deletedRows = await cityDAO.deleteCity(newCity);
      console.log('Number of rows deleted:', deletedRows);
  
    } catch (error) {
      console.error('Error during DB operations:', JSON.stringify(error));
    }
  }
  ```

## SUMMARY: ##

In this section, we have covered the following steps:

- Step 1: Prepared the essential library files from the `db` folder (including `BaseEntity`, `BaseRelationalDatabase`, `DbTable`, and `Entity`), which centralize database operation handling.
- Step 2: Configured the database in `DBConfig` and created the `MyMeteoDB` singleton to manage the database connection.
- Step 3: Defined the entity `CityEntity` representing records in the city table.
- Step 4: Created the `DAO` interface `ICityDAO` and implemented it with `CityDAORdb`, utilizing `CRUD` methods from `BaseRelationalDatabase`.
- Step 5: Implemented mappers to convert between DTOs, entities, and the database record format.
- Step 6: Provided an example usage that demonstrates initializing the database and performing `CRUD` operations on `City` objects.

**This modular approach makes the system easy to extend and maintain.**

### Class diagram: ###

![UML-data-layer](http://www.plantuml.com/plantuml/proxy?cache=no&src=https://raw.githubusercontent.com/pmandes/app-MyMeteo/refs/heads/db/images/db.iuml)

## Implementation of the Repository Pattern ##

The Repository pattern in this project is used to abstract data access logic, providing a unified interface for retrieving and storing weather data. In this implementation, the `WeatherRepository` class mediates between the business logic and the underlying data sources (remote and local). Its responsibilities include:

- **Abstracting Data Access:**

  The repository hides the details of data fetching and caching, allowing the rest of the application to work with a consistent API.

- **Deciding on the Data Source:**

  Depending on data freshness and availability, the repository decides whether to fetch new data from the remote source or return cached data from the local storage.

- **Coordinating Operations:**

  It coordinates calls between the remote data source (`WeatherRemoteDataSource`) and the local data source (`WeatherLocalDataSource`), ensuring that data is saved and retrieved in a consistent manner.

Below, selected code fragments illustrate these points.


### 1. Initialization and Wiring of the Repository ###

The repository is instantiated and configured in a dedicated initialization function. This process sets up the remote and local data sources and wires them into the repository. For example:
```typescript
private async initDbAndRepo(): Promise<void> {
  try {
    // 1. Initialize the database connection using the MyMeteoDB singleton.
    const dbInstance = await MyMeteoDB.getInstance(this.context);

    // 2. Create the WeatherRepository by instantiating:
    //    - A remote data source using WeatherRemoteDataSource (which wraps a WeatherAPI instance).
    //    - A local data source using WeatherLocalDataSource (with DAO implementations for City, Weather, and Forecast).
    this.repository = new WeatherRepository(
      new WeatherRemoteDataSource(new WeatherAPI()),
      new WeatherLocalDataSource(
        new CityDAORdb(dbInstance),
        new WeatherDAORdb(dbInstance),
        new ForecastDAORdb(dbInstance)
      )
    );

    // 3. Make the repository globally accessible.
    globalThis.weatherRepository = this.repository;

    // 4. Retrieve and log saved cities.
    const cities = await this.repository.getSavedCities();
    hilog.warn(0x0000, 'testTag', 'Saved cities: %{public}s', JSON.stringify(cities));

  } catch (error) {
    hilog.error(0x0000, 'testTag', 'DB init error: %{public}s', JSON.stringify(error));
  }
}
```

### Retrieving Weather Data with Caching Logic ###

The repository exposes a unified method for obtaining weather data. It checks for local (cached) data first and decides whether to fetch fresh data based on its freshness.

```typescript
async getWeatherData(city: City): Promise<WeatherData> {
  console.info(`[Repository] getWeatherData for city: ${JSON.stringify(city)}`);

  // Ensure the city is saved locally.
  await this.saveCity(city);

  // Retrieve local weather data.
  const localData = await this.localDataSource.getWeatherData(city.place_id);

  // If no local data is found or data is incomplete, fetch fresh data.
  if (!localData || !localData.currentWeather || !localData.forecast) {
    console.warn(`[Repository] Incomplete local data, fetching remote data...`);
    return this.fetchAndSaveWeatherData(city);
  }

  // Check if the local data is obsolete.
  if (this.isDataObsolete(localData.lastUpdated)) {
    console.warn(`[Repository] Local data is obsolete, fetching new data...`);
    return this.fetchAndSaveWeatherData(city);
  }

  console.info(`[Repository] Returning fresh local data.`);
  return localData;
}
```
### 3. Fetching and Saving Fresh Data ###

When the repository determines that the local data is missing or outdated, it fetches new data from the remote source and updates the local storage:

```typescript
private async fetchAndSaveWeatherData(city: City): Promise<WeatherData> {
  console.info(`[Repository] Fetching data from remote for cityId=${city.place_id}`);

  // Fetch current weather and forecast concurrently.
  const [ currentWeather, forecast ] = await Promise.all([
    this.remoteDataSource.getCurrentWeather(city.lat, city.lon),
    this.remoteDataSource.getForecast(city.lat, city.lon)
  ]);

  const lastUpdated = new Date();

  // Save the freshly fetched data into local storage.
  await this.saveWeatherData(city.place_id, currentWeather, forecast, lastUpdated);

  console.info(`[Repository] Returning newly fetched data.`);
  return { currentWeather, forecast, lastUpdated };
}
```

![UML-repository](http://www.plantuml.com/plantuml/proxy?cache=no&src=https://raw.githubusercontent.com/pmandes/app-MyMeteo/refs/heads/db/images/repository.iuml)

### Conclusion ###
The **Repository** pattern is implemented by the `WeatherRepository` class, which abstracts and coordinates data access between remote and local sources. Key methods such as `getWeatherData` and `fetchAndSaveWeatherData` demonstrate how the repository decides whether to use cached data or fetch fresh data. The provided UML diagram illustrates the relationships and dependencies among the repository, data sources, and supporting classes.

By centralizing data access logic, this design simplifies the rest of the application’s code and makes it easier to manage changes in data retrieval or storage strategies in the future.

## MVVM Architecture in the Project ##

In this project, the `MVVM` (Model-View-ViewModel) pattern is used to separate concerns, making the application easier to extend, test, and maintain. The architecture is divided into three primary layers:

- **Model**:
  
  Represents the data and business logic. In our project, this includes data structures (such as `City`, `WeatherData`, `CurrentWeather`, and `Forecast`), as well as the data access layer (e.g., `WeatherRepository` and the associated remote and local data sources).

- **ViewModel**:

  Acts as a mediator between the View and the Model. The `WeatherViewModel` retrieves data from the repository, manages the application state, and prepares the data for display. It abstracts the business logic and data retrieval from the view.

- **View**:

  The View is responsible for rendering the user interface and reacting to user interactions. For example, the main view (`Index`) uses reactive state variables (annotated with `@State`) to update the UI as the data changes. The View delegates data operations to the ViewModel.

---

### Interactions Between Layers ###

### 1. Model ###
- **Responsibility**:

  The Model stores the data and handles business logic. This includes retrieving data from a database or an API.
- **Examples**:

  - **Data Transfer Objects (DTOs) and Models:** `City`, `WeatherData`, `CurrentWeather`, `Forecast`
  - **Repository**: `WeatherRepository` centralizes data access by deciding whether to retrieve data from local storage or a remote API, and it updates the local cache as needed.

### 2. ViewModel ###

- **Responsibility**:

  The `WeatherViewModel` is responsible for:

  - Retrieving data from the model by calling methods on the repository (e.g., `getSavedCities()`, `searchCity()`, `getWeatherData(city)`). 
  - Managing the application state (for example, keeping track of the current view state, list of cities, current weather, and errors). 
  - Delegating user actions to the repository.

  ```typescript
  export class WeatherViewModel {
    private repository?: WeatherRepository;

    /**
     * Creates a new instance of WeatherViewModel.
     * @param {WeatherRepository} repository - The repository to access weather and city data.
     */
    constructor(repository: WeatherRepository) {
      console.debug(`[${LOG_TAG}] created...`);
      this.repository = repository;
    }

    async getSavedCities(): Promise<City[]> {
      if (!this.repository) {
        console.error(`[${LOG_TAG}] No repository. Returning empty array.`);
        return [];
      }

      console.info(`[${LOG_TAG}] getSavedCities -> Retrieving saved cities...`);
      const cities: City[] = await this.repository.getSavedCities();
      console.info(`[${LOG_TAG}] Saved cities: ${JSON.stringify(cities)}`);
      return cities;
    }

    async searchCity(query: string): Promise<City[]> {
      if (!this.repository) {
        console.error(`[${LOG_TAG}] No repository. searchCity returning empty array.`);
        return [];
      }
      console.info(`[${LOG_TAG}] searchCity: ${query}`);
      return this.repository.searchCity(query);
    }

    async getWeatherData(city: City): Promise<WeatherData> {
      console.info(`[${LOG_TAG}] getWeatherData called for city: ${city.name} (id=${city.place_id})`);
      if (!this.repository) {
        console.error(`[${LOG_TAG}] No repository. Returning empty WeatherData.`);
        return { currentWeather: null, forecast: null, lastUpdated: null };
      }
      try {
        const weatherData = await this.repository.getWeatherData(city);
        console.info(`[${LOG_TAG}] getWeatherData -> Received data: ${JSON.stringify(weatherData)}`);
        return weatherData;
      } catch (err) {
        console.error(`[${LOG_TAG}] getWeatherData error: `, err);
        return { currentWeather: null, forecast: null, lastUpdated: null };
      }
    }
  }
  ```

### 3. View ###

- **Responsibility**:

   The View (e.g., the main component `Index`) is responsible for rendering the user interface and handling user interactions. It:

  - Maintains reactive state variables (using` @State`) to reflect the current UI state, such as `viewState`, `cities`, `selectedCity`, `currentWeather`, `forecast`, and `error`.
  - Calls methods on the ViewModel to retrieve data (for instance, invoking `getSavedCities()` or `getWeatherData()`).
  - Dynamically renders components (like `SearchBarComponent`, `ResultsComponent`, `CityDetailsComponent`, `LoadingComponent`, and `ErrorComponent`) based on the current `viewState`.

```typescript
@Entry
@Component
struct Index {
  @State viewModel: WeatherViewModel = weatherViewModel;
  @State viewState: ViewState = ViewState.IDLE;

  /// ... other State variables

  // Called when the Index page is about to appear;
  // Then, it initiates the fetching of saved cities to update the UI with the latest local city data.
  aboutToAppear(): void {
    console.debug("Index page is about to appear...");
    this.fetchSavedCities();
  }

  // Constructs and returns the UI layout based on the current state.
  // Dynamically renders components (e.g., search bar, results, city details, loading, error) according to 'viewState'.      
  build() {
    Column() {
    
      SearchBarComponent({
        viewState: this.viewState,
        cities: this.cities,
        error: this.error
      })

      if (this.viewState == ViewState.IDLE || this.viewState == ViewState.SHOW_RESULTS) {
      
        ResultsComponent({
          viewState: this.viewState,
          results: this.cities,
          savedCities: this.savedCities,
          selectedCity: this.selectedCity,
          currentWeather: this.currentWeather,
          forecast: this.forecast
        });
        
      } else if (this.viewState == ViewState.SHOW_CITY) {
  
        CityDetailsComponent({
          viewState: this.viewState,
          city: this.selectedCity,
          currentWeather: this.currentWeather,
          forecast: this.forecast
        });
  
      } else if (this.viewState == ViewState.LOADING) {
  
        LoadingComponent();
  
      } else if (this.viewState == ViewState.ERROR) {
  
        ErrorComponent({ error: this.error });
  
      }
    }
  }

  // Asynchronously fetches the list of saved cities from the global weatherViewModel 
  // and updates the 'savedCities' state, triggering an automatic UI refresh when the data is loaded.
  async fetchSavedCities() {
    this.savedCities = await weatherViewModel.getSavedCities();
  }
}
```

### `State Management` ### 

State in this project is managed primarily within the View using reactive variables (annotated with `@State`). These variables include:

- `viewState`:
Tracks the current view mode (e.g., `IDLE`, `LOADING`, `ERROR`, `SHOW_RESULTS`, `SHOW_CITY`).

- `cities` and `savedCities`:
Arrays that hold the list of cities from search results and those saved locally.

- `selectedCity`, `currentWeather`, `forecast`:
Hold detailed data for the selected city.

- `error`:
Stores error information when any operation fails.

Changes in these state variables trigger automatic updates of the UI, ensuring that the interface remains in sync with the latest data from the ViewModel.

The following sequence diagram illustrates how the Model, ViewModel, and View interact within the MVVM architecture:

![UML-repository](http://www.plantuml.com/plantuml/proxy?cache=no&src=https://raw.githubusercontent.com/pmandes/app-MyMeteo/refs/heads/db/images/mvvm.iuml)


## Project Modularization ##

The project is divided into two primary modules:

1. **Entry Module:**
Contains the main ability, the user interface (UI), and the associated ViewModel. This module is responsible for all presentation logic.

2. **Data Module:**
Contains the data layer, which includes the repository, data sources (both remote and local), database access (DB, DAO), and API communication. This module encapsulates all data access functionality using the Repository pattern.

### Module Definitions ###

**Data Module**

The data module is defined by its own `module.json5` file:
```json
{
  "module": {
    "name": "data",
    "type": "har",
    "deviceTypes": [
      "default"
    ]
  }
}
```
This file tells the build system that this module is named `data` and specifies its type and supported device types.

**Exposing Classes from the Data Module**

Inside the data module, the `Index.ts` file exposes key classes and types to be used by other modules. For example:
```typescript
export { WeatherRepository } from './src/main/ets/repository/WeatherRepository';
export { WeatherData } from './src/main/ets/model/WeatherData';
        
// ... other exports ...
```

This approach allows other modules (like the **entry** module) to import these classes using a simple path e.g.
```typescript
import { City, WeatherData, WeatherRepository } from '@mymeteo/data';)
````
rather than using complex relative paths.

**Package Definition for the Data Module**
The data module is packaged as `@mymeteo/data` via its `oh-package.json5` file:
```json
{
  "name": "@mymeteo/data",
  "version": "1.0.0",
  "description": "Data module for MyMeteo app providing access to different data sources via Repository pattern",
  "main": "Index.ts",
  "dependencies": {},
  
  ...
}
```

This file defines the package name, version, and entry point (which is `Index.ts`) and allows the module to be used as a dependency in other parts of the project.

**Entry Module**

The entry module contains the UI layer and associated ViewModels. To use the classes from the data module, the entry module defines a dependency on `@mymeteo/data` in its `oh-package.json5` file:

```json
{
  "name": "entry",
  "version": "1.0.0",
  "description": "Entry module with presentation layer.",
  "main": "",
  "dependencies": {
    "@mymeteo/data": "../data"
  },
  
  ...
}
```
This dependency declaration allows developers in the entry module to import classes from the data module without worrying about deep relative paths.


### Build Configuration ###
The main build profile (`build-profile.json5`) includes both modules in the project. For example:

```json
{
  "app": {
    "signingConfigs": [
      {
         .... signing keys, etc. ....
      }
    ],
    "products": [
      {
        "name": "default",
        "signingConfig": "default",
        "compileSdkVersion": 11,
        "compatibleSdkVersion": 11,
        "runtimeOS": "OpenHarmony"
      }
    ],
    "buildModeSet": [
      { "name": "debug" },
      { "name": "release" }
    ]
  },
  "modules": [
    {
      "name": "entry",
      "srcPath": "./entry",
      "targets": [
        {
          "name": "default",
          "applyToProducts": [ "default" ]
        }
      ]
    },
    {
      "name": "data",
      "srcPath": "./data"
    }
  ]
}
```
This configuration file ensures that both modules are included in the final build, with their respective source paths specified. The entry module is set as the main module for the UI, while the data module is available as a dependency.

---

### Simplified File Structure

Below is a simplified file structure of the project illustrating the key directories and files:

```shell
/MyMeteo
├── /entry
│   ├── oh-package.json5                  // Entry module package definition
│   └── /src
│       └── /main
│           ├── module.json5              // Entry module configuration
│           └── /ets
│               ├── /entryability
│               │   └── EntryAbility.ets  // Main application ability
│               ├── /pages
│               │   └── Index.ets         // Main view component
│               ├── /view
│               │   ├── SearchBarComponent.ets
│               │   ├── ResultsComponent.ets
│               │   ├── CityDetailsComponent.ets
│               │   ├── LoadingComponent.ets
│               │   └── ErrorComponent.ets
│               └── /viewmodel
│                   └── WeatherViewModel.ets
│
├── /data
│   ├── oh-package.json5                   // Data module package definition
│   ├── Index.ts                           // Exposes classes for external use
│   └── /src
│       └── /main
│           ├── module.json5               // Data module configuration
│           └── /ets
│               ├── /repository
│               │   └── WeatherRepository.ts
│               ├── /net
│               │   ├── /dto
│               │   │   └── WeatherDTO.ts
│               │   └── WeatherAPI.ts
│               ├── /datasource
│               │   ├── /remote
│               │   │   └── WeatherRemoteDataSource.ts
│               │   └── /local
│               │       └── WeatherLocalDataSource.ts
│               ├── /database
│               │   ├── /dao
│               │   │   ├── CityDAORdb.ts
│               │   │   ├── WeatherDAORdb.ts
│               │   │   └── ForecastDAORdb.ts
│               │   └── MyMeteoDB.ts
│               └── /model
│                   └── WeatherData.ts
│
├── build-profile.json5                    // Main build configuration (includes both modules)
└── oh-package.json5                       // Global package configuration
```

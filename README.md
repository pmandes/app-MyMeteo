# app-MyMeteo

The application is a client of OpenMeteo and allows you to check the weather forecast for the city you are searching for.

![MyMeteo](images/MyMeteo.png)

## Description

MyMeteo is a weather forecast application that allows users to search for and view weather information for different cities. The application fetches data from the OpenMeteo API and displays it in a user-friendly format.

## Basic Functions

- Search for weather forecasts by city name.
- Display current weather conditions.
- Show weather forecasts for the upcoming days.

## APIs Used

- **OpenMeteo API**: Provides weather data.
- **MapBox API**: Used for rendering maps.

## Endpoints

The application interacts with the following endpoints:

- **OpenMeteo API**: Fetches weather data.
- **MapBox API**: Retrieves static map images based on coordinates.

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



To use the makeHttpRequest function, you can follow this example:

```TypeScript
import { makeHttpRequest } from './path/to/makeHttpRequest';
import http from '@ohos.net.http';

async function fetchWeatherData(city: string) {
  const url = `https://api.open-meteo.com/v1/forecast?city=${city}`;
  try {
    const data = await makeHttpRequest(url, http.RequestMethod.GET);
    console.log('Weather data:', data);
  } catch (error) {
    console.error('Error fetching weather data:', error);
  }
}

fetchWeatherData('Warszawa');

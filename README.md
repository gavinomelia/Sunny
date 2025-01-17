# Sunny - A Simple Rails Weather App
Sunny is a weather application built with Ruby on Rails that provides current weather data and a 7-day forecast. 

Sunny is live on Heroku. See it here: https://sunny-weather-d6496c4b68f1.herokuapp.com
  
## Features

- **Current Weather:** Get real-time weather information based on location.
- **7-Day Forecast:** View the weather forecast for the upcoming week.
- **Search Locations:** Search for weather details by city or use your current location.
- **7-Day Graphs:** See all the highs and lows for the week in one simple graph.

## Configuration
- Rails 8.0.1
- Ruby 3.3.6
  
## Installation

To set up Sunny locally, follow these steps:

### 1. Clone the Repository

```bash
git clone https://github.com/yourusername/sunny.git
cd sunny
```

### 2. Install Dependencies

Make sure you have Ruby and Rails installed. Then run:

```bash
bundle install
```

### 3. Set Up the Database

Run the following command to set up the database:

```bash
rails db:create
rails db:migrate
```

### 4. API Key for Geocoding

Sunny uses a geocoding API for some data. To set up the API key:

1. Sign up at https://geocode.xyz
2. Copy your API key.
3. Create a `.env` file in the root directory of the project and add the following:

```
GEOCODE_API_KEY=your_api_key_here
```

### 5. Start the Rails Server

Once everything is set up, run the Rails server:

```bash
rails server
```

This will start the server at `http://localhost:3000`.

## Usage

- Visit `http://localhost:3000` to start using the app.
- Enter a city name or coordinates to get current weather and a 7-day forecast.
- The weather data is displayed in a user-friendly, easy-to-read format.

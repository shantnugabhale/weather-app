# 🌤️ Modern Weather App

A beautiful, modern weather application built with Flutter that provides real-time weather information with an intuitive and elegant user interface.

## ✨ Features

### 🎨 **Modern UI/UX Design**
- **Clean, minimal interface** with no text shadows or glows
- **Gradient backgrounds** that adapt to weather conditions
- **Smooth animations** and transitions
- **Responsive design** for all screen sizes
- **Dark/Light mode** toggle with theme persistence

### 📍 **Smart Location Handling**
- **Automatic location detection** using GPS
- **Permission management** with user-friendly prompts
- **Fallback search** for manual city input
- **Location settings** integration

### 🌡️ **Comprehensive Weather Data**
- **Current temperature** with °C/°F toggle
- **Weather conditions** with animated icons
- **"Feels like" temperature**
- **Humidity, wind speed, UV index, and air quality**
- **2x2 grid layout** for detailed information
- **Last updated timestamp**

### 🔄 **Enhanced Functionality**
- **Pull-to-refresh** gesture
- **Offline cache** for last known weather
- **Weather tips** based on current conditions
- **Error handling** with retry options
- **Settings integration**

### 🎯 **Technical Features**
- **Provider pattern** for state management
- **Shared preferences** for user settings
- **Permission handling** with proper fallbacks
- **Responsive layouts** using Flutter widgets
- **Clean architecture** with separated concerns

## 🚀 Getting Started

### Prerequisites
- Flutter 3.6.1 or higher
- Dart SDK
- Android Studio / VS Code
- OpenWeatherMap API key

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd weather-app
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure API Key**
   - Get a free API key from [OpenWeatherMap](https://openweathermap.org/api)
   - Update the API key in `lib/services/weather_services.dart`

4. **Run the app**
   ```bash
   flutter run
   ```

## 📱 Screenshots

The app features:
- **Splash Screen**: Animated welcome with weather icon
- **Home Screen**: Main weather display with all information
- **Search**: City search with location integration
- **Settings**: Theme and temperature unit preferences

## 🏗️ Architecture

```
lib/
├── models/
│   └── weather_model.dart          # Weather data model
├── providers/
│   └── weather_provider.dart       # State management
├── screens/
│   ├── splash_screen.dart          # Welcome screen
│   └── home_screen.dart            # Main weather screen
├── services/
│   ├── weather_services.dart       # API integration
│   └── location_service.dart       # Location handling
└── main.dart                       # App entry point
```

## 🔧 Dependencies

- **flutter**: Core Flutter framework
- **provider**: State management
- **http**: API requests
- **geolocator**: Location services
- **permission_handler**: Permission management
- **shared_preferences**: Local storage
- **lottie**: Animated weather icons
- **flutter_typeahead**: Search suggestions

## 🎨 Design Principles

- **Minimalism**: Clean, uncluttered interface
- **Accessibility**: High contrast and readable text
- **Responsiveness**: Adapts to different screen sizes
- **Performance**: Smooth animations and fast loading
- **User Experience**: Intuitive navigation and feedback

## 🌟 Key Improvements

1. **No Text Shadows**: Clean, flat text design
2. **Modern Gradients**: Dynamic backgrounds based on weather
3. **Smart Layouts**: 2x2 grid for detailed information
4. **Location Integration**: Seamless GPS and permission handling
5. **Theme Support**: Dark/light mode with persistence
6. **Error Handling**: User-friendly error messages and recovery

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 👨‍💻 Author

**Shantnu Gabhale**
- Created a modern, beautiful weather app
- Focused on clean design and user experience
- Implemented all requested features and improvements

---

**Built with ❤️ using Flutter**
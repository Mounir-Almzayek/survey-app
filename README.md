# King Abdulaziz Center Survey App 📱

A comprehensive mobile application for researchers to conduct surveys and manage accreditation processes for King Abdulaziz Center. Built with Flutter, this app provides offline-first survey management with advanced features for data collection, device custody, and response synchronization.

## 🌟 Key Features

### 🔐 **Authentication & Security**
- Secure researcher login with WebAuthn and email/password authentication
- QR code-based device registration and custody management
- Biometric authentication support
- Encrypted data storage with secure preferences

### 📋 **Survey Management**
- **Offline-First Architecture**: Complete surveys offline with automatic syncing when online
- **Auto-Save**: Continuous data preservation to prevent loss
- **Progress Tracking**: Visual progress indicators and completion status
- **Conditional Logic**: Dynamic question display based on responses
- **GPS Integration**: Location capture for geo-tagged responses

### 📊 **Data Collection & Upload**
- **Multimedia Support**: Image and file upload capabilities
- **Response Management**: View, edit, and sync survey responses
- **Real-time Sync**: Queue-based synchronization system
- **Data Validation**: Comprehensive input validation and error handling

### 🏢 **Device & Custody Management**
- **Device Registration**: QR code-based device onboarding
- **Custody Tracking**: Check-in/check-out system with verification codes
- **Device Transfer**: Secure device handover between researchers
- **Location Monitoring**: GPS tracking and zone violation detection

### 🌐 **Public Survey Links**
- **Link Generation**: Create shareable public survey links
- **QR Code Sharing**: Easy distribution via QR codes
- **Link Management**: View and manage active survey links
- **Statistics**: Track link usage and response rates

### 📱 **User Experience**
- **Multi-language Support**: Arabic and English localization
- **Responsive Design**: Optimized for mobile, tablet, and web
- **Push Notifications**: Firebase-powered notifications
- **Dark/Light Themes**: System-adaptive theming

## 🛠️ Technical Architecture

### **State Management**
- BLoC pattern for predictable state management
- Feature-based architecture with clean separation of concerns
- Repository pattern for data abstraction

### **Offline Capabilities**
- Hive local database for offline data persistence
- Request queue system for background synchronization
- Connectivity monitoring and automatic retry mechanisms

### **Security Features**
- Encrypted local storage for sensitive data
- Secure API communication with Dio
- Device fingerprinting and validation
- Biometric authentication integration

### **Performance & Reliability**
- Lazy loading and pagination for large datasets
- Optimistic updates for better UX
- Comprehensive error handling and logging
- Background sync and conflict resolution

## 📦 Dependencies

- **State Management**: flutter_bloc, equatable
- **Networking**: dio, connectivity_plus
- **Local Storage**: hive, hive_flutter, shared_preferences
- **Authentication**: local_auth, flutter_secure_storage
- **Multimedia**: image_picker, file_picker, mobile_scanner
- **Location**: geolocator, geolocator_android
- **Notifications**: firebase_messaging, flutter_local_notifications
- **UI/UX**: flutter_svg, lottie, fl_chart, readmore
- **Utilities**: uuid, crypto, pointycastle, intl

## 🚀 Getting Started

1. **Clone the repository**
   ```bash
   git clone https://github.com/your-username/king-abdulaziz-center-survey-app.git
   cd king-abdulaziz-center-survey-app
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure Firebase** (optional for notifications)
   - Add your `google-services.json` to `android/app/`
   - Configure Firebase project settings

4. **Run the app**
   ```bash
   flutter run
   ```

## 📱 Supported Platforms

- **Android**: API 21+ (Android 5.0+)
- **iOS**: iOS 12.0+
- **Web**: Modern browsers with WebAuthn support

## 🏗️ Project Structure

```
lib/
├── core/                 # Core functionality and utilities
│   ├── enums/           # Application enums
│   ├── l10n/            # Localization files
│   ├── models/          # Core data models
│   ├── routes/          # App routing
│   ├── services/        # Core services
│   ├── styles/          # Themes and styling
│   └── utils/           # Utility functions
├── features/            # Feature-based modules
│   ├── auth/           # Authentication
│   ├── assignment/     # Survey assignments
│   ├── custody/        # Device custody
│   ├── device_location/# GPS and location
│   ├── home/           # Dashboard
│   ├── profile/        # User profile
│   ├── public_links/   # Survey sharing
│   ├── qr_scanner/     # QR code scanning
│   ├── responses/      # Response management
│   ├── upload/         # File uploads
│   └── ...
└── main.dart           # App entry point
```

## 🔧 Development

### **Code Generation**
```bash
# Generate localization files
flutter pub run intl_utils:generate

# Generate Hive adapters
flutter pub run build_runner build
```

### **Testing**
```bash
# Run tests
flutter test

# Run integration tests
flutter test integration_test/
```

## 📄 License

This project is proprietary software for King Abdulaziz Center.

## 🤝 Contributing

Please follow the established code style and architecture patterns. Ensure all new features include comprehensive tests and documentation.

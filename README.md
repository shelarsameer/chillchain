# ChillChain App

ChillChain is a comprehensive cold storage logistics solution for the transportation and storage of temperature-sensitive products. This mobile application facilitates the connection between product vendors, customers, and delivery partners while maintaining proper temperature conditions throughout the supply chain.

## Features

### For Customers
- Browse temperature-controlled products across various categories
- Order products with confidence that they will arrive at the right temperature
- Track deliveries in real-time with temperature monitoring
- View temperature history of your orders
- Receive alerts if a product's temperature goes out of range

### For Vendors
- Manage product inventory with temperature requirements
- Monitor storage conditions in real-time
- Track orders and delivery status
- View temperature logs throughout the supply chain
- Receive alerts for temperature deviations

### For Delivery Partners
- Accept delivery assignments based on required temperature conditions
- Monitor cargo temperature in real-time during delivery
- Log temperature readings throughout the delivery journey
- Receive alerts for temperature deviations
- Track earnings and delivery history

## Tech Stack

- **Frontend**: Flutter for cross-platform mobile app development
- **Backend**: Firebase for authentication, database, and cloud functions
- **Temperature Monitoring**: IoT sensor integration with real-time data streaming
- **Geolocation**: Location tracking and mapping for deliveries
- **Notifications**: Push notifications for alerts and updates

## Getting Started

### Prerequisites
- Flutter SDK (latest stable version)
- Android Studio or VS Code with Flutter extension
- Firebase project setup

### Installation

1. Clone the repository:
   ```
   git clone https://github.com/yourusername/chillchain.git
   ```

2. Navigate to the project directory:
   ```
   cd chillchain/chillchain_app
   ```

3. Install dependencies:
   ```
   flutter pub get
   ```

4. Run the app:
   ```
   flutter run
   ```

### Demo Credentials

For testing purposes, you can use the following demo credentials:

- **Customer**
  - Email: customer@chillchain.com
  - Password: password123

- **Vendor**
  - Email: vendor@chillchain.com
  - Password: password123

- **Delivery Partner**
  - Email: delivery@chillchain.com
  - Password: password123

## Project Structure

```
lib/
├── constants/         # App-wide constants and configurations
├── models/            # Data models
├── providers/         # State management using provider pattern
├── screens/           # UI screens
│   ├── auth/          # Authentication screens
│   ├── customer/      # Customer-specific screens
│   ├── vendor/        # Vendor-specific screens
│   └── delivery/      # Delivery partner screens
├── services/          # Services for API calls and data handling
├── utils/             # Utility functions
└── widgets/           # Reusable UI components
```

## Temperature Zones

ChillChain categorizes products into different temperature zones:

- **Frozen** (-25°C to -18°C): For frozen goods like ice cream and frozen meats
- **Chilled** (0°C to 4°C): For refrigerated items like dairy, meat, and fish
- **Cool** (8°C to 15°C): For items like fruits, vegetables, and chocolates
- **Ambient** (15°C to 25°C): For items that need protection from extreme temperatures

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- Thanks to the Flutter team for the amazing framework
- All the open-source libraries that made this project possible

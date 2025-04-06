import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'constants/app_constants.dart';
import 'models/user.dart';
import 'models/product.dart';
import 'providers/auth_provider.dart';
import 'providers/product_provider.dart';
import 'providers/order_provider.dart';
import 'providers/storage_provider.dart' as app_storage;
import 'providers/theme_provider.dart';
import 'providers/compartment_provider.dart';
import 'services/compartment_service.dart';
import 'screens/auth/login_screen.dart';
import 'screens/customer/home_screen.dart';
import 'screens/customer/product_detail_screen.dart';
import 'screens/customer/product_list_screen.dart';
import 'screens/customer/cart_screen.dart';
import 'screens/customer/checkout_screen.dart';
import 'screens/vendor/vendor_dashboard_screen.dart';
import 'screens/delivery/delivery_dashboard_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/settings/settings_screen.dart';
import 'widgets/drawer_menu.dart';

// Global navigation key to use for navigation from anywhere
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

// Utility function to convert Color to MaterialColor
MaterialColor getMaterialColorFromColor(Color color) {
  final int red = color.red;
  final int green = color.green;
  final int blue = color.blue;
  final int alpha = color.alpha;

  final Map<int, Color> shades = {
    50: Color.fromARGB(alpha, red, green, blue),
    100: Color.fromARGB(alpha, red, green, blue),
    200: Color.fromARGB(alpha, red, green, blue),
    300: Color.fromARGB(alpha, red, green, blue),
    400: Color.fromARGB(alpha, red, green, blue),
    500: Color.fromARGB(alpha, red, green, blue),
    600: Color.fromARGB(alpha, red, green, blue),
    700: Color.fromARGB(alpha, red, green, blue),
    800: Color.fromARGB(alpha, red, green, blue),
    900: Color.fromARGB(alpha, red, green, blue),
  };

  return MaterialColor(color.value, shades);
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => app_storage.StorageProvider()),
        ChangeNotifierProvider(create: (_) => OrderProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        Provider(create: (_) => CompartmentService()),
        ChangeNotifierProxyProvider<CompartmentService, CompartmentProvider>(
          create: (context) => CompartmentProvider(context.read<CompartmentService>()),
          update: (context, service, previous) => previous ?? CompartmentProvider(service),
        ),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            title: AppConstants.appName,
            debugShowCheckedModeBanner: false,
            navigatorKey: navigatorKey,
            theme: themeProvider.lightTheme,
            darkTheme: themeProvider.darkTheme,
            themeMode: themeProvider.themeMode,
            initialRoute: AppConstants.splashRoute,
            onGenerateRoute: (settings) {
              if (settings.name == AppConstants.productDetailRoute) {
                final Product product = settings.arguments as Product;
                return MaterialPageRoute(
                  builder: (context) => ProductDetailScreen(product: product),
                );
              }
              return null;
            },
            routes: {
              AppConstants.splashRoute: (context) => const SplashScreen(),
              AppConstants.loginRoute: (context) => const LoginScreen(),
              AppConstants.homeRoute: (context) => const HomeScreen(),
              AppConstants.productListRoute: (context) => const ProductListScreen(),
              AppConstants.cartRoute: (context) => const CartScreen(),
              AppConstants.checkoutRoute: (context) => const CheckoutScreen(),
              AppConstants.vendorDashboardRoute: (context) => const VendorDashboardScreen(),
              AppConstants.deliveryDashboardRoute: (context) => const DeliveryDashboardScreen(),
              '/settings': (context) => const SettingsScreen(),
            },
          );
        },
      ),
    );
  }
}

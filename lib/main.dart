import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'providers/auth_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/favourites_provider.dart';
import 'providers/product_provider.dart';
import 'Screens/cart_screen.dart';
import 'Screens/home_screen.dart';
import 'Screens/sign_screen.dart';
import 'Screens/poduct_details_screen.dart';
import 'Screens/profile_screen.dart';
import 'Screens/search_screen.dart';
import 'Screens/signup_screen.dart';
import 'Screens/splash_screen.dart';
import 'utils/app_colors.dart';
import 'utils/app_routes.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const ShopApp());
}

class ShopApp extends StatelessWidget {
  const ShopApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => FavoritesProvider()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
      ],
      child: MaterialApp(
        title: 'Shop App',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          scaffoldBackgroundColor: AppColors.background,
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppColors.primary,
            primary: AppColors.primary,
          ),
        ),
        initialRoute: AppRoutes.splash,
        routes: {
          AppRoutes.splash: (_) => const SplashScreen(),
          AppRoutes.login: (_) => const LoginScreen(),
          AppRoutes.signup: (_) => const SignupScreen(),
          AppRoutes.home: (_) => const HomeScreen(),
          AppRoutes.cart: (_) => const CartScreen(),
          AppRoutes.search: (_) => const SearchScreen(),
          AppRoutes.profile: (_) => const ProfileScreen(),
        },
        onGenerateRoute: (settings) {
          if (settings.name == AppRoutes.productDetails) {
            final productId = settings.arguments as String;
            return MaterialPageRoute(
              builder: (_) => ProductDetailsScreen(productId: productId),
            );
          }
          return null;
        },
      ),
    );
  }
}

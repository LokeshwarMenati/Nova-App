import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'data/local/local_storage_service.dart';
import 'data/repositories/product_repository.dart';
import 'data/services/product_api_service.dart';
import 'features/auth/auth_provider.dart';
import 'features/cart/cart_provider.dart';
import 'features/home/home_provider.dart';
import 'features/orders/order_provider.dart';
import 'features/profile/profile_provider.dart';
import 'features/search/search_provider.dart';
import 'features/wishlist/wishlist_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Edge-to-edge system chrome and orientation setup
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.transparent,
    ),
  );

  // Initialize Local Storage Service (SharedPreferences + offline JSON cache)
  final localStorage = await LocalStorageService.init();

  // Initialize Network API & Repository layers
  final apiService = ProductApiService();
  final productRepository = ProductRepository(
    apiService: apiService,
    localStorage: localStorage,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>(
          create: (_) => AuthProvider(localStorage),
        ),
        ChangeNotifierProvider<ProfileProvider>(
          create: (_) => ProfileProvider(
            localStorage: localStorage,
            productRepository: productRepository,
          ),
        ),
        ChangeNotifierProvider<WishlistProvider>(
          create: (_) => WishlistProvider(
            localStorage: localStorage,
            productRepository: productRepository,
          ),
        ),
        ChangeNotifierProvider<CartProvider>(
          create: (_) => CartProvider(localStorage),
        ),
        ChangeNotifierProvider<HomeProvider>(
          create: (_) => HomeProvider(productRepository: productRepository),
        ),
        ChangeNotifierProvider<SearchProvider>(
          create: (_) => SearchProvider(
            productRepository: productRepository,
            localStorage: localStorage,
          ),
        ),
        ChangeNotifierProvider<OrderProvider>(
          create: (_) => OrderProvider(localStorage),
        ),
      ],
      child: const NovaApp(),
    ),
  );
}

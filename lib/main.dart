import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/config/app_config.dart';
import 'core/navigation/app_shell.dart';
import 'core/networking/ndichow_api_client.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/application/auth_controller.dart';
import 'features/auth/data/auth_repository.dart';
import 'features/auth/data/session_store.dart';
import 'features/auth/presentation/auth_screen.dart';
import 'features/cart/application/cart_controller.dart';
import 'features/home/data/home_repository.dart';
import 'features/orders/data/order_repository.dart';
import 'shared/widgets/app_progress_animation.dart';

void main() => runApp(const NdiChowApp());

class NdiChowApp extends StatefulWidget {
  const NdiChowApp({
    super.key,
    this.apiClient,
    this.homeRepository,
    this.orderRepository,
    this.authController,
    this.loadingBuilder,
  });

  final NdiChowApiClient? apiClient;
  final HomeRepository? homeRepository;
  final OrderRepository? orderRepository;
  final AuthController? authController;
  final WidgetBuilder? loadingBuilder;

  @override
  State<NdiChowApp> createState() => _NdiChowAppState();
}

class _NdiChowAppState extends State<NdiChowApp> {
  late final NdiChowApiClient _api =
      widget.apiClient ?? NdiChowApiClient(baseUrl: AppConfig.apiBaseUrl);
  late final HomeRepository _homeRepository =
      widget.homeRepository ?? HttpHomeRepository(_api);
  late final OrderRepository _orderRepository =
      widget.orderRepository ?? HttpOrderRepository(_api);
  late final AuthController _authController =
      widget.authController ??
      AuthController(AuthRepository(_api, const SecureSessionStore()));
  late final CartController _cartController = CartController();

  @override
  void initState() {
    super.initState();
    _api.onUnauthorized = _authController.sessionExpired;
    _authController.addListener(_handleAuthChanged);
  }

  void _handleAuthChanged() {
    if (_authController.status == AuthStatus.unauthenticated &&
        !_cartController.isEmpty) {
      _cartController.clear();
    }
  }

  @override
  void dispose() {
    _authController.removeListener(_handleAuthChanged);
    _api.onUnauthorized = null;
    _api.close();
    _authController.dispose();
    _cartController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => MultiProvider(
    providers: [
      ChangeNotifierProvider.value(value: _authController),
      ChangeNotifierProvider.value(value: _cartController),
      Provider<HomeRepository>.value(value: _homeRepository),
      Provider<OrderRepository>.value(value: _orderRepository),
    ],
    child: MaterialApp(
      title: 'NdiChow',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: _RootGate(loadingBuilder: widget.loadingBuilder),
    ),
  );
}

class _RootGate extends StatelessWidget {
  const _RootGate({this.loadingBuilder});

  final WidgetBuilder? loadingBuilder;

  @override
  Widget build(BuildContext context) => Consumer<AuthController>(
    builder:
        (context, auth, _) => switch (auth.status) {
          AuthStatus.loading => Scaffold(
            body: Center(
              child:
                  loadingBuilder?.call(context) ??
                  const AppProgressAnimation(height: 72),
            ),
          ),
          AuthStatus.unauthenticated => const AuthScreen(),
          AuthStatus.authenticated => AppShell(
            homeRepository: context.read<HomeRepository>(),
            orderRepository: context.read<OrderRepository>(),
            loadingBuilder: loadingBuilder,
          ),
        },
  );
}

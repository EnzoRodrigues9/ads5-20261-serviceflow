import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app_routes.dart';
import 'core/theme/app_theme.dart';

class AppWidget extends StatelessWidget {
  const AppWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ServiceFlow',
      theme: AppTheme.light,
      // Rota inicial baseada na sessão atual do Supabase
      initialRoute: _getInitialRoute(),
      routes: AppRoutes.routes,
      debugShowCheckedModeBanner: false,
    );
  }

  /// Determina a rota inicial:
  /// - Se há sessão ativa → vai direto para Home
  /// - Se não há sessão → vai para Splash → Login
  String _getInitialRoute() {
    final session = Supabase.instance.client.auth.currentSession;
    return session != null ? AppRoutes.home : AppRoutes.splash;
  }
}

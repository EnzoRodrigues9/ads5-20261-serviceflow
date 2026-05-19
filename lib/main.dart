import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app/app_widget.dart';
import 'app/core/helpers/app.config.dart';
import 'app/core/helpers/database_helper.dart';

void main() async {
  // 1. Garante a inicialização da comunicação com o sistema nativo
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Inicializa o Supabase (autenticação e API)
  await Supabase.initialize(
    url: AppConfig.supabaseUrl,
    anonKey: AppConfig.supabaseKey,
  );

  // 3. Inicializa o banco de dados SQLite local
  await DbHelper.instance.database;

  runApp(const AppEntry());
}

class AppEntry extends StatelessWidget {
  const AppEntry({super.key});

  @override
  Widget build(BuildContext context) {
    return AppWidget();
  }
}
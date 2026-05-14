import 'package:flutter/material.dart';

import 'modules/splash/presentation/pages/splash_page.dart';
import 'modules/auth/presentation/pages/login_page.dart';
import 'modules/auth/presentation/pages/cadastro_page.dart';
import 'modules/auth/presentation/pages/menu_laboratorio_page.dart';
import 'modules/auth/presentation/pages/demo_camera_page.dart';
import 'modules/auth/presentation/pages/demo_signature_page.dart';
import 'modules/auth/presentation/pages/dashboard_page.dart';
import 'modules/clientes/presentation/pages/cadastro_cliente_page.dart';
import 'modules/ordens_servico/presentation/pages/ordens_servico_page.dart';
import 'modules/home/presentation/pages/home_page.dart';
import 'modules/ordens_servico/presentation/pages/ordens_servico_list_page.dart';
import 'modules/clientes/presentation/pages/clientes_list_page.dart';

class AppRoutes {
  static const splash = '/splash';
  static const login = '/auth/login';
  static const cadastro = '/auth/cadastro';
  static const menuLab = '/menu-lab';
  static const demoCamera = '/demo-camera';
  static const demoSignature = '/demo-signature';
  static const dashboard = '/dashboard';
  static const cadastroCliente = '/clientes/cadastro';
  static const ordensServico = '/ordens-servico';
  static const home = '/home';
  static const ordensServicoList = '/ordens-servico-list';
  static const clienteList = '/cliente-list';


  static Map<String, WidgetBuilder> get routes => {
        splash: (_) => const SplashPage(),
        login: (_) => const LoginPage(),
        home: (_) => const HomePage(),
        cadastro: (_) => const CadastroPage(),
        menuLab: (context) => const MenuLaboratorioPage(),
        demoCamera: (context) => const DemoCameraPage(),
        demoSignature: (context) => const DemoSignaturePage(),
        dashboard: (context) => const DashboardPage(),
        cadastroCliente: (_) => const CadastroClientePage(),
        ordensServico: (_) => const OrdensServicoPage(),
        ordensServicoList: (_) => const OrdensServicoListPage(),
        clienteList: (_) => const ClienteListPage(),

      };
}

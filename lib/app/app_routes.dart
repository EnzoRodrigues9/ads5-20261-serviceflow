import 'package:flutter/material.dart';

import 'modules/splash/presentation/pages/splash_page.dart';

import 'modules/auth/presentation/pages/login_page.dart';
import 'modules/auth/presentation/pages/cadastro_page.dart';
import 'modules/dashboard/dashboard_page.dart';

import 'modules/home/presentation/pages/home_page.dart';

import 'modules/clientes/presentation/pages/clientes_list_page.dart';
import 'modules/clientes/presentation/pages/cadastro_cliente_page.dart';

import 'modules/ordens_servico/presentation/pages/cadastro_ordem_servico_page.dart';
import 'modules/ordens_servico/presentation/pages/ordens_servico_list_page.dart';

import 'modules/tecnicos/presentation/pages/tecnico_list_page.dart';
import 'modules/tecnicos/presentation/pages/cadastro_tecnico_page.dart';

import 'modules/servicos/presentation/pages/servico_list_page.dart';
import 'modules/servicos/presentation/pages/cadastro_servico_page.dart';

import 'modules/usuarios/presentation/pages/cadastro_usuario_page.dart';
import 'modules/usuarios/presentation/pages/usuarios_list_page.dart';

class AppRoutes {
  // Splash/Auth
  static const splash = '/splash';
  static const login = '/auth/login';
  static const cadastro = '/auth/cadastro';

  // Home
  static const home = '/home';
  static const dashboard = '/dashboard';

  // Clientes
  static const clienteList = '/clientes';
  static const cadastroCliente = '/clientes/cadastro';

  // Técnicos
  static const tecnicoList = '/tecnicos';
  static const cadastroTecnico = '/tecnicos/cadastro';

  // Ordens de Serviço
  static const ordensServicoList = '/ordens-servico';
  static const ordensServico = '/ordens-servico/cadastro';

  //Serviços
  static const servicoList = '/servicos';
  static const cadastroServico = '/servicos/cadastro';

  //Usuários
  static const usuariosList = '/usuarios';
  static const cadastroUsuario = '/usuarios-cadastro';

  static Map<String, WidgetBuilder> get routes => {
        // Splash/Auth
        splash: (_) => const SplashPage(),
        login: (_) => const LoginPage(),
        cadastro: (_) => const CadastroPage(),

        // Home
        home: (_) => const HomePage(),
        dashboard: (_) => const DashboardPage(),

        // Clientes
        clienteList: (_) => const ClienteListPage(),
        cadastroCliente: (_) => const CadastroClientePage(),

        // Técnicos
        tecnicoList: (_) => const TecnicoListPage(),
        cadastroTecnico: (_) => const CadastroTecnicoPage(),

        // Ordens de Serviço
        ordensServico: (_) => const CadastroOrdemServicoPage(),
        ordensServicoList: (_) => const OrdemServicoListPage(),

        // Serviços
        servicoList: (_) => const ServicoListPage(),
        cadastroServico: (_) => const CadastroServicoPage(),

        // Usuários
        usuariosList: (_) => const UsuariosListPage(),
        cadastroUsuario: (_) => const CadastroUsuarioPage(),
      };
}

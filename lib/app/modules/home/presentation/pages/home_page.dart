import 'package:flutter/material.dart';
import 'package:serviceflow/app/shared/widgets/widgets.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomGradientAppBar(
        title: 'ServiceFlow',
        onLogout: () => Navigator.pushReplacementNamed(context, '/auth/login'),
      ),
      drawer: CustomAppDrawer.serviceFlow(
        onLogout: () => Navigator.pushReplacementNamed(context, '/auth/login'),
      ),
      body: CustomGradientBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CustomWelcomeHeader(),
                Expanded(
                  child: CustomMenuGrid(
                    crossAxisCount: 2,
                    menuItems: [
                      CustomMenuCard(
                        title: 'Clientes',
                        description: 'Gerenciar clientes',
                        icon: Icons.people,
                        color: AppColors.primary,
                        onTap: () => Navigator.pushNamed(context, '/clientes'),
                      ),
                      CustomMenuCard(
                        title: 'OS',
                        description: 'Criar e gerenciar ordens de serviço',
                        icon: Icons.build,
                        color: AppColors.success,
                        onTap: () =>
                            Navigator.pushNamed(context, '/ordens-servico'),
                      ),
                      CustomMenuCard(
                        title: 'Relatórios',
                        description: 'Visualizar relatórios',
                        icon: Icons.bar_chart,
                        color: AppColors.warning,
                        onTap: () => Navigator.pushNamed(context, '/dashboard'),
                      ),
                      CustomMenuCard(
                        title: 'Usuários',
                        description: 'Gerenciar usuários',
                        icon: Icons.man,
                        color: Colors.purple,
                        onTap: () => Navigator.pushNamed(context, '/usuarios'),
                      ),
                      CustomMenuCard(
                        title: 'Técnicos',
                        description: 'Gerenciar técnicos',
                        icon: Icons.engineering,
                        color: Colors.teal,
                        onTap: () => Navigator.pushNamed(context, '/tecnicos'),
                      ),
                      CustomMenuCard(
                        title: 'Serviços',
                        description: 'Gerenciar serviços',
                        icon: Icons.settings,
                        color: Colors.grey,
                        onTap: () => Navigator.pushNamed(context, '/servicos'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSizes.lg),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

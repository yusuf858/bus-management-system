import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/bus_provider.dart';
import '../../widgets/route_card.dart';

class BusRoutesScreen extends StatelessWidget {
  const BusRoutesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bus Routes')),
      body: Consumer<BusProvider>(
        builder: (context, busProvider, _) {
          if (busProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (busProvider.routes.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.route, size: 80, color: AppColors.textSecondary),
                  SizedBox(height: 16),
                  Text('No routes available', style: TextStyle(fontSize: 18, color: AppColors.textSecondary)),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => busProvider.loadAllData(),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: busProvider.routes.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                return RouteCard(route: busProvider.routes[index]);
              },
            ),
          );
        },
      ),
    );
  }
}
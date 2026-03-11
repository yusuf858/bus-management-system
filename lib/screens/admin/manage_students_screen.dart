import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/bus_provider.dart';

class ManageStudentsScreen extends StatelessWidget {
  const ManageStudentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Students'),
      ),
      body: Consumer<BusProvider>(
        builder: (context, busProvider, _) {
          final students = busProvider.students;

          if (students.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.school, size: 64, color: AppColors.textSecondary),
                  SizedBox(height: 16),
                  Text('No students found', style: TextStyle(fontSize: 16)),
                ],
              ),
            );
          }

          // Group students by route
          final Map<String?, List<dynamic>> studentsByRoute = {};
          for (var student in students) {
            final routeId = student.selectedRouteId;
            if (!studentsByRoute.containsKey(routeId)) {
              studentsByRoute[routeId] = [];
            }
            studentsByRoute[routeId]!.add(student);
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: studentsByRoute.keys.length,
            itemBuilder: (context, index) {
              final routeId = studentsByRoute.keys.elementAt(index);
              final studentsInRoute = studentsByRoute[routeId]!;

              String routeName = 'No Route Selected';
              if (routeId != null) {
                final route = busProvider.routes.firstWhere(
                      (r) => r.routeId == routeId,
                  orElse: () => busProvider.routes.first,
                );
                routeName = route.routeName;
              }

              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: ExpansionTile(
                  leading: CircleAvatar(
                    backgroundColor: routeId != null
                        ? AppColors.primaryColor.withOpacity(0.2)
                        : AppColors.textSecondary.withOpacity(0.2),
                    child: Icon(
                      Icons.route,
                      color: routeId != null
                          ? AppColors.primaryColor
                          : AppColors.textSecondary,
                    ),
                  ),
                  title: Text(
                    routeName,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text('${studentsInRoute.length} students'),
                  children: studentsInRoute.map((student) {
                    return ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: AppColors.accentLight,
                        child: Icon(Icons.person, color: AppColors.accentColor),
                      ),
                      title: Text(student.name),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(student.email),
                          if (student.phoneNumber != null)
                            Text('Phone: ${student.phoneNumber}'),
                        ],
                      ),
                      isThreeLine: student.phoneNumber != null,
                    );
                  }).toList(),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
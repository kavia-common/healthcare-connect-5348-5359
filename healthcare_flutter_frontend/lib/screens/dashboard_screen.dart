import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'appointments_screen.dart';
import 'doctors_screen.dart';
import 'medical_records_screen.dart';
import '../theme/app_theme.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final role = auth.role;

    final tabs = <Tab>[
      const Tab(icon: Icon(Icons.local_hospital_outlined), text: 'Doctors'),
      const Tab(icon: Icon(Icons.event_note_outlined), text: 'Appointments'),
      const Tab(icon: Icon(Icons.folder_shared_outlined), text: 'Medical Records'),
    ];
    final views = const <Widget>[
      DoctorsScreen(),
      AppointmentsScreen(),
      MedicalRecordsScreen(),
    ];

    return DefaultTabController(
      length: tabs.length,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Healthcare Connect'),
          actions: [
            Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.only(right: 12),
              child: Text(role.toUpperCase(), style: const TextStyle(color: AppColors.secondary)),
            ),
            IconButton(
              tooltip: 'Logout',
              icon: const Icon(Icons.logout),
              onPressed: () async {
                await context.read<AuthProvider>().logout();
                if (context.mounted) {
                  Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
                }
              },
            )
          ],
          bottom: TabBar(tabs: tabs),
        ),
        body: TabBarView(children: views),
      ),
    );
  }
}

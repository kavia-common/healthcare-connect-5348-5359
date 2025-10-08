import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/consultations_provider.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';

class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({super.key});

  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<ConsultationsProvider>().fetch());
  }

  Future<void> _create() async {
    final patientCtrl = TextEditingController();
    final dtCtrl = TextEditingController(text: DateTime.now().toUtc().toIso8601String());
    final notesCtrl = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Schedule consultation'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: patientCtrl, decoration: const InputDecoration(labelText: 'Patient ID')),
            const SizedBox(height: 8),
            TextField(controller: dtCtrl, decoration: const InputDecoration(labelText: 'Scheduled (ISO8601)')),
            const SizedBox(height: 8),
            TextField(controller: notesCtrl, decoration: const InputDecoration(labelText: 'Notes (optional)')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Create')),
        ],
      ),
    );
    if (ok == true) {
      try {
        await context.read<ConsultationsProvider>().create(
              patientId: patientCtrl.text.trim(),
              scheduledAt: dtCtrl.text.trim(),
              notes: notesCtrl.text.trim().isEmpty ? null : notesCtrl.text.trim(),
            );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final role = context.watch<AuthProvider>().role;
    final canCreate = role == 'doctor' || role == 'admin';
    final provider = context.watch<ConsultationsProvider>();
    final items = provider.items;

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () => provider.fetch(),
        child: provider.isLoading
            ? const Center(child: CircularProgressIndicator())
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: items.length,
                itemBuilder: (_, i) {
                  final it = items[i];
                  return Card(
                    child: ListTile(
                      title: Text('Consultation ${it['id'] ?? ''}'),
                      subtitle: Text('Patient: ${it['patient_id']} • Doctor: ${it['doctor_id']}\nAt: ${it['scheduled_at']}\n${it['notes'] ?? ''}'),
                      isThreeLine: true,
                    ),
                  );
                },
              ),
      ),
      floatingActionButton: canCreate ? FloatingActionButton(onPressed: _create, child: const Icon(Icons.add)) : null,
    );
  }
}

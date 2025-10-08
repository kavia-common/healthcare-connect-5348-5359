import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/medical_records_provider.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';

class MedicalRecordsScreen extends StatefulWidget {
  const MedicalRecordsScreen({super.key});

  @override
  State<MedicalRecordsScreen> createState() => _MedicalRecordsScreenState();
}

class _MedicalRecordsScreenState extends State<MedicalRecordsScreen> {
  final _patientFilterCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    final role = context.read<AuthProvider>().role;
    Future.microtask(() => context.read<MedicalRecordsProvider>().fetch(patientId: role == 'doctor' ? '' : null));
  }

  Future<void> _loadWithFilter() async {
    await context.read<MedicalRecordsProvider>().fetch(patientId: _patientFilterCtrl.text.trim().isEmpty ? null : _patientFilterCtrl.text.trim());
  }

  Future<void> _createRecord() async {
    final patientCtrl = TextEditingController();
    final entriesCtrl = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Create medical record'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: patientCtrl, decoration: const InputDecoration(labelText: 'Patient ID')),
            const SizedBox(height: 8),
            TextField(controller: entriesCtrl, decoration: const InputDecoration(labelText: 'Entries (comma-separated)')),
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
        final entries = entriesCtrl.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
        await context.read<MedicalRecordsProvider>().create(patientId: patientCtrl.text.trim(), entries: entries.isEmpty ? null : entries);
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
    final provider = context.watch<MedicalRecordsProvider>();
    final items = provider.items;

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (role == 'doctor') ...[
              Row(
                children: [
                  Expanded(child: TextField(controller: _patientFilterCtrl, decoration: const InputDecoration(labelText: 'Filter by patient ID'))),
                  const SizedBox(width: 8),
                  ElevatedButton(onPressed: _loadWithFilter, child: const Text('Load')),
                ],
              ),
              const SizedBox(height: 12),
            ],
            Expanded(
              child: provider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : RefreshIndicator(
                      onRefresh: () => provider.fetch(patientId: role == 'doctor' ? _patientFilterCtrl.text.trim() : null),
                      child: ListView.separated(
                        itemCount: items.length,
                        separatorBuilder: (_, __) => const Divider(),
                        itemBuilder: (_, i) {
                          final r = items[i];
                          return ListTile(
                            title: Text('Record: ${r['id'] ?? ''}'),
                            subtitle: Text('Patient: ${r['patient_id']}\nEntries: ${(r['entries'] as List?)?.join(', ') ?? 'N/A'}'),
                            isThreeLine: true,
                          );
                        },
                      ),
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: canCreate ? FloatingActionButton(onPressed: _createRecord, child: const Icon(Icons.add)) : null,
    );
  }
}

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/api_client.dart';
import '../theme/app_theme.dart';

class DoctorsScreen extends StatefulWidget {
  const DoctorsScreen({super.key});

  @override
  State<DoctorsScreen> createState() => _DoctorsScreenState();
}

class _DoctorsScreenState extends State<DoctorsScreen> {
  final _client = ApiClient();
  bool _loading = false;
  List<Map<String, dynamic>> _items = [];

  Future<void> _fetch() async {
    setState(() => _loading = true);
    try {
      final resp = await _client.get('/doctors');
      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body) as List<dynamic>;
        setState(() => _items = data.cast<Map<String, dynamic>>());
      } else {
        throw Exception('Failed with ${resp.statusCode}');
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _createDoctorDialog() async {
    final specialtyCtrl = TextEditingController();
    final bioCtrl = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Create doctor profile'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: specialtyCtrl, decoration: const InputDecoration(labelText: 'Specialty')),
            const SizedBox(height: 8),
            TextField(controller: bioCtrl, decoration: const InputDecoration(labelText: 'Bio')),
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
        final resp = await _client.post('/doctors', body: {
          'specialty': specialtyCtrl.text.trim().isEmpty ? null : specialtyCtrl.text.trim(),
          'bio': bioCtrl.text.trim().isEmpty ? null : bioCtrl.text.trim(),
        });
        if (resp.statusCode == 201) {
          await _fetch();
        } else {
          throw Exception('Failed: ${resp.statusCode} ${resp.body}');
        }
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error));
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  @override
  Widget build(BuildContext context) {
    final role = context.watch<AuthProvider>().role;
    final canCreate = role == 'doctor' || role == 'admin';
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _fetch,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : ListView.separated(
                padding: const EdgeInsets.all(16),
                separatorBuilder: (_, __) => const Divider(),
                itemCount: _items.length,
                itemBuilder: (_, i) {
                  final d = _items[i];
                  return ListTile(
                    title: Text(d['full_name'] ?? 'Doctor ${d['id'] ?? ''}'),
                    subtitle: Text('${d['specialty'] ?? 'N/A'} • ${d['bio'] ?? ''}'),
                    leading: const CircleAvatar(child: Icon(Icons.person_outline)),
                  );
                },
              ),
      ),
      floatingActionButton: canCreate ? FloatingActionButton(onPressed: _createDoctorDialog, child: const Icon(Icons.add)) : null,
    );
  }
}

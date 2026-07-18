import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../core/config/app_config.dart';
import '../../../domain/usecases/recycle_bin_engine.dart';
import '../../widgets/glass_card.dart';

class RecycleBinScreen extends StatefulWidget {
  const RecycleBinScreen({super.key});

  @override
  State<RecycleBinScreen> createState() => _RecycleBinScreenState();
}

class _RecycleBinScreenState extends State<RecycleBinScreen> {
  final RecycleBinEngine _binEngine = RecycleBinEngine();

  @override
  void initState() {
    super.initState();
    // स्क्रीन लोड होताना मुदत संपलेला डेटा साफ करा
    _binEngine.purgeExpiredItems();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recycle Bin'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Items in Recycle Bin are permanently purged after 30 days.')),
              );
            },
          )
        ],
      ),
      body: ValueListenableBuilder(
        valueListenable: Hive.box(AppConfig.recycleBinBoxName).listenable(),
        builder: (context, Box box, _) {
          if (box.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.delete_outline, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('Recycle Bin is empty!', style: TextStyle(color: Colors.grey, fontSize: 16)),
                ],
              ),
            );
          }

          final keys = box.keys.toList();

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: keys.length,
            itemBuilder: (context, index) {
              final String key = keys[index] as String;
              final Map<String, dynamic> binItem = Map<String, dynamic>.from(box.get(key));
              final String type = binItem['type'] as String;
              final Map<String, dynamic> rawData = Map<String, dynamic>.from(binItem['data']);
              final String itemName = rawData['name'] ?? rawData['productName'] ?? 'Unnamed Record';

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: GlassCard(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: type == 'CUSTOMER' ? Colors.blue.shade100 : Colors.amber.shade100,
                      child: Icon(
                        type == 'CUSTOMER' ? Icons.person : Icons.receipt_long,
                        color: type == 'CUSTOMER' ? Colors.blue : Colors.amber,
                      ),
                    ),
                    title: Text(itemName, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('Type: $type'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Restore Button
                        IconButton(
                          icon: const Icon(Icons.restore, color: Colors.green),
                          tooltip: 'Restore Record',
                          onPressed: () async {
                            await _binEngine.restoreItem(key);
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Record successfully restored!'), backgroundColor: Colors.green),
                              );
                            }
                          },
                        ),
                        // Permanent Delete Button
                        IconButton(
                          icon: const Icon(Icons.delete_forever, color: Colors.red),
                          tooltip: 'Delete Permanently',
                          onPressed: () async {
                            await box.delete(key);
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Record permanently deleted.')),
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
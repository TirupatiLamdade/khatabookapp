import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class DeveloperSettingsView extends StatelessWidget {
  const DeveloperSettingsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('डेव्हलपर सेटिंग्स'),
        backgroundColor: Colors.blue.shade800,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '⚠️ चेतावणी: हे पर्याय फक्त टेस्टिंगसाठी आहेत. येथील बदलांमुळे लोकल कॅश डेटा डिलीट होऊ शकतो.',
              style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            
            // 🔄 ऑप्शन १: Hive कॅश साफ करणे
            Card(
              child: ListTile(
                leading: const Icon(Icons.storage, color: Colors.red),
                title: const Text('लोकल Hive कॅश क्लिअर करा'),
                subtitle: const Text('ॲपमधील साठवलेला तात्पुरता डेटा साफ करा'),
                trailing: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade700, foregroundColor: Colors.white),
                  onPressed: () async {
                    var box = Hive.box('settings_box');
                    await box.clear();
                    
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('लोकल कॅश यशस्वीरित्या साफ केली!')),
                      );
                    }
                  },
                  child: const Text('Clear'),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // 📋 ऑप्शन २: सिस्टीम इन्फो (Diagnostic)
            Card(
              child: ListTile(
                leading: const Icon(Icons.info_outline, color: Colors.blue),
                title: const Text('ॲप व्हर्जन आणि डायग्नोस्टिक्स'),
                subtitle: const Text('v1.0.0 (Production Engine) • Firebase Sync: Active'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
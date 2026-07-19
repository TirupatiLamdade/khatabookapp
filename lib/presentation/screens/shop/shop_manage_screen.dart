import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/global_provider_hub.dart';
import '../../viewmodels/shop_viewmodel.dart'; // 👈 तुमचे शॉप व्ह्यू-मॉडेल

class ShopManageScreen extends ConsumerWidget {
  const ShopManageScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 🏪 सध्या ॲक्टिव्ह असलेला शॉप आयडी मिळवा
    final currentActiveShopId = ref.watch(activeShopIdProvider);
    
    // 🔍 स्ट्रीम किंवा फ्युचर प्रोव्हाइडरद्वारे या दुकानदाराच्या सर्व दुकानांची लिस्ट मिळवा
    // (सध्यातरी टेस्टिंगसाठी आपण डमी लिस्ट वापरत आहोत जी तुमच्या `shopViewModel` शी कनेक्ट होईल)
    final mockShops = [
      {'id': 'SHOP_KIRANA_01', 'name': 'माऊली किराणा स्टोअर्स', 'type': 'किराणा दुकान'},
      {'id': 'SHOP_CLOTH_02', 'name': 'जगदंबा मेन्स वेअर', 'type': 'कपड्यांचे दुकान'},
      {'id': 'SHOP_AGRO_03', 'name': 'बळीराजा ॲग्रो एजन्सी', 'type': 'कृषी केंद्र'},
    ];

    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > 900;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🏪 हेडिंग आणि वर्णन
              const Text(
                'माझी दुकाने (Manage Shops)',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              const Text(
                'तुम्ही ज्या दुकानाचा डेटा पाहू इच्छिता, ते दुकान निवडा. डेटा पूर्णपणे सुरक्षित आणि आयसोलेटेड राहील.',
                style: TextStyle(color: Colors.grey, fontSize: 13),
              ),
              const SizedBox(height: 24),

              // 🖥️ डेस्कटॉपवर ३ कॉलम ग्रिड, मोबाईलवर १ कॉलम व्हर्टिकल लिस्ट
              Expanded(
                child: GridView.builder(
                  itemCount: mockShops.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: isDesktop ? 3 : 1,
                    childAspectRatio: isDesktop ? 2.5 : 4,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                  ),
                  itemBuilder: (context, index) {
                    final shop = mockShops[index];
                    final isActive = currentActiveShopId == shop['id'];

                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isActive ? Colors.deepPurple.shade700 : Colors.grey.shade200,
                          width: isActive ? 2.5 : 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: isActive 
                                ? Colors.deepPurple.withOpacity(0.1) 
                                : Colors.black.withOpacity(0.02),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () {
                          // ⚡ शॉप चेंज मॅजिक: ग्लोबल शॉप आयडी अपडेट करा
                          ref.read(activeShopIdProvider.notifier).state = shop['id'];
                          
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('यशस्वीरित्या बदलले: ${shop['name']}'),
                              backgroundColor: Colors.deepPurple.shade800,
                              duration: const Duration(seconds: 1),
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            children: [
                              // 🏪 शॉप आयकॉन
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: isActive ? Colors.deepPurple.shade50 : Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  Icons.storefront,
                                  color: isActive ? Colors.deepPurple.shade800 : Colors.grey.shade600,
                                  size: 28,
                                ),
                              ),
                              const SizedBox(width: 16),
                              
                              // 📝 शॉप माहिती
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      shop['name']!,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: isActive ? Colors.deepPurple.shade900 : Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      shop['type']!,
                                      style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                              
                              // ✅ ॲक्टिव्ह इंडिकेटर
                              if (isActive)
                                Icon(Icons.check_circle, color: Colors.deepPurple.shade700, size: 24)
                              else
                                const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 14),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      
      // ➕ नवीन दुकान जोडण्यासाठी बटन
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // 🚧 नवीन दुकान जोडण्याचा डायलॉग किंवा बॉटम शीट इथे येईल
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('नवीन दुकान जोडण्याची सुविधा लवकरच येत आहे!')),
          );
        },
        backgroundColor: Colors.deepPurple.shade700,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_business),
        label: const Text('नवीन दुकान जोडा', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }
}
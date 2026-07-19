import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/customer_model.dart';

class FirestoreRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 🛡️ मल्टि-टेनंट सुरक्षेसाठी नियमांनुसार shopId फिल्टर
  Stream<List<CustomerModel>> getCustomersStream(String shopId) {
    return _firestore
        .collection('customers')
        .where('shopId', isEqualTo: shopId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => CustomerModel.fromDoc(doc))
            .toList());
  }

  // ट्रान्झॅक्शनसाठी आवश्यक असणारी मेथड (एरर टाळण्यासाठी)
  Future<void> addTransaction(Map<String, dynamic> data) async {
    await _firestore.collection('transactions').add(data);
  }
}
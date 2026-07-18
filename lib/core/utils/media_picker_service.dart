import 'package:image_picker/image_picker.dart';

class MediaPickerService {
  final ImagePicker _picker = ImagePicker();
  // गॅलरीमधून सुरक्षित प्रतिमा फेच करा
  Future<String?> pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70, // कॉम्प्रेशन करून मेमरी वाचवण्यासाठी
        maxWidth: 1000,
      );
      return image?.path;
    } catch (e) {
      return null;
    }
  }

  // मोबाईल कॅमेऱ्याने थेट फोटो कॅप्चर करा
  Future<String?> captureImageFromCamera() async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 70,
        maxWidth: 1000,
      );
      return photo?.path;
    } catch (e) {
      return null;
    }
  }
}

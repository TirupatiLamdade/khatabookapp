class TransliterationService {
  // कीबोर्ड वरून टाईप होणाऱ्या इंग्रजी शब्दांना भारतीय ध्वन्यात्मक भाषेत रुपांतरित करणारा मॅप
  static const Map<String, String> _indicPhoneticMap = {
    'namaste': 'नमस्ते',
    'khata': 'खाता',
    'smart': 'स्मार्ट',
    'ram': 'राम',
    'shyam': 'श्याम',
    'rokh': 'रोख',
    'udaar': 'उधार',
    'jama': 'जमा',
    'naave': 'नावे',
  };

  static String processRealtimeInput(String input) {
    if (input.isEmpty) return input;
    
    List<String> words = input.toLowerCase().split(' ');
    List<String> convertedWords = [];

    for (var word in words) {
      if (_indicPhoneticMap.containsKey(word)) {
        convertedWords.add(_indicPhoneticMap[word]!);
      } else {
        convertedWords.add(word); // मॅपमध्ये नसल्यास मूळ शब्द कायम ठेवा
      }
    }
    return convertedWords.join(' ');
  }
}
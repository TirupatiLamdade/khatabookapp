
// import 'dart:async';
// import 'dart:convert';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:http/http.dart' as http;
// import 'package:login_setup/core/providers/global_provider_hub.dart';

// class AiChatMessage {
//   final String text;
//   final bool isUser;
//   final DateTime timestamp;

//   AiChatMessage({
//     required this.text,
//     required this.isUser,
//     DateTime? timestamp,
//   }) : timestamp = timestamp ?? DateTime.now();
// }

// class AiChatFloatingWidget extends ConsumerStatefulWidget {
//   const AiChatFloatingWidget({Key? key}) : super(key: key);

//   @override
//   ConsumerState<AiChatFloatingWidget> createState() => _AiChatFloatingWidgetState();
// }

// class _AiChatFloatingWidgetState extends ConsumerState<AiChatFloatingWidget>
//     with SingleTickerProviderStateMixin {
//   // 🔑 YOUR WORKING API KEY (X-goog-api-key)
//   static const String _geminiApiKey = 'AQ.Ab8RN6LEgIKDVwvkO55KDnW5YiuDo8lTUIrLNINiuXXpeltLTA';

//   bool _isExpanded = false;
//   bool _isLoading = false;
//   final TextEditingController _messageController = TextEditingController();
//   final ScrollController _scrollController = ScrollController();

//   // 🔴 BLINKING ANIMATION FOR ROBOT ICON
//   late AnimationController _blinkController;
//   late Animation<double> _blinkAnimation;

//   // 🔄 Dynamic Tooltip Messages
//   Timer? _tooltipTimer;
//   int _currentTooltipIndex = 0;
//   List<String> _dynamicTooltips = [
//     "Hey Owner! 👋",
//     "Khatabook Smart 📊",
//     "Need Ledger Help? 💰",
//   ];

//   String _ownerName = "Shop Owner"; // Database store values
//   List<AiChatMessage> _messages = [];

//   @override
//   void initState() {
//     super.initState();

//     // ⚡ BLINKING ANIMATION SETUP
//     _blinkController = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 1200),
//     )..repeat(reverse: true);

//     _blinkAnimation = Tween<double>(begin: 0.7, end: 1.0).animate(
//       CurvedAnimation(parent: _blinkController, curve: Curves.easeInOut),
//     );

//     // Initial messages setup
//     _messages = [
//       AiChatMessage(
//         text: "Welcome to Khatabook Smart! 🤖\nHow can I help you manage your business today?",
//         isUser: false,
//       ),
//     ];

//     // 📊 Fetch Shop Owner Name directly from Firebase Firestore Database
//     _fetchShopOwnerName();

//     // ⏱️ Tooltip Rotation Timer
//     _tooltipTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
//       if (mounted) {
//         setState(() {
//           _currentTooltipIndex = (_currentTooltipIndex + 1) % _dynamicTooltips.length;
//         });
//       }
//     });
//   }

//   // 📡 Firestore मधून दुकानाचे/ओव्हरचे पूर्ण नाव आणणे
//   Future<void> _fetchShopOwnerName() async {
//     try {
//       final user = FirebaseAuth.instance.currentUser;
//       if (user != null) {
//         final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
//         if (doc.exists && doc.data() != null) {
//           final data = doc.data()!;
//           // shopName किंवा ownerName किंवा displayName डेटाबेसमधून वाचणे
//           final String fetchedName = data['shopName'] ?? data['ownerName'] ?? user.displayName ?? "Shop Owner";
          
//           if (mounted && fetchedName.isNotEmpty) {
//             setState(() {
//               _ownerName = fetchedName;
//               _dynamicTooltips = [
//                 "Hey $_ownerName! 👋",
//                 "Khatabook Smart 📊",
//                 "Need Ledger Help? 💰",
//               ];
//               // First Welcome message update with Full Owner Name
//               _messages[0] = AiChatMessage(
//                 text: "Welcome $_ownerName! 🤖\nI am your Khatabook Smart AI Assistant. How can I help you today?",
//                 isUser: false,
//               );
//             });
//           }
//         }
//       }
//     } catch (e) {
//       debugPrint("Error fetching owner name: $e");
//     }
//   }

//   @override
//   void dispose() {
//     _blinkController.dispose();
//     _tooltipTimer?.cancel();
//     _messageController.dispose();
//     _scrollController.dispose();
//     super.dispose();
//   }

//   void _scrollToBottom() {
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       if (_scrollController.hasClients) {
//         _scrollController.animateTo(
//           _scrollController.position.maxScrollExtent,
//           duration: const Duration(milliseconds: 300),
//           curve: Curves.easeOut,
//         );
//       }
//     });
//   }

//   // 🌐 Gemini API Call with Owner Context
//   Future<void> _sendMessage() async {
//     final text = _messageController.text.trim();
//     if (text.isEmpty || _isLoading) return;

//     _messageController.clear();

//     setState(() {
//       _messages.add(AiChatMessage(text: text, isUser: true));
//       _isLoading = true;
//     });
//     _scrollToBottom();

//     // 🎯 System Prompt with Database Shop Owner Name
//     final String systemPrompt = """
// You are the built-in AI assistant for the 'Khatabook Smart' application.
// Context Info:
// - Shop / Business Owner Name: $_ownerName

// App Scope & Knowledge Base:
// - Khatabook Smart helps track credit (Udhar / Giving) and debit (Jama / Payment Received).
// - Features: Add Customer, Record Ledger Entries, WhatsApp Reminders, PDF Statements, Cloud Backup & Restore, Recycle Bin.
// - Keep answers short, professional, helpful, and strictly related to Khatabook Smart app and business bookkeeping.

// User Question: $text
// """;

//     try {
//       final url = Uri.parse(
//         'https://generativelanguage.googleapis.com/v1beta/models/gemini-flash-latest:generateContent',
//       );

//       final response = await http.post(
//         url,
//         headers: {
//           'Content-Type': 'application/json',
//           'X-goog-api-key': _geminiApiKey,
//         },
//         body: jsonEncode({
//           "contents": [
//             {
//               "parts": [
//                 {"text": systemPrompt}
//               ]
//             }
//           ]
//         }),
//       );

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         final String aiReply =
//             data['candidates'][0]['content']['parts'][0]['text'] ?? "No response received.";

//         if (mounted) {
//           setState(() {
//             _messages.add(AiChatMessage(text: aiReply, isUser: false));
//             _isLoading = false;
//           });
//           _scrollToBottom();
//         }
//       } else {
//         final errorData = jsonDecode(response.body);
//         final String errorMsg = errorData['error']?['message'] ?? response.body;
//         throw Exception("Code ${response.statusCode}: $errorMsg");
//       }
//     } catch (e) {
//       if (mounted) {
//         setState(() {
//           _messages.add(AiChatMessage(
//             text: "Connection Error: $e",
//             isUser: false,
//           ));
//           _isLoading = false;
//         });
//         _scrollToBottom();
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final themeMode = ref.watch(themeModeProvider);
//     final isDark = themeMode == ThemeMode.dark ||
//         (themeMode == ThemeMode.system &&
//             MediaQuery.of(context).platformBrightness == Brightness.dark);

//     final cardBgColor = isDark ? const Color(0xFF0F172A) : Colors.white;
//     final headerBgColor = isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9);
//     final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
//     final borderColor = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
//     final userBubbleBg = isDark ? const Color(0xFF0284C7) : const Color(0xFF0066CC);
//     final aiBubbleBg = isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC);
//     final inputBgColor = isDark ? const Color(0xFF020617) : const Color(0xFFF1F5F9);

//     return AnimatedContainer(
//       duration: const Duration(milliseconds: 300),
//       curve: Curves.easeOutBack,
//       width: _isExpanded ? 350 : 130,
//       height: _isExpanded ? 490 : 85,
//       child: _isExpanded
//           ? Container(
//               decoration: BoxDecoration(
//                 color: cardBgColor,
//                 borderRadius: BorderRadius.circular(20),
//                 border: Border.all(color: borderColor, width: 1.5),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black.withOpacity(isDark ? 0.5 : 0.15),
//                     blurRadius: 16,
//                     offset: const Offset(0, 6),
//                   ),
//                 ],
//               ),
//               child: _buildChatWindow(
//                 isDark: isDark,
//                 cardBgColor: cardBgColor,
//                 headerBgColor: headerBgColor,
//                 textColor: textColor,
//                 borderColor: borderColor,
//                 userBubbleBg: userBubbleBg,
//                 aiBubbleBg: aiBubbleBg,
//                 inputBgColor: inputBgColor,
//               ),
//             )
//           : _buildBlinkingRobotButtonWithSpeechBubble(isDark),
//     );
//   }

//   // 🔴 BLINKING ROBOT ICON WITH DYNAMIC TOOLTIP
//   Widget _buildBlinkingRobotButtonWithSpeechBubble(bool isDark) {
//     return Stack(
//       alignment: Alignment.bottomRight,
//       children: [
//         // 💬 Speech Bubble
//         Positioned(
//           top: 0,
//           right: 2,
//           child: AnimatedSwitcher(
//             duration: const Duration(milliseconds: 400),
//             transitionBuilder: (Widget child, Animation<double> animation) {
//               return ScaleTransition(scale: animation, child: child);
//             },
//             child: Container(
//               key: ValueKey<int>(_currentTooltipIndex),
//               padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
//               decoration: BoxDecoration(
//                 color: const Color(0xFF0284C7),
//                 borderRadius: BorderRadius.circular(12),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black.withOpacity(0.2),
//                     blurRadius: 4,
//                     offset: const Offset(0, 2),
//                   ),
//                 ],
//               ),
//               child: Text(
//                 _dynamicTooltips[_currentTooltipIndex],
//                 style: const TextStyle(
//                   color: Colors.white,
//                   fontSize: 10.5,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ),
//           ),
//         ),

//         // 🤖 BLINKING ROBOT BUTTON
//         Positioned(
//           bottom: 0,
//           right: 0,
//           child: ScaleTransition(
//             scale: _blinkAnimation,
//             child: Material(
//               color: Colors.transparent,
//               child: InkWell(
//                 borderRadius: BorderRadius.circular(30),
//                 onTap: () => setState(() => _isExpanded = true),
//                 child: Container(
//                   width: 58,
//                   height: 58,
//                   decoration: BoxDecoration(
//                     gradient: const LinearGradient(
//                       colors: [Color(0xFF0284C7), Color(0xFF38BDF8)],
//                       begin: Alignment.topLeft,
//                       end: Alignment.bottomRight,
//                     ),
//                     shape: BoxShape.circle,
//                     border: Border.all(color: Colors.white, width: 2),
//                     boxShadow: [
//                       BoxShadow(
//                         color: const Color(0xFF0284C7).withOpacity(0.5),
//                         blurRadius: 12,
//                         spreadRadius: 1,
//                         offset: const Offset(0, 4),
//                       ),
//                     ],
//                   ),
//                   child: const Center(
//                     child: Icon(
//                       Icons.smart_toy_rounded,
//                       color: Colors.white,
//                       size: 30,
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   // 💬 Chat Window
//   Widget _buildChatWindow({
//     required bool isDark,
//     required Color cardBgColor,
//     required Color headerBgColor,
//     required Color textColor,
//     required Color borderColor,
//     required Color userBubbleBg,
//     required Color aiBubbleBg,
//     required Color inputBgColor,
//   }) {
//     return ClipRRect(
//       borderRadius: BorderRadius.circular(20),
//       child: Column(
//         children: [
//           // Header
//           Container(
//             padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
//             color: headerBgColor,
//             child: Row(
//               children: [
//                 Container(
//                   padding: const EdgeInsets.all(6),
//                   decoration: BoxDecoration(
//                     color: const Color(0xFF0284C7).withOpacity(0.15),
//                     shape: BoxShape.circle,
//                   ),
//                   child: const Icon(Icons.smart_toy_rounded, color: Color(0xFF0284C7), size: 22),
//                 ),
//                 const SizedBox(width: 10),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       Text('Khatabook Smart AI', style: TextStyle(color: textColor, fontWeight: FontWeight.w800, fontSize: 13.5)),
//                       Text(_ownerName, style: const TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.bold, fontSize: 10), overflow: TextOverflow.ellipsis),
//                     ],
//                   ),
//                 ),
//                 IconButton(
//                   icon: Icon(Icons.close_rounded, color: textColor, size: 20),
//                   onPressed: () => setState(() => _isExpanded = false),
//                   padding: EdgeInsets.zero,
//                   constraints: const BoxConstraints(),
//                 ),
//               ],
//             ),
//           ),
//           Divider(color: borderColor, height: 1),
          
//           // Messages List
//           Expanded(
//             child: ListView.builder(
//               controller: _scrollController,
//               padding: const EdgeInsets.all(12),
//               itemCount: _messages.length,
//               itemBuilder: (context, index) {
//                 final msg = _messages[index];
//                 return Align(
//                   alignment: msg.isUser ? Alignment.centerRight : Alignment.centerLeft,
//                   child: Container(
//                     margin: const EdgeInsets.only(bottom: 10),
//                     padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
//                     constraints: const BoxConstraints(maxWidth: 240),
//                     decoration: BoxDecoration(
//                       color: msg.isUser ? userBubbleBg : aiBubbleBg,
//                       border: msg.isUser ? null : Border.all(color: borderColor),
//                       borderRadius: BorderRadius.only(
//                         topLeft: const Radius.circular(14),
//                         topRight: const Radius.circular(14),
//                         bottomLeft: Radius.circular(msg.isUser ? 14 : 2),
//                         bottomRight: Radius.circular(msg.isUser ? 2 : 14),
//                       ),
//                     ),
//                     child: Text(
//                       msg.text,
//                       style: TextStyle(
//                         color: msg.isUser ? Colors.white : textColor,
//                         fontWeight: FontWeight.w600,
//                         fontSize: 12.5,
//                         height: 1.3,
//                       ),
//                     ),
//                   ),
//                 );
//               },
//             ),
//           ),

//           if (_isLoading)
//             Padding(
//               padding: const EdgeInsets.only(bottom: 8.0, left: 16),
//               child: Align(
//                 alignment: Alignment.centerLeft,
//                 child: Row(
//                   children: [
//                     SizedBox(
//                       width: 12,
//                       height: 12,
//                       child: CircularProgressIndicator(
//                         strokeWidth: 2,
//                         color: isDark ? const Color(0xFF38BDF8) : const Color(0xFF0284C7),
//                       ),
//                     ),
//                     const SizedBox(width: 8),
//                     Text(
//                       'AI is typing...',
//                       style: TextStyle(
//                         color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
//                         fontSize: 10.5,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           Divider(color: borderColor, height: 1),

//           // Input Box
//           Container(
//             padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
//             color: cardBgColor,
//             child: Row(
//               children: [
//                 Expanded(
//                   child: TextField(
//                     controller: _messageController,
//                     style: TextStyle(color: textColor, fontSize: 12.5, fontWeight: FontWeight.w600),
//                     decoration: InputDecoration(
//                       hintText: 'Ask about Khatabook Smart...',
//                       hintStyle: TextStyle(color: isDark ? Colors.grey.shade500 : Colors.grey.shade400, fontSize: 11.5),
//                       filled: true,
//                       fillColor: inputBgColor,
//                       contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(20),
//                         borderSide: BorderSide.none,
//                       ),
//                     ),
//                     onSubmitted: (_) => _sendMessage(),
//                   ),
//                 ),
//                 const SizedBox(width: 6),
//                 IconButton(
//                   icon: const Icon(Icons.send_rounded, color: Color(0xFF0284C7), size: 20),
//                   onPressed: _sendMessage,
//                   padding: EdgeInsets.zero,
//                   constraints: const BoxConstraints(),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
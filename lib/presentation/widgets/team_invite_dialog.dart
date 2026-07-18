import 'package:flutter/material.dart';

class TeamInviteDialog extends StatefulWidget {
  final Function(String email, String role) onInviteSent;

  const TeamInviteDialog({super.key, required this.onInviteSent});

  @override
  State<TeamInviteDialog> createState() => _TeamInviteDialogState();
}

class _TeamInviteDialogState extends State<TeamInviteDialog> {
  final _emailController = TextEditingController();
  String _selectedRole = 'Staff'; // Default selected role

  final List<String> _roles = ['Manager', 'Staff', 'Viewer'];

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.person_add_alt_1_outlined, color: Colors.deepPurple),
          SizedBox(width: 10),
          Text('Invite Team Member', style: TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Enter team member email & select workspace role permissions.', style: TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 16),
          TextField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: "Collaborator's Email",
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.email_outlined),
            ),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _selectedRole,
            decoration: const InputDecoration(
              labelText: "Assigned Role",
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.security_outlined),
            ),
            items: _roles.map((role) {
              return DropdownMenuItem(value: role, child: Text(role));
            }).toList(),
            onChanged: (val) {
              if (val != null) setState(() => _selectedRole = val);
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple, foregroundColor: Colors.white),
          onPressed: () {
            if (_emailController.text.isNotEmpty) {
              widget.onInviteSent(_emailController.text.trim(), _selectedRole);
              Navigator.pop(context);
            }
          },
          child: const Text('Send Invitation'),
        ),
      ],
    );
  }
}
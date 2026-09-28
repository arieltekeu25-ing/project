import 'package:flutter/material.dart';
import '../../../shared/widgets/app_scaffold.dart';

/// Page de chat (placeholder)
class ChatPage extends StatelessWidget {
  const ChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppScaffold(
      title: 'Messages',
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.chat, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Page de chat - En construction',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

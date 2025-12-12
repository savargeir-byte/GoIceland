import 'package:flutter/material.dart';

import '../../core/services/ai_service.dart';

class AIChatAssistant extends StatefulWidget {
  const AIChatAssistant({super.key});

  @override
  State<AIChatAssistant> createState() => _AIChatAssistantState();
}

class _AIChatAssistantState extends State<AIChatAssistant> {
  final _controller =
      TextEditingController(text: 'Ég vil sjá 3 fallega staði í 2 tíma.');
  final _aiService = AIService();
  String? _response;
  bool _loading = false;

  Future<void> _send() async {
    setState(() => _loading = true);
    final answer =
        await _aiService.surpriseRouteSuggestion(context: _controller.text);
    setState(() {
      _response = answer;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AI Travel Concierge')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              minLines: 2,
              maxLines: 4,
              decoration: const InputDecoration(labelText: 'Ask anything'),
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: _loading ? null : _send,
              icon: const Icon(Icons.auto_awesome),
              label: const Text('Generate'),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
                      child:
                          Text(_response ?? 'Ask the AI to get suggestions.')),
            ),
          ],
        ),
      ),
    );
  }
}

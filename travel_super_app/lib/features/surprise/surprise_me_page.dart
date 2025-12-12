import 'package:flutter/material.dart';

import '../../core/services/ai_service.dart';

class SurpriseMePage extends StatefulWidget {
  const SurpriseMePage({super.key});

  @override
  State<SurpriseMePage> createState() => _SurpriseMePageState();
}

class _SurpriseMePageState extends State<SurpriseMePage> {
  final _ai = AIService();
  String? _result;
  bool _loading = false;

  Future<void> _generate() async {
    setState(() => _loading = true);
    final text = await _ai.surpriseRouteSuggestion(
      context:
          'One waterfall, one food spot, and one adventure close to Reykjavík within 2 hours.',
    );
    setState(() {
      _result = text;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Surprise Me')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
                'AI picks 1 photo spot, 1 food spot, 1 experience based on live data.'),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: _loading ? null : _generate,
              child: const Text('Generate'),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
                      child: Text(_result ?? 'Press generate to get a route.')),
            ),
          ],
        ),
      ),
    );
  }
}

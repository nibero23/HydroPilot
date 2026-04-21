import 'package:flutter/material.dart';

class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Support'),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
          bottom: const TabBar(
            indicatorColor: Color(0xFF00B26B),
            labelColor: Color(0xFF00B26B),
            unselectedLabelColor: Colors.grey,
            tabs: [
              Tab(text: 'FAQ', icon: Icon(Icons.help_outline)),
              Tab(text: 'KI-Chat', icon: Icon(Icons.smart_toy)),
              Tab(text: 'E-Mail', icon: Icon(Icons.email)),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _FAQTab(),
            _KIChatTab(),
            _EmailTab(),
          ],
        ),
      ),
    );
  }
}

class _FAQTab extends StatelessWidget {
  const _FAQTab();
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildFaqItem('Wie verbinde ich meinen HydroPilot Topf?', 'Drücke den Knopf für 5 Sekunden...'),
        _buildFaqItem('Warum wird der Boden als offline angezeigt?', 'Überprüfe deine WLAN Verbindung...'),
        _buildFaqItem('Wie kalibriere ich den Sensor?', 'Gehe in die Einstellungen und nutze die Kalibrierungs-Buttons...'),
      ],
    );
  }

  // Hilfsfunktion, damit die FAQ-Texte immer garantiert weiß sind
  Widget _buildFaqItem(String question, String answer) {
    return ExpansionTile(
      title: Text(question, style: const TextStyle(color: Colors.white)),
      collapsedIconColor: Colors.white,
      iconColor: const Color(0xFF00B26B),
      children: [
        ListTile(
          title: Text(answer, style: const TextStyle(color: Colors.grey)),
        )
      ],
    );
  }
}

// ... [Oben bleibt der FAQ-Code gleich] ...

class _KIChatTab extends StatefulWidget {
  const _KIChatTab();

  @override
  State<_KIChatTab> createState() => _KIChatTabState();
}

class _KIChatTabState extends State<_KIChatTab> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  // Unsere Chat-Historie
  final List<Map<String, dynamic>> _messages = [
    {
      'isBot': true, 
      'text': 'Hallo! Ich bin dein HydroPilot KI-Assistent 🌱\nWie kann ich dir heute bei deinen Pflanzen helfen?'
    },
  ];
  
  bool _isTyping = false;

  void _sendMessage() async {
    if (_controller.text.trim().isEmpty) return;

    String userText = _controller.text;
    
    // 1. Nachricht des Nutzers anzeigen
    setState(() {
      _messages.add({'isBot': false, 'text': userText});
      _isTyping = true;
    });
    
    _controller.clear();
    _scrollToBottom();

    // 2. Künstliche Denkpause für den "KI-Effekt" (1,5 Sekunden)
    await Future.delayed(const Duration(milliseconds: 1500));

    // 3. Simuliertes KI-Gehirn (Hier kommt später der echte API-Aufruf zu Gemini/OpenAI rein!)
    String botReply = _getFakeAiResponse(userText.toLowerCase());

    // 4. Antwort des Bots anzeigen
    if (mounted) {
      setState(() {
        _isTyping = false;
        _messages.add({'isBot': true, 'text': botReply});
      });
      _scrollToBottom();
    }
  }

  // Das "Demo-Gehirn" für Vorführzwecke
  String _getFakeAiResponse(String input) {
    if (input.contains('offline') || input.contains('verbindung') || input.contains('wlan')) {
      return 'Wenn dein Topf als offline angezeigt wird, überprüfe bitte deinen WLAN-Router. Oft hilft es auch, den ESP32 durch langes Drücken des Hardware-Buttons neu zu starten.';
    } else if (input.contains('basilikum')) {
      return 'Basilikum mag es gerne feucht, verträgt aber absolut keine Staunässe. Eine Ziel-Bodenfeuchte von ca. 45% bis 60% ist ideal für ihn!';
    } else if (input.contains('gießen') || input.contains('wasser') || input.contains('pumpe')) {
      return 'Du kannst die Pumpe entweder manuell im Dashboard für einige Sekunden aktivieren, oder du legst dir unten in den Topf-Details einen festen Zeitplan an.';
    } else if (input.contains('hallo') || input.contains('hey') || input.contains('hi')) {
      return 'Hallo zurück! Was möchtest du über deine Pflanzen oder das System wissen?';
    } else {
      return 'Das ist eine interessante Frage! Da ich in dieser Demo-App aktuell noch kein echtes Backend habe, kann ich dir das noch nicht im Detail beantworten. Aber die Chat-Oberfläche sieht schon mal super aus, oder? 😉';
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Chat-Verlauf
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(16),
            itemCount: _messages.length + (_isTyping ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == _messages.length) {
                // Lade-Indikator, wenn die KI "tippt"
                return Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1C232D),
                      borderRadius: BorderRadius.circular(16).copyWith(topLeft: const Radius.circular(4)),
                    ),
                    child: const Text('KI tippt...', style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic)),
                  ),
                );
              }

              bool isBot = _messages[index]['isBot'];
              return Align(
                alignment: isBot ? Alignment.centerLeft : Alignment.centerRight,
                child: Container(
                  constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isBot ? const Color(0xFF1C232D) : const Color(0xFF00B26B),
                    borderRadius: BorderRadius.circular(16).copyWith(
                      topLeft: isBot ? const Radius.circular(4) : const Radius.circular(16),
                      topRight: !isBot ? const Radius.circular(4) : const Radius.circular(16),
                    ),
                  ),
                  child: Text(
                    _messages[index]['text'],
                    style: const TextStyle(color: Colors.white, height: 1.4),
                  ),
                ),
              );
            },
          ),
        ),
        
        // Eingabefeld unten
        Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: Color(0xFF12171E),
            border: Border(top: BorderSide(color: Colors.white10)),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  style: const TextStyle(color: Colors.white),
                  onSubmitted: (_) => _sendMessage(),
                  decoration: InputDecoration(
                    hintText: 'Frag mich etwas...',
                    hintStyle: TextStyle(color: Colors.grey.withOpacity(0.5)),
                    filled: true,
                    fillColor: const Color(0xFF1C232D),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: _sendMessage,
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: const BoxDecoration(color: Color(0xFF00B26B), shape: BoxShape.circle),
                  child: const Icon(Icons.send, color: Colors.white, size: 20),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ... [Unten bleibt der EmailTab-Code gleich] ...

// ... [Behalte den oberen Teil der support_screen.dart genau so, wie er ist] ...

class _EmailTab extends StatelessWidget {
  const _EmailTab();
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Unser Team antwortet innerhalb von 24 Stunden.', style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 24),
          
          Row(
            children: [
              Expanded(child: _buildFormField('Name *', 'Max Mustermann')),
              const SizedBox(width: 16),
              Expanded(child: _buildFormField('E-Mail *', 'max@beispiel.de')),
            ],
          ),
          const SizedBox(height: 16),
          _buildFormField('Betreff', 'Worum geht es?'),
          const SizedBox(height: 16),
          
          const Text('Nachricht *', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
          const SizedBox(height: 8),
          TextField(
            maxLines: 5,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Beschreibe dein Problem oder deine Frage...',
              hintStyle: TextStyle(color: Colors.grey.withValues(alpha: 0.5)),
              filled: true,
              fillColor: const Color(0xFF1C232D),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 24),
          
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00B26B),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {},
              icon: const Icon(Icons.send, color: Colors.white, size: 18),
              label: const Text('Anfrage senden', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormField(String label, String hint) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
        const SizedBox(height: 8),
        TextField(
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.withValues(alpha: 0.5)),
            filled: true,
            fillColor: const Color(0xFF1C232D),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          ),
        ),
      ],
    );
  }
}
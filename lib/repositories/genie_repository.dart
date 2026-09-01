import '../models/genie_message_model.dart';
import '../services/mock_data_store.dart';

abstract class GenieRepository {
  Future<List<GenieMessageModel>> getConversationHistory();
  Future<GenieMessageModel> sendMessage(String prompt);
  Future<void> clearConversation();
}

class MockGenieRepository implements GenieRepository {
  final MockDataStore _store = MockDataStore();

  @override
  Future<List<GenieMessageModel>> getConversationHistory() async {
    return List<GenieMessageModel>.from(_store.genieMessages);
  }

  @override
  Future<GenieMessageModel> sendMessage(String prompt) async {
    // 1. Add user message
    final userMsg = GenieMessageModel(
      id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
      text: prompt,
      isUser: true,
    );
    _store.genieMessages.add(userMsg);

    // Simulate AI reasoning delay
    await Future.delayed(const Duration(milliseconds: 650));

    // 2. Generate contextual response
    final responseText = _generateAiResponse(prompt.toLowerCase());

    final botMsg = GenieMessageModel(
      id: 'genie_${DateTime.now().millisecondsSinceEpoch}',
      text: responseText,
      isUser: false,
      quickReplies: _getFollowUpSuggestions(prompt.toLowerCase()),
    );

    _store.genieMessages.add(botMsg);
    return botMsg;
  }

  @override
  Future<void> clearConversation() async {
    _store.genieMessages.clear();
  }

  String _generateAiResponse(String query) {
    if (query.contains('ai') || query.contains('ml') || query.contains('machine learning')) {
      return "🤖 **AI & Tech Recommendations:**\n\n"
          "1. **AIRS (AI & Robotics Society)** is hosting the *Generative AI & LLM Architecture Workshop* in 5 days. They also have an open recruitment drive for ROS2 & perception engineers!\n"
          "2. **GDSC** is hosting *HackCampus 2026* where AI track entries receive dedicated GPU computing credits.\n\n"
          "💡 *Tip:* Your friend **Arjun Patel** is in AIRS and won 1st Place in the State Robotics Cup!";
    } else if (query.contains('event') || query.contains('weekend') || query.contains('happening')) {
      return "📅 **Top Upcoming Campus Events:**\n\n"
          "• **HackCampus 2026 (36-Hour Hackathon)** by GDSC — Starts in 3 days with \$10,000 in prizes!\n"
          "• **Golden Hour Campus Photo-Walk** by Lumière Photography Club — Tomorrow at 4:30 PM.\n"
          "• **Generative AI & LLM Workshop** by AIRS — In 5 days at Seminar Hall B.\n"
          "• **Venture Pitch 2026** by E-Cell — In 8 days.\n\n"
          "Tap on the **Calendar** tab to see your registrations!";
    } else if (query.contains('beginner') || query.contains('starter') || query.contains('newbie')) {
      return "🌱 **Beginner-Friendly Clubs & Events:**\n\n"
          "• **GDSC (Developer Student Club)**: Welcomes first-time coders with beginner workshops in Flutter & Web.\n"
          "• **Lumière Photography Club**: Offers basic camera gear orientation and free editing presets for newcomers.\n"
          "• **Rotaract Youth Club**: Open to all branches without prerequisites, focused on social impact and event leadership.\n"
          "• **Verve Dance Crew**: Has an open-door choreography track for passionate learners.";
    } else if (query.contains('friend') || query.contains('rahul') || query.contains('ananya') || query.contains('arjun')) {
      return "👥 **Friend Activity Insights:**\n\n"
          "• **Arjun Patel** is registered for *HackCampus 2026* and *Venture Pitch 2026*.\n"
          "• **Ananya Sen** recently joined *Lumière Photography Club* and registered for the Photo-Walk.\n"
          "• **Priya Verma** is organizing the *Venture Pitch 2026* with E-Cell.\n\n"
          "You can check full friend updates in the **Home → Friend Activity** feed!";
    } else if (query.contains('design') || query.contains('photo') || query.contains('art')) {
      return "🎨 **Creative & Design Recommendations:**\n\n"
          "• **Lumière Photography Club**: Best for cinematography, Lightroom color-grading, and studio gear.\n"
          "• **GDSC UI/UX Division**: Looking for Figma designers to build campus product interfaces.\n"
          "• *Upcoming Event:* Golden Hour Photo-Walk tomorrow at Clock Tower courtyard!";
    } else {
      return "✨ **C-QUBE Campus Genie Insight:**\n\n"
          "I analyzed active campus clubs, events, and your peer network for *\"$query\"*.\n\n"
          "• 6 active clubs are currently hosting events this month.\n"
          "• 2 clubs have open recruitment drives (GDSC & AIRS).\n"
          "• Over 310 students have registered for upcoming hackathons & workshops.\n\n"
          "Feel free to ask for specific clubs, events, or friend activities!";
    }
  }

  List<String> _getFollowUpSuggestions(String query) {
    if (query.contains('ai') || query.contains('ml')) {
      return [
        'How do I register for the AI Workshop?',
        'Tell me about AIRS recruitment',
        'Which events is Arjun registered for?'
      ];
    } else if (query.contains('event')) {
      return [
        'Which events are free to join?',
        'Show events this weekend',
        'Which clubs match my skills?'
      ];
    } else {
      return [
        'Which clubs are beginner friendly?',
        'What events are happening this weekend?',
        'Tell me about GDSC recruitment'
      ];
    }
  }
}

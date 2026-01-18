class QuoteModel {
  final String text;
  final String author;
  final String category;

  QuoteModel({
    required this.text,
    required this.author,
    this.category = 'motivation',
  });
}

class QuoteService {
  static final List<QuoteModel> _quotes = [
    // Productivity & Success
    QuoteModel(
      text: "The secret of getting ahead is getting started.",
      author: "Mark Twain",
      category: 'productivity',
    ),
    QuoteModel(
      text: "Success is the sum of small efforts repeated day in and day out.",
      author: "Robert Collier",
      category: 'productivity',
    ),
    QuoteModel(
      text: "Don't watch the clock; do what it does. Keep going.",
      author: "Sam Levenson",
      category: 'productivity',
    ),

    // Habits & Consistency
    QuoteModel(
      text:
          "We are what we repeatedly do. Excellence, then, is not an act, but a habit.",
      author: "Aristotle",
      category: 'habits',
    ),
    QuoteModel(
      text:
          "Motivation is what gets you started. Habit is what keeps you going.",
      author: "Jim Ryun",
      category: 'habits',
    ),
    QuoteModel(
      text: "The only way to do great work is to love what you do.",
      author: "Steve Jobs",
      category: 'habits',
    ),

    // Progress & Growth
    QuoteModel(
      text: "Progress, not perfection.",
      author: "Unknown",
      category: 'progress',
    ),
    QuoteModel(
      text:
          "Small daily improvements are the key to staggering long-term results.",
      author: "Unknown",
      category: 'progress',
    ),
    QuoteModel(
      text: "The only impossible journey is the one you never begin.",
      author: "Tony Robbins",
      category: 'progress',
    ),

    // Perseverance
    QuoteModel(
      text: "It does not matter how slowly you go as long as you do not stop.",
      author: "Confucius",
      category: 'perseverance',
    ),
    QuoteModel(
      text: "Fall seven times, stand up eight.",
      author: "Japanese Proverb",
      category: 'perseverance',
    ),
    QuoteModel(
      text: "Believe you can and you're halfway there.",
      author: "Theodore Roosevelt",
      category: 'perseverance',
    ),

    // Health & Wellness
    QuoteModel(
      text: "Take care of your body. It's the only place you have to live.",
      author: "Jim Rohn",
      category: 'health',
    ),
    QuoteModel(
      text: "The groundwork for all happiness is good health.",
      author: "Leigh Hunt",
      category: 'health',
    ),
    QuoteModel(
      text: "Your body hears everything your mind says. Stay positive.",
      author: "Unknown",
      category: 'health',
    ),

    // Discipline
    QuoteModel(
      text: "Discipline is the bridge between goals and accomplishment.",
      author: "Jim Rohn",
      category: 'discipline',
    ),
    QuoteModel(
      text:
          "Self-control is strength. Right thought is mastery. Calmness is power.",
      author: "James Allen",
      category: 'discipline',
    ),
    QuoteModel(
      text: "Do something today that your future self will thank you for.",
      author: "Sean Patrick Flanery",
      category: 'discipline',
    ),

    // Achievement
    QuoteModel(
      text: "The way to get started is to quit talking and begin doing.",
      author: "Walt Disney",
      category: 'achievement',
    ),
    QuoteModel(
      text: "Dream big. Start small. Act now.",
      author: "Robin Sharma",
      category: 'achievement',
    ),
    QuoteModel(
      text:
          "You don't have to be great to start, but you have to start to be great.",
      author: "Zig Ziglar",
      category: 'achievement',
    ),
  ];

  /// Get a daily quote based on the current date
  static QuoteModel getDailyQuote() {
    final today = DateTime.now();
    final dayOfYear = today.difference(DateTime(today.year, 1, 1)).inDays;
    final index = dayOfYear % _quotes.length;
    return _quotes[index];
  }

  /// Get a random quote
  static QuoteModel getRandomQuote() {
    final random = DateTime.now().millisecondsSinceEpoch % _quotes.length;
    return _quotes[random];
  }

  /// Get quotes by category
  static List<QuoteModel> getQuotesByCategory(String category) {
    return _quotes.where((quote) => quote.category == category).toList();
  }

  /// Get all quotes
  static List<QuoteModel> getAllQuotes() {
    return List.unmodifiable(_quotes);
  }

  /// Get quote for specific streak milestone
  static QuoteModel getStreakQuote(int streakDays) {
    if (streakDays >= 100) {
      return QuoteModel(
        text: "100 days! You're unstoppable! 🔥",
        author: "Progressly",
        category: 'milestone',
      );
    } else if (streakDays >= 50) {
      return QuoteModel(
        text: "50 days strong! Keep the momentum going!",
        author: "Progressly",
        category: 'milestone',
      );
    } else if (streakDays >= 30) {
      return QuoteModel(
        text: "30 days! You've built a solid habit!",
        author: "Progressly",
        category: 'milestone',
      );
    } else if (streakDays >= 7) {
      return QuoteModel(
        text: "One week streak! You're building consistency!",
        author: "Progressly",
        category: 'milestone',
      );
    } else {
      return getDailyQuote();
    }
  }
}

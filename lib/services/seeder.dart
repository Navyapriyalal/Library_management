import 'package:pocketbase/pocketbase.dart';
import 'pocketbase_service.dart';

final pb = PocketBaseService.pb;

Future<void> seedBooks() async {
  List<Map<String, dynamic>> books = [
    {
      "name": "Elon Musk",
      "author": "Walter Isaacson",
      "genre": "Biography",
      "price": 590,
      "yr_of_release": 2023,
      "language": "English",
      "status": "available"
    },
    {
      "name": "Becoming",
      "author": "Michelle Obama",
      "genre": "Autobiography",
      "price": 460,
      "yr_of_release": 2018,
      "language": "English",
      "status": "available"
    },
    {
      "name": "Steve Jobs",
      "author": "Walter Isaacson",
      "genre": "Biography",
      "price": 520,
      "yr_of_release": 2011,
      "language": "English",
      "status": "available"
    },
    {
      "name": "Outliers",
      "author": "Malcolm Gladwell",
      "genre": "Psychology",
      "price": 430,
      "yr_of_release": 2008,
      "language": "English",
      "status": "available"
    },
    {
      "name": "Blink",
      "author": "Malcolm Gladwell",
      "genre": "Psychology",
      "price": 410,
      "yr_of_release": 2005,
      "language": "English",
      "status": "available"
    },
    {
      "name": "The Tipping Point",
      "author": "Malcolm Gladwell",
      "genre": "Psychology",
      "price": 400,
      "yr_of_release": 2000,
      "language": "English",
      "status": "available"
    },
    {
      "name": "The Four Agreements",
      "author": "Don Miguel Ruiz",
      "genre": "Spirituality",
      "price": 360,
      "yr_of_release": 1997,
      "language": "English",
      "status": "available"
    },
    {
      "name": "The Monk Who Sold His Ferrari",
      "author": "Robin Sharma",
      "genre": "Self-help",
      "price": 390,
      "yr_of_release": 1999,
      "language": "English",
      "status": "available"
    },
    {
      "name": "Think Like a Monk",
      "author": "Jay Shetty",
      "genre": "Self-help",
      "price": 420,
      "yr_of_release": 2020,
      "language": "English",
      "status": "available"
    },
    {
      "name": "Tools of Titans",
      "author": "Tim Ferriss",
      "genre": "Business",
      "price": 580,
      "yr_of_release": 2016,
      "language": "English",
      "status": "available"
    },
    {
      "name": "Tribe of Mentors",
      "author": "Tim Ferriss",
      "genre": "Motivational",
      "price": 560,
      "yr_of_release": 2017,
      "language": "English",
      "status": "available"
    },
    {
      "name": "Start-Up Nation",
      "author": "Dan Senor",
      "genre": "Economics",
      "price": 440,
      "yr_of_release": 2009,
      "language": "English",
      "status": "available"
    },
    {
      "name": "The Lean CEO",
      "author": "Jacob Stoller",
      "genre": "Business",
      "price": 470,
      "yr_of_release": 2015,
      "language": "English",
      "status": "available"
    },
    {
      "name": "Deep Learning",
      "author": "Ian Goodfellow",
      "genre": "Technology",
      "price": 680,
      "yr_of_release": 2016,
      "language": "English",
      "status": "available"
    },
    {
      "name": "Introduction to Algorithms",
      "author": "Thomas H. Cormen",
      "genre": "Computer Science",
      "price": 720,
      "yr_of_release": 2009,
      "language": "English",
      "status": "available"
    },
    {
      "name": "Python Crash Course",
      "author": "Eric Matthes",
      "genre": "Programming",
      "price": 540,
      "yr_of_release": 2015,
      "language": "English",
      "status": "available"
    },
    {
      "name": "You Don't Know JS",
      "author": "Kyle Simpson",
      "genre": "Programming",
      "price": 470,
      "yr_of_release": 2014,
      "language": "English",
      "status": "available"
    },
    {
      "name": "Grokking Algorithms",
      "author": "Aditya Bhargava",
      "genre": "Computer Science",
      "price": 490,
      "yr_of_release": 2016,
      "language": "English",
      "status": "available"
    },
    {
      "name": "Flutter in Action",
      "author": "Eric Windmill",
      "genre": "Programming",
      "price": 510,
      "yr_of_release": 2020,
      "language": "English",
      "status": "available"
    },
    {
      "name": "Clean Architecture",
      "author": "Robert C. Martin",
      "genre": "Software Engineering",
      "price": 550,
      "yr_of_release": 2017,
      "language": "English",
      "status": "available"
    }
  ]

  ;

  for (final book in books) {
    await pb.collection('books').create(body: book);
  }

  print('✅ Books seeded successfully!');
}

Future<void> updateAllBookCountsTo10() async {
  try {
    final records = await pb.collection('books').getFullList();

    for (var record in records) {
      final currentCount = record.data['count'];

      // Only update if count is missing or not 10
      if (currentCount == null || currentCount != 10) {
        await pb.collection('books').update(record.id, body: {
          'count': 10,
        });
        print('✅ Updated book "${record.data['name']}" with count = 10');
      }
    }

    print('🎉 All books updated with count = 10!');
  } catch (e) {
    print('❌ Error updating books: $e');
  }
}
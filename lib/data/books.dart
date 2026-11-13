class Book {
  const Book(
    this.id,
    this.title,
    this.author,
    this.duration,
    this.age,
    this.description,
    this.category,
    this.price,
  );
  final String id, title, author, description, category;
  final int duration, age, price;
  String get cover => 'assets/images/$id.png';
  String get time => switch (id) {
    'prince' => '44:11',
    'soul' => '01:22:19',
    'ferdinand' => '56:42',
    _ =>
      duration >= 60
          ? '01:${(duration - 60).toString().padLeft(2, '0')}:41'
          : '$duration:27',
  };
}

const books = [
  Book(
    'kubo',
    'Kubo',
    'Travis Knight',
    31,
    7,
    'Stop-motion animated action fantasy film directed by Travis Knight',
    'Tales',
    3,
  ),
  Book(
    'prince',
    'Little Prince',
    'Antoine de Saint-Exupéry',
    44,
    8,
    'Novella by French aristocrat, writer, and aviator Antoine de Saint-Exupéry.',
    'Tales',
    3,
  ),
  Book(
    'coco',
    'Coco',
    'Pixar Animation Studios',
    87,
    14,
    'Computer-animated fantasy film produced by Pixar Animation Studios',
    'Tales',
    0,
  ),
  Book(
    'soul',
    'Soul',
    'Pete Docter',
    82,
    12,
    'A journey through music, imagination, and the little joys of everyday life.',
    'Poems',
    3,
  ),
  Book(
    'ferdinand',
    'Ferdinand',
    'Munro Leaf',
    56,
    8,
    'A gentle bull discovers the courage to be himself and follow his heart.',
    'History books',
    0,
  ),
];

const sampleStory = '''The Starlight Garden

An original SweetDream sample

Under a sky full of silver stars, a little traveler found a quiet garden. The moon smiled over the sleeping flowers. Every leaf held a tiny drop of light.

The traveler sat beside a friendly fox and opened a book. Somewhere beyond the garden, a blue planet turned slowly in the dark.

“There is no need to hurry,” said the fox. “Tonight, every story can wait for a gentle voice.”

They listened to the wind move through the trees. It sounded like the turning of a thousand soft pages. The traveler thought about all the places still waiting to be discovered, and all the friends waiting along the way.

“Close your eyes,” said the fox, “and listen to the stars.”

The little traveler smiled. Home was not so far away after all.

When morning arrived, the garden was golden. The traveler put a bookmark between the pages, thanked the fox, and stepped into a new day.

Every good story leaves a small light behind. Carry yours with you.''';

class BookFilter {
  int age = 5;
  double minDuration = 12, maxDuration = 46, minPrice = 4, maxPrice = 11;
  String language = 'ENG', price = 'All';
  bool active = false;

  bool matches(Book book) =>
      !active ||
      (book.age >= age &&
          book.duration >= minDuration &&
          book.duration <= maxDuration &&
          language == 'ENG' &&
          (price == 'All' ||
              (price == 'Free' ? book.price == 0 : book.price > 0)) &&
          (price != 'Paid' ||
              (book.price >= minPrice && book.price <= maxPrice)));

  void reset() {
    age = 5;
    minDuration = 3;
    maxDuration = 90;
    minPrice = 0;
    maxPrice = 17;
    language = 'ENG';
    price = 'All';
    active = false;
  }
}

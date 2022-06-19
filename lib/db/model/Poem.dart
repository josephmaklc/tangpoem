class Poem {
  final String title;
  final String author;
  final String category;
  final String text;
  final String id;
  final String favorite;
  final int authorOrder;
  final int titleOrder;
  String searchResult="";
  int occurence=0;

  Poem({
    required this.title,
    required this.author,
    required this.category,
    required this.text,
    required this.id,
    required this.favorite,
    required this.authorOrder,
    required this.titleOrder,
    this.searchResult="",
    this.occurence=0
  });

  // Convert a Poem into a Map. The keys must correspond to the names of the
  // columns in the database.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'text': text,
      'author':author,
      'category':category,
      'favorite':favorite,
      'authorOrder':authorOrder,
      'titleOrder':titleOrder
    };
  }

  @override
  String toString() {
    return 'Poem{id: $id, title: $title, author: $author, category: $category}';
  }
}
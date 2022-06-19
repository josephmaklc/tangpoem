class Chapter {
  final int id;
  final String title;
  final String text;
  final String language;
  String searchResult="";
  int occurence=0;

  Chapter({
    required this.id,
    required this.title,
    required this.text,
    required this.language,
    this.searchResult="",
    this.occurence=0
  });

  // Convert a Chapter into a Map. The keys must correspond to the names of the
  // columns in the database.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'text': text,
      'language':language
    };
  }

  @override
  String toString() {
    //return 'Chapter{id: $id, title: $title, language: $language, text: $text}';
    return 'Chapter{id: $id, title: $title, language: $language}';
  }
}
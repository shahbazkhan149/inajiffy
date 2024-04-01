class ArticleModel {
  final SourceModel source;
  final String author;
  final String title;
  final String description;
  final String url;
  final String urlToImage;
  final String publishedAt;
  final String content;
  bool viewed;

  ArticleModel({
    required this.source,
    required this.author,
    required this.title,
    required this.description,
    required this.url,
    required this.urlToImage,
    required this.publishedAt,
    required this.content,
    this.viewed = false,
  });

  factory ArticleModel.fromJson(Map<String, dynamic> json) {
    //print("Json= $json");
    return ArticleModel(
      source: SourceModel.fromJson(json['source']),
      author: json['author'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      url: json['url'] ?? '',
      urlToImage: json['urlToImage'] ?? '',
      publishedAt: json['publishedAt'] ?? '',
      content:json['content'] ?? '',
    );
  }
  Map<String, dynamic> toJson()=>{
    'source': source.toJson(),
    'author': author,
    'title': title,
    'description': description,
    'url': url,
    'urlToImage': urlToImage,
    'publishedAt': publishedAt,
    'content': content,

  };
  String toString(){
    return 'source: ${source.toString()}, author: $author, title: $title, '
        'description: $description, url: $url, urlToImage: $urlToImage, publishedAt: $publishedAt, content: $content';
  }
}

class SourceModel {
  final String id;
  final String name;

  SourceModel({required this.id, required this.name});

  factory SourceModel.fromJson(Map<String, dynamic> json) {
    return SourceModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
    );
  }
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
  };
  String toString(){
    return 'id: $id, name: $name';
  }
}
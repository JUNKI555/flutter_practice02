class Album {
  Album({this.userId, this.id, this.title});

  final int userId;
  final int id;
  final String title;

  // ignore: sort_constructors_first
  factory Album.fromJson(Map<dynamic, dynamic> json) {
    return Album(
      userId: json['userId'] as int,
      id: json['id'] as int,
      title: json['title'] as String,
    );
  }
}

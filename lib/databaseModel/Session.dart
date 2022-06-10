class Session {
  int? id;
  int? courseId;
  String? title;
  String? description;
  bool isExpanded = false;


  Session({this.id, this.courseId, this.title, this.description});

  Session.fromJson(Map<String, dynamic> json) {
    id = json['Id'];
    courseId = json['CourseId'];
    title = json['Title'];
    description = json['Description'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Id'] = this.id;
    data['CourseId'] = this.courseId;
    data['Title'] = this.title;
    data['Description'] = this.description;
    return data;
  }
}

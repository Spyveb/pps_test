class Toolbox {
  int? id;
  int? sessionId;
  String? title;

  Toolbox({this.id, this.sessionId, this.title});

  Toolbox.fromJson(Map<String, dynamic> json) {
    id = json['Id'];
    sessionId = json['SessionId'];
    title = json['Title'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Id'] = this.id;
    data['SessionId'] = this.sessionId;
    data['Title'] = this.title;
    return data;
  }
}

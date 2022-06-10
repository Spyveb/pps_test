class Faq {
  int? id;
  int? SessionId;
  String? Title;


  Faq(this.id, this.SessionId, this.Title);

  Faq.fromJson(Map<String, dynamic> json) {
    id = json['Id'];
    SessionId = json['SessionId'];
    Title = json['Title'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Id'] = this.id;
    data['SessionId'] = this.SessionId;
    data['Title'] = this.Title;
    return data;
  }
}

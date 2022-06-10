class InteractiveType {
  int? id;
  String? type;

  InteractiveType({this.id, this.type});

  InteractiveType.fromJson(Map<String, dynamic> json) {
    id = json['Id'];
    type = json['Type'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Id'] = this.id;
    data['Type'] = this.type;
    return data;
  }
}

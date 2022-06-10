class Course {
  int? id;
  String? Name;
  String? Description;


  Course(this.id, this.Name, this.Description);

  Course.fromJson(Map<String, dynamic> json) {
    id = json['Id'];
    Name = json['Name'];
    Description = json['Description'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Id'] = this.id;
    data['Name'] = this.Name;
    data['Description'] = this.Description;
    return data;
  }
}

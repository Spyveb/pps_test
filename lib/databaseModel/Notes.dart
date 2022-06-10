class Notes {
  int? id;
  int? SubsessionId;
  String? Note;
  int? ContentType;

  Notes(this.SubsessionId, this.Note, this.ContentType);

  Notes.fromJson(Map<String, dynamic> json) {
    id = json['Id'];
    SubsessionId = json['SubsessionId'];
    Note = json['Note'];
    ContentType = json['ContentType'];
  }

  Notes.fromAPIJson(Map<String, dynamic> json) {
    id = int.parse(json['id']);
    SubsessionId = int.parse(json['subsession_id']);
    Note = json['note'];
    ContentType = int.parse(json['content_type_id']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['SubsessionId'] = this.SubsessionId;
    data['Note'] = this.Note;
    data['ContentType'] = this.ContentType;
    return data;
  }
}

class Bookmark {
  int? id;
  int? SessionId;
  int? SubsessionId;
  int? ContentTypeId;
  int? ServerId;

  Bookmark(
      this.SessionId, this.SubsessionId, this.ContentTypeId, this.ServerId);

  Bookmark.fromJson(Map<String, dynamic> json) {
    id = json['Id'];
    SessionId = json['SessionId'];
    SubsessionId = json['SubsessionId'];
    ContentTypeId = json['ContentTypeId'];
    ServerId = json['ServerId'];
  }

  Bookmark.fromAPIJson(Map<String, dynamic> json) {
    id = int.parse(json['id']);
    SessionId = int.parse(json['session_id']);
    SubsessionId = int.parse(json['subsession_id']);
    ContentTypeId = int.parse(json['content_type_id']);
    ServerId = int.parse(json['server_id']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['SessionId'] = this.SessionId;
    data['SubsessionId'] = this.SubsessionId;
    data['ContentTypeId'] = this.ContentTypeId;
    data['ServerId'] = this.ServerId;
    return data;
  }
}

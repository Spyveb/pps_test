class NoteList {
  int? id;
  int? SessionId;
  int? SubsessionId;
  int? ServerId;
  String? Note;
  int? ContentType;
  String? Title;
  String? SubTitle;
  String? MenuTitle;

  NoteList(this.SubsessionId, this.Note, this.ContentType, this.Title, this.SubTitle, this.SessionId, this.MenuTitle, this.ServerId);

  NoteList.fromJson(Map<String, dynamic> json) {
    id = json['Id'];
    SessionId = json['SessionId'];
    SubsessionId = json['SubsessionId'];
    ServerId = json['ServerId'];
    Note = json['Note'];
    ContentType = json['ContentType'];
    Title = json['Title'];
    SubTitle = json['Subtitle'];
    MenuTitle = json['MenuTitle'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['SubsessionId'] = this.SubsessionId;
    data['SessionId'] = this.SessionId;
    data['ServerId'] = this.ServerId;
    data['Note'] = this.Note;
    data['ContentType'] = this.ContentType;
    data['Title'] = this.Title;
    data['Subtitle'] = this.SubTitle;
    data['MenuTitle'] = this.MenuTitle;
    return data;
  }
}
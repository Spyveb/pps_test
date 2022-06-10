class BookmarkList {
  int? id;
  int? SessionId;
  int? SubsessionId;
  int? ContentTypeId;
  int? ServerId;
  String? Title;
  String? Subtitle;
  String? MenuTitle;


  BookmarkList(this.SessionId, this.SubsessionId, this.ContentTypeId, this.ServerId, this.Title, this.Subtitle, this.MenuTitle);

  BookmarkList.fromJson(Map<String, dynamic> json) {
    id = json['Id'];
    SessionId = json['SessionId'];
    SubsessionId = json['SubsessionId'];
    ContentTypeId = json['ContentTypeId'];
    ServerId = json['ServerId'];
    Title = json['Title'];
    Subtitle = json['Subtitle'];
    MenuTitle = json['MenuTitle'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['SessionId'] = this.SessionId;
    data['SubsessionId'] = this.SubsessionId;
    data['ContentTypeId'] = this.ContentTypeId;
    data['ServerId'] = this.ServerId;
    data['Title'] = this.Title;
    data['Subtitle'] = this.Subtitle;
    data['MenuTitle'] = this.MenuTitle;
    return data;
  }
}

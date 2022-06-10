class DrawerMenu {
  int? sessionid;
  int? SubSessionId;
  String? tileTitle;
  String? expansionTileTitle;
  String? subExpansionTileTitle;


  DrawerMenu(this.sessionid, this.SubSessionId, this.tileTitle, this.expansionTileTitle,
      this.subExpansionTileTitle);

  DrawerMenu.fromJson(Map<String, dynamic> json) {
    sessionid = json['sessionId'];
    SubSessionId = json['SubSessionId'];
    tileTitle = json['tileTitle'];
    expansionTileTitle = json['expansionTileTitle'];
    subExpansionTileTitle = json['subExpansionTileTitle'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['sessionId'] = this.sessionid;
    data['SubSessionId'] = this.SubSessionId;
    data['tileTitle'] = this.tileTitle;
    data['expansionTileTitle'] = this.expansionTileTitle;
    data['subExpansionTileTitle'] = this.subExpansionTileTitle;
    return data;
  }
}

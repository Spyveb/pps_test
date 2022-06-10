class SpecialityModule {
  int? id;
  int? SessionId;
  String? MenuTitle;
  String? Title;
  String? Content;
  String? ImageUrl;
  String? VideoTitle;
  String? VideoUrl;
  String? ArticleTitle;
  String? ArticleUrl;
  String? AudioTitle;
  String? AudioUrl;
  String? HelpfulResources;
  String? ImageData;
  String? VideoStatus;


  SpecialityModule(this.SessionId, this.MenuTitle, this.Title,
      this.Content, this.ImageUrl, this.VideoTitle, this.VideoUrl,
      this.ArticleTitle, this.ArticleUrl, this.AudioTitle, this.AudioUrl,
      this.HelpfulResources, this.ImageData, this.VideoStatus);

  SpecialityModule.fromJson(Map<String, dynamic> json) {
    id = json['Id'];
    SessionId = json['ServerId'];
    MenuTitle = json['MenuTitle'];
    Title = json['Title'];
    Content = json['Content'];
    ImageUrl = json['ImageUrl'];
    VideoTitle = json['VideoTitle'];
    VideoUrl = json['VideoUrl'];
    ArticleTitle = json['ArticleTitle'];
    ArticleUrl = json['ArticleUrl'];
    AudioTitle = json['AudioTitle'];
    AudioUrl = json['AudioUrl'];
    HelpfulResources = json['HelpfulResources'];
    ImageData = json['ImageData'];
    VideoStatus = json['VideoStatus'];
  }



  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['ServerId'] = this.SessionId;
    data['MenuTitle'] = this.MenuTitle;
    data['Title'] = this.Title;
    data['Content'] = this.Content;
    data['ImageUrl'] = this.ImageUrl;
    data['VideoTitle'] = this.VideoTitle;
    data['VideoUrl'] = this.VideoUrl;
    data['ArticleTitle'] = this.ArticleTitle;
    data['ArticleUrl'] = this.ArticleUrl;
    data['AudioTitle'] = this.AudioTitle;
    data['HelpfulResources'] = this.HelpfulResources;
    data['ImageData'] = this.ImageData;
    data['VideoStatus'] = this.VideoStatus;
    return data;
  }
}

class Subsession {
  int? id;
  int? sessionId;
  String? subtitle;
  String? description;
  String? imageUrl;
  Null imageData;
  String? videoUrl;
  String? articleTitle;
  String? articleUrl;
  String? videoName;
  String? audioName;
  String? audioUrl;
  String? articleTitle2;
  String? articleUrl2;
  int? videoStatus;
  String? noteTakingGuideUrl;
  String? noteTakingGuideTitle;
  int? interactiveTypeId; // 1 for Quiz, 2 for Expandable Interactives and 3 for Information Quiz
  int? interactiveId;
  String? interactiveTitle;
  int? toolBoxId;
  String? toolBoxTitle;
  int? faqId;
  String? faqTitle;



  Subsession(
      {this.id,
        this.sessionId,
        this.subtitle,
        this.description,
        this.imageUrl,
        this.imageData,
        this.videoUrl,
        this.articleTitle,
        this.articleUrl,
        this.videoName,
        this.audioName,
        this.audioUrl,
        this.articleTitle2,
        this.articleUrl2,
        this.videoStatus,
        this.noteTakingGuideUrl,
        this.noteTakingGuideTitle});

  Subsession.fromJson(Map<String, dynamic> json) {
    id = json['Id'];
    sessionId = json['SessionId'];
    subtitle = json['Subtitle'];
    description = json['Description'];
    imageUrl = json['ImageUrl'];
    imageData = json['ImageData'];
    videoUrl = json['VideoUrl'];
    articleTitle = json['ArticleTitle'];
    articleUrl = json['ArticleUrl'];
    videoName = json['VideoName'];
    audioName = json['AudioName'];
    audioUrl = json['AudioUrl'];
    articleTitle2 = json['ArticleTitle2'];
    articleUrl2 = json['ArticleUrl2'];
    videoStatus = json['VideoStatus'];
    noteTakingGuideUrl = json['NoteTakingGuideUrl'];
    noteTakingGuideTitle = json['NoteTakingGuideTitle'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Id'] = this.id;
    data['SessionId'] = this.sessionId;
    data['Subtitle'] = this.subtitle;
    data['Description'] = this.description;
    data['ImageUrl'] = this.imageUrl;
    data['ImageData'] = this.imageData;
    data['VideoUrl'] = this.videoUrl;
    data['ArticleTitle'] = this.articleTitle;
    data['ArticleUrl'] = this.articleUrl;
    data['VideoName'] = this.videoName;
    data['AudioName'] = this.audioName;
    data['AudioUrl'] = this.audioUrl;
    data['ArticleTitle2'] = this.articleTitle2;
    data['ArticleUrl2'] = this.articleUrl2;
    data['VideoStatus'] = this.videoStatus;
    data['NoteTakingGuideUrl'] = this.noteTakingGuideUrl;
    data['NoteTakingGuideTitle'] = this.noteTakingGuideTitle;
    return data;
  }


}

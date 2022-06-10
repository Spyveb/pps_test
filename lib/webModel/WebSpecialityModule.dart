
class WebSpecialityModule {
  Title? title;
  Acf? acf;

  WebSpecialityModule({this.title, this.acf});

  WebSpecialityModule.fromJson(Map<String, dynamic> json) {
    title = json['title'] != null ? new Title.fromJson(json['title']) : null;
    acf = json['acf'] != null ? new Acf.fromJson(json['acf']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.title != null) {
      data['title'] = this.title!.toJson();
    }
    if (this.acf != null) {
      data['acf'] = this.acf!.toJson();
    }
    return data;
  }
}

class Title {
  String? rendered;

  Title({this.rendered});

  Title.fromJson(Map<String, dynamic> json) {
    rendered = json['rendered'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['rendered'] = this.rendered;
    return data;
  }
}

class Acf {
  AppImage? appImage;
  String? appContent;
  String? appVideo;
  String? appNoteTakingGuide;
  String? appMp3;
  String? appHelpfulResources;

  Acf(
      {this.appImage,
        this.appContent,
        this.appVideo,
        this.appNoteTakingGuide,
        this.appMp3,
        this.appHelpfulResources});

  Acf.fromJson(Map<String, dynamic> json) {
    appImage = json['app_image'] != null
        ? new AppImage.fromJson(json['app_image'])
        : null;
    appContent = json['app_content'];
    appVideo = json['app_video'];
    appNoteTakingGuide = json['app_note_taking_guide'];
    appMp3 = json['app_mp3'];
    appHelpfulResources = json['app_helpful_resources'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.appImage != null) {
      data['app_image'] = this.appImage!.toJson();
    }
    data['app_content'] = this.appContent;
    data['app_video'] = this.appVideo;
    data['app_note_taking_guide'] = this.appNoteTakingGuide;
    data['app_mp3'] = this.appMp3;
    data['app_helpful_resources'] = this.appHelpfulResources;
    return data;
  }
}

class AppImage {
  String? url;

  AppImage({this.url});

  AppImage.fromJson(Map<String, dynamic> json) {
    url = json['url'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['url'] = this.url;
    return data;
  }
}

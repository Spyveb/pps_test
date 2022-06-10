class Subtab {
  int? id;
  int? interactiveId;
  int? faqId;
  String? title;
  String? content;
  int? toolboxId;

  Subtab(
      {this.id,
        this.interactiveId,
        this.faqId,
        this.title,
        this.content,
        this.toolboxId});

  Subtab.fromJson(Map<String, dynamic> json) {
    id = json['Id'];
    interactiveId = json['InteractiveId'];
    faqId = json['FaqId'];
    title = json['Title'];
    content = json['Content'];
    toolboxId = json['ToolboxId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Id'] = this.id;
    data['InteractiveId'] = this.interactiveId;
    data['FaqId'] = this.faqId;
    data['Title'] = this.title;
    data['Content'] = this.content;
    data['ToolboxId'] = this.toolboxId;
    return data;
  }
}

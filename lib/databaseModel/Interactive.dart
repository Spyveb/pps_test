class Interactive {
  int? id;
  int? subsessionId;
  int? isAssessment;
  String? title;
  int? interactiveTypeId;

  Interactive(
      {this.id,
        this.subsessionId,
        this.isAssessment,
        this.title,
        this.interactiveTypeId});

  Interactive.fromJson(Map<String, dynamic> json) {
    id = json['Id'];
    subsessionId = json['SubsessionId'];
    isAssessment = json['IsAssessment'];
    title = json['Title'];
    interactiveTypeId = json['InteractiveTypeId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Id'] = this.id;
    data['SubsessionId'] = this.subsessionId;
    data['IsAssessment'] = this.isAssessment;
    data['Title'] = this.title;
    data['InteractiveTypeId'] = this.interactiveTypeId;
    return data;
  }
}

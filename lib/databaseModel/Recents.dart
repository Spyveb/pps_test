class Recents {
  int? id;
  int? SessionId;
  int? SubsessionId;
  int? Timestamp;


  Recents(this.id, this.SessionId, this.SubsessionId, this.Timestamp);

  Recents.fromJson(Map<String, dynamic> json) {
    id = json['Id'];
    SessionId = json['SessionId'];
    SubsessionId = json['SubsessionId'];
    Timestamp = json['Timestamp'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Id'] = this.id;
    data['SessionId'] = this.SessionId;
    data['SubsessionId'] = this.SubsessionId;
    data['Timestamp'] = this.Timestamp;
    return data;
  }
}

class sqlite_sequence {
  String? name;
  int? seq;

  sqlite_sequence({this.name, this.seq});

  sqlite_sequence.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    seq = json['seq'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['seq'] = this.seq;
    return data;
  }
}

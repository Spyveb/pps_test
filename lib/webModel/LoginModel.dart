class LoginModel {
  bool? ok;
  int? userId;
  String? name;
  String? nameF;
  String? nameL;
  String? email;
  String? login;
  String? msg;
  Subscriptions? subscriptions;
  Categories? categories;
  List<Null>? groups;
  List<String>? resources;
  int? memberShipLevel;
  String? subscription;

  static bool isBonus = false;
  static bool isSubscriptionForAudio = false;
  static bool isGoldUser = false;
  static bool isSilverUser = false;
  static bool isBronzeUser = false;
  static int userLevel = 0;
  static bool userAbleToPlayAudio = false;

  LoginModel(
      {this.ok,
      this.userId,
      this.name,
      this.nameF,
      this.nameL,
      this.email,
      this.login,
      this.subscriptions,
      this.categories,
      this.groups,
      this.resources,
      this.msg});

  LoginModel.fromJson(Map<String, dynamic> json) {
    ok = json['ok'];
    userId = json['user_id'];
    name = json['name'];
    nameF = json['name_f'];
    nameL = json['name_l'];
    email = json['email'];
    login = json['login'];
    msg = json['msg'];

    if(json['subscriptions'].runtimeType.toString() == 'List<dynamic>' || json['subscriptions'].runtimeType.toString() == '_GrowableList<dynamic>'){
      List? list = json['subscriptions'].cast<List>();

      subscriptions = json['subscriptions'] != null && list!.length > 0
          ? new Subscriptions.fromJson(json['subscriptions'])
          : null;
    } else {
      subscriptions = json['subscriptions'] != null
          ? new Subscriptions.fromJson(json['subscriptions'])
          : null;
    }

    if(json['categories'].runtimeType.toString() == 'List<dynamic>' || json['subscriptions'].runtimeType.toString() == '_GrowableList<dynamic>'){
      List? list = json['categories'].cast<List>();

      categories = json['categories'] != null && list!.length > 0
          ? new Categories.fromJson(json['categories'])
          : null;
    } else {
      categories = json['categories'] != null
          ? new Categories.fromJson(json['categories'])
          : null;
    }

    if (json['resources'] != null) resources = json['resources'].cast<String>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['ok'] = this.ok;
    data['user_id'] = this.userId;
    data['name'] = this.name;
    data['name_f'] = this.nameF;
    data['name_l'] = this.nameL;
    data['email'] = this.email;
    data['login'] = this.login;
    if (this.subscriptions != null) {
      data['subscriptions'] = this.subscriptions;
    }
    if (this.categories != null) {
      data['categories'] = this.categories;
    }
    data['resources'] = this.resources;
    return data;
  }
}

class Subscriptions {
  Map<String, dynamic>? sub;

  Subscriptions.fromJson(Map<String, dynamic>? json) {
    sub = json;
  }
}

class Categories {
  Map<String, dynamic>? userLevel;

  Categories.fromJson(Map<String, dynamic>? json) {
    userLevel = json;
  }
}

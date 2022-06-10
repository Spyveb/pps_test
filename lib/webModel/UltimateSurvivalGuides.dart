class UltimateSurvivalGuides {
  int? iD;
  String? name;
  String? slug;
  String? description;
  int? count;
  List<Items>? items;
  Meta? meta;
  bool isExpanded = false;

  UltimateSurvivalGuides(
      {this.iD,
        this.name,
        this.slug,
        this.description,
        this.count,
        this.items,
        this.meta});

  UltimateSurvivalGuides.fromJson(Map<String, dynamic> json) {
    iD = json['ID'];
    name = json['name'];
    slug = json['slug'];
    description = json['description'];
    count = json['count'];
    if (json['items'] != null) {
      items = [];
      json['items'].forEach((v) {
        items!.add(new Items.fromJson(v));
      });
    }
    meta = json['meta'] != null ? new Meta.fromJson(json['meta']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['ID'] = this.iD;
    data['name'] = this.name;
    data['slug'] = this.slug;
    data['description'] = this.description;
    data['count'] = this.count;
    if (this.items != null) {
      data['items'] = this.items!.map((v) => v.toJson()).toList();
    }
    if (this.meta != null) {
      data['meta'] = this.meta!.toJson();
    }
    return data;
  }
}

class Items {
  int? id;
  int? order;
  int? parent;
  String? title;
  String? url;
  String? attr;
  String? target;
  String? classes;
  String? xfn;
  String? description;
  int? objectId;
  String? object;
  String? objectSlug;
  String? type;
  String? typeLabel;

  Items(
      {this.id,
        this.order,
        this.parent,
        this.title,
        this.url,
        this.attr,
        this.target,
        this.classes,
        this.xfn,
        this.description,
        this.objectId,
        this.object,
        this.objectSlug,
        this.type,
        this.typeLabel});

  Items.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    order = json['order'];
    parent = json['parent'];
    title = json['title'];
    url = json['url'];
    attr = json['attr'];
    target = json['target'];
    classes = json['classes'];
    xfn = json['xfn'];
    description = json['description'];
    objectId = json['object_id'];
    object = json['object'];
    objectSlug = json['object_slug'];
    type = json['type'];
    typeLabel = json['type_label'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['order'] = this.order;
    data['parent'] = this.parent;
    data['title'] = this.title;
    data['url'] = this.url;
    data['attr'] = this.attr;
    data['target'] = this.target;
    data['classes'] = this.classes;
    data['xfn'] = this.xfn;
    data['description'] = this.description;
    data['object_id'] = this.objectId;
    data['object'] = this.object;
    data['object_slug'] = this.objectSlug;
    data['type'] = this.type;
    data['type_label'] = this.typeLabel;
    return data;
  }
}

class Meta {
  Links? links;

  Meta({this.links});

  Meta.fromJson(Map<String, dynamic> json) {
    links = json['links'] != null ? new Links.fromJson(json['links']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.links != null) {
      data['links'] = this.links!.toJson();
    }
    return data;
  }
}

class Links {
  String? collection;
  String? self;

  Links({this.collection, this.self});

  Links.fromJson(Map<String, dynamic> json) {
    collection = json['collection'];
    self = json['self'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['collection'] = this.collection;
    data['self'] = this.self;
    return data;
  }
}

class BattleTested {
  int? iD;
  String? name;
  String? slug;
  String? description;
  int? count;
  List<Items>? items;
  bool isExpanded = false;

  BattleTested(
      {this.iD,
        this.name,
        this.slug,
        this.description,
        this.count,
        this.items});

  BattleTested.fromJson(Map<String, dynamic> json) {
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
  List<Children>? children;

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
        this.typeLabel,
        this.children});

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
    if (json['children'] != null) {
      children = [];
      json['children'].forEach((v) {
        children!.add(new Children.fromJson(v));
      });
    }
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
    if (this.children != null) {
      data['children'] = this.children!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Children {
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

  Children(
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

  Children.fromJson(Map<String, dynamic> json) {
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

class VideoTutorial {
  int? id;
  String? date;
  String? dateGmt;
  Guid? guid;
  String? modified;
  String? modifiedGmt;
  String? slug;
  String? status;
  String? type;
  String? link;
  Guid? title;
  int? parent;
  int? menuOrder;
  String? template;
  List<int>? videoCategory;
  String? yoastHead;
  YoastHeadJson? yoastHeadJson;
  Acf? acf;
  Links? lLinks;

  VideoTutorial(
      {this.id,
        this.date,
        this.dateGmt,
        this.guid,
        this.modified,
        this.modifiedGmt,
        this.slug,
        this.status,
        this.type,
        this.link,
        this.title,
        this.parent,
        this.menuOrder,
        this.template,
        this.videoCategory,
        this.yoastHead,
        this.yoastHeadJson,
        this.acf,
        this.lLinks});

  VideoTutorial.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    date = json['date'];
    dateGmt = json['date_gmt'];
    guid = json['guid'] != null ? new Guid.fromJson(json['guid']) : null;
    modified = json['modified'];
    modifiedGmt = json['modified_gmt'];
    slug = json['slug'];
    status = json['status'];
    type = json['type'];
    link = json['link'];
    title = json['title'] != null ? new Guid.fromJson(json['title']) : null;
    parent = json['parent'];
    menuOrder = json['menu_order'];
    template = json['template'];
    videoCategory = json['video_category'].cast<int>();
    yoastHead = json['yoast_head'];
    yoastHeadJson = json['yoast_head_json'] != null
        ? new YoastHeadJson.fromJson(json['yoast_head_json'])
        : null;
    acf = json['acf'] != null ? new Acf.fromJson(json['acf']) : null;
    lLinks = json['_links'] != null ? new Links.fromJson(json['_links']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['date'] = this.date;
    data['date_gmt'] = this.dateGmt;
    if (this.guid != null) {
      data['guid'] = this.guid!.toJson();
    }
    data['modified'] = this.modified;
    data['modified_gmt'] = this.modifiedGmt;
    data['slug'] = this.slug;
    data['status'] = this.status;
    data['type'] = this.type;
    data['link'] = this.link;
    if (this.title != null) {
      data['title'] = this.title!.toJson();
    }
    data['parent'] = this.parent;
    data['menu_order'] = this.menuOrder;
    data['template'] = this.template;
    data['video_category'] = this.videoCategory;
    data['yoast_head'] = this.yoastHead;
    if (this.yoastHeadJson != null) {
      data['yoast_head_json'] = this.yoastHeadJson!.toJson();
    }
    if (this.acf != null) {
      data['acf'] = this.acf!.toJson();
    }
    if (this.lLinks != null) {
      data['_links'] = this.lLinks!.toJson();
    }
    return data;
  }
}

class Guid {
  String? rendered;

  Guid({this.rendered});

  Guid.fromJson(Map<String, dynamic> json) {
    rendered = json['rendered'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['rendered'] = this.rendered;
    return data;
  }
}

class YoastHeadJson {
  String? title;
  Robots? robots;
  String? canonical;
  String? ogLocale;
  String? ogType;
  String? ogTitle;
  String? ogUrl;
  String? ogSiteName;
  String? articleModifiedTime;
  Schema? schema;

  YoastHeadJson(
      {this.title,
        this.robots,
        this.canonical,
        this.ogLocale,
        this.ogType,
        this.ogTitle,
        this.ogUrl,
        this.ogSiteName,
        this.articleModifiedTime,
        this.schema});

  YoastHeadJson.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    robots =
    json['robots'] != null ? new Robots.fromJson(json['robots']) : null;
    canonical = json['canonical'];
    ogLocale = json['og_locale'];
    ogType = json['og_type'];
    ogTitle = json['og_title'];
    ogUrl = json['og_url'];
    ogSiteName = json['og_site_name'];
    articleModifiedTime = json['article_modified_time'];
    schema =
    json['schema'] != null ? new Schema.fromJson(json['schema']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['title'] = this.title;
    if (this.robots != null) {
      data['robots'] = this.robots!.toJson();
    }
    data['canonical'] = this.canonical;
    data['og_locale'] = this.ogLocale;
    data['og_type'] = this.ogType;
    data['og_title'] = this.ogTitle;
    data['og_url'] = this.ogUrl;
    data['og_site_name'] = this.ogSiteName;
    data['article_modified_time'] = this.articleModifiedTime;
    if (this.schema != null) {
      data['schema'] = this.schema!.toJson();
    }
    return data;
  }
}

class Robots {
  String? index;
  String? follow;
  String? maxSnippet;
  String? maxImagePreview;
  String? maxVideoPreview;

  Robots(
      {this.index,
        this.follow,
        this.maxSnippet,
        this.maxImagePreview,
        this.maxVideoPreview});

  Robots.fromJson(Map<String, dynamic> json) {
    index = json['index'];
    follow = json['follow'];
    maxSnippet = json['max-snippet'];
    maxImagePreview = json['max-image-preview'];
    maxVideoPreview = json['max-video-preview'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['index'] = this.index;
    data['follow'] = this.follow;
    data['max-snippet'] = this.maxSnippet;
    data['max-image-preview'] = this.maxImagePreview;
    data['max-video-preview'] = this.maxVideoPreview;
    return data;
  }
}

class Schema {
  String? context;
  List<Graph>? graph;

  Schema({this.context, this.graph});

  Schema.fromJson(Map<String, dynamic> json) {
    context = json['@context'];
    if (json['@graph'] != null) {
      graph = [];
      json['@graph'].forEach((v) {
        graph!.add(new Graph.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['@context'] = this.context;
    if (this.graph != null) {
      data['@graph'] = this.graph!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Graph {
  String? type;
  String? id;
  String? url;
  String? name;
  String? description;
  List<PotentialAction>? potentialAction;
  String? inLanguage;
  IsPartOf? isPartOf;
  String? datePublished;
  String? dateModified;
  IsPartOf? breadcrumb;
  List<ItemListElement>? itemListElement;

  Graph(
      {this.type,
        this.id,
        this.url,
        this.name,
        this.description,
        this.potentialAction,
        this.inLanguage,
        this.isPartOf,
        this.datePublished,
        this.dateModified,
        this.breadcrumb,
        this.itemListElement});

  Graph.fromJson(Map<String, dynamic> json) {
    type = json['@type'];
    id = json['@id'];
    url = json['url'];
    name = json['name'];
    description = json['description'];
    if (json['potentialAction'] != null) {
      potentialAction = [];
      json['potentialAction'].forEach((v) {
        potentialAction!.add(new PotentialAction.fromJson(v));
      });
    }
    inLanguage = json['inLanguage'];
    isPartOf = json['isPartOf'] != null
        ? new IsPartOf.fromJson(json['isPartOf'])
        : null;
    datePublished = json['datePublished'];
    dateModified = json['dateModified'];
    breadcrumb = json['breadcrumb'] != null
        ? new IsPartOf.fromJson(json['breadcrumb'])
        : null;
    if (json['itemListElement'] != null) {
      itemListElement = [];
      json['itemListElement'].forEach((v) {
        itemListElement!.add(new ItemListElement.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['@type'] = this.type;
    data['@id'] = this.id;
    data['url'] = this.url;
    data['name'] = this.name;
    data['description'] = this.description;
    if (this.potentialAction != null) {
      data['potentialAction'] =
          this.potentialAction!.map((v) => v.toJson()).toList();
    }
    data['inLanguage'] = this.inLanguage;
    if (this.isPartOf != null) {
      data['isPartOf'] = this.isPartOf!.toJson();
    }
    data['datePublished'] = this.datePublished;
    data['dateModified'] = this.dateModified;
    if (this.breadcrumb != null) {
      data['breadcrumb'] = this.breadcrumb!.toJson();
    }
    if (this.itemListElement != null) {
      data['itemListElement'] =
          this.itemListElement!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class PotentialAction {
  String? type;
  String? queryInput;

  PotentialAction({this.type, this.queryInput});

  PotentialAction.fromJson(Map<String, dynamic> json) {
    type = json['@type'];
    queryInput = json['query-input'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['@type'] = this.type;
    data['query-input'] = this.queryInput;
    return data;
  }
}

class IsPartOf {
  String? id;

  IsPartOf({this.id});

  IsPartOf.fromJson(Map<String, dynamic> json) {
    id = json['@id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['@id'] = this.id;
    return data;
  }
}

class ItemListElement {
  String? type;
  int? position;
  String? name;
  String? item;

  ItemListElement({this.type, this.position, this.name, this.item});

  ItemListElement.fromJson(Map<String, dynamic> json) {
    type = json['@type'];
    position = json['position'];
    name = json['name'];
    item = json['item'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['@type'] = this.type;
    data['position'] = this.position;
    data['name'] = this.name;
    data['item'] = this.item;
    return data;
  }
}

class Acf {
  String? vimeoLink;

  Acf({this.vimeoLink});

  Acf.fromJson(Map<String, dynamic> json) {
    vimeoLink = json['vimeo_link'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['vimeo_link'] = this.vimeoLink;
    return data;
  }
}

class Links {
  List<Self>? self;
  List<Collection>? collection;
  List<About>? about;
  List<WpTerm>? wpTerm;
  List<Curies>? curies;

  Links(
      {this.self,
        this.collection,
        this.about,
        this.wpTerm,
        this.curies});

  Links.fromJson(Map<String, dynamic> json) {
    if (json['self'] != null) {
      self = [];
      json['self'].forEach((v) {
        self!.add(new Self.fromJson(v));
      });
    }
    if (json['collection'] != null) {
      collection = [];
      json['collection'].forEach((v) {
        collection!.add(new Collection.fromJson(v));
      });
    }
    if (json['about'] != null) {
      about = [];
      json['about'].forEach((v) {
        about!.add(new About.fromJson(v));
      });
    }

    if (json['wp:term'] != null) {
      wpTerm = [];
      json['wp:term'].forEach((v) {
        wpTerm!.add(new WpTerm.fromJson(v));
      });
    }
    if (json['curies'] != null) {
      curies = [];
      json['curies'].forEach((v) {
        curies!.add(new Curies.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.self != null) {
      data['self'] = this.self!.map((v) => v.toJson()).toList();
    }
    if (this.collection != null) {
      data['collection'] = this.collection!.map((v) => v.toJson()).toList();
    }
    if (this.about != null) {
      data['about'] = this.about!.map((v) => v.toJson()).toList();
    }

    if (this.wpTerm != null) {
      data['wp:term'] = this.wpTerm!.map((v) => v.toJson()).toList();
    }
    if (this.curies != null) {
      data['curies'] = this.curies!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class About {
  String? href;

  About({this.href});

  About.fromJson(Map<String, dynamic> json) {
    href = json['href'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['href'] = this.href;
    return data;
  }
}

class Collection {
  String? href;

  Collection({this.href});

  Collection.fromJson(Map<String, dynamic> json) {
    href = json['href'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['href'] = this.href;
    return data;
  }
}

class Self {
  String? href;

  Self({this.href});

  Self.fromJson(Map<String, dynamic> json) {
    href = json['href'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['href'] = this.href;
    return data;
  }
}

class WpTerm {
  String? taxonomy;
  bool? embeddable;
  String? href;

  WpTerm({this.taxonomy, this.embeddable, this.href});

  WpTerm.fromJson(Map<String, dynamic> json) {
    taxonomy = json['taxonomy'];
    embeddable = json['embeddable'];
    href = json['href'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['taxonomy'] = this.taxonomy;
    data['embeddable'] = this.embeddable;
    data['href'] = this.href;
    return data;
  }
}

class Curies {
  String? name;
  String? href;
  bool? templated;

  Curies({this.name, this.href, this.templated});

  Curies.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    href = json['href'];
    templated = json['templated'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['href'] = this.href;
    data['templated'] = this.templated;
    return data;
  }
}

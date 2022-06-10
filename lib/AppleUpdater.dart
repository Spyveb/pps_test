class AppleUpdater {
  int? resultCount;
  List<Results>? results;

  AppleUpdater({this.resultCount, this.results});

  AppleUpdater.fromJson(Map<String, dynamic> json) {
    resultCount = json['resultCount'];
    if (json['results'] != null) {
      results = [];
      json['results'].forEach((v) {
        results!.add(new Results.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['resultCount'] = this.resultCount;
    if (this.results != null) {
      data['results'] = this.results!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Results {
  bool? isGameCenterEnabled;
  List<String>? screenshotUrls;
  List<String>? ipadScreenshotUrls;
  List<Null>? appletvScreenshotUrls;
  String? artworkUrl60;
  String? artworkUrl512;
  String? artworkUrl100;
  String? artistViewUrl;
  List<String>? supportedDevices;
  List<String>? advisories;
  List<String>? features;
  String? kind;
  String? trackCensoredName;
  List<String>? languageCodesISO2A;
  String? fileSizeBytes;
  String? sellerUrl;
  String? contentAdvisoryRating;
  double? averageUserRatingForCurrentVersion;
  int? userRatingCountForCurrentVersion;
  double? averageUserRating;
  String? trackViewUrl;
  String? trackContentRating;
  int? trackId;
  String? trackName;
  String? releaseDate;
  String? releaseNotes;
  List<String>? genreIds;
  String? formattedPrice;
  String? primaryGenreName;
  String? minimumOsVersion;
  bool? isVppDeviceBasedLicensingEnabled;
  String? sellerName;
  int? primaryGenreId;
  String? currency;
  int? artistId;
  String? artistName;
  List<String>? genres;
  double? price;
  String? description;
  String? bundleId;
  String? currentVersionReleaseDate;
  String? version;
  String? wrapperType;
  int? userRatingCount;

  Results(
      {this.isGameCenterEnabled,
        this.screenshotUrls,
        this.ipadScreenshotUrls,
        this.appletvScreenshotUrls,
        this.artworkUrl60,
        this.artworkUrl512,
        this.artworkUrl100,
        this.artistViewUrl,
        this.supportedDevices,
        this.advisories,
        this.features,
        this.kind,
        this.trackCensoredName,
        this.languageCodesISO2A,
        this.fileSizeBytes,
        this.sellerUrl,
        this.contentAdvisoryRating,
        this.averageUserRatingForCurrentVersion,
        this.userRatingCountForCurrentVersion,
        this.averageUserRating,
        this.trackViewUrl,
        this.trackContentRating,
        this.trackId,
        this.trackName,
        this.releaseDate,
        this.releaseNotes,
        this.genreIds,
        this.formattedPrice,
        this.primaryGenreName,
        this.minimumOsVersion,
        this.isVppDeviceBasedLicensingEnabled,
        this.sellerName,
        this.primaryGenreId,
        this.currency,
        this.artistId,
        this.artistName,
        this.genres,
        this.price,
        this.description,
        this.bundleId,
        this.currentVersionReleaseDate,
        this.version,
        this.wrapperType,
        this.userRatingCount});

  Results.fromJson(Map<String, dynamic> json) {
    isGameCenterEnabled = json['isGameCenterEnabled'];
    screenshotUrls = json['screenshotUrls'].cast<String>();
    ipadScreenshotUrls = json['ipadScreenshotUrls'].cast<String>();
    if (json['appletvScreenshotUrls'] != null) {
      appletvScreenshotUrls = [];
    }
    artworkUrl60 = json['artworkUrl60'];
    artworkUrl512 = json['artworkUrl512'];
    artworkUrl100 = json['artworkUrl100'];
    artistViewUrl = json['artistViewUrl'];
    supportedDevices = json['supportedDevices'].cast<String>();
    advisories = json['advisories'].cast<String>();
    features = json['features'].cast<String>();
    kind = json['kind'];
    trackCensoredName = json['trackCensoredName'];
    languageCodesISO2A = json['languageCodesISO2A'].cast<String>();
    fileSizeBytes = json['fileSizeBytes'];
    sellerUrl = json['sellerUrl'];
    contentAdvisoryRating = json['contentAdvisoryRating'];
    averageUserRatingForCurrentVersion =
    json['averageUserRatingForCurrentVersion'];
    userRatingCountForCurrentVersion = json['userRatingCountForCurrentVersion'];
    averageUserRating = json['averageUserRating'];
    trackViewUrl = json['trackViewUrl'];
    trackContentRating = json['trackContentRating'];
    trackId = json['trackId'];
    trackName = json['trackName'];
    releaseDate = json['releaseDate'];
    releaseNotes = json['releaseNotes'];
    genreIds = json['genreIds'].cast<String>();
    formattedPrice = json['formattedPrice'];
    primaryGenreName = json['primaryGenreName'];
    minimumOsVersion = json['minimumOsVersion'];
    isVppDeviceBasedLicensingEnabled = json['isVppDeviceBasedLicensingEnabled'];
    sellerName = json['sellerName'];
    primaryGenreId = json['primaryGenreId'];
    currency = json['currency'];
    artistId = json['artistId'];
    artistName = json['artistName'];
    genres = json['genres'].cast<String>();
    price = json['price'];
    description = json['description'];
    bundleId = json['bundleId'];
    currentVersionReleaseDate = json['currentVersionReleaseDate'];
    version = json['version'];
    wrapperType = json['wrapperType'];
    userRatingCount = json['userRatingCount'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['isGameCenterEnabled'] = this.isGameCenterEnabled;
    data['screenshotUrls'] = this.screenshotUrls;
    data['ipadScreenshotUrls'] = this.ipadScreenshotUrls;
    data['artworkUrl60'] = this.artworkUrl60;
    data['artworkUrl512'] = this.artworkUrl512;
    data['artworkUrl100'] = this.artworkUrl100;
    data['artistViewUrl'] = this.artistViewUrl;
    data['supportedDevices'] = this.supportedDevices;
    data['advisories'] = this.advisories;
    data['features'] = this.features;
    data['kind'] = this.kind;
    data['trackCensoredName'] = this.trackCensoredName;
    data['languageCodesISO2A'] = this.languageCodesISO2A;
    data['fileSizeBytes'] = this.fileSizeBytes;
    data['sellerUrl'] = this.sellerUrl;
    data['contentAdvisoryRating'] = this.contentAdvisoryRating;
    data['averageUserRatingForCurrentVersion'] =
        this.averageUserRatingForCurrentVersion;
    data['userRatingCountForCurrentVersion'] =
        this.userRatingCountForCurrentVersion;
    data['averageUserRating'] = this.averageUserRating;
    data['trackViewUrl'] = this.trackViewUrl;
    data['trackContentRating'] = this.trackContentRating;
    data['trackId'] = this.trackId;
    data['trackName'] = this.trackName;
    data['releaseDate'] = this.releaseDate;
    data['releaseNotes'] = this.releaseNotes;
    data['genreIds'] = this.genreIds;
    data['formattedPrice'] = this.formattedPrice;
    data['primaryGenreName'] = this.primaryGenreName;
    data['minimumOsVersion'] = this.minimumOsVersion;
    data['isVppDeviceBasedLicensingEnabled'] =
        this.isVppDeviceBasedLicensingEnabled;
    data['sellerName'] = this.sellerName;
    data['primaryGenreId'] = this.primaryGenreId;
    data['currency'] = this.currency;
    data['artistId'] = this.artistId;
    data['artistName'] = this.artistName;
    data['genres'] = this.genres;
    data['price'] = this.price;
    data['description'] = this.description;
    data['bundleId'] = this.bundleId;
    data['currentVersionReleaseDate'] = this.currentVersionReleaseDate;
    data['version'] = this.version;
    data['wrapperType'] = this.wrapperType;
    data['userRatingCount'] = this.userRatingCount;
    return data;
  }
}

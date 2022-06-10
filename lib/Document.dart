class Document {
  bool? _isHeading;
  String? documentName;
  String? documentUrl;
  String? sectionHeading;

  Document(bool isHeading, String? documentName, String? documentUrl, String? sectionHeading) {
    this._isHeading = isHeading;
    this.documentName = documentName;
    this.documentUrl = documentUrl;
    this.sectionHeading = sectionHeading;
  }

  bool? isHeading() {
    return _isHeading;
  }

  void setHeading(bool heading) {
    _isHeading = heading;
  }

  String? getDocumentName() {
    return documentName;
  }

  void setDocumentName(String documentName) {
    this.documentName = documentName;
  }

  String? getDocumentUrl() {
    return documentUrl;
  }

  void setDocumentUrl(String documentUrl) {
    this.documentUrl = documentUrl;
  }

  String? getSectionHeading() {
    return sectionHeading;
  }

  void setSectionHeading(String sectionHeading) {
    this.sectionHeading = sectionHeading;
  }
}
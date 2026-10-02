class unitModel {
  String? Code;

  unitModel({
    this.Code,
    // this.Line_No,
  });

  unitModel.fromJson(Map<String, dynamic> json) {
    Code = json['Code'];
  }
}

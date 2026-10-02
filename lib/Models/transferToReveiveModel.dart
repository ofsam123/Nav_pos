class TransferToRevieveModel {
  String? Transfer_from_Code;
  String? No;
  String? Transfer_to_Code;
  String? Responsibility_Center;
  String? Posting_Date;
  String? POS_Status;

  TransferToRevieveModel(
      {this.Transfer_from_Code, this.No, this.Posting_Date, this.POS_Status});

  TransferToRevieveModel.fromJson(Map<String, dynamic> json) {
    Transfer_from_Code = json['Transfer_from_Code'];
    No = json['No'];
    Transfer_to_Code = json['Transfer_to_Code'];
    Posting_Date = json['Posting_Date'];

    POS_Status = json['POS_Status'];
  }
}

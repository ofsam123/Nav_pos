class returnOrderModel {
  String? No;
  String? Description;
  String? Transfer_to_Code;
  String? Posting_Date;
  String? Items_Weight;
  String? Status;

  returnOrderModel({
    this.No,
    this.Description,
    this.Posting_Date,
    this.Transfer_to_Code,
    this.Items_Weight,
    this.Status,
  });

  returnOrderModel.fromJson(Map<String, dynamic> json) {
    No = json['No'];
    Description = json['Description'];
    Transfer_to_Code = json['Transfer_to_Code'];
    Posting_Date = json['Posting_Date'];
    Items_Weight = json['Items_Weight'];
    Status = json['Status'];
  }
}

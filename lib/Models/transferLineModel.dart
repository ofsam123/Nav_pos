class transferLineModel {
  String? Item_No;
  String? Receipt_Date;
  String? Assigned_User_ID;
  String? POS_Status;

  transferLineModel({
    this.Item_No,
    this.Receipt_Date,
    this.Assigned_User_ID,
    this.POS_Status,
  });

  transferLineModel.fromJson(Map<String, dynamic> json) {
    Item_No = json['Item_No'];
    Receipt_Date = json['Receipt_Date'];
    Assigned_User_ID = json['Assigned_User_ID'];
    POS_Status = json['POS_Status'];
  }
}

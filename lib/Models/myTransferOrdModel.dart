class tranOrdModel {
  String? No;
  String? Transfer_from_Code;
  String? DescriTransfer_to_Codeption_2;
  String? Shipment_Date;
  // int? Items_Weight;
  // String? Type;

  tranOrdModel({
    this.No,
    this.Transfer_from_Code,
    this.DescriTransfer_to_Codeption_2,
    this.Shipment_Date,
  });

  tranOrdModel.fromJson(Map<String, dynamic> json) {
    No = json['No'];
    Transfer_from_Code = json['Transfer_from_Code'];
    DescriTransfer_to_Codeption_2 = json['DescriTransfer_to_Codeption_2'];
    Shipment_Date = json['Shipment_Date'];
  }
}

class itemsModel2 {
  String? No;
  String? Description;
  String? Description_2;
  String? Search_Description;
  String? Base_Unit_of_Measure;
  String? Type;
  bool? Blocked;
  String? Item_Category_Code;
  String? Picture;
  // String? Net_Weight;
  // String? Gross_Weight;
  //

  // String? Unit_Volume;
  // String? Unit_Price;
  // String? Price_Includes_VAT;
  String? Sales_Unit_of_Measure;
  String? Item_Tracking_Code;
  String? Lot_Nos;
  String? Serial_Nos;
  String? Global_Dimension_1_Filter;
  String? Global_Dimension_2_Filter;
  String? Location_Filter;
  String? Drop_Shipment_Filter;
  String? Variant_Filter;
  String? Lot_No_Filter;
  String? Serial_No_Filter;

  itemsModel2({
    this.No,
    this.Description,
    this.Search_Description,
    this.Description_2,
    this.Base_Unit_of_Measure,
    this.Type,
    this.Blocked,
    this.Item_Category_Code,
    this.Picture,
    // this.Net_Weight,
    // this.Gross_Weight,
    // //

    // this.Unit_Volume,
    // this.Unit_Price,
    // this.Price_Includes_VAT,
    this.Sales_Unit_of_Measure,
    this.Item_Tracking_Code,
    this.Lot_Nos,
    this.Serial_Nos,
    this.Global_Dimension_1_Filter,
    this.Global_Dimension_2_Filter,
    this.Location_Filter,
    this.Drop_Shipment_Filter,
    this.Variant_Filter,
    this.Lot_No_Filter,
    this.Serial_No_Filter,
  });

  itemsModel2.fromJson(Map<String, dynamic> json) {
    No = json['No'];
    Description = json['Description'];
    Description_2 = json['Description_2'];
    Search_Description = json['Search_Description'];
    Base_Unit_of_Measure = json['Base_Unit_of_Measure'];
    Type = json['Type'];
    Blocked = json['Blocked'];
    Item_Category_Code = json['Item_Category_Code'];
    Picture = json['Picture'];
    // Net_Weight = json['Net_Weight'];
    // Gross_Weight = json['Gross_Weight'];
    // //
    // Unit_Volume = json['Unit_Volume'];
    // Unit_Price = json['Unit_Price'];
    // Price_Includes_VAT = json['Price_Includes_VAT'];
    Sales_Unit_of_Measure = json['Sales_Unit_of_Measure'];
    Item_Tracking_Code = json['Item_Tracking_Code'];
    Lot_Nos = json['Lot_Nos'];
    Serial_Nos = json['Serial_Nos'];
    Global_Dimension_1_Filter = json['Global_Dimension_1_Filter'];
    Global_Dimension_2_Filter = json['Global_Dimension_2_Filter'];
    Location_Filter = json['Location_Filter'];
    Drop_Shipment_Filter = json['Drop_Shipment_Filter'];
    Variant_Filter = json['Variant_Filter'];
    Lot_No_Filter = json['Lot_No_Filter'];
    Serial_No_Filter = json['Serial_No_Filter'];
  }
}

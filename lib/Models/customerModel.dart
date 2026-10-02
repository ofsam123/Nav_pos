class customerModel {
  String? No;
  String? Name;
  // String? Balance_LCY;
  // String? Balance_Due_LCY;
  String? Blocked;
  String? Salesperson_Code;
  // String? Blocked;
  String? Responsibility_Center;
  String? Phone_No;
  String? E_Mail;
  String? Home_Page;
  bool? Prices_Including_VAT;
  String? Primary_Contact_No;
  String? Picture;
  String? Global_Dimension_2_Filter;
  String? Global_Dimension_1_Filter;
  String? Currency_Filter;
  String? Date_Filter;

  customerModel({
    this.No,
    this.Name,
    this.Blocked,
    this.Salesperson_Code,
    this.Responsibility_Center,
    this.Phone_No,
    this.Picture,
    this.E_Mail,
    this.Prices_Including_VAT,
    this.Primary_Contact_No,
    this.Global_Dimension_1_Filter,
    this.Global_Dimension_2_Filter,
    this.Currency_Filter,
    this.Date_Filter,
  });

  customerModel.fromJson(Map<String, dynamic> json) {
    No = json['No'];
    Name = json['Name'];
    Blocked = json['Blocked'];
    Salesperson_Code = json['Salesperson_Code'];
    Responsibility_Center = json['Responsibility_Center'];
    Phone_No = json['Phone_No'];
    Picture = json['Picture@odata.mediaReadLink'];
    E_Mail = json['E_Mail'];

    Prices_Including_VAT = json['Prices_Including_VAT'];
    Primary_Contact_No = json['Primary_Contact_No'];
    Global_Dimension_1_Filter = json['Global_Dimension_1_Filter'];
    Global_Dimension_2_Filter = json['Global_Dimension_2_Filter'];
    Currency_Filter = json['Currency_Filter'];
    Date_Filter = json['Date_Filter'];
  }
}

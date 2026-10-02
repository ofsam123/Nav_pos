class ApiUrl {
//Dev
  static const String MainIP =
      "http://40.67.140.177:7048/DynamicsNAV110/ODataV4/Company('WAGCOL%20POS')/";
  static const String APIusername = "INTRANET" + r'\' + "NAV.CLOUD";
  static const String APIpassword =
      "Ek88JQH7tAFFqsbw7xxcl8S4X+Z+JY0py2gWqQMCAe8=";

//  Live
//   static const String Auth            = "711c73f64afdce07bA02";
//   static const String MainIP          = "";
//   static const String APIusername     = "";
//   static const String APIpassword     = "";

  static const String ItemAPI = MainIP + "ItemsAPI";
  static const String VisitationApi = MainIP + "VisitationAPI";

  static const String registerCustomer = MainIP + "CustomerAPI";
  static const String customerAPI =
      MainIP + "CustomerAPI?" + "\$" + "filter=Responsibility_Center eq '";
  static const String SalesHeaderAPI = MainIP + "SalesHeaderAPI";
  static const String SalesLineAPI = MainIP + "SalesLineAPI";

  static const String TransferHeaderAPI = MainIP + "TransferHeaderAPI";
  static const String TransferLineAPI = MainIP + "TransferLineAPI";
  static const String ResponsibilityCenterAPI =
      MainIP + "ResponsibilityCenterAPI?" + "\$filter=User_ID eq '";

  static const String userLogin = MainIP +
      "UserAPI?" +
      "\$" +
      "filter" +
      "=User_Name eq " +
      "'INTRANET" +
      r"\";

  static const String totalItemSold =
      MainIP + "SalesInvLineAPI?" + "\$filter=Location_Code eq ";
}

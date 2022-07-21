import 'package:base_lib/all.dart';

/// config table
// ignore_for_file: non_constant_identifier_names
class ConfigTab {
  String id; 
  int show_name;
  int show_work_date;
  int show_latitude;
  int show_longitude;
  int show_address;
  int show_location;
  int show_other1;
  int show_other2;
  int show_other3;
  String account;
  int login_radio;

  ConfigTab({
    this.id = '1', 
    this.show_name = 0,
    this.show_work_date = 0,
    this.show_latitude = 0,
    this.show_longitude = 0,
    this.show_address = 0,
    this.show_location = 0,
    this.show_other1 = 0,
    this.show_other2 = 0,
    this.show_other3 = 0,
    this.account = '',
    this.login_radio = 0
  });

  Map<String, Object> toJson() {
    return {
      'id': id, 
      'show_name': show_name,
      'show_work_date': show_work_date,
      'show_latitude': show_latitude,
      'show_longitude': show_longitude,
      'show_address': show_address,
      'show_location': show_location,
      'show_other1': show_other1,
      'show_other2': show_other2,
      'show_other3': show_other3,
      'account': account,
      'login_radio': login_radio,
    };
  }

  ///convert json to model, static for be parameter !!
  static ConfigTab fromJson(Map<String, dynamic> json){
    return ConfigTab(
      id: json['id'], 
      show_name: json['show_name'] ?? 0,
      show_work_date: json['show_work_date'] ?? 0,
      show_latitude: json['show_latitude'] ?? 0,
      show_longitude: json['show_longitude'] ?? 0,
      show_address: json['show_address'] ?? 0,
      show_location: json['show_location'] ?? 0,
      show_other1: json['show_other1'] ?? 0,
      show_other2: json['show_other2'] ?? 0,
      show_other3: json['show_other3'] ?? 0,
      account: json['account'] ?? '',
      login_radio: json['login_radio'] ?? 0,      
    );    
  }
  
  static Future<Map<String, dynamic>?> getJsonAsync() async {
    return await DbUt.getJsonAsync("select * from config where id='1'");
  }

  static Future<ConfigTab?> getAsync() async {
    var map = await getJsonAsync();
    return (map == null)
      ? null
      : fromJson(map);
  }

  static Future<bool> insertAsync(ConfigTab row) async {
    if (StrUt.isEmpty(row.id)){
      row.id = '1';
    }
    return await DbUt.insertAsync('config', row.toJson());
  }

  static Future<bool> updateAsync(ConfigTab row) async {
    return await DbUt.updateAsync('config', row.toJson(), 'id=?', ['1']);
  }

}//class
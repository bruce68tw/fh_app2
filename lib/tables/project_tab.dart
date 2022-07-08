import 'package:base_lib/all.dart';

/// project table
// ignore_for_file: non_constant_identifier_names

class ProjectTab {
  String id; 
  String name;
  String? work_order_no;
  int save_flag;
  String? area_id;
  String work_class_id;
  String? work_dispatch_id;
  String? close_reason_id;
  String? close_reason_detail_id;
  String? latitude;
  String? longitude;
  String? work_date;
  String? address;
  String? location;
  String? signal;
  String? note;
  String? other1;
  String? other2;
  String? other3;

  ProjectTab({
    required this.id, 
    required this.name,
    this.work_order_no,
    required this.save_flag,
    this.area_id,
    required this.work_class_id,
    this.work_dispatch_id,
    this.close_reason_id,
    this.close_reason_detail_id,
    this.latitude,
    this.longitude,
    this.work_date,
    this.address,
    this.location,
    this.signal,
    this.note,
    this.other1,
    this.other2,
    this.other3
  });

  /// entity to map
  /// 必須使用 toJson 這個名稱, 否則執行 jsonEncode() 時會出現 JsonUnsupportedObjectError !!
  Map<String, Object> toJson() {
    return {
      'id': id, 
      'name': name,
      'work_order_no': work_order_no ?? '',
      'save_flag': save_flag,
      'area_id': area_id ?? '',
      'work_class_id': work_class_id,
      'work_dispatch_id': work_dispatch_id ?? '',
      'close_reason_id': close_reason_id ?? '',
      'close_reason_detail_id': close_reason_detail_id ?? '',
      'latitude': latitude ?? '',
      'longitude': longitude ?? '',
      'work_date': work_date ?? '',
      'address': address ?? '',
      'location': location ?? '',
      'signal': signal ?? '',
      'note': note ?? '',
      'other1': other1 ?? '',
      'other2': other2 ?? '',
      'other3': other3 ?? ''
    };
  }

  Map<String, Object> toServerJson() {
    return {
      'Id': id, 
      'Name': name,
      'WorkOrderNo': work_order_no ?? '',
      //'save_flag': save_flag,
      'AreaId': area_id ?? '',
      'WorkClassId': work_class_id,
      'WorkDispatchId': work_dispatch_id ?? '',
      'CloseReasonId': close_reason_id ?? '',
      'CloseReasonDetailId': close_reason_detail_id ?? '',
      'Latitude': latitude ?? '',
      'Longitude': longitude ?? '',
      'WorkDate': work_date ?? '',
      'Address': address ?? '',
      'Location': location ?? '',
      'Signal': signal ?? '',
      'Note': note ?? '',
      'Other1': other1 ?? '',
      'Other2': other2 ?? '',
      'Other3': other3 ?? ''
    };
  }

  ///convert json to model, static for be parameter !!
  static ProjectTab fromJson(Map<String, dynamic> json){
    return ProjectTab(
      id: json['id'], 
      name: json['name'],
      work_order_no: json['work_order_no'] ?? '',
      save_flag: json['save_flag'] ?? 0,
      area_id: json['area_id'] ?? '',
      work_class_id: json['work_class_id'],
      work_dispatch_id: json['work_dispatch_id'] ?? '',
      close_reason_id: json['close_reason_id'] ?? '',
      close_reason_detail_id: json['close_reason_detail_id'] ?? '',
      latitude: json['latitude'].toString(),
      longitude: json['longitude'].toString(),
      work_date: json['work_date'] ?? '',
      address: json['address'] ?? '',
      location: json['location'] ?? '',
      signal: json['signal'] ?? '',
      note: json['note'] ?? '',
      other1: json['other1'] ?? '',
      other2: json['other2'] ?? '',
      other3: json['other3'] ?? ''
    );    
  }

  /// convert json to model, static for be parameter !!
  /// 後端傳回額外時間字串 WorkDate2
  static ProjectTab fromServerJson(Map<String, dynamic> json){
    var a = json['a'];
    return ProjectTab(
      id: a['Id'], 
      name: a['Name'] ?? '',
      work_order_no: a['WorkOrderNo'] ?? '',
      save_flag: 0,
      area_id: a['AreaId'] ?? '',
      work_class_id: a['WorkClassId'],
      work_dispatch_id: a['WorkDispatchId'] ?? '',
      close_reason_id: a['CloseReasonId'] ?? '',
      close_reason_detail_id: a['CloseReasonDetailId'] ?? '',
      latitude: a['Latitude'].toString(),
      longitude: a['Longitude'].toString(),
      address: a['Address'] ?? '',
      location: a['Location'] ?? '',
      signal: a['Signal'] ?? '',
      note: a['Note'] ?? '',
      other1: a['Other1'] ?? '',
      other2: a['Other2'] ?? '',
      other3: a['Other3'] ?? '',
      //
      work_date: json['WorkDate2'] ?? '',
    );    
  }

  static Future<Map<String, dynamic>?> getJsonAsync(String id) async {
    return await DbUt.getMapAsync("select * from project where id='$id'");
  }

  static Future<bool> insertAsync(ProjectTab row) async {
    if (row.id == '') row.id = StrUt.uuid();
    return await DbUt.insertAsync('project', row.toJson());
  }

  static Future<bool> updateAsync(ProjectTab row) async {
    return await DbUt.updateAsync('project', row.toJson(), 'id=?', [row.id]);
  }

  static Future<int> deleteAsync(String id) async {
    return await DbUt.deleteAsync('project', 'id=?', [id]);
  }

  static Future<int> deletesAsync(String list) async {
    return await DbUt.deleteAsync('project', 'id in ($list)');
  }

}//class
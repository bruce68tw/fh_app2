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
  //DateTime workTime;
  String? latitude;
  String? longitude;
  String? work_time;
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
    this.work_time,
    this.address,
    this.location,
    this.signal,
    this.note,
    this.other1,
    this.other2,
    this.other3
  });

  /// entity to map
  static Map<String, Object> toMap(ProjectTab row) {
    return {
      'id': row.id, 
      'name': row.name,
      'work_order_no': row.work_order_no ?? '',
      'save_flag': row.save_flag,
      'area_id': row.area_id ?? '',
      'work_class_id': row.work_class_id,
      'work_dispatch_id': row.work_dispatch_id ?? '',
      'close_reason_id': row.close_reason_id ?? '',
      'close_reason_detail_id': row.close_reason_detail_id ?? '',
      'latitude': row.latitude ?? '',
      'longitude': row.longitude ?? '',
      'work_time': row.work_time ?? '',
      'address': row.address ?? '',
      'location': row.location ?? '',
      'signal': row.signal ?? '',
      'note': row.note ?? '',
      'other1': row.other1 ?? '',
      'other2': row.other2 ?? '',
      'other3': row.other3 ?? ''
    };
  }

  static Map<String, Object> toServerMap(ProjectTab row) {
    return {
      'Id': row.id, 
      'Name': row.name,
      'WorkOrderNo': row.work_order_no ?? '',
      //'save_flag': row.save_flag,
      'AreaId': row.area_id ?? '',
      'WorkClassId': row.work_class_id,
      'WorkDispatchId': row.work_dispatch_id ?? '',
      'CloseReasonId': row.close_reason_id ?? '',
      'CloseReasonDetailId': row.close_reason_detail_id ?? '',
      'Latitude': row.latitude ?? '',
      'Longitude': row.longitude ?? '',
      'WorkTime': row.work_time ?? '',
      'Address': row.address ?? '',
      'Location': row.location ?? '',
      'Signal': row.signal ?? '',
      'Note': row.note ?? '',
      'Other1': row.other1 ?? '',
      'Other2': row.other2 ?? '',
      'Other3': row.other3 ?? ''
    };
  }

  ///convert json to model, static for be parameter !!
  static ProjectTab fromMap(Map<String, dynamic> json){
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
      work_time: json['work_time'] ?? '',
      address: json['address'] ?? '',
      location: json['location'] ?? '',
      signal: json['signal'] ?? '',
      note: json['note'] ?? '',
      other1: json['other1'] ?? '',
      other2: json['other2'] ?? '',
      other3: json['other3'] ?? ''
    );    
  }

  ///convert json to model, static for be parameter !!
  static ProjectTab fromServerMap(Map<String, dynamic> json){
    return ProjectTab(
      id: json['Id'], 
      name: json['Name'] ?? '',
      work_order_no: json['WorkOrderNo'] ?? '',
      save_flag: 0,
      area_id: json['AreaId'] ?? '',
      work_class_id: json['WorkClassId'],
      work_dispatch_id: json['WorkDispatchId'] ?? '',
      close_reason_id: json['CloseReasonId'] ?? '',
      close_reason_detail_id: json['CloseReasonDetailId'] ?? '',
      latitude: json['Latitude'].toString(),
      longitude: json['Longitude'].toString(),
      work_time: json['WorkTime'] ?? '',
      address: json['Address'] ?? '',
      location: json['Location'] ?? '',
      signal: json['Signal'] ?? '',
      note: json['Note'] ?? '',
      other1: json['Other1'] ?? '',
      other2: json['Other2'] ?? '',
      other3: json['Other3'] ?? ''
    );    
  }

  static Future<Map<String, dynamic>?> getMapAsync(String id) async {
    return await DbUt.getMapAsync("select * from project where id='$id'");
  }

  static Future<bool> insertAsync(ProjectTab row) async {
    if (row.id == '') row.id = StrUt.uuid();
    return await DbUt.insertAsync('project', ProjectTab.toMap(row));
  }

  static Future<bool> updateAsync(ProjectTab row) async {
    return await DbUt.updateAsync('project', ProjectTab.toMap(row), 'id=?', [row.id]);
  }

  static Future<int> deleteAsync(String id) async {
    return await DbUt.deleteAsync('project', 'id=?', [id]);
  }

  static Future<int> deletesAsync(String list) async {
    return await DbUt.deleteAsync('project', 'id in ($list)');
  }

}//class
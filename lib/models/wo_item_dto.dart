import 'package:fh_app2/all_com.dart';

class WoItemDto {
  bool checked;
  String id;
  String label;
  int woStatus;
  String name1;
  String name2;
  String name3;

  WoItemDto({
    required this.checked, 
    required this.id, 
    required this.label,
    required this.woStatus,
    required this.name1, 
    required this.name2, 
    required this.name3,
    });

  ///convert json to model, static for be parameter !!
  static WoItemDto fromJson(Map<String, dynamic> json){
    return WoItemDto(
      checked: false,
      id : json['Id'],
      label : json['Name'] ?? '',
      woStatus : json['WorkStatusId'] ?? WorkStatusEnum.unAssign,
      name1 : json['WorkClassId'],
      name2 : json['Address'] ?? '',
      name3 : json['WorkOrderNo'] ?? '',
    );    
  }

}//class
import 'package:fh_app2/all_com.dart';

class ProjectItemDto {
  bool checked;
  String id;
  String name;
  String workClassId;
  String address;
  String workOrderNo;
  int status;

  ProjectItemDto({
    required this.checked, 
    required this.id, 
    required this.name,
    required this.workClassId, 
    required this.address, 
    required this.workOrderNo,
    required this.status,
    });

  ///convert json to model, static for be parameter !!
  static ProjectItemDto fromJson(Map<String, dynamic> json){
    return ProjectItemDto(
      checked: false,
      id : json['Id'],
      name : json['Name'] ?? '',
      workClassId : json['WorkClassId'],
      address : json['Address'] ?? '',
      workOrderNo : json['WorkOrderNo'] ?? '',
      status : json['WorkStatusId'] ?? WorkStatusEnum.unAssign,
    );    
  }

}//class
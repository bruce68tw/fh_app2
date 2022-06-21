class ProjectItemDto {
  bool checked;
  String id;
  String name;
  String workClassId;
  String address;
  String workOrderNo;

  ProjectItemDto({
    required this.checked, 
    required this.id, 
    required this.name,
    required this.workClassId, 
    required this.address, 
    required this.workOrderNo
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
    );    
  }

}//class
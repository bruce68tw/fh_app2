class WorkRowDto {
  String workClass;
  int workStatus;
  bool collected;
  String count;

  WorkRowDto({required this.workClass, required this.workStatus,
    required this.collected, required this.count
    });

  ///convert json to model, static for be parameter !!
  static WorkRowDto fromJson(Map<String, dynamic> json){
    return WorkRowDto(
      workClass : json['WorkClass'],
      workStatus : json['WorkStatus'],
      collected : json['Collected'],
      count : json['Count'],
    );    
  }

}//class
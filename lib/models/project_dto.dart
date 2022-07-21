/// projet form input
class ProjectDto {
  String table;   //local table
  bool tableTail; //true(table -> table_xxx)
  String ctrl;    //server controller name
  bool addBtn;    //add button function
  List<String> wcIds;
  List<String> wcNames;
  //String imageDirName;

  ProjectDto({required this.table, required this.tableTail, required this.ctrl, 
    required this.addBtn, required this.wcIds, required this.wcNames
    //, required this.imageDirName
  });

}
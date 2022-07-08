/// projet form input
class ProjectDto {
  String table;
  bool addBtn;
  //List<String> wcNames;
  List<String> wcIds;
  String imageDirName;

  ProjectDto({required this.table, required this.addBtn,
    required this.wcIds, required this.imageDirName
  });

}
import 'package:flutter/material.dart';
import 'models/project_dto.dart';
import 'project0.dart';
import 'services/xp.dart';

class Project extends Project0 {  
  Project({Key? key}) : super(key: key, dto:ProjectDto(
    table: 'project',
    addBtn: true,
    imageDirName: 'Project',
    wcIds: [Xp.prjMeetWcId, Xp.prjMachWcId, Xp.prjFixWcId, Xp.prjCheckWcId],
  ));

  @override
  _ProjectState createState() => _ProjectState();
}

class _ProjectState extends Project0State<Project> {  

  /// 顯示統計表格, 如果數字>0, 則可以開啟畫面
  @override
  Widget table(){
    //const label = 'New';
    //const label = '新增';
    const label = '+';
    return Table(
      columnWidths: const {
        0: FlexColumnWidth(4),
        1: FlexColumnWidth(3),
        2: FlexColumnWidth(3),
        3: FlexColumnWidth(3),
        4: FlexColumnWidth(3)
      }, 
      children: [
        TableRow(children: [
          const Text(''),
          tableHeader('會勘'),
          tableHeader('裝機'),
          tableHeader('維修'),
          tableHeader('巡檢'),
        ]),
        TableRow(children: [
          const Text(''),
          cell(elevBtn2(label, funAdds[0] ? ()=> onAddAsync(0) : null), headerHeight),
          cell(elevBtn2(label, funAdds[1] ? ()=> onAddAsync(1) : null), headerHeight),
          cell(elevBtn2(label, funAdds[2] ? ()=> onAddAsync(2) : null), headerHeight),
          cell(elevBtn2(label, funAdds[3] ? ()=> onAddAsync(3) : null), headerHeight),
        ]),
        //文字左邊加空白做為padding
        tableRow('未指派', unAssigns, (id)=> onUnAssignAsync(id), Colors.red),
        tableRow('已指派', assigneds, (id)=> onAssignedAsync(id)),
        tableRow('已領取', pickeds, (id)=> onPickedAsync(id)),
        tableRow('未上傳', unUpload, (id)=> onUnUploadAsync(id)),
        tableRow('''當日完工
 待審核''', auditings, onAuditingAsync),
    ]);
  }

} //class

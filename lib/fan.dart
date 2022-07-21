import 'package:base_lib/all.dart';
import 'package:flutter/material.dart';
import 'models/project_dto.dart';
import 'project0.dart';
import 'services/xp.dart';

class Fan extends Project0 {  
  Fan({Key? key}) : super(key: key, dto:ProjectDto(
    table: 'fan',
    tableTail: true,
    ctrl: 'Fan',
    addBtn: false,
    //imageDirName: 'Project',
    wcIds: [Xp.fanCheckWcId, Xp.fanFixWcId, Xp.fanMachWcId],
    wcNames: ['會勘', '維修', '裝機'],
  ));

  @override
  _FanState createState() => _FanState();
}

class _FanState extends Project0State<Fan> {  

  /// 顯示統計表格, 如果數字>0, 則可以開啟畫面
  @override
  Widget table(){
    //const label = '新增';
    //const label = '+';
    var wcNames = widget.dto.wcNames;
    return Table(
      columnWidths: const {
        0: FlexColumnWidth(4),
        1: FlexColumnWidth(3),
        2: FlexColumnWidth(3),
        3: FlexColumnWidth(3),
        //4: FlexColumnWidth(3)
      }, 
      children: [
        TableRow(children: [
          const Text(''),
          tableHeader(wcNames[0]),
          tableHeader(wcNames[1]),
          tableHeader(wcNames[2]),
        ]),
        /*
        TableRow(children: [
          const Text(''),
          cell(elevBtn2(label, _funAdds[0] ? ()=> onAddAsync(0) : null), headerHeight),
          cell(elevBtn2(label, _funAdds[1] ? ()=> onAddAsync(1) : null), headerHeight),
          cell(elevBtn2(label, _funAdds[2] ? ()=> onAddAsync(2) : null), headerHeight),
          cell(elevBtn2(label, _funAdds[3] ? ()=> onAddAsync(3) : null), headerHeight),
        ]),
        */
        //文字左邊加空白做為padding
        tableRow('未指派', unAssigns, (id)=> onUnAssignAsync(id), Colors.red),
        tableRow('已指派', assigneds, (id)=> onAssignedAsync(id)),
        tableRow('已領取', pickeds, (id)=> onPickedAsync(id)),
        tableRow('未上傳', unUpload, (id)=> onUnUploadAsync(id)),
        tableRow('''當日完工
 待審核''', auditings, onAuditingAsync),
    ]);
  }

  /// 讀取 locale 的統計數字
  @override
  Future<List<Map<String, dynamic>>> getLocaleCountAsync(String areaId, int saveFlag) async {

    //欄位名稱為 WorkClassId,Count(配合 setCount())
    //union
    var sql = '''
select
  work_class_id as WorkClassId,
  count(*) as Count
from fan_check 
where ('$areaId'='' or area_id='$areaId')
and save_flag=$saveFlag
''';
    return await DbUt.getJsonsAsync(sql);
  }

} //class

import 'package:fh_app2/project_edit.dart';
import 'package:flutter/material.dart';
import 'package:base_lib/all.dart';
import 'all_com.dart';
import 'project_items.dart';

class Project extends StatefulWidget {  
  const Project({Key? key}) : super(key: key);

  @override
  _ProjectState createState() => _ProjectState();
}

class _ProjectState extends State<Project> {  
  static const headerHeight = 40.0;   //table header height
 
  //宣告固定長度陣列 for 顯示畫面
  late List<int> _unAssigns;   //未指派
  late List<int> _assigneds;   //已指派
  late List<int> _pickeds;     //已領取
  late List<int> _unUpload;    //未上傳
  late List<int> _auditings;   //當日完工待審核

  //權限
  final List<bool> _funAdds = [false,false,false,false];    //新增按鈕
  final List<bool> _funViews = [false,false,false,false];   //檢視統計數字內容

  //順序配合DB欄位 WorkClass.Sort
  final List<String> _wcIds = [];     //WorkClass.Id list
  final List<String> _wcNames = [];   //會勘,裝機,巡檢,維修

  bool _isOk = false;   //status
  String _areaId = '';  //empty means all
  //int _actRadio = 0;    //radio function

  @override
  void initState() {
    //call before rebuild()
    super.initState();

    //讀取資料, call async rebuild
    Future.delayed(Duration.zero, ()=> showAsync());
  }

  /// rebuild page
  Future showAsync() async {

    //讀取資料庫, get rows & check
    var data = {
      'getBase': _isOk ? '0' : '1', //must be string !!
      'areaId': _areaId, 
    };
    await HttpUt.getJsonAsync(context, 'api/Project/PageCount', false, data, (result) async {
      var json = Xp.getResult(result);
      if (json == null) return;

      //initial if need
      if (!_isOk){
        //設定下拉式欄位內容
        //_classIds = json['ClassIds'];
        Xp.areas = JsonUt.rowsToIdStrs(json['Areas']);
        Xp.areas.insert(0, IdStrDto(id:'', str:'全部'));

        Xp.workClasses = JsonUt.rowsToIdStrs(json['WorkClasses']);
        Xp.dispatches = JsonUt.rowsToIdStrs(json['Dispatches']);
        Xp.closes = JsonUt.rowsToIdStrs(json['Closes']);
        //has ext(closeReasonId)
        Xp.closeDetails = JsonUt.rowsToIdStrs2(json['CloseDetails']);

        //set variables
        _wcNames.clear();
        _wcIds.clear();
        for (var row in Xp.workClasses){
          _wcIds.add(row.id);
          _wcNames.add(row.str);
        }
        //_classLen = _classIds.length;

        //set _funViews, _funAdds
        _funViews.forEach((a)=> a = false);      
        _funAdds.forEach((a)=> a = false);
        var wcAdds = JsonUt.rowsToIdStrs(json['WcAdds']);
        for (var row in wcAdds){   
          var find = _wcIds.indexOf(row.id);
          if (find >= 0){
            _funViews[find] = true;
            _funAdds[find] = (row.str == '1');
          }
        }
      }

      //清除數字為0
      resetCount();

      //設定統計數字      
      setCount(_unAssigns, List<Map>.from(json['New']));  //未指派
      setCount2(List<Map>.from(json['NotNew']));  //已指派, 待審核

      //讀取 sqlLite      
      setCount(_pickeds, await getLocaleMapsAsync(_areaId, 0));   //已領取
      setCount(_unUpload, await getLocaleMapsAsync(_areaId, 1));  //未上傳

      setState(()=> _isOk = true); //call build()
    }, null, false);
  }

  void resetCount(){
    _unAssigns = [0,0,0,0];
    _assigneds = [0,0,0,0];
    _pickeds = [0,0,0,0];
    _unUpload = [0,0,0,0];
    _auditings = [0,0,0,0];
  }

  //讀取 locale 的統計數字
  Future<List<Map<String, dynamic>>> getLocaleMapsAsync(String areaId, int saveFlag) async {

    //欄位名稱為 ClassId,Count(配合 setCount())
    var sql = '''
select
  work_class_id as ClassId,
  count(*) as Count
from project 
where ('$areaId'='' or area_id='$areaId')
and save_flag=$saveFlag
group by work_class_id
''';
    return await DbUt.getMapsAsync(sql);
  }

  //設定統計數字(未指派,未上傳)
  void setCount(List<int> srcList, List<Map> jsons){
    for (var json in jsons){   
      //find classIds   
      var find = _wcIds.indexOf(json['ClassId']);
      srcList[find] = (find >= 0)
        ? json['Count'] : 0;
    }
  }

  /// 設定統計數字(已指派, 待審核)
  /// param picked {bool} true(已領取), false(已指派但未領取)
  void setCount2(List<Map> jsons){
    for (var json in jsons){   
      //find classIds
      var find = _wcIds.indexOf(json['WorkClassId']);
      if (find >= 0){
        if (json['WorkStatusId'] == WorkStatusEnum.auditing){
          _auditings[find] = json['Count']; //待審核
        } else if (json['Collected'] == 0){
          _assigneds[find] = json['Count']; //已指派
        //} else {
        //  _pickeds[find] = json['Count'];
        }
      }
    }
  }

  //table header
  Widget tableHeader(String label){
    return cell(WG.getText(label), headerHeight);
  }

  //button
  static Widget elevBtn2(String text, [VoidCallback? fnOnClick]) {
    return Padding(
      padding: const EdgeInsets.all(1),
      child: WG.elevBtn(text, fnOnClick)
    );
  }

  /// 顯示統計表格, 如果數字>0, 則可以開啟畫面
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
          tableHeader(_wcNames[0]),
          tableHeader(_wcNames[1]),
          tableHeader(_wcNames[2]),
          tableHeader(_wcNames[3]),
        ]),
        TableRow(children: [
          const Text(''),
          cell(elevBtn2(label, _funAdds[0] ? ()=> onAddAsync(0) : null), headerHeight),
          cell(elevBtn2(label, _funAdds[1] ? ()=> onAddAsync(1) : null), headerHeight),
          cell(elevBtn2(label, _funAdds[2] ? ()=> onAddAsync(2) : null), headerHeight),
          cell(elevBtn2(label, _funAdds[3] ? ()=> onAddAsync(3) : null), headerHeight),
        ]),
        //文字左邊加空白做為padding
        tableRow('未指派', _unAssigns, (id)=> onUnAssignAsync(id), Colors.red),
        tableRow('已指派', _assigneds, (id)=> onAssignedAsync(id)),
        tableRow('已領取', _pickeds, (id)=> onPickedAsync(id)),
        tableRow('未上傳', _unUpload, (id)=> onUnUploadAsync(id)),
        tableRow('''當日完工
 待審核''', _auditings, onAuditingAsync),
    ]);
  }

  Future<void> openItemsAsync(String wsId, int actEnum) async {
    var msg = await ToolUt.openFormAsync(context, ProjectItems(areaId:_areaId, wcId:wsId, actEnum:actEnum)) ?? '';
    if (msg != ''){
      ToolUt.msg(context, msg); //first
      await showAsync();
    }
  }

  //onclick 未指派,已指派會開啟相同UI
  Future onUnAssignAsync(String wsId) async {
    await openItemsAsync(wsId, WoActEnum.unAssign);
    //ToolUt.openForm(context, ProjectItems(areaId:_areaId, wsId:wsId, actEnum:WoActEnum.unAssign));
  }

  //onclick 已指派
  Future onAssignedAsync(String wsId) async {
    await openItemsAsync(wsId, WoActEnum.assigned);
    //ToolUt.openForm(context, ProjectItems(areaId:_areaId, wsId:wsId, actEnum:WoActEnum.assigned));
  }

  //onclick 已領取數字
  Future onPickedAsync(String wsId) async {
    await openItemsAsync(wsId, WoActEnum.picked);
    //ToolUt.openForm(context, ProjectItems(areaId:_areaId, wsId:wsId, actEnum:WoActEnum.picked));
  }

  //onclick 未上傳
  Future onUnUploadAsync(String wsId) async {
    await openItemsAsync(wsId, WoActEnum.unUpload);
    //ToolUt.openForm(context, ProjectItems(areaId:_areaId, wsId:wsId, actEnum:WoActEnum.unUpload));
  }

  //onclick 待審核
  Future onAuditingAsync(String wsId) async {
    await openItemsAsync(wsId, WoActEnum.auditing);
    //ToolUt.openForm(context, ProjectItems(areaId:_areaId, wsId:wsId, actEnum:WoActEnum.auditing));
  }

  //table cell, height: empty to 55, if null will not set
  Widget cell(Widget item, [double? height = 0]){
    if (height == 0) height = 55;
    return SizedBox(
      height: height,
      child: Center(child: item)
    );
  }

  /// 顯示一列資料
  /// param rows: 統計資料
  TableRow tableRow(String label, List<int> rows, Function fnOnClick, [Color? color]){
    List<Widget> list = [cell(WG2.rowLabel(label), label.length > 4 ? null : 0)];
    for(var i=0; i<rows.length; i++){
      var value = rows[i];
      var item = (value == 0)
        ? WG2.numText(value, color)
        : WG2.numBtn(value, color, _funViews[i] ? ()=>fnOnClick(_wcIds[i]) : null);
      list.add(cell(item));
    }
    return TableRow(children: list);
  }

  //onclick 新增 button
  Future<void> onAddAsync(int idx) async {
    var msg = await ToolUt.openFormAsync(context, ProjectEdit(id: '', areaId: _areaId, isEdit: true, wcId: _wcIds[idx])) ?? '';
    if (msg != ''){
      ToolUt.msg(context, msg);
      await showAsync();
    }
  }

  /*
  //get radio widget
  Radio radio(int value){
    return Radio(
      value: value,
      groupValue: _actRadio,
      onChanged: (val) {
        _actRadio = (val == null) ? 0 : val;
        setState((){});
      },
    );
  }

  //get radio label
  Text radioLabel(String label){
    return WG.getText(label);
  }
  */

  @override
  Widget build(BuildContext context) {
    //check status
    if (!_isOk) return Container();

    return SingleChildScrollView(
    //return Padding(
      padding: const EdgeInsets.all(2),
      child: Padding(
        padding: const EdgeInsets.only(left:5, right:5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            WG2.areaField('區域', _areaId, 260, (value) async {
              _areaId = value;
              await showAsync();
            }),
            table(),
            Center(
              child: WG.elevBtn('重新讀取', () async => await showAsync())
            )
      ])));
  }
  
} //class

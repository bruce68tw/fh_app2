import 'package:fh_app2/project_edit.dart';
import 'package:flutter/material.dart';
import 'package:base_lib/all.dart';
import 'all_com.dart';
//import 'models/project_dto.dart';
import 'wo_list.dart';

/// base widget class for 專案,DCU,FAN
/// 因為先做專案, 所以使用 project0 做為基底類別
class Project0 extends StatefulWidget {  
  const Project0({Key? key, required this.dto}) : super(key: key);
  final ProjectDto dto;

  @override
  Project0State createState() => Project0State();
}

class Project0State<T extends Project0> extends State<T> {  
  double headerHeight = 40.0;   //table header height
 
  late ProjectDto _dto;

  //陣列 for 顯示畫面
  late List<int> unAssigns;   //未指派
  late List<int> assigneds;   //已指派
  late List<int> pickeds;     //已領取
  late List<int> unUpload;    //未上傳
  late List<int> auditings;   //當日完工待審核

  //List<IdStrDto> areas = [];

  //權限, 陣列元素取最大值4
  final List<bool> funAdds = [false,false,false,false];    //新增按鈕
  //final List<bool> funViews = [false,false,false,false];   //檢視統計數字內容

  //順序配合DB欄位 WorkClass.Sort
  late int wcLen;
  //final List<String> wcIds = [];     //WorkClass.Id list
  //final List<String> wcNames = [];   //會勘,裝機,巡檢,維修

  bool _isOk = false;   //status
  String _areaId = '';  //empty means all
  //int _actRadio = 0;    //radio function

  /// === 子類別實作 start ===
  /// 顯示統計表格
  Widget table()=> Container(); 

  /// 讀取 locale 的統計數字
  Future<List<Map<String, dynamic>>> getLocaleCountAsync(String areaId, int saveFlag) async => [];
  /// === 子類別實作 end ===


  @override
  void initState() {
    _dto = widget.dto;

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
    await HttpUt.getJsonAsync(context, 'api/${_dto.ctrl}/PageCount', false, data, (result) async {
      var json = Xp.getResult(result);
      if (json == null) return;

      //initial if need
      if (!_isOk){
        //設定下拉式欄位內容
        //_classIds = json['ClassIds'];
        var areas = JsonUt.rowsToIdStrs(json['Areas']);
        areas.insert(0, IdStrDto(id:'', str:'全部'));
        Xp.areas = areas; //set global !!

        //Xp.workClasses = JsonUt.rowsToIdStrs(json['WorkClasses']);  //for dropdown
        //Xp.dispatches = JsonUt.rowsToIdStrs(json['Dispatches']);
        //Xp.closes = JsonUt.rowsToIdStrs(json['Closes']);
        //has ext(closeReasonId)
        //Xp.closeDetails = JsonUt.rowsToIdStrs2(json['CloseDetails']);

        wcLen = _dto.wcIds.length;
        /*
        //set variables
        wcNames.clear();
        wcIds.clear();
        wcLen = Xp.workClasses.length;
        for (var row in Xp.workClasses){
          wcIds.add(row.id);
          wcNames.add(row.str);
        }
        //_classLen = _classIds.length;
        */

        //set _funViews, _funAdds if need
        if (_dto.addBtn){
          //funViews.forEach((a)=> a = false);      
          funAdds.forEach((a)=> a = false);
          var wcAdds = JsonUt.rowsToIdStrs(json['WcAdds']);
          for (var row in wcAdds){   
            var find = _dto.wcIds.indexOf(row.id);
            if (find >= 0){
              //funViews[find] = true;
              funAdds[find] = (row.str == '1');
            }
          }
        }
      }

      //清除數字為0
      resetCount();

      //設定統計數字      
      setCount(unAssigns, List<Map>.from(json['New']));  //未指派
      setCount2(List<Map>.from(json['NotNew']));  //已指派, 完工待審核

      //讀取 sqlLite      
      setCount(pickeds, await getLocaleCountAsync(_areaId, 0));   //已領取
      setCount(unUpload, await getLocaleCountAsync(_areaId, 1));  //未上傳

      setState(()=> _isOk = true); //call build()
    }, null, false);
  }

  void resetCount(){
    //陣列元素取最大值4
    unAssigns = [0,0,0,0];
    assigneds = [0,0,0,0];
    pickeds = [0,0,0,0];
    unUpload = [0,0,0,0];
    auditings = [0,0,0,0];
  }

  //設定統計數字(未指派,未上傳)
  void setCount(List<int> srcList, List<Map> jsons){
    for (var json in jsons){
      var wcId = json['WorkClassId'];
      if (wcId == null) continue;
      
      //find classIds   
      var find = _dto.wcIds.indexOf(wcId);
      if (find >= 0) {
        srcList[find] = json['Count'];
      }
    }
  }

  /// 設定統計數字(已指派, 待審核)
  /// param picked {bool} true(已領取), false(已指派但未領取)
  void setCount2(List<Map> jsons){
    for (var json in jsons){   
      //find classIds
      var find = _dto.wcIds.indexOf(json['WorkClassId']);
      if (find >= 0){
        if (json['WorkStatusId'] == WorkStatusEnum.auditing){
          auditings[find] = json['Count']; //待審核
        } else if (json['Collected'] == 0){
          assigneds[find] = json['Count']; //已指派
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
  Widget elevBtn2(String text, [VoidCallback? fnOnClick]) {
    return Padding(
      padding: const EdgeInsets.all(1),
      child: WG.elevBtn(text, fnOnClick)
    );
  }

  Future<void> openItemsAsync(String wsId, int actEnum) async {
    var msg = await ToolUt.openFormAsync(context, WoList(dto:_dto, 
      areaId:_areaId, wcId:wsId, actEnum:actEnum)) ?? '';
    if (msg != ''){
      ToolUt.msg(context, msg); //first
      await showAsync();
    }
  }

  //onclick 未指派,已指派會開啟相同UI
  Future onUnAssignAsync(String wsId) async {
    await openItemsAsync(wsId, WoActEnum.unAssign);
  }

  //onclick 已指派
  Future onAssignedAsync(String wsId) async {
    await openItemsAsync(wsId, WoActEnum.assigned);
  }

  //onclick 已領取數字
  Future onPickedAsync(String wsId) async {
    await openItemsAsync(wsId, WoActEnum.picked);
  }

  //onclick 未上傳
  Future onUnUploadAsync(String wsId) async {
    await openItemsAsync(wsId, WoActEnum.unUpload);
  }

  //onclick 待審核
  Future onAuditingAsync(String wsId) async {
    await openItemsAsync(wsId, WoActEnum.auditing);
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
    //for(var i=0; i<rows.length; i++){
    for(var i=0; i<wcLen; i++){
      var value = rows[i];
      var item = (value == 0)
        ? WG2.numText(value, color)
        : WG2.numBtn(value, color, ()=>fnOnClick(_dto.wcIds[i]));
        //: WG2.numBtn(value, color, funViews[i] ? ()=>fnOnClick(_dto.wcIds[i]) : null);
      list.add(cell(item));
    }
    return TableRow(children: list);
  }

  //onclick 新增 button
  Future<void> onAddAsync(int idx) async {
    var msg = await ToolUt.openFormAsync(context, 
      ProjectEdit(id: '', areaId: _areaId, wcId: _dto.wcIds[idx], isEdit:true, fromServer:false)) ?? '';
    if (msg != ''){
      ToolUt.msg(context, msg);
      await showAsync();
    }
  }

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

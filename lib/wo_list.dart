// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:base_lib/all.dart';
import 'package:provider/provider.dart';
import 'all_com.dart';
import 'project_edit.dart';

/// Model(view object) for UI
class WoListVo with ChangeNotifier {
  //String str1;
  List<WoItemDto> items;

  WoListVo(this.items);

  /// set checkbox status
  void setCheck(int index, bool value){
    items[index].checked = value;
    notifyListeners();
  }

  void loadItems(List<WoItemDto> newItems){
    items = newItems;
    notifyListeners();
  }

  void deleteItem(int index){
    items.removeAt(index);
    notifyListeners();
  }
}

/// UI
//點擊 未指派/已指派 數字時開啟本畫面
class WoList extends StatefulWidget {
  const WoList({Key? key, required this.dto, required this.areaId, 
    required this.wcId, required this.actEnum}) : super(key: key);

  final ProjectDto dto;
  final String areaId;  //Area.Id
  final String wcId;    //WorkClass.Id
  final int actEnum;    //WoActEnum

  @override
  WoListState createState() => WoListState();
}

class WoListState extends State<WoList> { 
  late ProjectDto _dto;
  late String _areaId;  //Area.Id
  late String _wcId;    //WorkClass.Id
  late int _actEnum;    //WoActEnum

  //BuildContext? _context;
  WoListVo? _vo;

  bool _isOk = false;       //state variables
  List<WoItemDto> _items = [];      //list rows from server
  int _checkeds = 0;   //checked count
  final addressCtrl = TextEditingController();

  @override
  void initState() {
    _dto = widget.dto;
    _areaId = widget.areaId;
    _wcId = widget.wcId;
    _actEnum = widget.actEnum;

    //call before rebuild()
    super.initState();

    //讀取資料, call async rebuild
    Future.delayed(Duration.zero, ()=> getItemsAsync(true));
  }

  /// read and load _items
  Future<void> readLoadItemsAsync() async {
    await getItemsAsync();
    _vo!.loadItems(_items);
  }

  Future<WoListVo> getVoAsync() async {
    var items = await getItemsAsync();
    return WoListVo(items);
  }

  /// set _items
  Future<List<WoItemDto>> getItemsAsync([bool updState = false]) async {
    //read db
    var readServer = true;  //從後端db讀取資料, false:read locale
    var act = '';   //server action
    switch(_actEnum){
      //未指派
      case WoActEnum.unAssign:
        act = 'UnAssigns'; break;
      //已指派
      case WoActEnum.assigned:
        act = 'Assigneds'; break;
      //完工待審核
      case WoActEnum.auditing:
        act = 'Auditings'; break;

      //get locale(已領取)
      case WoActEnum.picked:
        act = 'Pickeds'; 
        readServer = false;
        break;

      //get locale(未上傳)
      case WoActEnum.unUpload:
        act = 'Pickeds'; 
        readServer = false;
        break;
        
      default:
        ToolUt.msg(context, 'Input Wrong');
        return [];
    }

    //read server
    if (readServer){
      var data = {
        'areaId': _areaId, 
        'wsId': _wcId,
      };
      await HttpUt.getJsonAsync(context, 'api/${_dto.ctrl}/$act', false, data, (result) async {
        var json = Xp.getResult(result);
        if (json == null) return;

        _items = json.map((row) => WoItemDto.fromJson(row)).cast<WoItemDto>().toList(); //has cast<>
      });

    //read locale
    } else {      
      var sql = '''
select
  id as Id,
  name as Name,
  work_class_id as WorkClassId,
  address as Address,
  work_order_no as WorkOrderNo
from ${_dto.table} 
where ('$_areaId'='' or area_id='$_areaId')
and work_class_id='$_wcId'
and save_flag=${_actEnum == WoActEnum.unUpload ? 1 : 0}
''';
      var json = await DbUt.getJsonsAsync(sql);
      _items = json.map((row)=> WoItemDto.fromJson(row)).cast<WoItemDto>().toList(); //has cast<>
    }

    if (updState) setState(()=> _isOk = true);
    return _items;
  }

  //set checkeds count
  void setCheckeds() {
    _checkeds = getFormItems().where((a)=> a.checked).length;
  }

  //領取作業 for 未指派/已指派
  Future onPicksAsync() async {
    //get checked id list
    var list = getCheckedList(false);
    if (!hasCheckeds(list)) return;

    //call action & check result
    await HttpUt.getJsonAsync(context, 'api/${_dto.ctrl}/Picks', false, { 'list': list }, (result) async {
      String? data = Xp.getResult(result);
      if (data == null) return;

      //insert local db
      var count = 0;
      var ids = data.split(',');
      for(var row in getFormItems()){
        if (row.checked && ids.contains(row.id)){
          var tab = ProjectTab(
            id: row.id, 
            name: row.name1,
            work_order_no: row.name3,
            save_flag: 0,
            //work_class_id: row.workClassId,
            work_class_id: _wcId,
            //workDispatchId: row.workDispatchId,
            //workTime: row.workTime,
            //areaId: row.areaId,
            //latitude: row.latitude,
            //longitude: row.longitude,
            address: row.name2,
            //location: row.location,
            //signal: row.signal,
            //closeReasonId: row.closeReasonId,
            //closeReasonDetailId: row.closeReasonDetailId,
            //note: row.note,
            //other1: row.other1,
            //other2: row.other2,
            //other3: row.other3
          );

          try{
            await ProjectTab.insertAsync(tab);
          } catch (error){
            await ProjectTab.updateAsync(tab);
          }
          count++;
      }}

      //close with msg
      ToolUt.closeForm(context, '成功領取 $count 筆資料。');
    });
  }

  //onclick (edit/view row)
  onEditAsync(String id, String wcId, bool isEdit, bool fromServer) async {
    var msg = await ToolUt.openFormAsync(context, 
      ProjectEdit(id: id, areaId: _areaId, wcId: wcId, isEdit: isEdit, fromServer: fromServer)) ?? '';
    if (msg != ''){
      ToolUt.msg(context, msg);
      await readLoadItemsAsync();
    }
  }

  //是否有選取資料
  bool hasCheckeds(String list){
    var empty = (list == '');
    if (empty){
      ToolUt.msg(context, '請先選取資料。');
    }
    return !empty;
  }

  List<WoItemDto> getFormItems(){
    return _vo!.items;
  }

  String getCheckedList(bool comma){
    return getFormItems().where((a) => a.checked)
      .map((a)=> comma ? "'${a.id}'" : a.id)
      .toList()
      .join(',');
  }

  //資料上傳審核 for 未上傳
  Future onUploadsAsync() async {
    //get checked id list
    var list = getCheckedList(true);
    if (!hasCheckeds(list)) return;

    var sql = '''
select * from ${_dto.table}
where id in ($list)
''';
    var jsons = await DbUt.getJsonsAsync(sql);
    var rows = jsons.map((a) => ProjectTab.fromJson(a)).cast<ProjectTab>().toList(); //has cast<>
    await Xp.sendAuditRowsAsync(context, rows, (){
      //回上個畫面
      ToolUt.closeForm(context, '資料上傳完成');
    });
  }

  /// 資料取消 by 已領取/未上傳 (已領取->未指派, 未上傳->刪除)
  /// isPakced: true(已領取), false(未上傳)
  Future onCancelsAsync(bool isPicked) async {
    //get checked id list
    var list = getCheckedList(true);
    if (!hasCheckeds(list)) return;

    if (isPicked){
    //update server db
    //call action & check result
    var data = { 'list': list.replaceAll("'", '') };  //後端不需要引號
    await HttpUt.getJsonAsync(context, 'api/${_dto.ctrl}/Cancels', false, data, (result) async {
      String? data = Xp.getResult(result);
      if (data == null) return;

      await _onCancelsAsync2(list);
    });
    } else {
      await _onCancelsAsync2(list);
    }
  }

  Future _onCancelsAsync2(String list) async {
    //delete locale db(no locale files)
    await ProjectTab.deletesAsync(list);

    //show msg
    ToolUt.msg(context, '作業完成。');
    await readLoadItemsAsync();
  }

  /// projectPicks to widget list
  /// 同時計算筆數與過濾地址
  /// @rows source rows
  /// @act C(checkbox),E(編輯),V(檢視)
  /// @return list widget
  List<Widget> getItemWidgets(bool showCheck, String? editFun, bool fromServer) {

    List<Widget> widgets = [];
    for (int i = 0; i < _items.length; i++) {
      //add checkbox or text
      var item = _items[i];
      var statusName = Xp.getWoStatusName(item.woStatus);
      widgets.add(
        showCheck 
          ? SizedBox(
              height: 32, //限制高度, 否則太高
              child: WG.icheck(statusName, item.checked, (value){
                //setState(()=> row.checked = value);
                _vo!.setCheck(i, value);
            }))
          : WG.getText(statusName)
      );

      //add text with onclick function
      widgets.add(InkWell(
        onTap: (editFun == null)
          ? null
          : ()=> onEditAsync(item.id, _wcId, (editFun == 'E'), fromServer),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            WG.getText(item.name1),
            WG.getText(item.name2),
            WG.getText(item.name3),
        ])));

      widgets.add(WG2.divider());
    }
    return widgets;
  }

  /// get form body
  /// var showCheck = true;   //show checkbox
  /// var fromServer = true;  //read rows from server
  /// String? editFun;        //null,E(edit),V(view) 
  List<Widget> getBody(bool showCheck, bool fromServer, String? editFun) {
    //上方查詢欄位
    var areaWidget = showCheck
      ? WG.tableLabelWidget('區域', WG2.areaField('', _areaId, 160, (value) async {
          _areaId = value;
          await readLoadItemsAsync();
        }, '已選擇 $_checkeds 筆'))
      : WG.iselect2('區域', _areaId, Xp.areas, (value) async {
          _areaId = value;
          await readLoadItemsAsync();
      });

    //body, value參數配合 projectPicksToWidgets()
    List<Widget> widgets = [
      Table(
        columnWidths: const {
          0: FlexColumnWidth(1),
          1: FlexColumnWidth(4),
        }, 
        children: [
          areaWidget,
          WG.itext2('地址', addressCtrl, required:false, 
            fnOnChange: (value){
              var address = addressCtrl.text;
              var items = (address == '')
                ? _items
                : _items.where((a)=> a.name2.contains(address)).toList();
              _vo!.loadItems(items);
            })
    ])];

    //add rows, 使用Expanded(最外面)讓多筆資料捲動, 然後SingleChildScrollView
    widgets.add(WG2.vGap());

    //var items = ref.watch(woItemsProvider).items;
    var itemWidgets = getItemWidgets(showCheck, editFun, fromServer);
    if (itemWidgets.isNotEmpty){
      widgets.add(
        Expanded(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: itemWidgets
      )))));
    }

    //add tail button if need
    if (_actEnum == WoActEnum.unAssign || _actEnum == WoActEnum.assigned) {
      widgets.add(WG2.centerElevBtn('領取作業', onPicksAsync));
    } else if(_actEnum == WoActEnum.picked) {
      //已領取
      widgets.add(WG2.centerElevBtn('資料取消', ()=> onCancelsAsync(true)));
    } else if(_actEnum == WoActEnum.unUpload) {
      //未上傳
      widgets.add(Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          WG.elevBtn('資料上傳', onUploadsAsync),
          WG2.hGap(),
          WG.elevBtn('資料取消', ()=> onCancelsAsync(false))
      ]));
    }
    
    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    //_context = context;
    //_ref = ref;

    //Future.delayed(Duration.zero, ()=> setItemsAsync());

    if (!_isOk) return Container();

    var title = '';
    var showCheck = true;   //show checkbox
    var fromServer = true;  //read rows from server
    String? editFun;        //null,E(edit),V(view) 
    switch(_actEnum){
      case WoActEnum.unAssign:
        title = '未指派'; 
        break;
      case WoActEnum.assigned:
        title = '已指派'; 
        break;
      case WoActEnum.picked:
        title = '已領取'; 
        //showCheck = false;
        fromServer = false;
        editFun = 'E';  //edit
        break;
      case WoActEnum.unUpload:
        title = '未上傳'; 
        fromServer = false;
        editFun = 'E';  //edit
        break;
      case WoActEnum.auditing:       
        title = '當日完工待審核'; 
        showCheck = false;
        editFun = 'V';  //view
        break;
    }

    //計算筆數
    //setCheckeds();
    return ChangeNotifierProvider<WoListVo>(
    //return FutureBuilder<WoListVo>(
      create: (_)=> WoListVo(_items),
      //future: getVoAsync(),
      child: Scaffold(
        appBar: WG2.appBar(title),
        body: Padding(
          padding: const EdgeInsets.all(5),
          child: Consumer<WoListVo>(
            builder: (a1, vo, a2){
              _vo = vo; //set instance variables
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: getBody(showCheck, fromServer, editFun)
              );
    }))));
  }
  
} //class
import 'package:flutter/material.dart';
import 'package:base_lib/all.dart';
import 'xp.dart';

/// project widget(static)
class WG2 {

  static const pagePad = EdgeInsets.all(10);

  ///get appBar widget
  ///@title title string
  static AppBar appBar(String title) {
    return AppBar(
      toolbarHeight: 42,
      title: Text(title, style: titleLabelStyle())
    );
  }

  static TextStyle titleLabelStyle() {
    return const TextStyle(fontSize: Xp.titleFontSize);
  }

  //區域欄位
  static Widget areaField(String label, String value, double? width, Function fnOnChange, [String? tail]){
    List<Widget> list = [];
    if (label != ''){
      list.add(WG.getLabel('區域'));
      list.add(const Spacer(flex: 1));
    }
    list.add(SizedBox(
        width: width,
        child: WG.iselect('', value, Xp.areas, fnOnChange)
    ));
    list.add(const Spacer(flex: 1));

    if (tail != null){
      list.add(WG.getText(tail));
      list.add(const Spacer(flex: 1));
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: list,
    );
  }

  //new
  //統計表格資料列文字
  static Text rowLabel(String label){
    return WG.getText(label);
  }

  /// center ElevatedButton
  static Widget centerElevBtn(String text, [VoidCallback? fnOnClick]) {
    return Center(child: WG.elevBtn(text, fnOnClick));
  }

  /*
  static Widget tailCenter(Widget widget) {
    return Container(
      alignment: Alignment.center,
      margin: WG.gap(10),
      child: widget,
    );
  }
  */

  ///return empty message
  static Widget emptyMsg(){
    return WG.emptyMsg('目前無任何資料。', Xp.fontSize, Colors.red);
  }

  static Divider divider(){
    return WG.divider(15);
  }

  //vertical gap
  static Widget vGap([double value = 10]){
    return SizedBox(height: value);
  }

  //horizontal gap
  static Widget hGap([double value = 5]){
    return SizedBox(width: value);
  }

  //數字文字, for 統計表格的值
  static Text numText(int value, [Color? color]){
    return Text(value.toString(),
      style: TextStyle(fontSize: Xp.fontSize, color: color),
    );
  }

  //專案使用 DefaultTabController, 無法設定 theme !!
  //所以在這裡設定 textBtn fontsize
  static Widget numBtn(int value, [Color? color, Function? fnOnClick]) {
    return TextButton(
      child: Text(value.toString(),
        style: TextStyle(fontSize: Xp.fontSize, color: color),
      ),
      onPressed: (fnOnClick == null) ? null : ()=> fnOnClick(),
    );
  }

} //class

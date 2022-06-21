import 'package:base_lib/all.dart';
import 'package:flutter/material.dart';
//import 'project_camera.dart';
import 'services/widget2.dart';

class EmptyForm extends StatefulWidget {
  const EmptyForm({ Key? key }) : super(key: key);

  @override
  _EmptyFormState createState() => _EmptyFormState();
}

class _EmptyFormState extends State<EmptyForm> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: WG2.appBar('拍照'),
      body: Center(
        //padding: const EdgeInsets.all(5),
        //child: WG.textBtn('開啟相機', ()=> ToolUt.openForm(context, ProjectCamera()))
      ));
  }
}
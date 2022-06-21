import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:base_lib/all.dart';
import 'all_com.dart';
import 'login.dart';

void main() {
  runApp(const MainApp());
}

/// This Widget is the main application widget.
class MainApp extends StatelessWidget {
  const MainApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const MainForm(),
      theme: ThemeData(
        textTheme: const TextTheme(
          button: TextStyle(fontSize:Xp.fontSize),
        ),
      ),      
    );
  }
} //MainApp

class MainForm extends StatefulWidget {
  const MainForm({Key? key}) : super(key: key);

  @override
  _MainFormState createState() => _MainFormState();
}

class _MainFormState extends State<MainForm> {
  bool _isOk = false;

  @override
  void initState() {
    //call before rebuild()
    super.initState();

    Future.delayed(Duration.zero, ()=> showAsync());
  }

  Future showAsync() async {
    if (kDebugMode){
      await FunUt.init(Xp.isHttpsTest, Xp.apiServerTest);
    } else {
      await FunUt.init(Xp.isHttps, Xp.apiServer);
    }

    //set global
    FunUt.fontSize = Xp.fontSize;
    FunUt.logHttpUrl = true;

    //delete temp files
    FileUt.deleteDirFiles(FunUt.dirTemp);

    Db.init();
    _isOk = true;
    setState((){});
  }

  @override
  void dispose() {
    DbUt.closeAsync();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //check status
    if (!_isOk) return Container();

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: TabBar(
            labelStyle: WG2.titleLabelStyle(),
            tabs: const [
              Tab(text: '登入'),
              Tab(text: '線上報修'),
              Tab(text: '報修查詢'),
            ],
          ),
        ),
        body: const TabBarView(children: <Widget>[
            Login(),
            Text('TabsView 2'),
            Text('TabsView 3'),
    ])));
  }

} //class
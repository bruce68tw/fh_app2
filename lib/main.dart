import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:base_lib/all.dart';
//import 'package:flutter_riverpod/flutter_riverpod.dart';
//import 'package:image/image.dart';
import 'all_com.dart';
import 'login.dart';

void main() {
  runApp(const MainApp());
  //runApp(const ProviderScope(child: MainApp()));
}

/// This Widget is the main application widget.
class MainApp extends StatelessWidget {
  const MainApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const bgColor = Color(0xFFA7D55B);

    return MaterialApp(
      home: const MainForm(),
      theme: ThemeData(
        //scaffoldBackgroundColor: const Color(0xFFA7D55B),
        //primaryColor: titleBgColor,
        //primarySwatch: MaterialColor(0xFFA7D55B, null),
        appBarTheme: const AppBarTheme(
          foregroundColor: Colors.black,
          backgroundColor: bgColor,
        ),
        textTheme: const TextTheme(
          button: TextStyle(fontSize:Xp.fontSize),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            primary: bgColor
            //onPrimary: Colors.black, // foreground (text) color
        )),
    ));
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
            labelColor: Colors.black,
            unselectedLabelColor: Colors.grey,
            labelStyle: WG2.titleLabelStyle(),
            tabs: const [
              Tab(text: '??????'),
              Tab(text: '????????????'),
              Tab(text: '????????????'),
            ],
          ),
        ),
        body: const TabBarView(children: <Widget>[
            Login(),
            //Sqlite(),
            Text('TabsView 2'),
            Text('TabsView 3'),
    ])));
  }

} //class
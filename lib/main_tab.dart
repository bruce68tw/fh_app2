import 'package:flutter/material.dart';
import 'project.dart';
import 'services/widget2.dart';

class MainTab extends StatefulWidget {
  const MainTab({ Key? key, required this.actType }) : super(key: key);
  final int actType;

  @override
  _MainTabState createState() => _MainTabState();
}

class _MainTabState extends State<MainTab> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      initialIndex: widget.actType,
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: TabBar(
            labelStyle: WG2.titleLabelStyle(),
            tabs: const [
              Tab(text: '空品'),
              Tab(text: '''能源
(FAN)'''),
              Tab(text: '''能源
(DCU)'''),
              Tab(text: '專案'),
            ],
          ),
        ),
        body: const TabBarView(children: <Widget>[
            Text('TabsView 1'),
            Text('TabsView 2'),
            Text('TabsView 3'),
            Project(),
        ]),
      ),
    );
  }
}
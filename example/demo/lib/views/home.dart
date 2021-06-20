import 'package:demo/actions/post_actions.dart';
import 'package:demo/actions/actions.dart' as actions;
import 'package:demo/refs.dart';
import 'package:demo/widgets/post_list_widget.dart';
import 'package:demo/widgets/user_post_list.dart';
import 'package:flutter/material.dart';
import 'package:nano/nano.dart' as n;

class HomeView extends StatefulWidget {
  HomeView({Key key}) : super(key: key);

  @override
  _HomeViewState createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> with TickerProviderStateMixin {
  final authStore = authRef.store;
  final color = n.Writable(state: Colors.redAccent);
  TabController controller;
  @override
  void initState() {
    controller = TabController(length: 2, vsync: this);
    super.initState();
    controller.addListener(() {
      if (!controller.indexIsChanging) if (controller.index == 0)
        color.add(Colors.redAccent);
      else
        color.add(Colors.deepPurpleAccent);
    });
    // PostActions.fetch(onError: (e) => e).run();
    n.Action(actions.fetch,onError: (e) => e).run();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(102),
          child: n.StateBuilder<Color>(
            stream: color.stream,
            initialState: color.state,
            onData: (_, data) => AppBar(
              backgroundColor: data,
              title: Text("Demo App"),
              bottom: TabBar(
                  indicatorColor: Colors.white,
                  controller: controller,
                  tabs: [Tab(text: "You"), Tab(text: "All")]),
            ),
          ),
        ),
        body: TabBarView(
          controller: controller,
          children: [UserPosts(), PostList()],
        ),
      ),
    );
  }
}

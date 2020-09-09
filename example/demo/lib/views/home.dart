import 'package:demo/actions/post_actions.dart';
import 'package:demo/models/auth_model.dart';
import 'package:demo/refs.dart';
import 'package:demo/views/authenticate.dart';
import 'package:demo/widgets/post_list_widget.dart';
import 'package:demo/widgets/user_post_list.dart';
import 'package:flutter/material.dart';
import 'package:nano/nano.dart';

class HomeView extends StatefulWidget {
  HomeView({Key key}) : super(key: key);

  @override
  _HomeViewState createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> with TickerProviderStateMixin {
  final authStore = authRef.store;
  final color = Writable(state: Colors.redAccent);
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
    PostActions.fetch(onError: (e) => e).run();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(102),
          child: StateBuilder<Color>(
            stream: color.stream,
            initialState: color.state,
            onData: (_, data) => AppBar(
              backgroundColor: data,
              title: Text("Demo App"),
              bottom: TabBar(
                  indicatorColor: Colors.white,
                  controller: controller,
                  tabs: [
                    Tab(text: "All"),
                    Tab(
                      text: "You",
                    )
                  ]),
            ),
          ),
        ),
        body: TabBarView(
          controller: controller,
          children: [PostList(), UserPosts()],
        ),
      ),
    );
  }
}

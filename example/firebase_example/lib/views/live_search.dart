import 'package:flutter/material.dart';
import 'package:nano/nano.dart';
import '../refs.dart';

class LiveSearchView extends StatefulWidget {
  LiveSearchView({Key key}) : super(key: key);

  @override
  _LiveSearchViewState createState() => _LiveSearchViewState();
}

class _LiveSearchViewState extends State<LiveSearchView> {
  final search = Writable<List<String>>(setInitialState: false);
  final contacts = contactRef.store.cData.contacts;
  void onChange(String name) {
    final temp = contacts
        .where((element) =>
            element.name.toLowerCase().contains(name.toLowerCase()))
        .map((e) => e.name)
        .toList();
    if (temp.isEmpty)
      search.addError("Empty");
    else
      search.add(temp);
  }

  @override
  void dispose() {
    search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          onChanged: onChange,
          decoration: InputDecoration(hintText: "Search here"),
        ),
      ),
      body: StateBuilder<List<String>>(
        initialState: search.state,
        stream: search.stream,
        waiting: (context) => Center(
          child: Text("Start typing to search for contact"),
        ),
        onError: (context, err) => Center(
          child: Text("Couldn't find any contact"),
        ),
        onData: (context, data) => ListView.builder(
          itemCount: data.length,
          itemBuilder: (context, index) => ListTile(
            title: Text(data[index]),
          ),
        ),
      ),
    );
  }
}

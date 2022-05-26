import 'dart:developer';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../models/band.dart';

class HomeView extends StatefulWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  List<Band> bands = [
    Band(id: '1', name: 'Pink floyd', votes: 5),
    Band(id: '2', name: 'Molotov', votes: 4),
    Band(id: '3', name: 'Enanitos verder', votes: 2),
    Band(id: '4', name: 'Black sabath', votes: 3),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 1,
        title: const Text(
          'Bands names',
          style: TextStyle(color: Colors.black87),
        ),
      ),
      body: ListView.builder(
        itemBuilder: ((context, index) => _BandTile(band: bands[index])),
        itemCount: bands.length,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNewBand,
        elevation: 1,
        child: const Icon(Icons.add),
      ),
    );
  }

  void _addNewBand() {
    if (Platform.isAndroid) {
      _showDialog('New band name', true);
    } else {
      _showDialog('New band name', false);
    }
  }

  void _showDialog(String title, bool isAndroid) {
    final textController = TextEditingController();
    isAndroid
        ? showDialog(
            context: context,
            builder: (context) => AlertDialog(
                  title: const Text('New band name'),
                  content: TextField(
                    controller: textController,
                  ),
                  actions: <Widget>[
                    TextButton(
                        onPressed: () => _saveNewBand(textController.text),
                        child: const Text(
                          'Add',
                          style: TextStyle(color: Colors.blue),
                        )),
                    TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          'Dissmiss',
                          style: TextStyle(color: Colors.red.shade400),
                        ))
                  ],
                ))
        : showCupertinoDialog(
            context: context,
            builder: (context) {
              return CupertinoAlertDialog(
                title: const Text('Add band name'),
                content: CupertinoTextField(controller: textController),
                actions: <Widget>[
                  CupertinoDialogAction(
                      isDefaultAction: true,
                      child: const Text('Add'),
                      onPressed: () => _saveNewBand(textController.text))
                ],
              );
            });
  }

  void _saveNewBand(String bandName) {
    if (bandName.isNotEmpty) {
      bands.add(Band(id: DateTime.now().toString(), name: bandName, votes: 0));
    }
    setState(() {});
    Navigator.pop(context);
  }
}

class _BandTile extends StatelessWidget {
  const _BandTile({
    Key? key,
    required this.band,
  }) : super(key: key);

  final Band band;

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(band.id),
      direction: DismissDirection.endToStart,
      background: Container(
        color: Colors.red.shade900,
        child: const Padding(
          padding: EdgeInsets.all(8.0),
          child: Align(
            alignment: Alignment.centerRight,
            child: Icon(
              Icons.delete_forever,
              color: Colors.white,
            ),
          ),
        ),
      ),
      onDismissed: _deletBand,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue[100],
          child: Text(band.name.substring(0, 2)),
        ),
        title: Text(band.name),
        trailing: Text('${band.votes}', style: const TextStyle(fontSize: 20)),
      ),
    );
  }

  void _deletBand(DismissDirection direction) {
    log('$direction');
    if (direction == DismissDirection.endToStart) {}
  }
}

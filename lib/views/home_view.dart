import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:pie_chart/pie_chart.dart';
import 'dart:io';
import 'package:provider/provider.dart';

import 'package:band_names/services/socket_service.dart';

import '../models/band.dart';

class HomeView extends StatefulWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  List<Band> bands = [];

  @override
  void initState() {
    final socketService = Provider.of<SocketService>(context, listen: false);

    socketService.socket.on('active-bands', (data) {
      bands = (data as List).map((band) => Band.fromMap(band)).toList();
      setState(() {});
    });
    super.initState();
  }

  @override
  void dispose() {
    final socketService = Provider.of<SocketService>(context);
    socketService.socket.off('active-bands');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final socketService = Provider.of<SocketService>(context);
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 1,
        title: const Text(
          'Bands names',
          style: TextStyle(color: Colors.black87),
        ),
        actions: <Widget>[
          Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              child: (socketService.status == ServerStatus.online)
                  ? Icon(Icons.check_circle, color: Colors.green.shade300)
                  : Icon(Icons.offline_bolt, color: Colors.red.shade300))
        ],
      ),
      body: Column(
        children: [
          _Graph(bands: bands),
          Expanded(
            child: ListView.builder(
              itemBuilder: ((context, index) => _BandTile(band: bands[index])),
              itemCount: bands.length,
            ),
          ),
        ],
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
      final socketService = Provider.of<SocketService>(context, listen: false);
      socketService.socket.emit('add-band', {'name': bandName});
    }

    Navigator.pop(context);
  }
}

class _Graph extends StatelessWidget {
  final List<Band> bands;

  const _Graph({
    Key? key,
    required this.bands,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Map<String, double> dataMap = Map();

    if (bands.isNotEmpty) {
      bands.forEach((band) =>
          dataMap.putIfAbsent(band.name, () => band.votes.toDouble()));
      final List<Color> colors = [
        Colors.blueAccent.shade400,
        Colors.blue.shade50,
        Colors.orange.shade600,
        Colors.pinkAccent,
        Colors.redAccent
      ];
      return Container(
        width: double.infinity,
        height: 200,
        child: PieChart(
          dataMap: dataMap,
          colorList: colors,
          animationDuration: const Duration(milliseconds: 800),
          chartLegendSpacing: 32,
          chartRadius: MediaQuery.of(context).size.width / 3.2,
          initialAngleInDegree: 0,
          chartType: ChartType.ring,
          ringStrokeWidth: 32,
          legendOptions: const LegendOptions(
            showLegendsInRow: false,
            legendPosition: LegendPosition.right,
            showLegends: true,
            legendShape: BoxShape.circle,
            legendTextStyle: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          chartValuesOptions: const ChartValuesOptions(
            showChartValueBackground: false,
            showChartValues: true,
            showChartValuesInPercentage: true,
            showChartValuesOutside: true,
            //decimalPlaces: 1,
          ),
        ),
      );
    } else {
      return Container();
    }
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
    final socketService = Provider.of<SocketService>(context);

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
      onDismissed: (_) {
        socketService.socket.emit('delete-band', {'id': band.id});
      },
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue[100],
          child: Text(band.name.substring(0, 2)),
        ),
        title: Text(band.name),
        trailing: Text('${band.votes}', style: const TextStyle(fontSize: 20)),
        onTap: () {
          socketService.socket.emit('votar-banda', {'id': band.id});
        },
      ),
    );
  }
}

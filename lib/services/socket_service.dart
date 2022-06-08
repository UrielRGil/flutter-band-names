import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

enum ServerStatus { online, offline, connecting }

class SocketService extends ChangeNotifier {
  ServerStatus _status = ServerStatus.connecting;
  late IO.Socket _socket;
  SocketService() {
    _initConfig();
  }

  ServerStatus get status => _status;

  IO.Socket get socket => _socket;

  void _initConfig() {
    _socket = IO.io(
        'http://192.168.0.114:3000',
        IO.OptionBuilder()
            .setTransports(['websocket']) // for Flutter or Dart VM
            .enableAutoConnect() // optional
            .build());

    _socket.onConnect((_) {
      _status = ServerStatus.online;
      log('Conectado');
      notifyListeners();
      _socket.emit('msj', 'Prueba de conexion');
    });
    _socket.onDisconnect((_) {
      _status = ServerStatus.offline;
      log('Disconnect');
      notifyListeners();
    });

    //socket.on('nuevo-mensaje', (data) {
    //  log('Nuevo mensaje');
    //  log('Nombre: ' + data['nombre']);
    //});
  }

  void update() {
    notifyListeners();
  }
}

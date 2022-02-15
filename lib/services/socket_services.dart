

import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

enum ServerStatus {
  Online,
  Offline,
  Connecting,
}

class SocketService with ChangeNotifier{

  ServerStatus _serverStatus =ServerStatus.Connecting;
  late IO.Socket _socket;

  ServerStatus get serverStatus => _serverStatus;
  IO.Socket  get socket => _socket;

  Function get emit => _socket.emit;


  SocketService() {
    this._initConfig();
  }

  void _initConfig(){
    debugPrint('iNIT CONFIG EN SOCKET SERVICE');

    String urlSocket = 'http://192.168.1.201:3000';
  
    _socket = IO.io(
        urlSocket,
        IO.OptionBuilder()
            .setTransports(['websocket']) // for Flutter or Dart VM
            .enableAutoConnect()
            //.setExtraHeaders({'foo': 'bar'}) // optional
            .build()
    );
    

    //Estado conectado
    _socket.onConnect((_) {
      debugPrint('Conectado por Socket');
      _serverStatus = ServerStatus.Online;
      notifyListeners();
    });

    // Estado Desconectado
    _socket.onDisconnect((_) {
      debugPrint('Desconectado del Socket Server');
      _serverStatus = ServerStatus.Offline;
      notifyListeners();
    });

  }


}



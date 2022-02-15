import 'package:band_name/services/socket_services.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


class StatusPage extends StatelessWidget {
  const StatusPage({Key? key}) : super(key: key);

  

  @override
  Widget build(BuildContext context) {
    debugPrint('Build status');

    final socketService =  Provider.of<SocketService>(context);
    
    debugPrint(socketService.toString());

    return  Scaffold(
      body: Center( 
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children:[
            Text('ServerStatus:${socketService.serverStatus}'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.message),
        onPressed: (){
          socketService.socket.emit('emitir-mensaje',{
            'nombre':'FLUTTER', 'mensaje':'Hola desde flutter',
          });
        },
      ),
   );
  }
}
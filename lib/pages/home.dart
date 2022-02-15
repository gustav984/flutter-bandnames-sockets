
import 'dart:io';

import 'package:band_name/models/band.dart';
import 'package:band_name/services/socket_services.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({ Key? key }) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

 List<Band> bands=[
   Band(id: '1',name: 'Oasis',votes: 7),
   Band(id: '2',name: 'Soda Stereo',votes: 5),
   Band(id: '3',name: 'Queen',votes: 11),
   Band(id: '4',name: 'Blur',votes: 3),
 ];

 @override
  void initState() {
    final socketService =  Provider.of<SocketService>(context,listen: false);

    socketService.socket.on('bandas-activas', _handleActiveBands);
    super.initState();

  }

  _handleActiveBands(dynamic payload){
      bands = (payload as List)
        .map( (band) => Band.fromMap(band))
        .toList();

      setState(() {});
  }

  @override
  void dispose() {
    final socketService =  Provider.of<SocketService>(context,listen: false);
    socketService.socket.off('bandas-activas');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

     final socketService =  Provider.of<SocketService>(context);

    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        title: Text('BandNames',style: TextStyle(color: Colors.black87),),
        backgroundColor: Colors.white,
        centerTitle: true,
        actions: [
          Container(
            margin:const EdgeInsets.only(right: 10),
            child:(socketService.serverStatus==ServerStatus.Online)
              ?Icon(Icons.check_circle,color: Colors.blue[300])
              :Icon(Icons.offline_bolt,color: Colors.red[300])
          ),
        ],
      ),
      body: Column(
        children: [
          _showGraph(),
          Expanded(
            child: ListView.builder(
              itemCount: bands.length,
              itemBuilder: (BuildContext context, int index) {  
                return _bandTile(bands[index]);
              },
            ),
          ),
        ],
      ),
      floatingActionButton:FloatingActionButton(
        elevation: 1,
        child: Icon(Icons.add),
        onPressed: addNewBand
      ) ,
    );
  }

  Dismissible _bandTile(Band band) {

    final socketService=Provider.of<SocketService>(context,listen: false);
     
    return Dismissible(
      key: Key(band.id!),
      direction: DismissDirection.startToEnd,
      onDismissed: (direction){
        socketService.emit('delete-band',{'id':band.id});//Elimina 
      },
      background: Container(
        padding: EdgeInsets.only(left: 8.0),
        color: Colors.red,
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text('Delete band',style: TextStyle(color: Colors.white),)
        ),
      ),
      child: ListTile(
        leading: CircleAvatar(
          child: Text(band.name!.substring(0,2)),
          backgroundColor: Colors.blue[100],
        ),
        title: Text(band.name!),
        trailing: Text( '${band.votes}',style: TextStyle(fontSize: 20),),
        onTap: () {
           socketService.socket.emit('vote-band',{'id':band.id});
        },
      ),
    );
  }

  addNewBand(){
    final textController=new TextEditingController();

    if(Platform.isAndroid){
      return showDialog(
        context: context,
        builder: (context){
          return AlertDialog(
            title: Text('New Band name:'),
            actions: [
              MaterialButton(
                child: Text('Add'),
                onPressed: ()=> addBandToList(textController.text)
              )
            ],
            content: TextField(
              controller: textController,
            ),
          );
        }
      );
    }

    showCupertinoDialog(
      context: context,
       builder: (_){
         return CupertinoAlertDialog(
           title: Text('New band name:'),
           content: CupertinoTextField(
             controller: textController,
           ),
           actions: [
              CupertinoDialogAction(
                isDefaultAction: true,
                 child: Text('Add'),
                 onPressed:()=> addBandToList(textController.text) ,
              ),
              CupertinoDialogAction(
                isDefaultAction: true,
                 child: Text('Dismiss'),
                 onPressed:()=>Navigator.pop(context) ,
              )
           ],
         );
       }
    );
    
    
  }

  void addBandToList(String name){
    final socketService=Provider.of<SocketService>(context,listen: false);

    if(name.length>1){
      socketService.emit('add-band',{'name':name});
    }
    Navigator.pop(context);
  }

  Widget _showGraph(){

    Map<String, double> dataMap=new Map();
    //dataMap.putIfAbsent('Flutter',()=>5);
    bands.forEach((band) {
       dataMap.putIfAbsent(band.name!, () => band.votes!.toDouble());
    });
    
    final List<Color> colorList=[
       Colors.blue[50]!,
       Colors.blue[200]!,
       Colors.pink[50]!,
       Colors.pink[200]!,
       Colors.yellow[50]!,
       Colors.yellow[200]!,
       Colors.red[50]!,
       Colors.red[200]!,
    ];
    
    return Container(
      padding:const EdgeInsets.all(10),
      //width: double.infinity,
      child: PieChart(
        dataMap: dataMap,
        animationDuration: Duration(milliseconds: 800),
        chartLegendSpacing: 32,
        colorList: colorList,
        initialAngleInDegree: 0,
        chartType: ChartType.disc,
        ringStrokeWidth: 32,
        legendOptions:const LegendOptions(
          showLegendsInRow: false,
          legendPosition: LegendPosition.right,
          showLegends: true,
          legendShape: BoxShape.circle,
          legendTextStyle: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        chartValuesOptions:const ChartValuesOptions(
          showChartValueBackground: true,
          showChartValues: true,
          showChartValuesInPercentage: true,
          showChartValuesOutside: false,
          decimalPlaces: 1,
        ),
        // gradientList: ---To add gradient colors---
        // emptyColorGradient: ---Empty Color gradient---
      ),
    );

  }


}
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/webSocketService.dart';

class ConnectedUsersPage extends StatefulWidget {
  @override
  _ConnectedUsersPageState createState() => _ConnectedUsersPageState();
}

class _ConnectedUsersPageState extends State<ConnectedUsersPage> {
  final WebSocketService webSocketService = Get.find<WebSocketService>();
  List<String> connectedUsers = [];

  @override
  void initState() {
    super.initState();
    webSocketService.listenToConnectedUsers((users) {
      setState(() {
        connectedUsers = users;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Usuarios Conectados')),
      body: ListView.builder(
        itemCount: connectedUsers.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text('Usuario: ${connectedUsers[index]}'),
          );
        },
      ),
    );
  }
}

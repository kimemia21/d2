import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class WebSocketExample extends StatefulWidget {
  @override
  _WebSocketExampleState createState() => _WebSocketExampleState();
}

class _WebSocketExampleState extends State<WebSocketExample> {
  @override
  void initState() {
    super.initState();
    setupWebSocketConnection();
  }

  void setupWebSocketConnection() {
    // Create a socket instance and configure it
    IO.Socket socket = IO.io(
     'ws://127.0.0.1:8000/socket.io/',
      IO.OptionBuilder().setTransports(['websocket'])

          .enableReconnection()
          .setReconnectionDelayMax(2)

          // .setre
          // .setReconnection(true)
          .build(),
    );
 socket.connect();
  if (socket.connected) {
  print('Socket is connected');
} else {

  print('Socket is not connected');
  socket.onError((error) {

  print('Socket error: $error');
});
}

    // Check connection status
    socket.onConnect((_) {
      print('Connected to WebSocket server');
    });

    // Handle connection error
    socket.onConnectError((error) {
      print('Connection Error step 2: $error');
    });

    // Handle disconnection
    socket.onDisconnect((_) {
      print('Disconnected from WebSocket server');
    });

    // Listen for incoming messages (replace 'product_update' with your event name)
    
    socket.on('product_update', (data) {
      print('Received message: $data');
      // Handle the received message (e.g., update UI)
    });

    // Emit messages to the server (optional)
    socket.emit('message', {'type': 'Hello Server'});

    // Close the connection when not needed
    // socket.close();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('WebSocket Example')),
      body: Center(child: Text('Check console for WebSocket status')),
    );
  }
}

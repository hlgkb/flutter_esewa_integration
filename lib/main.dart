import 'dart:convert';
import 'dart:convert' as prefix0;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  static const platform = const MethodChannel('pagal101/payment');
  String message;
  String paidAmount;
  String errorMessage;

  @override
  void initState() {
    message = 'Amount paid via eSewa';
    paidAmount = '0';
    errorMessage = '';
    super.initState();
  }

  _listenToResponse(
    Function onSuccess,
    Function onCancled,
    Function onError,
  ) {
    platform.setMethodCallHandler((call) {
      switch (call.method) {
        case "eSewa#success":
          onSuccess(call.arguments);
          break;
        case "eSewa#cancled":
          onCancled(call.arguments);
          break;
        case "eSewa#error":
          onError(call.arguments);
          break;
        default:
      }
    });
  }

  initeSewaPayment({
    double amount,
    Function onSuccess,
    Function onCancled,
    Function onError,
  }) {
    try {
      platform.invokeMethod('payViaEsewa', <String, String>{
        "amount": amount.toString(),
        "productName": "Random Ticket"
      });
      _listenToResponse(onSuccess, onCancled, onError);
    } on PlatformException catch (e) {
      debugPrint(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text('Random Title'),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Invoke "debug painting" (press "p" in the console, choose the
          // "Toggle Debug Paint" action from the Flutter Inspector in Android
          // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
          // to see the wireframe for each widget.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              '${this.message}',
            ),
            Text(
              '${this.paidAmount}',
              style: Theme.of(context).textTheme.display1,
            ),
            Text(
              '${this.errorMessage}',
              style: Theme.of(context).textTheme.subtitle,
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          initeSewaPayment(
            amount: 120.0,
            onSuccess: (data) async {
              print("[initeSewaPayment][Success] Payment Successful.");
              Map<String, dynamic> jsonData = json.decode(data);
              print(jsonData['totalAmount']);
              await Future.delayed(Duration(microseconds: 300));
              setState(() {
                this.paidAmount = jsonData["totalAmount"].toString();
                this.errorMessage = '';
              });
            },
            onCancled: (data) async {
              print('[initeSewaPayment][Cancled] $data');
              await Future.delayed(Duration(microseconds: 300));
              setState(() {
                this.errorMessage = "You cancled the payment 🙄";
              });
            },
            onError: (error) async {
              print('[initeSewaPayment][Error] $error');
              await Future.delayed(Duration(microseconds: 300));
              setState(() {
                this.errorMessage = "Error occured 🤷‍♀️";
              });
            },
          );
        },
        tooltip: 'Pay using eSewa',
        child: Icon(Icons.payment),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

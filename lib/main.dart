import 'dart:math';
import 'dart:async';
import 'package:flutter/material.dart';
import 'rand.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
          scaffoldBackgroundColor: Colors.black, fontFamily: 'IBMPlexMono'),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _Label {
  int id;
  Color color;
  double top;
  double left;
  double rotate;
}

class _MyHomePageState extends State<MyHomePage> {
  List<_Label> _labels = List<_Label>();
  double _width, _height;
  bool _started = false;
  bool _startedOnce = false;
  static const int _max = 600;
  Stopwatch _sw = Stopwatch();
  int _prevElapsed;
  int _processed = 0;
  int _prevCount;
  double _accum;
  int _accumN;
  String _dopes = '';

  Random2 rand = Random2(0);

  void loop(){
      var label = _Label();    
      label.color = Color.fromARGB(
          255, 
          (rand.nextDouble()*255).round(),
          (rand.nextDouble()*255).round(),
          (rand.nextDouble()*255).round());
      label.top = rand.nextDouble()*_height;
      label.left = rand.nextDouble()*_width;
      label.rotate = rand.nextDouble()*pi*2;
      label.id = _processed;
      _processed++;

      if (_processed > _max){
        _labels.removeAt(0);

        if (_prevElapsed == null) {
          _prevElapsed = _sw.elapsedMilliseconds;
          _prevCount = _processed;
        }
        
        var diff = _sw.elapsedMilliseconds - _prevElapsed;
        
        if (diff > 500) {
          _prevElapsed = _sw.elapsedMilliseconds;
          var val = (_processed-_prevCount)/diff*1000;
          _dopes = val.toStringAsFixed(2) + ' Dopes/s';
          _accum += val;
          _accumN++;
          _prevElapsed = _sw.elapsedMilliseconds;
          _prevCount = _processed;
        }
      }
      _labels.add(label);

      setState(() {
        if (_started){
          Timer.run(loop);
        }
        else{
          _dopes = (_accum/_accumN).toStringAsFixed(2) + ' Dopes/s (AVG)';
        }
      });
  }

  void _buttonClick() {
    setState(() {
      if (!_started) {
        _started = _startedOnce = true;
        _dopes = 'Warming up..';
        _sw.start();
        _prevElapsed = null;
        _accum = 0;
        _accumN = 0;
      }
      else _started = false;
      
      Timer.run(loop);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_width == null){
      _width = MediaQuery.of(context).size.width;
      _height = MediaQuery.of(context).size.height;
    }

    var children = <Widget>[];

    _labels.forEach((element) {
      children.add(Transform(
        transform: Matrix4.translationValues(element.left, element.top, 0)..rotateZ(element.rotate),
        child: Text('Dope', style: TextStyle(color: element.color)),
        key: ValueKey(element.id),
      ));
    });

    if (_startedOnce)
      children.add(
        Align(
          alignment: Alignment.topCenter,
          child: Padding(
            padding: EdgeInsets.all(25.0), 
            child: 
            Container(
              padding: EdgeInsets.all(7.0),
              color: Colors.red,
              child: Text('$_dopes', style: TextStyle(color: Colors.white, backgroundColor: Colors.red))
          )
        )
      ));

    return Scaffold(
      body: 
        Stack(
          children: children,
        ),
      
      floatingActionButton: FlatButton(
        onPressed: _buttonClick,
        color: !_started ? Colors.green : Colors.red,
        textColor: Colors.white,
        child: !_started ? Text('@ Start') : Text('@ Stop') ,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat
    );
  }
}

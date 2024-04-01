import 'package:flutter/material.dart';
import 'package:inajiffy/main.dart';

class Splash extends StatefulWidget {
  const Splash({Key? key}) : super(key: key);

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _navigatetohome();
  }

  _navigatetohome() async {
    await Future.delayed(Duration(milliseconds: 1500), () {});
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>MyHomePage(title: 'Top Headlines', key: ValueKey('myHomePage'), urlToImage: '', description: '', content: '')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //backgroundColor: Colors.blue[900],
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.redAccent, Colors.blueAccent],
          ),
        ),
        child: Center(
          child: Container(
            child: CircleAvatar(
              backgroundImage: AssetImage('assets/inajiffynew.png'),
              radius: 100,
            ),
          ),
        ),
      ),
    );
  }
}






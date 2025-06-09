import 'package:flutter/material.dart';
import 'package:que/resources/style_manager.dart';

class NoWifiWidget extends StatelessWidget {
  const NoWifiWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Que'),
      ),
      body: Center(
        child: Column(children: [
          Container(
            width: 175.0,
            height: 175.0,
            child: Image.asset('assets/images/no_wifi.png', fit: BoxFit.contain,),
          ),
          Text('No Internet Connection', style: getBoldFont(color: Colors.black, fontSize: 20.0),)
        ], mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.center,),
      ),
    );
  }
}

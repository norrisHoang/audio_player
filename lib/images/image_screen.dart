import 'package:flutter/material.dart';

class ImageScreen extends StatefulWidget {
  final double widthScreen;
  final double heightScreen;

  const ImageScreen(this.widthScreen, this.heightScreen, {Key? key})
      : super(key: key);


  @override
  State<ImageScreen> createState() => _ImageScreenState();
}

class _ImageScreenState extends State<ImageScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [

          ],
        ),
      ),
    );
  }
}

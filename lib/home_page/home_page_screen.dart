import 'package:flutter/material.dart';
import 'package:flutter_demo_widget_41_50/images/image_screen.dart';

import '../audio_players/audio_player_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late double widthScreen;
  late double heightScreen;

  @override
  Widget build(BuildContext context) {
    widthScreen = MediaQuery.of(context).size.width;
    heightScreen = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildButton(
                  context, 'Images', ImageScreen(widthScreen, heightScreen)),
              _buildButton(context, 'Audio Players', const AudioPlayerScreen()),
              // _buildButton(context, 'Path Provider',
              //     PathProviderScreen(widthScreen, heightScreen)),
              // _buildButton(context, 'AboutDialog',
              //     AboutDialogScreen(widthScreen, heightScreen)),
              // _buildButton(context, 'CheckboxListTile',
              //     CheckboxListTileScreen(widthScreen, heightScreen)),
              // _buildButton(context, 'ShaderMask',
              //     ShaderMaskScreen(widthScreen, heightScreen)),
              // _buildButton(context, 'ListWheelScrollView',
              //     ListWheelScrollViewScreen(widthScreen, heightScreen)),
              // _buildButton(context, 'SnackBar',
              //     SnackBarScreen(widthScreen, heightScreen)),
              // _buildButton(
              //     context, 'Drawer', DrawerScreen(widthScreen, heightScreen)),
              // _buildButton(context, 'TabBar', const TabBarScreen()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildButton(
      BuildContext context, String text, StatefulWidget screen) {
    return Center(
      child: GestureDetector(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (BuildContext context) => screen,
          ),
        ),
        child: Container(
          width: widthScreen * 0.3,
          height: heightScreen * 0.1,
          margin: const EdgeInsets.only(top: 20),
          alignment: Alignment.center,
          color: Colors.blue,
          child: Text(text,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white)),
        ),
      ),
    );
  }
}

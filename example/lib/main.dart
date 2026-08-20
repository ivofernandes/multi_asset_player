import 'package:flutter/material.dart';
import 'package:multi_asset_player/multi_asset_player.dart';

void main() => runApp(const ExampleApp());

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Multi Asset Player',
      theme: ThemeData(colorSchemeSeed: Colors.indigo),
      home: const DefaultTabController(
        length: 4,
        child: Scaffold(
          appBar: TabBar(
            tabs: [
              Tab(text: 'Image'),
              Tab(text: 'SVG'),
              Tab(text: 'Text'),
              Tab(text: 'JSON'),
            ],
          ),
          body: TabBarView(
            children: [
              MultiAssetPlayer('assets/logo.png'),
              MultiAssetPlayer('assets/turing_deal_logo.svg'),
              MultiAssetPlayer('assets/readme.txt'),
              MultiAssetPlayer('assets/config.json'),
            ],
          ),
        ),
      ),
    );
  }
}

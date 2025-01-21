import 'dart:async';

import 'package:flutter/material.dart';
import 'package:morning_cli_ui_app/src/commands/commands_handler.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String deployedServices = 'loading...';
  int counter = 0;
  bool isDeploying = false;
  String deployingLog = '';
  final _scrollController = ScrollController();

  void updateValue(String value) {
    setState(() {
      deployedServices = value;
      counter = '-service'.allMatches(deployedServices).isNotEmpty ? '-service'.allMatches(deployedServices).length + 1 : 0;
    });
  }

  @override
  void initState() {
    super.initState();
    Commands.showDeployed().then(updateValue);
    Timer.periodic(const Duration(seconds: 15), (Timer t) => Commands.showDeployed().then(updateValue));
  }

  @override
  Widget build(BuildContext context) {
    Future.delayed(Duration.zero, () {
        _scrollController.animateTo(_scrollController.position.maxScrollExtent, duration: const Duration(milliseconds: 100), curve: Curves.easeOut);
     });
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('morning-cli status'),
      ),
      body: Center(
        child: Column(
          children: [
             actionBar(),
             logWidget(),
             Divider(thickness: 2,),
             runningWidget()
          ]
        )
      ),
    );
  }

  Widget runningWidget(){
    return Column(
      children: [
        Text('Deployed services count: $counter'),
        Text(deployedServices),
      ],
    );
  }

  Widget logWidget(){
    return SizedBox(
      height: 300,
      child: Column(children: [
        if(isDeploying)
          IconButton(
            icon: const Icon(Icons.close_sharp, color: Colors.red,),
            onPressed: () {
              Commands.kill();
            }),
        Container(
          child: NotificationListener<ScrollNotification>(
                  child: SingleChildScrollView(
                  controller: _scrollController,
                  child: Container(color: Colors.black ,child: Text(deployingLog, style: const TextStyle(color: Colors.lightGreen)))).expanded(),
        ))
      ]),
    );
  }

  Widget actionBar(){
    return isDeploying ? const LinearProgressIndicator() : Container(
      color: Theme.of(context).colorScheme.secondaryFixedDim,
      child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
                icon: const Icon(Icons.play_arrow),
                onPressed: () {
                  setState(() {
                    deployingLog = '';
                    isDeploying = true;
                  });
                  Commands.deployAll().then((stream){
                    stream.listen((log){
                      print(log);
                      setState(() {
                        deployingLog += Commands.cleanOutput(log);
                      });
                    }, onDone: (){
                      setState(() {
                        isDeploying = false;
                      });
                    });
                  });
                }),
          ]),
    );
  }

  @override
  void dispose() {
    super.dispose();
    Commands.kill();
  }
}

extension on Widget {
  Widget expanded() => Expanded(child: this);
}

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:morning_cli_ui_app/src/commands/commands_handler.dart';
import 'package:split_view/split_view.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';

import '../split_view_page/split_view_page.dart';

const amountOfServices = 28;
const version = '0.0.1';

class MyHomePage extends StatefulWidget  {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  String deployedServices = 'loading...';
  int counter = 0;
  bool isDeploying = false;
  bool restarting = false;
  String deployingLog = '';
  final _scrollController = ScrollController();
  DateTime start = DateTime.now();
  DateTime end = DateTime.now();
  final StopWatchTimer _stopWatchTimer = StopWatchTimer();
  final splitViewController = SplitViewController();
  late final AnimationController _controller  = AnimationController(vsync: this);

  void updateDeployedService(String value) {
    setState(() {
      deployedServices = value;
      counter = '-service'.allMatches(deployedServices).isNotEmpty
          ? '-service'.allMatches(deployedServices).length + 1
          : 0;
    });
  }

  @override
  void initState() {
    super.initState();
    Commands.showDeployed().then(updateDeployedService);
    Timer.periodic(const Duration(seconds: 15),
        (Timer t) => Commands.showDeployed().then(updateDeployedService));
  }

  @override
  Widget build(BuildContext context) {
    if(_scrollController.hasClients && _scrollController.position.maxScrollExtent - _scrollController.position.pixels < 300) {
        _scrollController.animateTo(_scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 100), curve: Curves.easeOut);
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: actionBar(),
      ),
      body: ResizableScreen(
        top: runningServicesWidget(),
        bottom: logWidget(),
        controller: splitViewController
      ),
    );
  }

  Widget runningServicesWidget() {
    return Stack(
      fit: StackFit.expand,
      clipBehavior: Clip.antiAliasWithSaveLayer,
      children: [
        // if(isDeploying)
        //   Lottie.asset(
        //     alignment: Alignment.topCenter,
        //     fit: BoxFit.fitHeight,
        //     'assets/deploy.json',
        //   ),
        SingleChildScrollView(
          child: Column(children:[
            if(isDeploying)
              LinearProgressIndicator(value: counter / amountOfServices, minHeight: 10, color: Colors.deepPurple),
              // Lottie.asset(
              //   alignment: Alignment.topCenter,
              //   fit: BoxFit.fitHeight,
              //   'assets/deploy.json',
              // )
            // if(isDeploying)
            //   Lottie.asset(
            //     alignment: Alignment.topCenter,
            //     fit: BoxFit.fitHeight,
            //     'assets/deploy.json',
            //   ),
            Text('Deployed services: $counter'),
            Text(deployedServices),
          ]),
        )],
    );
  }

  Widget logWidget() {
    return Column(children: [
      if(isDeploying)
        const LinearProgressIndicator(),
      SingleChildScrollView(
              controller: _scrollController,
              child: Container(
                  width: double.infinity,
                  color: Colors.black,
                  child: Padding(
                      padding: const EdgeInsetsDirectional.all(10),
                      child: SelectableText(
                          deployingLog,
                          style: const TextStyle(color: Colors.lightGreen)
                      )))).expanded(),

    ]);
  }

  Widget actionBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        const Text('version: $version'),
        Spacer(),
        Row(mainAxisAlignment: MainAxisAlignment.start,
            children: [

          isDeploying ?
            IconButton(
                icon: const Icon(
                Icons.stop,
                color: Colors.red,
              ),
              onPressed: () {
              Commands.kill();
            })
          : IconButton(
              icon: const Icon(Icons.play_arrow, color: Colors.green),
              onPressed: () async {
                setState(() {
                  deployingLog = '';
                  isDeploying = true;
                  _stopWatchTimer.onStartTimer();
                });
                Commands.deployAll().then((stream)  {
                  stream.listen((log) {
                    print(log);
                    setState(() {
                      deployingLog += Commands.cleanOutput(log);
                    });
                  }, onDone: () {
                    setState(() {
                      _stopWatchTimer.onStopTimer();
                      isDeploying = false;
                    });
                  });
                });
              }),
          if(!isDeploying)
            restarting ? const CircularProgressIndicator() : IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                restarting = true;
                Commands.restartDocker().then((_) => restarting = false).catchError((_) => restarting = false);
              }),
          if(isDeploying)
            Text('${(counter / amountOfServices * 100).toInt()}%'),
        ]),
      ],
    );
  }

  @override
  void dispose() {
    super.dispose();
    Commands.kill();
  }
}

extension on Widget {
  Widget expanded({int flex = 1}) => Expanded(flex: flex, child: this);
}

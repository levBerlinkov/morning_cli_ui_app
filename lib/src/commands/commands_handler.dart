import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:async/async.dart';
import 'package:rxdart/streams.dart';

class Commands {
  static Future<String> showDeployed() async {
    final process = await Process.run('morning-cli', ['services', 'show-deployed']);
    _pids.add(process.pid);
    return cleanOutput(process.stdout as String);
  }

  static String cleanOutput(String output) {
    final ansiEscape = RegExp(r'\x1B\[[0-9;]*[A-Za-z]');
    return output.replaceAll(ansiEscape, '');
  }
  
  static final _pids = HashSet<int>();

  static Future<void> kill() async {
    for(int pid in _pids){
      Process.killPid(pid);
    }
    _pids.clear();
  }

  static Future<Stream<String>> deployAll() async  {
    final dockerUp = await Process.run('morning-cli', ['docker', 'down']);
    _pids.add(dockerUp.pid);
    print(dockerUp.stdout);
    print(dockerUp.stderr);
    final dockerDown =  await Process.run('morning-cli', ['docker', 'up']);
    _pids.add(dockerDown.pid);
    print(dockerDown.stdout);
    print(dockerDown.stderr);
    final process = await Process.start('morning-cli', ['services', 'deploy', '--all']);
    _pids.add(process.pid);

    return StreamGroup.merge<List<int>>([

      process.stdout,
      process.stderr]).transform(utf8.decoder);


  }
}

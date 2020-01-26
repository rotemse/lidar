import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'dart:convert';
//import 'package:dartson/dartson.dart';

class ProgStorage {
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/progNames.txt');
  }
  
  Future<List<String>> readNames() async {
    List<String> names = [
      "Option 1",
      "Option 2",
      "Option 3",
      "Option 4",
      "Option 5"
    ];
    try {
      final file = await _localFile;

      // Read the file
     // names = await file.readAsLines();
      
     // String s = file.readAsStringSync();
      names = (jsonDecode(file.readAsStringSync()) as List<dynamic>).cast<String>();
      //String contents = await file.readAsString();

      return names;
    } catch (e) {
      // If encountering an error, return 0
      print(e.toString());
      return names;
    }
  }

  Future<File> writeNames(List<String> names) async {
    final file = await _localFile;
    file.writeAsStringSync(jsonEncode(names));
   // names.forEach((n) {
  //    file.writeAsString(n+'\n');
  //  });
    // Write the file
    return file;
  }
}

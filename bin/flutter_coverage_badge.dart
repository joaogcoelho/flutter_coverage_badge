import 'dart:async';
import 'dart:io';

import 'package:args/args.dart';
import 'package:flutter_coverage_badge/flutter_coverage_badge.dart';
import 'package:path/path.dart' as p;
import 'package:process_run/process_run.dart';

Future main(List<String> args) async {
  final package = Directory.current;
  final parser = new ArgParser();

  parser.addFlag('help', abbr: 'h', help: 'Show usage', negatable: false);
  parser.addFlag(
    "merge_coverages",
    abbr: 'm',
    help:
        'Merges all lcovs from inside folders ending in "module", into one main lcov',
  );
  parser.addOption('input', abbr: 'i', help: 'Path of input file');
  parser.addOption('output', abbr: 'o', help: 'Name of output file');
  parser.addFlag('badge', help: 'Gernerate badge', defaultsTo: true);

  String? path;
  String? outputName;

  final options = parser.parse(args);

  if (options.wasParsed('help')) {
    print(parser.usage);
    return;
  }

  if (options.wasParsed('input')) {
    print('Loading coverage file from: ' + options['input']);
    path = options['input'];
  }

  if (options.wasParsed('output')) {
    print('Generated badge in: ' + '/.github/badges/' + options['output']);
    outputName = options['output'];
  }

  if (options.wasParsed('merge_coverages')) {
    _mergeCoverages(rootPath: path ?? "./");
  }

  final lineCoverage = calculateLineCoverage(
    File(path ?? 'coverage/lcov.info'),
  );
  generateBadge(package, lineCoverage, outputName);
  return;
}

Future<void> _mergeCoverages({
  required String rootPath,
}) async {
  List<String> modulesPath = await _getModulesPath(rootPath);
  String contentLcovToMerge = await _getContentLcovToMerge(modulesPath);

  _appendContentToMainLcov(contentLcovToMerge, rootPath: rootPath);
}

Future<List<String>> _getModulesPath(String rootPath) async {
  List<String> modulesPath = [];

  Completer completer = Completer<List<String>>();

  Directory directory = new Directory(rootPath);
  Stream<FileSystemEntity> lister = directory.list();
  Shell shell = Shell();

  lister.listen(
    (event) async {
      if (event.path.endsWith("_module")) {
        await shell.run('''flutter test --coverage''');
        modulesPath.add(event.path);
      }
    },
    onDone: () => completer.complete(modulesPath),
  );

  return await completer.future;
}

Future<String> _getContentLcovToMerge(List<String> modulesPath) async {
  String contentLcovs = "\n";

  for (var item in modulesPath) {
    String pathModuleLcov = p.absolute(item, 'coverage', 'lcov.info');

    await File(pathModuleLcov).readAsString().then((value) {
      contentLcovs += "$value";
      contentLcovs += "\n";
    });
  }

  return contentLcovs;
}

void _appendContentToMainLcov(
  String content, {
  required String rootPath,
}) {
  String pathMainLcov = p.absolute(rootPath, 'coverage', 'lcov.info');
  File(pathMainLcov).writeAsString(content, mode: FileMode.append);
}

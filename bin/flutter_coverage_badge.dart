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
    print("Buscando por modulos de microApp...");
    await _mergeCoverages(rootPath: path ?? "./");
    print("Merge de lcovs realizado com sucesso!");
    return;
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
  String contentLcovs = await _getContentLcovsToMerge(modulesPath);

  await _appendContentToMainLcov(contentLcovs, rootPath: rootPath);
}

Future<List<String>> _getModulesPath(String rootPath) async {
  List<String> modulesPath = [];

  Directory directory = new Directory(rootPath);
  Stream<FileSystemEntity> lister = directory.list();
  Shell shell = Shell();

  await for (FileSystemEntity fileSystem in lister) {
    if (fileSystem.path.endsWith("_module")) {
      print('Iniciando teste em moludo: ${fileSystem.path}');

      await shell.run(
        'cd ${fileSystem.path} && flutter test --coverage && cd ..',
      );

      modulesPath.add(fileSystem.path);
    }
  }

  return modulesPath;
}

Future<String> _getContentLcovsToMerge(List<String> modulesPath) async {
  String contentLcovs = "";

  for (var item in modulesPath) {
    contentLcovs = "\n";
    String pathModuleLcov = p.absolute(item, 'coverage', 'lcov.info');

    await File(pathModuleLcov).readAsString().then((value) {
      contentLcovs += "$value";
    });
  }

  return contentLcovs;
}

Future<void> _appendContentToMainLcov(
  String content, {
  required String rootPath,
}) async {
  String pathMainLcov = p.absolute(rootPath, 'coverage', 'lcov.info');
  await File(pathMainLcov).writeAsString(content, mode: FileMode.append);
}

import 'dart:io';

import 'package:args/args.dart';
import 'package:flutter_coverage_badge/flutter_coverage_badge.dart';

Future main(List<String> args) async {
  final package = Directory.current;
  final parser = new ArgParser();

  parser.addFlag('help', abbr: 'h', help: 'Show usage', negatable: false);
  parser.addFlag('input',
      abbr: 'i', help: 'Path of input file', negatable: false);
  parser.addFlag('output',
      abbr: 'o', help: 'Name of output file', negatable: false);
  parser.addFlag('badge', help: 'Gernerate badge', defaultsTo: true);

  String? path;
  String? outputName;

  final options = parser.parse(args);

  if (options.wasParsed('help')) {
    print(parser.usage);
    return;
  }

  if (options.wasParsed('input')) {
    path = parser.findByNameOrAlias('input')?.valueOrDefault('');
  }

  if (options.wasParsed('output')) {
    outputName = parser.findByNameOrAlias('output')?.valueOrDefault('');
  }

  final lineCoverage =
      calculateLineCoverage(File(path ?? 'coverage/lcov.info'));
  generateBadge(package, lineCoverage, outputName);
  return;
}

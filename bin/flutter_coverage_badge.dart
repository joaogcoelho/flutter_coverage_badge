import 'dart:io';

import 'package:args/args.dart';
import 'package:flutter_coverage_badge/flutter_coverage_badge.dart';

Future main(List<String> args) async {
  final package = Directory.current;
  final parser = new ArgParser();

  parser.addFlag('help', abbr: 'h', help: 'Show usage', negatable: false);
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

  final lineCoverage =
      calculateLineCoverage(File(path ?? 'coverage/lcov.info'));
  generateBadge(package, lineCoverage, outputName);
  return;
}

/// Configuration for using `package:build`-compatible build systems.
///
/// This library is **not** intended to be imported by typical end-users unless
/// you are creating a custom compilation pipeline.
///
/// See [package:build_runner](https://pub.dev/packages/build_runner)
/// for more information.
library builder;

import 'dart:async';
import 'package:meta/meta.dart';
import 'package:build/build.dart';
import 'package:pubspec_parse/pubspec_parse.dart';
import 'package:source_gen/source_gen.dart';

Future<String> _pubspecSource({
  @required BuildStep buildStep,
  @required _FieldNames fields,
}) async {
  final assetId = AssetId(buildStep.inputId.package, 'pubspec.yaml');
  final content = await buildStep.readAsString(assetId);
  final pubspec = Pubspec.parse(content, sourceUrl: assetId.uri);

  final buff = StringBuffer();

  const _header =
      '''// Generated file. Do not modify.\n//\n// This file is generated using the build_pubspec package.\n// For more information, go to: https://pub.dev/packages/build_pubspec''';

  buff.writeln(_header);

  if (pubspec.authors != null && pubspec.authors.isNotEmpty) {
    buff.writeln('''const List<String> ${fields.authorsFieldName} = [''');
    final writeAuthor = (author) => buff.writeln('''  '$author',''');
    pubspec.authors.forEach(writeAuthor);
    buff.writeln('''];''');
  }

  if (pubspec.description != null) {
    buff.writeln(
        """const String ${fields.descriptionFieldName} = '''${pubspec.description}'''; """);
  }

  if (pubspec.documentation != null) {
    buff.writeln(
        """const String ${fields.documentationFieldName} = '''${pubspec.documentation}''';""");
  }

  if (pubspec.homepage != null) {
    buff.writeln(
        """const String ${fields.homepageFieldName} = '''${pubspec.homepage}''';""");
  }

  if (pubspec.issueTracker != null) {
    buff.writeln(
        """const String ${fields.issueTrackerFieldName} = '''${pubspec.issueTracker}''';""");
  }

  if (pubspec.name != null) {
    buff.writeln(
        """const String ${fields.nameFieldName} = '''${pubspec.name}''';""");
  }

  if (pubspec.repository != null) {
    buff.writeln(
        """const String ${fields.repositoryFieldName} = '''${pubspec.repository}''';""");
  }

  if (pubspec.version != null) {
    buff.writeln(
        """const String ${fields.versionFieldName} = '''${pubspec.version}''';""");
  }

  return buff.toString();
}

Builder buildPubspec([BuilderOptions options]) => _PubspecBuilder(options);

Builder buildPubspecPart([BuilderOptions options]) {
  return PartBuilder(
    [_PubspecPartGenerator(_FieldNames.fromBuilderOptions(options))],
    '.pubspec.g.dart',
  );
}

class _FieldNames {
  _FieldNames(Map<String, dynamic> config)
      : authorsFieldName = _f(config, 'authors'),
        descriptionFieldName = _f(config, 'description'),
        documentationFieldName = _f(config, 'documentation'),
        homepageFieldName = _f(config, 'homepage'),
        issueTrackerFieldName = _f(config, 'issue_tracker'),
        nameFieldName = _f(config, 'name'),
        repositoryFieldName = _f(config, 'repository'),
        versionFieldName = _f(config, 'version');

  factory _FieldNames.fromBuilderOptions(BuilderOptions options) {
    return _FieldNames(options?.config ?? {});
  }

  static String _f(Map<String, dynamic> config, String name) {
    if (config == null) return name;
    final key = '${name}_field_name';
    return config[key] as String ?? name;
  }

  final String authorsFieldName;
  final String descriptionFieldName;
  final String documentationFieldName;
  final String homepageFieldName;
  final String issueTrackerFieldName;
  final String nameFieldName;
  final String repositoryFieldName;
  final String versionFieldName;
}

class _PubspecBuilder implements Builder {
  _PubspecBuilder([BuilderOptions options])
      : fields = _FieldNames.fromBuilderOptions(options);

  final _FieldNames fields;

  @override
  Future build(BuildStep buildStep) async {
    await buildStep.writeAsString(
      AssetId(buildStep.inputId.package, 'lib/src/pubspec.dart'),
      await _pubspecSource(buildStep: buildStep, fields: fields),
    );
  }

  @override
  final buildExtensions = const {
    r'$lib$': ['src/pubspec.dart']
  };
}

class _PubspecPartGenerator extends Generator {
  _PubspecPartGenerator(this.fields);

  final _FieldNames fields;

  @override
  Future<String> generate(LibraryReader library, BuildStep buildStep) =>
      _pubspecSource(buildStep: buildStep, fields: fields);
}

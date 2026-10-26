import 'package:serverpod/serverpod.dart';

/// Shows the Serverpod version and run mode via a web/templates template.
class BuiltWithServerpodPageWidget extends TemplateWidget {
  BuiltWithServerpodPageWidget() : super(name: 'built_with_serverpod') {
    values = {'served': DateTime.now(), 'runmode': Serverpod.instance.runMode};
  }
}


import 'dart:io';

import 'package:csslib/parser.dart' as css;
import 'package:csslib/visitor.dart';


StyleSheet parseCss(String cssInput, {List errors, List opts}) =>
    css.parse(cssInput, errors: errors, options: opts == null ?
        ['--no-colors', '--checked', 'memory'] : opts);

// Pretty printer for CSS.
var emitCss = new _ScopingCssPrinter();
String prettyPrint(StyleSheet ss) =>
    (emitCss..visitTree(ss, pretty: true)).toString();

main() {
  var filename = new Options().arguments[0];
  var ss = new File(filename).readAsStringSync();
  
  var errors = [];
  var stylesheet = parseCss(ss, errors: errors);

  if (!errors.isEmpty) {
    print("Got ${errors.length} errors.\n");
    for (var error in errors) {
      print(error);
    }
  } else {
    // prettyPrint(stylesheet);
    print(prettyPrint(stylesheet));
  }

}

class _ScopingCssPrinter extends CssPrinter {
  visitSelector(Selector s) {
    var old = s.simpleSelectorSequences;
    var sl = [new ElementSelector(new Identifier('*', null), null), new ClassSelector(new Identifier('dalliance', null), null)];
    sl.add(new SimpleSelectorSequence(old[0], null, css.TokenKind.COMBINATOR_DESCENDANT));
    sl.addAll(s.simpleSelectorSequences.sublist(1));
    super.visitSelector(new Selector(sl, s.span));
  }
}
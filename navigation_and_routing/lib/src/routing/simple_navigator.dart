import 'package:bookstore/src/routing/simple_page.dart';
import 'package:bookstore/src/routing/stacking_logic.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

import '../routing.dart';

/// Replaces [Navigator] and automatically stack pages based on their url.
///
/// A list of [SimplePage] is required which replaces [Page] objects
///
/// A [StackingLogic] is required to determine which pages will be stacked
///
class SimpleNavigator extends StatelessWidget {
  final List<SimplePage> pages;
  final String currentUrl;
  final Key navKey;
  final StackingLogic stackingLogic;

  const SimpleNavigator(
      {Key? key,
        required this.navKey,
        required this.pages,
        required this.currentUrl,
        required this.stackingLogic})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    var newPages = <Page>[];

    // Not logged in etc
    if (pages.first.guardActive) {
      newPages.add(pages.first.child);
    }
    // Normal flow
    else {
      // Scaffold is added first, if exists
      final alwaysPresent = getScaffold();
      if (alwaysPresent != null) {
        newPages.add(alwaysPresent.child);
      }

      // Filtered stack
      final stack = stackingLogic.stack(pages);
      newPages.addAll(stack.map((e) => e.child));
    }

    debug(newPages);

    return Navigator(
      key: navKey,
      pages: newPages,
      onPopPage: (route, dynamic result) {
        if (route.settings is Page) {
          final redirect = stackingLogic.popRedirect(pages);
          if (redirect != null) {
            final routeState = RouteStateScope.of(context)!;
            routeState.go(redirect);
          }
        }

        return route.didPop(result);
      },
    );
  }

  SimplePage? getScaffold() {
    final scaffold = pages.firstWhereOrNull((element) => element.alwaysPresent);
    return scaffold;
  }

  static String? getParent(String path) {
    final regEx = RegExp('/.*(?=(\/))');
    final root = regEx.firstMatch(path);
    if (root != null) return root.group(0)!;

    return null;
  }

  // If nothing is found we return a container
  // Page blankPage() {
  //   return MaterialPage<dynamic>(
  //       child: Container(
  //     color: Colors.deepOrangeAccent,
  //   ));
  // }

  void debug(List<Page> newPages) {
    print('*******');
    print(
        'nav:${navKey.toString()} pathTemplate: "$currentUrl" pages given (* stacked):');
    for (final page in pages) {
      final s = newPages.firstWhereOrNull((element) => page.child == element);

      print('${page.url ?? '(scaffold)'} ${(s == null) ? '' : '*'}');
    }
  }
}

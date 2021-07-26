import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

import '../routing.dart';

class SimpleNavigator extends StatelessWidget {
  final List<SimplePage> pages;
  final String pathTemplate;
  final Key navKey;

  const SimpleNavigator({
    Key? key,
    required this.navKey,
    required this.pages,
    required this.pathTemplate,
  }) : super(key: key);

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
      final scaffold = getScaffold();
      if (scaffold != null) {
        newPages.add(scaffold.child);
      }

      // Filtered stack
      final stack = getStack();
      newPages.addAll(stack);
    }

    debug(newPages);

    return Navigator(
      key: navKey,
      pages: newPages,
      onPopPage: (route, dynamic result) {
        if (route.settings is Page) {
          // Find matching url for child that has a parent
          final child = pages.firstWhereOrNull((element) =>
              element.parentUrl != null && element.url == pathTemplate);

          // If child exists, go to parent
          if (child != null) {
            final routeState = RouteStateScope.of(context)!;
            routeState.go(child.parentUrl!);
          }
        }

        return route.didPop(result);
      },
    );
  }

  SimplePage? getScaffold() {
    final scaffold = pages.firstWhereOrNull((element) => element.scaffold);
    return scaffold;
  }

  List<Page> getStack() {
    return pages
        .where((element) => shouldStack(element.url ?? '', pathTemplate))
        .map((e) => e.child)
        .toList();
  }

  bool shouldStack(String current, String path) {
    if (current == path) return true;

    final p = getParent(path);
    if (p != null) return current.startsWith(p);

    return false;
  }

  String? getParent(String path) {
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
        'nav:${navKey.toString()} pathTemplate: "$pathTemplate" pages given (* stacked):');
    for (final page in pages) {
      final s = newPages.firstWhereOrNull((element) => page.child == element);

      print('${page.url} ${(s == null) ? '' : '*'}');
    }
  }
}

class SimplePage {
  final Page child;
  final bool guardActive;
  final bool scaffold;
  final String? url;
  final String? parentUrl;

  SimplePage(
      {required this.child,
      this.guardActive = false,
      this.scaffold = false,
      this.url,
      this.parentUrl})
      : assert(url == null && scaffold == true || url != null,
            'Url required. Except for scaffold');
}

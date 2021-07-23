import 'package:flutter/material.dart';

class SimpleNavigator extends StatelessWidget {
  final List<Page<dynamic>> pages;
  final PopPageCallback? onPopPage;
  final String pathTemplate;
  final Key navKey;
  final bool exactMatch;

  const SimpleNavigator(
      {Key? key,
      required this.navKey,
      required this.pages,
      required this.onPopPage,
      required this.pathTemplate,
      this.exactMatch = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    var newPages = <Page>[];
    if (exactMatch) {
      newPages.add(getExactMatch());
    } else {
      newPages.addAll(pages.take(lastMatch()));
    }

    print('pagesGiven: ${pages.length} '
        'pagesStacked: ${newPages.length} '
        'pathTemplate: $pathTemplate');
    for (final page in pages) {
      print(
          'key: ${page.key.toString()} ${(newPages.indexWhere((element) => element.key.toString() == page.key.toString()) != -1) ? ' * stacked' : ''}');
    }

    return Navigator(
      key: navKey,
      pages: newPages,
      onPopPage: onPopPage,
    );
  }

  // In case we don't need to stack pages, instead we only need 1 page
  Page getExactMatch() {
    for (final page in pages) {
      final pagePathMatch = getKey(page.key!);

      if (pathTemplate.contains(RegExp(pagePathMatch))) {
        return page;
      }
    }
    return blankPage();
  }

  // Reverse lookup of matching page
  int lastMatch() {
    for (int j = pages.length - 1; j >= 0; j--) {
      final pagePathMatch = getKey(pages[j].key!);

      if (pathTemplate.contains(RegExp(pagePathMatch))) {
        return j + 1;
      }
    }
    return 0;
  }

  // If nothing is found we return a container
  Page blankPage() {
    return MaterialPage<dynamic>(child: Container());
  }

  // Key's .toString() adds brackets, so we remove them
  String getKey(Key rawKey) {
    return rawKey.toString().replaceFirst('[<\'', '').replaceFirst('\'>]', '');
  }
}

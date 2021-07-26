// Copyright 2021, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:bookstore/src/routing/simple_navigator.dart';
import 'package:bookstore/src/routing/simple_page.dart';
import 'package:bookstore/src/routing/stacking_logic.dart';
import 'package:flutter/material.dart';

import '../routing.dart';
import '../screens/settings.dart';
import '../widgets/fade_transition_page.dart';
import 'authors.dart';
import 'books.dart';

/// Displays the contents of the body of [BookstoreScaffold]
class BookstoreScaffoldBody extends StatelessWidget {
  static GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>(debugLabel: 'innerNav');

  const BookstoreScaffoldBody({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var currentRoute = RouteStateScope.of(context)!.route;

    // A nested Router isn't necessary because the back button behavior doesn't
    // need to be customized.
    return SimpleNavigator(
      stackingLogic: AncestorStackingLogic(currentRoute.pathTemplate),
      currentUrl: currentRoute.pathTemplate,
      navKey: navigatorKey,
      pages: [
        SimplePage(
            url: '/authors',
            child: const FadeTransitionPage<void>(
              key: ValueKey('AuthorsScreen'),
              child: AuthorsScreen(),
            )),
        SimplePage(
            url: '/settings',
            child: const FadeTransitionPage<void>(
              key: ValueKey('SettingsScreen'),
              child: SettingsScreen(),
            )),
        SimplePage(
            url: '/books',
            child: FadeTransitionPage<void>(
              key: const ValueKey('BooksScreen'),
              child: BooksScreen(currentRoute: currentRoute),
            ))
      ],
    );
  }
}

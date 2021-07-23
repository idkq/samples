// Copyright 2021, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:bookstore/src/routing/simple_navigator.dart';
import 'package:flutter/material.dart';

import '../routing.dart';
import '../screens/settings.dart';
import '../widgets/fade_transition_page.dart';
import 'authors.dart';
import 'books.dart';

/// Displays the contents of the body of [BookstoreScaffold]
class BookstoreScaffoldBody extends StatelessWidget {
  static GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  const BookstoreScaffoldBody({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var currentRoute = RouteStateScope.of(context)!.route;

    // A nested Router isn't necessary because the back button behavior doesn't
    // need to be customized.
    return SimpleNavigator(
      exactMatch: true,
      pathTemplate: currentRoute.pathTemplate,
      navKey: navigatorKey,
      onPopPage: (route, dynamic result) => route.didPop(result),
      pages: [
        // REMOVED
        //if (currentRoute.pathTemplate.startsWith('/authors'))
          const FadeTransitionPage<void>(
            key: ValueKey('/authors'),
            child: AuthorsScreen(),
          ),
        // REMOVED
        //else if (currentRoute.pathTemplate.startsWith('/settings'))
          const FadeTransitionPage<void>(
            key: ValueKey('/settings'),
            child: SettingsScreen(),
          ),
        // REMOVED
        //else if (currentRoute.pathTemplate.startsWith('/books') ||
           // currentRoute.pathTemplate == '/')
          FadeTransitionPage<void>(
            key: const ValueKey('/books'),
            child: BooksScreen(currentRoute: currentRoute),
          )

          // Avoid building a Navigator with an empty `pages` list when the
          // RouteState is set to an unexpected path, such as /signin.
          //
          // Since RouteStateScope is an InheritedNotifier, any change to the
          // route will result in a call to this build method, even though this
          // widget isn't built when those routes are active.
        // else
        //   FadeTransitionPage<void>(
        //     key: const ValueKey('empty'),
        //     child: Container(),
        //   ),
      ],
    );
  }
}

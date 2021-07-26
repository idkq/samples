// Copyright 2021, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:bookstore/src/routing/simple_navigator.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

import '../auth.dart';
import '../data.dart';
import '../routing.dart';
import '../screens/sign_in.dart';
import '../widgets/fade_transition_page.dart';
import '../widgets/library_scope.dart';
import 'author_details.dart';
import 'book_details.dart';
import 'scaffold.dart';

/// Builds the top-level navigator for the app. The pages to display are based
/// on the [routeState] that was parsed by the TemplateRouteParser.
class BookstoreNavigator extends StatefulWidget {
  final GlobalKey<NavigatorState> navigatorKey;

  const BookstoreNavigator({
    required this.navigatorKey,
    Key? key,
  }) : super(key: key);

  @override
  _BookstoreNavigatorState createState() => _BookstoreNavigatorState();
}

class _BookstoreNavigatorState extends State<BookstoreNavigator> {
  @override
  Widget build(BuildContext context) {
    final routeState = RouteStateScope.of(context)!;
    final authState = BookstoreAuthScope.of(context)!;
    final pathTemplate = routeState.route.pathTemplate;
    final library = LibraryScope.of(context);

    Book? selectedBook;
    if (pathTemplate == '/book/:bookId') {
      selectedBook = library.allBooks.firstWhereOrNull(
          (b) => b.id.toString() == routeState.route.parameters['bookId']);
    }

    Author? selectedAuthor;
    if (pathTemplate == '/author/:authorId') {
      selectedAuthor = library.allAuthors.firstWhereOrNull(
          (b) => b.id.toString() == routeState.route.parameters['authorId']);
    }

    return SimpleNavigator(
      pathTemplate: pathTemplate,
      navKey: widget.navigatorKey,
      pages: [
        SimplePage(
            url: '/signin',
            guardActive: !authState.signedIn,
            child: FadeTransitionPage<void>(
              child: SignInScreen(
                onSignIn: (credentials) async {
                  var signedIn = await authState.signIn(
                      credentials.username, credentials.password);
                  if (signedIn) {
                    routeState.go('/books/popular');
                  }
                },
              ),
            )),
        // Display the app
        SimplePage(
            scaffold: true,
            child: const FadeTransitionPage<void>(
              child: BookstoreScaffold(),
            )),
        SimplePage(
            url: '/book/:bookId',
            parentUrl: '/books',
            child: MaterialPage<void>(
              child: BookDetailsScreen(
                book: selectedBook,
              ),
            )),
        SimplePage(
            url: '/author/:authorId',
            parentUrl: '/authors',
            child: MaterialPage<void>(
              child: (selectedAuthor != null)
                  ? AuthorDetailsScreen(
                      author: selectedAuthor,
                    )
                  : const SizedBox.shrink(),
            )),
      ],
    );
  }
}

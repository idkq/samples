import 'package:flutter/material.dart';

/// Replaces a [Page] object and add new attributes.
class SimplePage {
  final Page child;

  /// State of the current guard used for logins. If guard is active, show the
  /// respective guard screen
  final bool guardActive;

  /// Used to always stack a scaffold page, for nested navigators
  final bool alwaysPresent;

  /// URL of the current page
  final String? url;

  /// Used for automatically pop
  final String? parentUrl;

  SimplePage(
      {required this.child,
        this.guardActive = false,
        this.alwaysPresent = false,
        this.url,
        this.parentUrl})
      : assert(url == null && alwaysPresent == true || url != null,
  'Url required (except for scaffold)');
}

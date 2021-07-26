import 'package:bookstore/src/routing/simple_navigator.dart';
import 'package:bookstore/src/routing/simple_page.dart';
import 'package:collection/collection.dart';

abstract class StackingLogic {
  final String currentUrl;

  StackingLogic({required this.currentUrl});

  List<SimplePage> stack(List<SimplePage> pages) {
    return pages;
  }

  String? popRedirect(List<SimplePage> pages) {
    return null;
  }
}

/// The default stacking logic is based on a common ancestor. Example:
/// pages '/module1' and '/module1/screen2' will be stacked when url starts with
/// '/module1' because they have a common ancestor in the url path '/module1'.
/// In contrast, '/module2/' and '/module2/screen3' will not be stacked when
/// current url starts with '/module1'.
class AncestorStackingLogic extends StackingLogic {
  AncestorStackingLogic(String currentUrl) : super(currentUrl: currentUrl);

  @override
  List<SimplePage> stack(List<SimplePage> pages) {
    return pages
        .where((element) => shouldStack(element.url ?? '', currentUrl))
        .toList();
  }

  bool shouldStack(String current, String path) {
    if (current == path) return true;

    final p = SimpleNavigator.getParent(path);
    if (p != null) return current.startsWith(p);

    return false;
  }

  @override
  String? popRedirect(List<SimplePage> pages) {
    final redirect = pages.firstWhereOrNull(
            (element) => element.url == SimpleNavigator.getParent(currentUrl));
    return redirect?.url;
  }
}

/// Stacking logic based on the [SimplePage.parentUrl] attribute. Example:
/// page '/x' has a parent called '/y'. When stacking '/x'
/// '/y' will be automatically stacked underneath it because it is its parent.
///
/// When compared to [AncestorStackingLogic] this class gives greater
/// flexibility when choosing the url names because it does not depend on the
/// url characters and slashes but only if the parent matches or not. So it does
/// not matter if the string starts with something.
///
/// Recursive Multi levels are supported such as 'l1/l2/l3' in which 'l3's
/// parent is 'l2'. 'l2's parent is 'l1'.
class ParentStackingLogic extends StackingLogic {
  ParentStackingLogic(String currentUrl) : super(currentUrl: currentUrl);

  @override
  List<SimplePage> stack(List<SimplePage> pages) {
    return pages
        .where((element) => shouldStack(element, pages, currentUrl))
        .toList();
  }

  bool shouldStack(SimplePage current, List<SimplePage> all, String path) {
    if (current.url == path) return true;

    return getParent(current.url ?? '', all, path) != null;
  }

  // Recursive lookup
  String? getParent(String current, List<SimplePage> all, String path ){
    final parentUrl =
    all.firstWhereOrNull((element) => element.parentUrl == current);
    if (parentUrl!=null) {
      if (parentUrl.url == path) {
        return 'found stack';
      } else {
        return getParent(parentUrl.url!, all, path);
      }
    }

    return null;
  }

  @override
  String? popRedirect(List<SimplePage> pages) {
    final redirect = pages.firstWhereOrNull(
            (element) => element.url == SimpleNavigator.getParent(currentUrl));
    return redirect?.url;
  }
}

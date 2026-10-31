/// The back button inside the bottom-tab shell: a tab screen can claim it
/// first (for example to close a result and show its form again); otherwise
/// the shell goes to the Today tab, and from there asks before leaving.
class ShellBack {
  ShellBack._();

  static final _handlers = <(int, bool Function())>[];

  /// [handler] runs only while tab [tab] is showing. It returns true when it
  /// used the back press.
  static void add(int tab, bool Function() handler) => _handlers.add((tab, handler));

  static void remove(bool Function() handler) => _handlers.removeWhere((h) => h.$2 == handler);

  /// Gives the back press to the newest handler of [tab] that wants it.
  static bool handle(int tab) {
    for (final (t, h) in _handlers.reversed) {
      if (t == tab && h()) return true;
    }
    return false;
  }
}

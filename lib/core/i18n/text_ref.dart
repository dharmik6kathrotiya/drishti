/// A reference to a localizable text: a key plus parameters.
///
/// The engine returns these instead of finished sentences so the UI can
/// render them in the user's language (see EngineTexts). Parameter values may
/// be Planet, Sign, int, bool, String or lists of those; EngineTexts formats
/// them for the language.
class TextRef {
  const TextRef(this.key, [this.params = const {}]);

  final String key;
  final Map<String, Object> params;

  @override
  String toString() => 'TextRef($key, $params)';
}

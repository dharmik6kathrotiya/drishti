import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../core/geo/places.dart';
import '../../core/models/profile.dart';
import '../../l10n/app_localizations.dart';

/// Offline place search. Returns the chosen [Place].
Future<Place?> showPlaceSearch(BuildContext context) => showModalBottomSheet<Place>(
  context: context,
  isScrollControlled: true,
  useRootNavigator: true,
  showDragHandle: true,
  builder: (_) => const _PlaceSearchSheet(),
);

class _PlaceSearchSheet extends ConsumerStatefulWidget {
  const _PlaceSearchSheet();

  @override
  ConsumerState<_PlaceSearchSheet> createState() => _PlaceSearchSheetState();
}

class _PlaceSearchSheetState extends ConsumerState<_PlaceSearchSheet> {
  String _query = '';
  List<Place> _results = const [];
  Timer? _debounce;
  bool _manual = false;

  @override
  void dispose() {
    _debounce?.cancel();
    _lat.dispose();
    _lon.dispose();
    super.dispose();
  }

  /// Searching 170k places on every keystroke is wasteful; wait for a pause.
  void _onQuery(String v) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 220), () {
      final db = ref.read(placeDatabaseProvider).value;
      if (!mounted || db == null) return;
      setState(() {
        _query = v;
        _results = db.search(v);
      });
    });
  }

  final _lat = TextEditingController();
  final _lon = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final db = ref.watch(placeDatabaseProvider);
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SizedBox(
        height: MediaQuery.sizeOf(context).height * 0.8,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: TextField(
                autofocus: true,
                decoration: InputDecoration(prefixIcon: const Icon(Icons.search), hintText: l.searchPlaceHint),
                onChanged: _onQuery,
              ),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                icon: const Icon(Icons.edit_location_alt_outlined),
                label: Text(l.enterCoordinates),
                onPressed: () => setState(() => _manual = !_manual),
              ),
            ),
            if (_manual)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _lat,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                        decoration: InputDecoration(labelText: l.latitude),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _lon,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                        decoration: InputDecoration(labelText: l.longitude),
                      ),
                    ),
                    IconButton.filled(
                      icon: const Icon(Icons.check),
                      onPressed: db.hasValue ? () => _useCoordinates(db.value!) : null,
                    ),
                  ],
                ),
              ),
            Expanded(
              child: db.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('$e')),
                data: (db) {
                  final results = _results;
                  if (_query.length < 2) {
                    return Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(l.searchPlaceHelp, style: theme.textTheme.bodyMedium),
                    );
                  }
                  if (results.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(l.noPlacesFound, style: theme.textTheme.bodyMedium),
                    );
                  }
                  return ListView.builder(
                    itemCount: results.length,
                    itemBuilder: (_, i) {
                      final p = results[i];
                      return ListTile(
                        leading: const Icon(Icons.place_outlined),
                        title: Text(p.name),
                        subtitle: Text([p.region, db.countryName(p.countryCode)].where((s) => s.isNotEmpty).join(', ')),
                        trailing: Text(
                          '${p.latitude.toStringAsFixed(2)}, ${p.longitude.toStringAsFixed(2)}',
                          style: theme.textTheme.bodySmall,
                        ),
                        onTap: () => Navigator.pop(context, p),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _useCoordinates(PlaceDatabase db) {
    final lat = double.tryParse(_lat.text.trim());
    final lon = double.tryParse(_lon.text.trim());
    if (lat == null || lon == null || lat.abs() > 90 || lon.abs() > 180) return;
    final near = db.nearest(lat, lon);
    Navigator.pop(
      context,
      Place(
        name: '${lat.toStringAsFixed(4)}, ${lon.toStringAsFixed(4)}',
        region: near.name,
        countryCode: near.countryCode,
        latitude: lat,
        longitude: lon,
        timezoneId: near.timezoneId,
      ),
    );
  }
}

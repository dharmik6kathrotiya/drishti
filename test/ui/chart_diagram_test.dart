import 'package:drishti/core/astro/chart.dart';
import 'package:drishti/core/astro/constants.dart';
import 'package:drishti/core/astro/settings.dart';
import 'package:drishti/core/astro/vedic/divisional.dart';
import 'package:drishti/ui/charts/chart_diagram.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Builds a chart by hand (no ephemeris) with a few crowded signs and
/// retrograde planets to exercise label layout.
Chart fakeChart({bool withHouses = true, AstroSystem system = AstroSystem.vedic}) {
  const asc = 100.0; // Cancer 10°
  final lons = {
    Planet.sun: 101.0,
    Planet.moon: 103.0,
    Planet.mars: 104.5,
    Planet.mercury: 106.0,
    Planet.jupiter: 250.0,
    Planet.venus: 252.0,
    Planet.saturn: 330.0,
    Planet.rahu: 15.0,
    Planet.ketu: 195.0,
    if (system == AstroSystem.western) ...{Planet.uranus: 108.0, Planet.neptune: 290.0, Planet.pluto: 222.0},
  };
  final cusps = [for (var i = 0; i < 12; i++) norm360(asc + i * 30)];
  return Chart(
    jd: 2451545,
    settings: CalcSettings(system: system),
    ayanamsaValue: system == AstroSystem.vedic ? 23.85 : 0,
    ascendant: withHouses ? asc : null,
    midheaven: withHouses ? 10 : null,
    cusps: withHouses ? cusps : null,
    latitude: withHouses ? 28.6 : null,
    longitude: withHouses ? 77.2 : null,
    planets: {
      for (final e in lons.entries)
        e.key: PlanetPlacement(
          planet: e.key,
          longitude: e.value,
          latitude: 0,
          speed: e.key == Planet.saturn || e.key == Planet.mercury ? -0.05 : 0.5,
          house: withHouses ? Sign.fromLongitude(asc).countTo(Sign.fromLongitude(e.value)) : null,
        ),
    },
  );
}

Widget host(Widget child, {Brightness brightness = Brightness.light}) => MaterialApp(
  theme: ThemeData(colorSchemeSeed: Colors.deepPurple, brightness: brightness),
  home: Scaffold(body: Center(child: child)),
);

void main() {
  for (final style in ChartStyle.values) {
    for (final withHouses in [true, false]) {
      testWidgets('${style.name} renders (houses: $withHouses)', (tester) async {
        final chart = fakeChart(
          withHouses: withHouses,
          system: style == ChartStyle.westernWheel ? AstroSystem.western : AstroSystem.vedic,
        );
        await tester.pumpWidget(host(ChartDiagram(chart: chart, style: style, size: 320)));
        expect(tester.takeException(), isNull);
        expect(find.byType(CustomPaint), findsWidgets);

        // Dark theme and the smallest supported size.
        await tester.pumpWidget(
          host(
            ChartDiagram(chart: chart, style: style, size: 280),
            brightness: Brightness.dark,
          ),
        );
        expect(tester.takeException(), isNull);
      });
    }
  }

  testWidgets('Indian styles render divisional charts', (tester) async {
    for (final style in [ChartStyle.northIndian, ChartStyle.southIndian, ChartStyle.eastIndian]) {
      for (final varga in [Varga.d9, Varga.d10, Varga.d60]) {
        await tester.pumpWidget(host(ChartDiagram(chart: fakeChart(), style: style, varga: varga, size: 420)));
        expect(tester.takeException(), isNull);
      }
    }
  });

  testWidgets('North Indian top diamond is house 1', (tester) async {
    int? tapped;
    await tester.pumpWidget(
      host(ChartDiagram(chart: fakeChart(), style: ChartStyle.northIndian, size: 320, onHouseTap: (h) => tapped = h)),
    );
    final topLeft = tester.getTopLeft(find.byType(CustomPaint).last);
    await tester.tapAt(topLeft + const Offset(160, 80));
    expect(tapped, 1);
    await tester.tapAt(topLeft + const Offset(80, 160));
    expect(tapped, 4);
  });

  testWidgets('South Indian tap maps the ascendant sign to house 1', (tester) async {
    int? tapped;
    await tester.pumpWidget(
      host(ChartDiagram(chart: fakeChart(), style: ChartStyle.southIndian, size: 320, onHouseTap: (h) => tapped = h)),
    );
    final topLeft = tester.getTopLeft(find.byType(CustomPaint).last);
    // Cancer is row 1, column 3.
    await tester.tapAt(topLeft + const Offset(280, 120));
    expect(tapped, 1);
  });

  test('ChartView uses the Moon as lagna without birth time', () {
    final view = ChartView.from(fakeChart(withHouses: false), Varga.d1);
    expect(view.isMoonChart, isTrue);
    expect(view.lagna, Sign.cancer);
    expect(view.bySign.values.expand((l) => l).any((l) => l.isAscendant), isFalse);
  });
}

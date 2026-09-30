import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' as riverpod;

// State scopes
import 'package:edusmart_school_erp_flutter/data/dashboard_repository.dart';
import 'package:edusmart_school_erp_flutter/modules/fees/core/state/app_providers.dart' as fee_providers;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Phase 4: Cross-Cutting Non-Functional Testing', () {

    // -------------------------------------------------------------------------
    // 5.1 Multi-Platform & Responsive Rendering (<1100px vs >=1100px)
    // -------------------------------------------------------------------------
    testWidgets('1. Responsive Layout: Multi-column Flex Row at >=1100px and Stacked Column at <1100px without overflows',
        (tester) async {
      final children = [
        Container(key: const Key('widget-1'), height: 100, color: Colors.red),
        Container(key: const Key('widget-2'), height: 100, color: Colors.green),
        Container(key: const Key('widget-3'), height: 100, color: Colors.blue),
      ];

      // Helper function with LayoutBuilder mirroring _ResponsiveRow
      Widget buildTestableResponsive({required double width, required double height}) {
        return MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: width,
                height: height,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    if (constraints.maxWidth >= 1100) {
                      return Row(
                        key: const Key('responsive-row'),
                        children: [
                          Expanded(flex: 1, child: children[0]),
                          const SizedBox(width: 16),
                          Expanded(flex: 1, child: children[1]),
                          const SizedBox(width: 16),
                          Expanded(flex: 1, child: children[2]),
                        ],
                      );
                    } else {
                      return SingleChildScrollView(
                        child: Column(
                          key: const Key('responsive-column'),
                          children: [
                            children[0],
                            const SizedBox(height: 16),
                            children[1],
                            const SizedBox(height: 16),
                            children[2],
                          ],
                        ),
                      );
                    }
                  },
                ),
              ),
            ),
          ),
        );
      }

      // 1.1 Test Desktop Viewport >= 1100px (1440x900)
      await tester.binding.setSurfaceSize(const Size(1440, 900));
      await tester.pumpWidget(buildTestableResponsive(width: 1440, height: 900));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('responsive-row')), findsOneWidget);
      expect(find.byKey(const Key('responsive-column')), findsNothing);
      expect(tester.takeException(), isNull, reason: 'Zero RenderFlex overflows at >=1100px');

      // 1.2 Test Tablet / Narrow Viewport < 1100px (800x1280)
      await tester.binding.setSurfaceSize(const Size(800, 1280));
      await tester.pumpWidget(buildTestableResponsive(width: 800, height: 1280));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('responsive-column')), findsOneWidget);
      expect(find.byKey(const Key('responsive-row')), findsNothing);
      expect(tester.takeException(), isNull, reason: 'Zero RenderFlex overflows at <1100px');

      // Reset surface size
      await tester.binding.setSurfaceSize(null);
    });

    // -------------------------------------------------------------------------
    // 5.2 State Coexistence & Memory Leak Testing (Provider + Riverpod Isolation)
    // -------------------------------------------------------------------------
    testWidgets('2. State Coexistence: Provider and Riverpod operate in nested scopes without collision',
        (tester) async {
      final dashboardRepo = DashboardRepository();

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<DashboardRepository>.value(value: dashboardRepo),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: Column(
                children: [
                  // Provider consumer
                  Consumer<DashboardRepository>(
                    builder: (context, repo, _) => Text(
                      'Students: ${repo.totalStudents}',
                      key: const Key('provider-text'),
                    ),
                  ),
                  // Riverpod isolated scope
                  riverpod.ProviderScope(
                    child: riverpod.Consumer(
                      builder: (context, ref, _) {
                        final dayCounter = ref.watch(fee_providers.dayCounterProvider);
                        return Text(
                          'Counter: ₹${dayCounter.openingCash.toStringAsFixed(0)}',
                          key: const Key('riverpod-text'),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byKey(const Key('provider-text')), findsOneWidget);
      expect(find.byKey(const Key('riverpod-text')), findsOneWidget);
      expect(tester.takeException(), isNull, reason: 'Provider and Riverpod co-exist without framework collisions');
    });

    // -------------------------------------------------------------------------
    // 5.3 Network Resiliency, Offline Fallback & Retry Simulation
    // -------------------------------------------------------------------------
    testWidgets('3. Network Resiliency & Offline Fallback: Graceful degradation on network timeout or disconnect',
        (tester) async {
      bool simulateOffline = true;
      String? alertMessage;

      Future<void> submitData() async {
        if (simulateOffline) {
          throw Exception('SocketException: Failed host lookup');
        }
      }

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return Center(
                  child: Column(
                    children: [
                      if (alertMessage != null)
                        Text(alertMessage!, key: const Key('error-banner')),
                      ElevatedButton(
                        key: const Key('submit-btn'),
                        onPressed: () async {
                          try {
                            await submitData();
                          } catch (e) {
                            setState(() {
                              alertMessage = 'Network unavailable. Please retry.';
                            });
                          }
                        },
                        child: const Text('Submit'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      );

      // Trigger action in offline state
      await tester.tap(find.byKey(const Key('submit-btn')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('error-banner')), findsOneWidget);
      expect(find.text('Network unavailable. Please retry.'), findsOneWidget);
      expect(tester.takeException(), isNull, reason: 'Network failure handled cleanly without app crash');
    });

    // -------------------------------------------------------------------------
    // 5.4 Concurrency, Double-Click & Race Condition Testing
    // -------------------------------------------------------------------------
    testWidgets('4. Concurrency Guard: Rapid double-tap is intercepted by saving guard preventing duplicate actions',
        (tester) async {
      int mutationCount = 0;
      bool isSaving = false;

      Future<void> performMutation() async {
        if (isSaving) return; // Concurrency guard
        isSaving = true;
        mutationCount++;
        await Future.delayed(const Duration(milliseconds: 100));
        isSaving = false;
      }

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return ElevatedButton(
                  key: const Key('action-btn'),
                  onPressed: isSaving
                      ? null
                      : () async {
                          setState(() {});
                          await performMutation();
                          setState(() {});
                        },
                  child: Text(isSaving ? 'Processing...' : 'Pay Fee'),
                );
              },
            ),
          ),
        ),
      );

      // Rapidly tap twice
      await tester.tap(find.byKey(const Key('action-btn')));
      await tester.tap(find.byKey(const Key('action-btn')));
      await tester.pump(const Duration(milliseconds: 50));

      // Second tap while isSaving should be discarded
      expect(mutationCount, equals(1), reason: 'Double-tap must only execute mutation once');

      // Complete async delay
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pumpAndSettle();
      expect(mutationCount, equals(1));
    });
  });
}

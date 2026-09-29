import 'package:flutter/material.dart';
import 'controller/settings_controller.dart';
import 'theme/app_colors.dart';
import 'widgets/category_card.dart';
import 'widgets/general_settings_form.dart';
import 'widgets/save_settings_bar.dart';
import 'widgets/setting_toggle.dart';
import 'widgets/settings_header.dart';
import 'widgets/toast.dart';

void main() {
  runApp(const ErpSettingsApp());
}

class ErpSettingsApp extends StatefulWidget {
  const ErpSettingsApp({super.key});

  @override
  State<ErpSettingsApp> createState() => _ErpSettingsAppState();
}

class _ErpSettingsAppState extends State<ErpSettingsApp> {
  final SettingsController controller = SettingsController();
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    controller.load().then((_) {
      if (mounted) setState(() => _ready = true);
    });
    controller.addListener(() => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ERP System Settings',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Roboto',
        colorSchemeSeed: AppColors.primaryBlue,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Roboto',
        colorSchemeSeed: AppColors.primaryBlue,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.pageBgTopDark,
      ),
      themeMode: controller.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: !_ready
          ? const Scaffold(body: Center(child: CircularProgressIndicator()))
          : ToastHost(
              controller: controller,
              child: SettingsPage(controller: controller),
            ),
    );
  }
}

class SettingsPage extends StatefulWidget {
  final SettingsController controller;
  const SettingsPage({super.key, required this.controller});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    final dark = controller.isDarkMode;
    final width = MediaQuery.of(context).size.width;

    // Responsive column counts
    final categoryColumns = width >= 1100
        ? 6
        : width >= 820
            ? 3
            : width >= 520
                ? 2
                : 1;
    final toggleColumns = width >= 1000
        ? 4
        : width >= 680
            ? 2
            : 1;

    return Scaffold(
      backgroundColor: dark ? AppColors.pageBgTopDark : AppColors.pageBgTop,
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: dark
                  ? [AppColors.pageBgTopDark, AppColors.pageBgBottomDark]
                  : [AppColors.pageBgTop, AppColors.pageBgBottom],
            ),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(18),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1400),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SettingsHeader(controller: controller),
                  const SizedBox(height: 18),

                  // Category cards
                  LayoutBuilder(builder: (context, constraints) {
                    const gap = 14.0;
                    final itemWidth = (constraints.maxWidth -
                            gap * (categoryColumns - 1)) /
                        categoryColumns;
                    return Wrap(
                      spacing: gap,
                      runSpacing: gap,
                      children: kCategories.map((c) {
                        return SettingsCategoryCard(
                          data: c,
                          selected: controller.selectedCategory == c.title,
                          dark: dark,
                          width: itemWidth,
                          onTap: () => controller.setCategory(c.title),
                        );
                      }).toList(),
                    );
                  }),

                  const SizedBox(height: 18),

                  // General settings form
                  GeneralSettingsForm(controller: controller),

                  const SizedBox(height: 18),

                  // Toggle cards grid
                  LayoutBuilder(builder: (context, constraints) {
                    const gap = 14.0;
                    final itemWidth =
                        (constraints.maxWidth - gap * (toggleColumns - 1)) /
                            toggleColumns;
                    return Wrap(
                      spacing: gap,
                      runSpacing: gap,
                      children: kToggles.map((t) {
                        return SettingToggleCard(
                          data: t,
                          value: controller.toggles[t.title] ?? false,
                          dark: dark,
                          width: itemWidth,
                          onChanged: (_) => controller.toggleSetting(t.title),
                        );
                      }).toList(),
                    );
                  }),

                  const SizedBox(height: 18),

                  // Bottom save bar
                  SaveSettingsBar(controller: controller),

                  const SizedBox(height: 18),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

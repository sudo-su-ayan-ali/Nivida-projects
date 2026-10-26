import 'package:flutter/material.dart';
import 'controller/settings_controller.dart';
import 'theme/app_colors.dart';
import 'widgets/appearance_settings_view.dart';
import 'widgets/backup_settings_view.dart';
import 'widgets/category_card.dart';
import 'widgets/general_settings_form.dart';
import 'widgets/notifications_settings_view.dart';
import 'widgets/roles_settings_view.dart';
import 'widgets/save_settings_bar.dart';
import 'widgets/security_settings_view.dart';
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
  void initState() {
    super.initState();
    widget.controller.addListener(_onControllerChanged);
  }

  @override
  void didUpdateWidget(SettingsPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_onControllerChanged);
      widget.controller.addListener(_onControllerChanged);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerChanged);
    super.dispose();
  }

  void _onControllerChanged() {
    if (mounted) setState(() {});
  }
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

                  // Category cards selector
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

                  // Main View Content based on Search or Selected Category
                  _buildMainContent(context, controller, dark),

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

  Widget _buildMainContent(BuildContext context, SettingsController controller, bool dark) {
    // If search is active, show search results
    if (controller.searchQuery.isNotEmpty) {
      return _buildSearchResults(context, controller, dark);
    }

    // Otherwise render view matching selected category
    switch (controller.selectedCategory) {
      case 'Security':
        return SecuritySettingsView(controller: controller);
      case 'Users & Roles':
        return RolesSettingsView(controller: controller);
      case 'Backup':
        return BackupSettingsView(controller: controller);
      case 'Notifications':
        return NotificationsSettingsView(controller: controller);
      case 'Appearance':
        return AppearanceSettingsView(controller: controller);
      case 'System Settings':
      default:
        return _buildSystemSettingsView(context, controller, dark);
    }
  }

  Widget _buildSystemSettingsView(BuildContext context, SettingsController controller, bool dark) {
    final width = MediaQuery.of(context).size.width;
    final toggleColumns = width >= 1000 ? 4 : (width >= 680 ? 2 : 1);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
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
      ],
    );
  }

  Widget _buildSearchResults(BuildContext context, SettingsController controller, bool dark) {
    final q = controller.searchQuery.toLowerCase();
    final matchedCategories = kCategories.where((c) =>
        c.title.toLowerCase().contains(q) || c.subtitle.toLowerCase().contains(q)).toList();
    final matchedToggles = kToggles.where((t) =>
        t.title.toLowerCase().contains(q) || t.description.toLowerCase().contains(q)).toList();

    final cardBg = dark ? AppColors.cardWhiteDark : Colors.white;
    final borderColor = dark ? AppColors.cardBorderDark : AppColors.cardBorder;
    final textPrimary = dark ? AppColors.textPrimaryDark : AppColors.textPrimary;
    final textSecondary = dark ? AppColors.textSecondaryDark : AppColors.textSecondary;

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.search_rounded, color: AppColors.primaryBlue, size: 22),
              const SizedBox(width: 10),
              Text(
                'Search Results for "${controller.searchQuery}"',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: textPrimary),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: () => controller.clearSearch(),
                icon: const Icon(Icons.close_rounded, size: 16),
                label: const Text('Clear Search'),
              ),
            ],
          ),
          const SizedBox(height: 16),

          if (matchedCategories.isEmpty && matchedToggles.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Text(
                  'No settings found matching "${controller.searchQuery}". Try searching for "backup", "security", "academic", or "notifications".',
                  style: TextStyle(fontSize: 13, color: textSecondary),
                ),
              ),
            ),

          if (matchedCategories.isNotEmpty) ...[
            Text('Matching Categories', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: textPrimary)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: matchedCategories.map((c) {
                return OutlinedButton.icon(
                  onPressed: () {
                    controller.clearSearch();
                    controller.setCategory(c.title);
                  },
                  icon: Icon(c.icon, size: 18, color: c.iconFg),
                  label: Text('Open ${c.title}'),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: borderColor),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
          ],

          if (matchedToggles.isNotEmpty) ...[
            Text('Matching Toggles & Rules', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: textPrimary)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: matchedToggles.map((t) {
                final isEnabled = controller.toggles[t.title] ?? false;
                return Container(
                  width: 320,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: dark ? const Color(0xFF141A28) : const Color(0xFFF6F8FD),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: borderColor),
                  ),
                  child: Row(
                    children: [
                      Icon(t.icon, size: 20, color: t.iconFg),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(t.title, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: textPrimary)),
                            Text(t.description, style: TextStyle(fontSize: 11, color: textSecondary)),
                          ],
                        ),
                      ),
                      Switch(
                        value: isEnabled,
                        activeColor: AppColors.primaryBlue,
                        onChanged: (_) => controller.toggleSetting(t.title),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app/theme.dart';
import '../core/localization/app_localizations.dart';
import '../viewmodels/auth_company_viewmodel.dart';
import '../viewmodels/dashboard_viewmodel.dart';
import '../viewmodels/functions_viewmodel.dart';
import '../viewmodels/staff_viewmodel.dart';
import 'dashboard/dashboard_screen.dart';
import 'functions/upcoming_bookings_screen.dart';
import 'functions/previous_bookings_screen.dart';
import 'functions/create_function_screen.dart';
import 'staff/staff_screen.dart';
import 'materials/make_material_list_screen.dart';
import 'settings/shop_profile_screen.dart';
import 'settings/language_selection_screen.dart';
import 'auth/logout_dialog.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _currentIndex = 0;
  String? _lastCompanyId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final currentCompanyId = context.watch<AuthCompanyViewModel>().activeCompany?.id;
    if (currentCompanyId != null && currentCompanyId != _lastCompanyId) {
      _lastCompanyId = currentCompanyId;
      _reloadAllData(currentCompanyId);
    }
  }

  void _reloadAllData(String companyId) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<DashboardViewModel>().loadDashboard(companyId);
      context.read<FunctionsViewModel>().loadFunctions(companyId);
      context.read<StaffViewModel>().loadStaff(companyId);
    });
  }

  void _navigateToTab(int index) {
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final authVM = context.watch<AuthCompanyViewModel>();
    final activeComp = authVM.activeCompany;

    final screens = [
      DashboardScreen(
        onNavigateTab: _navigateToTab,
        onOpenDrawer: () => _scaffoldKey.currentState?.openDrawer(),
        onOpenCreateFunction: () async {
          await Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const CreateFunctionScreen()),
          );
          if (!mounted) return;
          final compId = authVM.activeCompany?.id;
          if (compId != null) _reloadAllData(compId);
        },
      ),
      const UpcomingBookingsScreen(),
      const PreviousBookingsScreen(),
      const StaffScreen(),
    ];

    return Scaffold(
      key: _scaffoldKey,
      drawer: Drawer(
        backgroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.horizontal(right: Radius.circular(24)),
        ),
        child: Column(
          children: [
            // ==========================================
            // 1. CLEAN & PROFESSIONAL HEADER
            // ==========================================
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF0F172A), Color(0xFF203A5F)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(24),
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
                  child: InkWell(
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const ShopProfileScreen()));
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Row(
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            activeComp?.name.isNotEmpty == true
                                ? activeComp!.name[0].toUpperCase()
                                : 'C',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF203A5F),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      activeComp?.name ?? 'Catering Business',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                        letterSpacing: -0.3,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  const Icon(
                                    Icons.verified_rounded,
                                    size: 16,
                                    color: Color(0xFF38BDF8),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${activeComp?.ownerName ?? "Owner"} • ${activeComp?.phone ?? ""}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.white.withValues(alpha: 0.7),
                                  fontWeight: FontWeight.w400,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          Icons.edit_rounded,
                          size: 18,
                          color: Colors.white.withValues(alpha: 0.5),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // ==========================================
            // 2. DRAWER ITEMS
            // ==========================================
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                children: [
                  // Section 1
                  _buildSectionHeader('OPERATIONS & ORDERS'),
                  _buildDrawerTile(
                    context: context,
                    icon: Icons.playlist_add_rounded,
                    iconColor: const Color(0xFF9F1239), // Deep Rose
                    iconBg: const Color(0xFFFFE4E6), // Soft Rose
                    title: context.tr('make_list'),
                    trailing: _buildBadge(
                      text: 'PDF Ready',
                      textColor: const Color(0xFF9F1239),
                      bgColor: const Color(0xFFFFE4E6),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const MakeMaterialListScreen()));
                    },
                  ),

                  const SizedBox(height: 16),

                  // Section 2
                  _buildSectionHeader('PREFERENCES & SYSTEM'),
                  _buildDrawerTile(
                    context: context,
                    icon: Icons.storefront_rounded,
                    iconColor: AppTheme.primaryNavy,
                    iconBg: const Color(0xFFF1F5F9),
                    title: context.tr('shop_profile'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const ShopProfileScreen()));
                    },
                  ),
                  _buildDrawerTile(
                    context: context,
                    icon: Icons.translate_rounded,
                    iconColor: AppTheme.primaryNavy,
                    iconBg: const Color(0xFFF1F5F9),
                    title: context.tr('language'),
                    trailing: _buildBadge(
                      text: _getLanguageShortLabel(authVM.currentLanguage),
                      textColor: AppTheme.primaryNavy,
                      bgColor: AppTheme.primaryNavy.withValues(alpha: 0.08),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const LanguageSelectionScreen()));
                    },
                  ),
                  _buildDrawerTile(
                    context: context,
                    icon: Icons.inventory_2_outlined,
                    iconColor: Colors.grey.shade700,
                    iconBg: const Color(0xFFF1F5F9),
                    title: context.tr('inventory_upcoming'),
                    trailing: _buildBadge(
                      text: 'Soon',
                      textColor: Colors.amber.shade800,
                      bgColor: Colors.amber.shade50,
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Inventory ledger is an upcoming feature.')),
                      );
                    },
                  ),

                  _buildDrawerTile(
                    context: context,
                    icon: Icons.logout_rounded,
                    iconColor: const Color(0xFFDC2626),
                    iconBg: const Color(0xFFFEE2E2),
                    title: context.tr('logout'),
                    onTap: () {
                      Navigator.pop(context);
                      showLogoutConfirmationDialog(context);
                    },
                  ),

                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    child: Divider(color: Color(0xFFE2E8F0), height: 1),
                  ),
                ],
              ),
            ),

            // ==========================================
            // 3. CLEAN FOOTER
            // ==========================================
            Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              child: SafeArea(
                top: false,
                child: Row(
                  children: [
                    const Icon(Icons.eco_rounded, size: 16, color: AppTheme.accentEmerald),
                    const SizedBox(width: 8),
                    Text(
                      'RasoiPro Catering ERP',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'v2.4.0',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade400,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: AppTheme.borderLight, width: 1)),
        ),
        child: NavigationBar(
          selectedIndex: _currentIndex,
          backgroundColor: Colors.white,
          indicatorColor: AppTheme.primaryNavy.withValues(alpha: 0.08),
          elevation: 0,
          height: 65,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          onDestinationSelected: (idx) => setState(() => _currentIndex = idx),
          destinations: [
            NavigationDestination(
              icon: const Icon(Icons.dashboard_outlined, size: 22),
              selectedIcon: const Icon(Icons.dashboard_rounded, color: AppTheme.primaryNavy, size: 22),
              label: context.tr('nav_dashboard'),
            ),
            NavigationDestination(
              icon: const Icon(Icons.event_available_outlined, size: 22),
              selectedIcon: const Icon(Icons.event_available_rounded, color: AppTheme.accentEmerald, size: 22),
              label: context.tr('nav_upcoming'),
            ),
            NavigationDestination(
              icon: const Icon(Icons.history_rounded, size: 22),
              selectedIcon: const Icon(Icons.history_rounded, color: AppTheme.accentBlue, size: 22),
              label: context.tr('nav_previous'),
            ),
            NavigationDestination(
              icon: const Icon(Icons.group_outlined, size: 22),
              selectedIcon: const Icon(Icons.group_rounded, color: AppTheme.primaryNavy, size: 22),
              label: context.tr('nav_staff'),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // HELPER WIDGETS FOR CLEAN UI
  // ==========================================

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 12, bottom: 8, top: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: Color(0xFF94A3B8), // Slate 400
          letterSpacing: 1.0,
        ),
      ),
    );
  }

  Widget _buildBadge({
    required String text,
    required Color textColor,
    required Color bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: textColor,
        ),
      ),
    );
  }

  String _getLanguageShortLabel(String code) {
    switch (code) {
      case 'hi': return 'HI';
      case 'mr': return 'MR';
      case 'gu': return 'GU';
      case 'en':
      default: return 'EN';
    }
  }

  // 👇 Updated: Removed subtitle, adjusted padding for perfect vertical alignment
  Widget _buildDrawerTile({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String title,
    Widget? trailing,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        tileColor: Colors.transparent,
        hoverColor: const Color(0xFFF8FAFC),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
        minVerticalPadding: 12,
        leading: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: iconBg,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Icon(icon, color: iconColor, size: 20),
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14.5, // Slightly larger since it's the only text
            color: AppTheme.textPrimary,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: trailing ?? const Icon(
          Icons.chevron_right_rounded,
          size: 20,
          color: Color(0xFFCBD5E1),
        ),
        onTap: onTap,
      ),
    );
  }
}
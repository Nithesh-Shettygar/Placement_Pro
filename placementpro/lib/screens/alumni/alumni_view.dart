import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:placementpro/screens/alumni/theme_tokens.dart';

import 'tabs/home_tab.dart';
import 'tabs/profile_tab.dart';
import 'tabs/jobs_tab.dart';

class AlumniDashboard extends StatefulWidget {
  final Map<String, dynamic> userData;
  const AlumniDashboard({super.key, required this.userData});

  @override
  State<AlumniDashboard> createState() => _AlumniDashboardState();
}

class _AlumniDashboardState extends State<AlumniDashboard>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;

  /// Screens wider than this are treated as desktop/tablet
  static const double _desktopBreakpoint = 768;

  late AnimationController _animController;

  final List<_NavItem> _navItems = const [
    _NavItem(icon: Icons.home_rounded,             label: 'Home'),
    _NavItem(icon: Icons.person_outline_rounded,   label: 'Profile'),
    _NavItem(icon: Icons.business_center_outlined, label: 'Jobs'),
  ];

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  List<Widget> get _pages => [
        HomeTab(userData: widget.userData, themeColor: AppColors.skyAccent),
        ProfileTab(userData: widget.userData),
        const JobsTab(),
      ];

  @override
  Widget build(BuildContext context) {
    final bool isDesktop =
        MediaQuery.of(context).size.width >= _desktopBreakpoint;

    return Scaffold(
      backgroundColor: AppColors.softWhite,
      extendBody: !isDesktop,
      body: isDesktop ? _buildDesktopLayout() : _buildMobileLayout(),
    );
  }

  // ════════════════════════════════════════════════════════════════════════════
  // DESKTOP LAYOUT  —  left sidebar + scrollable content
  // ════════════════════════════════════════════════════════════════════════════
  Widget _buildDesktopLayout() {
    return Row(
      children: [
        _buildSidebar(),
        Expanded(
          child: IndexedStack(
            index: _selectedIndex,
            children: _pages,
          ),
        ),
      ],
    );
  }

  // ════════════════════════════════════════════════════════════════════════════
  // MOBILE LAYOUT  —  full screen + floating bottom nav
  // ════════════════════════════════════════════════════════════════════════════
  Widget _buildMobileLayout() {
    return Stack(
      children: [
        IndexedStack(index: _selectedIndex, children: _pages),
        Align(
          alignment: Alignment.bottomCenter,
          child: _buildFloatingNav(),
        ),
      ],
    );
  }

  // ════════════════════════════════════════════════════════════════════════════
  // SIDEBAR  (desktop only)
  // ════════════════════════════════════════════════════════════════════════════
  Widget _buildSidebar() {
    return Container(
      width: 260,
      height: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.deepNavy,
        boxShadow: AppShadows.hero,
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Brand ──────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 0),
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: AppColors.skyAccent,
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: const Icon(Icons.dashboard_customize_rounded,
                        color: Colors.white, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ALUMNI',
                        style: TextStyle(
                          fontSize: 10,
                          color: AppColors.iceBlue.withOpacity(0.55),
                          fontWeight: FontWeight.w700,
                          letterSpacing: 2.2,
                        ),
                      ),
                      const Text(
                        'Portal',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // ── User mini-card ──────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.glassOnDark,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.glassBorderOnDark),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.iceBlue.withOpacity(0.15),
                        border: Border.all(
                            color: AppColors.iceBlue.withOpacity(0.3),
                            width: 2),
                      ),
                      child: const Icon(Icons.person_rounded,
                          color: AppColors.iceBlue, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.userData['name'] ?? 'Alumnus',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            'Batch ${widget.userData['batch'] ?? '2018'}',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.iceBlue.withOpacity(0.55),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Online indicator
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.success,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 36),

            // ── Section label ───────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(26, 0, 24, 12),
              child: Text(
                'NAVIGATION',
                style: TextStyle(
                  fontSize: 10,
                  color: AppColors.iceBlue.withOpacity(0.38),
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.8,
                ),
              ),
            ),

            // ── Nav items ───────────────────────────────────────────────────
            ...List.generate(
              _navItems.length,
              (i) => _buildSidebarItem(_navItems[i], i),
            ),

            const Spacer(),

            // ── Divider ─────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Divider(
                  color: AppColors.glassDividerOnDark, height: 1),
            ),

            const SizedBox(height: 16),

            // ── Logout ──────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 28),
              child: _buildSidebarLogout(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSidebarItem(_NavItem item, int index) {
    final bool selected = _selectedIndex == index;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 3, 16, 3),
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          setState(() => _selectedIndex = index);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
          decoration: BoxDecoration(
            color: selected ? AppColors.skyAccent : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Icon(
                item.icon,
                color: selected
                    ? Colors.white
                    : AppColors.iceBlue.withOpacity(0.45),
                size: 20,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  item.label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: selected
                        ? FontWeight.w700
                        : FontWeight.w500,
                    color: selected
                        ? Colors.white
                        : AppColors.iceBlue.withOpacity(0.55),
                    letterSpacing: 0.1,
                  ),
                ),
              ),
              // Active dot
              if (selected)
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSidebarLogout() {
    return GestureDetector(
      onTap: _showLogoutDialog,
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        decoration: BoxDecoration(
          color: Colors.redAccent.withOpacity(0.10),
          borderRadius: BorderRadius.circular(16),
          border:
              Border.all(color: Colors.redAccent.withOpacity(0.20)),
        ),
        child: const Row(
          children: [
            Icon(Icons.logout_rounded,
                color: Colors.redAccent, size: 20),
            SizedBox(width: 14),
            Text(
              'Sign Out',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.redAccent,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════════════════
  // FLOATING NAV  (mobile only)
  // ════════════════════════════════════════════════════════════════════════════
  Widget _buildFloatingNav() {
    return SafeArea(
      child: Container(
        margin: const EdgeInsets.fromLTRB(24, 0, 24, 16),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.deepNavy,
          borderRadius: BorderRadius.circular(32),
          boxShadow: AppShadows.floatingNav,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            ...List.generate(
              _navItems.length,
              (i) => _buildMobileNavItem(_navItems[i], i),
            ),
            // Logout icon
            GestureDetector(
              onTap: _showLogoutDialog,
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.redAccent.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.logout_rounded,
                    color: Colors.redAccent, size: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileNavItem(_NavItem item, int index) {
    final bool selected = _selectedIndex == index;
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        setState(() => _selectedIndex = index);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeInOut,
        padding: EdgeInsets.symmetric(
          horizontal: selected ? 18 : 12,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color:
              selected ? AppColors.skyAccent : Colors.transparent,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              item.icon,
              color: selected
                  ? Colors.white
                  : Colors.white.withOpacity(0.45),
              size: 22,
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 280),
              curve: Curves.easeInOut,
              child: selected
                  ? Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: Text(
                        item.label,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                          letterSpacing: 0.2,
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════════════════
  // LOGOUT DIALOG  (shared between desktop & mobile)
  // ════════════════════════════════════════════════════════════════════════════
  void _showLogoutDialog() {
    showDialog(
      context: context,
      barrierColor: AppColors.barrierColor,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28)),
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.redAccent.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.logout_rounded,
                    color: Colors.redAccent, size: 30),
              ),
              const SizedBox(height: 18),
              const Text(
                'Sign Out',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppColors.deepNavy,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Are you sure you want to sign out of your account?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade500,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                            color: Colors.grey.shade200),
                        padding: const EdgeInsets.symmetric(
                            vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(16),
                        ),
                      ),
                      child: Text('Cancel',
                          style: TextStyle(
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w600)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(
                            vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text('Sign Out',
                          style: TextStyle(
                              fontWeight: FontWeight.w700)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Nav Item Model ────────────────────────────────────────────────────────────
class _NavItem {
  final IconData icon;
  final String label;
  const _NavItem({required this.icon, required this.label});
}
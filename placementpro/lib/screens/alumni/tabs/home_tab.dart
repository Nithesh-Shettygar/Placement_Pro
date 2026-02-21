import 'package:flutter/material.dart';
import 'package:placementpro/screens/alumni/theme_tokens.dart';

class HomeTab extends StatelessWidget {
  final Map userData;
  final Color themeColor;

  const HomeTab({super.key, required this.userData, required this.themeColor});

  static const double _desktopBreakpoint = 768;

  @override
  Widget build(BuildContext context) {
    final bool isDesktop =
        MediaQuery.of(context).size.width >= _desktopBreakpoint;

    return Scaffold(
      backgroundColor: AppColors.softWhite,
      body: isDesktop
          ? _buildDesktopLayout(context)
          : _buildMobileLayout(context),
    );
  }

  // ════════════════════════════════════════════════════════════════════════════
  // MOBILE LAYOUT  (original single-column scroll)
  // ════════════════════════════════════════════════════════════════════════════
  Widget _buildMobileLayout(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeroHeader(context),
          const SizedBox(height: 28),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: _buildSearchBar(),
          ),
          const SizedBox(height: 28),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: _buildSectionHeader('Recruitment Overview', 'See all'),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                Expanded(child: _buildMetricCard(
                  label: 'Active Jobs', value: '03', sub: '2 closing soon',
                  icon: Icons.work_outline_rounded,
                  iconColor: AppColors.skyAccent, progress: 0.6,
                  progressColor: AppColors.skyAccent,
                )),
                const SizedBox(width: 16),
                Expanded(child: _buildMetricCard(
                  label: 'Applications', value: '24', sub: '8 new today',
                  icon: Icons.people_outline_rounded,
                  iconColor: AppColors.success, progress: 0.8,
                  progressColor: AppColors.success,
                )),
              ],
            ),
          ),
          const SizedBox(height: 28),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: _buildSectionHeader('Recent Activity', 'View all'),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(children: _activityCards()),
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════════════════
  // DESKTOP LAYOUT  (two-column with sticky left panel)
  // ════════════════════════════════════════════════════════════════════════════
  Widget _buildDesktopLayout(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          // ── Full-width flat hero (no rounded bottom on desktop) ────────────
          _buildDesktopHero(context),

          const SizedBox(height: 32),

          // ── Two-column body ───────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // LEFT column — metrics + activity
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Search bar
                      _buildSearchBar(),
                      const SizedBox(height: 28),

                      // Recruitment Overview
                      _buildSectionHeader('Recruitment Overview', 'See all'),
                      const SizedBox(height: 16),

                      // 2x2 metric grid
                      GridView.count(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        childAspectRatio: 1.15,
                        children: [
                          _buildMetricCard(
                            label: 'Active Jobs', value: '03',
                            sub: '2 closing soon',
                            icon: Icons.work_outline_rounded,
                            iconColor: AppColors.skyAccent, progress: 0.6,
                            progressColor: AppColors.skyAccent,
                          ),
                          _buildMetricCard(
                            label: 'Applications', value: '24',
                            sub: '8 new today',
                            icon: Icons.people_outline_rounded,
                            iconColor: AppColors.success, progress: 0.8,
                            progressColor: AppColors.success,
                          ),
                          _buildMetricCard(
                            label: 'Interviews', value: '06',
                            sub: '3 this week',
                            icon: Icons.event_note_outlined,
                            iconColor: AppColors.warning, progress: 0.45,
                            progressColor: AppColors.warning,
                          ),
                          _buildMetricCard(
                            label: 'Offers Sent', value: '02',
                            sub: '1 accepted',
                            icon: Icons.mark_email_read_outlined,
                            iconColor: const Color(0xFF9B59B6), progress: 0.5,
                            progressColor: const Color(0xFF9B59B6),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 28),

                // RIGHT column — activity feed (sticky feel)
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionHeader('Recent Activity', 'View all'),
                      const SizedBox(height: 16),
                      ..._activityCards(),
                      const SizedBox(height: 16),
                      // Extra desktop-only quick actions card
                      _buildQuickActionsCard(),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  // ── Desktop Hero (flat, no rounded bottom) ──────────────────────────────────
  Widget _buildDesktopHero(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(32, 48, 32, 40),
      decoration: const BoxDecoration(color: AppColors.deepNavy),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Left: greeting + headline
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.iceBlue.withOpacity(0.15),
                        border: Border.all(
                            color: AppColors.iceBlue.withOpacity(0.35),
                            width: 2),
                      ),
                      child: const Icon(Icons.person_rounded,
                          color: AppColors.iceBlue, size: 28),
                    ),
                    const SizedBox(width: 14),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Good Morning 👋',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.iceBlue.withOpacity(0.7),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          userData['name'] ?? 'Alumnus',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Text(
                  'Recruitment Portal',
                  style: TextStyle(
                    fontSize: 38,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -0.8,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Track your hiring pipeline at a glance.',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.iceBlue.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 32),

          // Right: stat strip (wider on desktop)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
            decoration: BoxDecoration(
              color: AppColors.glassOnDark,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.glassBorderOnDark),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDesktopStat('03', 'Active Jobs',
                    Icons.work_outline_rounded, AppColors.skyAccent),
                _buildStatDivider(),
                _buildDesktopStat('24', 'Applicants',
                    Icons.people_outline_rounded, AppColors.success),
                _buildStatDivider(),
                _buildDesktopStat('06', 'Interviews',
                    Icons.event_note_outlined, AppColors.warning),
                _buildStatDivider(),
                _buildDesktopStat('01', 'Closed',
                    Icons.check_circle_outline_rounded, AppColors.textMuted),
              ],
            ),
          ),

          const SizedBox(width: 16),

          // Notification bell
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.08),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.notifications_none_rounded,
                color: Colors.white, size: 24),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopStat(
      String val, String label, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 10),
          Text(val,
              style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white)),
          const SizedBox(height: 2),
          Text(label,
              style: TextStyle(
                  fontSize: 11,
                  color: AppColors.iceBlue.withOpacity(0.6),
                  fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildStatDivider() =>
      Container(width: 1, height: 50, color: AppColors.glassDividerOnDark);

  // ── Quick Actions Card (desktop only) ────────────────────────────────────────
  Widget _buildQuickActionsCard() {
    final actions = [
      _QuickAction('Post a Job', Icons.add_circle_outline_rounded, AppColors.skyAccent),
      _QuickAction('View Pipeline', Icons.account_tree_outlined, AppColors.success),
      _QuickAction('Send Invite', Icons.mail_outline_rounded, AppColors.warning),
      _QuickAction('Reports', Icons.bar_chart_rounded, AppColors.deepNavy),
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
              color: AppColors.deepNavy.withOpacity(0.06),
              blurRadius: 16,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Quick Actions',
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.deepNavy)),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 2.4,
            children: actions.map((a) => _buildQuickActionTile(a)).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionTile(_QuickAction action) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: action.color.withOpacity(0.07),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: action.color.withOpacity(0.15)),
        ),
        child: Row(
          children: [
            Icon(action.icon, color: action.color, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(action.label,
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: action.color),
                  overflow: TextOverflow.ellipsis),
            ),
          ],
        ),
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════════════════
  // SHARED WIDGETS
  // ════════════════════════════════════════════════════════════════════════════

  // ── Mobile Hero ─────────────────────────────────────────────────────────────
  Widget _buildHeroHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 60, 24, 36),
      decoration: const BoxDecoration(
        color: AppColors.deepNavy,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(36),
          bottomRight: Radius.circular(36),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.iceBlue.withOpacity(0.2),
                      border: Border.all(
                          color: AppColors.iceBlue.withOpacity(0.4), width: 2),
                    ),
                    child: const Icon(Icons.person_rounded,
                        color: AppColors.iceBlue, size: 26),
                  ),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Good Morning 👋',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.iceBlue.withOpacity(0.7),
                            fontWeight: FontWeight.w500,
                          )),
                      const SizedBox(height: 2),
                      Text(
                        userData['name'] ?? 'Alumnus',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.notifications_none_rounded,
                    color: Colors.white, size: 22),
              ),
            ],
          ),
          const SizedBox(height: 28),
          const Text(
            'Recruitment\nPortal',
            style: TextStyle(
              fontSize: 34,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              height: 1.15,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Track your hiring pipeline at a glance.',
            style: TextStyle(
                fontSize: 13, color: AppColors.iceBlue.withOpacity(0.6)),
          ),
          const SizedBox(height: 24),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: AppColors.glassOnDark,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.glassBorderOnDark),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildMiniStat('03', 'Active Jobs'),
                Container(
                    width: 1,
                    height: 36,
                    color: AppColors.glassDividerOnDark),
                _buildMiniStat('24', 'Applicants'),
                Container(
                    width: 1,
                    height: 36,
                    color: AppColors.glassDividerOnDark),
                _buildMiniStat('01', 'Closed'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat(String val, String label) {
    return Column(
      children: [
        Text(val,
            style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white)),
        const SizedBox(height: 2),
        Text(label,
            style: TextStyle(
                fontSize: 11,
                color: AppColors.iceBlue.withOpacity(0.6),
                fontWeight: FontWeight.w500)),
      ],
    );
  }

  // ── Search Bar ───────────────────────────────────────────────────────────────
  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
              color: AppColors.deepNavy.withOpacity(0.06),
              blurRadius: 20,
              offset: const Offset(0, 6)),
        ],
      ),
      child: Row(
        children: [
          Icon(Icons.search_rounded, color: AppColors.textMuted, size: 20),
          const SizedBox(width: 12),
          Text('Search jobs, applicants...',
              style:
                  TextStyle(color: AppColors.textMuted, fontSize: 14)),
          const Spacer(),
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColors.deepNavy,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.tune_rounded,
                color: Colors.white, size: 16),
          ),
        ],
      ),
    );
  }

  // ── Section Header ───────────────────────────────────────────────────────────
  Widget _buildSectionHeader(String title, String action) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title,
            style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: AppColors.deepNavy,
                letterSpacing: -0.2)),
        GestureDetector(
          onTap: () {},
          child: Text(action,
              style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.skyAccent,
                  fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }

  // ── Metric Card ──────────────────────────────────────────────────────────────
  Widget _buildMetricCard({
    required String label,
    required String value,
    required String sub,
    required IconData icon,
    required Color iconColor,
    required double progress,
    required Color progressColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
              color: AppColors.deepNavy.withOpacity(0.07),
              blurRadius: 20,
              offset: const Offset(0, 6)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(height: 16),
          Text(value,
              style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                  color: AppColors.deepNavy,
                  letterSpacing: -0.5)),
          const SizedBox(height: 2),
          Text(label,
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.deepNavy)),
          const SizedBox(height: 2),
          Text(sub,
              style: const TextStyle(
                  fontSize: 11, color: AppColors.textMuted)),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: AppColors.iceBlue.withOpacity(0.3),
              color: progressColor,
              minHeight: 5,
            ),
          ),
        ],
      ),
    );
  }

  // ── Activity Cards list ──────────────────────────────────────────────────────
  List<Widget> _activityCards() {
    return [
      _buildActivityCard(
        title: 'New Application',
        desc: 'Rahul S. applied for SDE Intern',
        time: '2h ago',
        icon: Icons.person_add_alt_1_rounded,
        tag: 'New',
        tagColor: AppColors.skyAccent,
      ),
      const SizedBox(height: 12),
      _buildActivityCard(
        title: 'Job Update',
        desc: 'Frontend Role reached 50 applicants',
        time: 'Yesterday',
        icon: Icons.trending_up_rounded,
        tag: 'Active',
        tagColor: AppColors.success,
      ),
      const SizedBox(height: 12),
      _buildActivityCard(
        title: 'System',
        desc: "Closed 'QA Engineer' posting",
        time: '2 days ago',
        icon: Icons.check_circle_outline_rounded,
        tag: 'Closed',
        tagColor: AppColors.textMuted,
      ),
    ];
  }

  Widget _buildActivityCard({
    required String title,
    required String desc,
    required String time,
    required IconData icon,
    required String tag,
    required Color tagColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: AppColors.deepNavy.withOpacity(0.05),
              blurRadius: 16,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: AppColors.deepNavy.withOpacity(0.05),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: AppColors.deepNavy, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: AppColors.deepNavy)),
                const SizedBox(height: 3),
                Text(desc,
                    style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textMuted,
                        height: 1.3)),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: tagColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Text(tag,
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: tagColor)),
              ),
              const SizedBox(height: 6),
              Text(time,
                  style: const TextStyle(
                      fontSize: 11, color: AppColors.textMuted)),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Helper model ──────────────────────────────────────────────────────────────
class _QuickAction {
  final String label;
  final IconData icon;
  final Color color;
  const _QuickAction(this.label, this.icon, this.color);
}
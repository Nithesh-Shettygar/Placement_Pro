import 'package:flutter/material.dart';

class ProfileTab extends StatefulWidget {
  final Map<String, dynamic> userData;
  const ProfileTab({super.key, required this.userData});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  // ── Insightlancer Palette ──────────────────────────────────────────────────
  static const Color deepNavy  = Color(0xFF1A365D);
  static const Color iceBlue   = Color(0xFFBFD7ED);
  static const Color skyAccent = Color(0xFF4A90D9);
  static const Color softWhite = Color(0xFFF7F9FC);
  static const Color cardWhite = Color(0xFFFFFFFF);
  static const Color textMuted = Color(0xFF8FA8C0);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          // ── Dark Navy Hero Header ──────────────────────────────────────────
          _buildHeroHeader(),

          const SizedBox(height: 28),

          // ── Skill Chips ───────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: _buildSkillChips(),
          ),

          const SizedBox(height: 28),

          // ── Professional Info ─────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: _buildSectionHeader('Professional Info', 'Edit'),
          ),
          const SizedBox(height: 14),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                _buildInfoCard(
                  icon: Icons.business_center_outlined,
                  title: 'Current Role',
                  value: 'Senior Software Engineer',
                  sub: 'Meta Platforms Inc. • Menlo Park',
                  iconColor: skyAccent,
                ),
                const SizedBox(height: 12),
                _buildInfoCard(
                  icon: Icons.school_outlined,
                  title: 'Academic Background',
                  value: 'B.Tech in Computer Science',
                  sub: 'Batch of ${widget.userData['batch'] ?? '2018'}',
                  iconColor: const Color(0xFF34C98B),
                ),
                const SizedBox(height: 12),
                _buildInfoCard(
                  icon: Icons.psychology_outlined,
                  title: 'Key Skills',
                  value: 'Flutter, Distributed Systems, Go',
                  sub: 'Verified by University Placement Cell',
                  iconColor: const Color(0xFFF5A623),
                ),
              ],
            ),
          ),

          const SizedBox(height: 28),

          // ── Social / Portfolio Links ───────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: _buildSectionHeader('Social & Portfolio', 'Edit'),
          ),
          const SizedBox(height: 14),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: _buildLinksCard(),
          ),

          const SizedBox(height: 28),

          // ── Account Settings Button ────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: _buildSettingsButton(),
          ),

          const SizedBox(height: 110), // Space for floating nav
        ],
      ),
    );
  }

  // ── Hero Header ─────────────────────────────────────────────────────────────
  Widget _buildHeroHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 60, 24, 36),
      decoration: const BoxDecoration(
        color: deepNavy,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(36),
          bottomRight: Radius.circular(36),
        ),
      ),
      child: Column(
        children: [
          // Avatar with camera badge
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: iceBlue.withOpacity(0.15),
                  border: Border.all(color: iceBlue.withOpacity(0.35), width: 3),
                ),
                child: const Icon(Icons.person_rounded, size: 52, color: iceBlue),
              ),
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: skyAccent,
                  shape: BoxShape.circle,
                  border: Border.all(color: deepNavy, width: 2),
                ),
                child: const Icon(Icons.camera_alt_rounded, size: 15, color: Colors.white),
              ),
            ],
          ),

          const SizedBox(height: 18),

          // Name
          Text(
            widget.userData['name'] ?? 'User Name',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'San Francisco, California',
            style: TextStyle(
              fontSize: 13,
              color: iceBlue.withOpacity(0.65),
              fontWeight: FontWeight.w400,
            ),
          ),

          const SizedBox(height: 24),

          // Stats row
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.07),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStat('2018', 'Batch'),
                _buildDivider(),
                _buildStat('6 yrs', 'Experience'),
                _buildDivider(),
                _buildStat('12', 'Referrals'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStat(String value, String label) {
    return Column(
      children: [
        Text(value,
            style: const TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
        const SizedBox(height: 2),
        Text(label,
            style: TextStyle(
                fontSize: 11,
                color: iceBlue.withOpacity(0.6),
                fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _buildDivider() =>
      Container(width: 1, height: 34, color: Colors.white.withOpacity(0.1));

  // ── Skill Chips ──────────────────────────────────────────────────────────────
  Widget _buildSkillChips() {
    final skills = ['Flutter', 'Go', 'Distributed Systems', 'System Design', 'Dart'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Top Skills', 'Edit'),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: skills.map((skill) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: cardWhite,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: deepNavy.withOpacity(0.06),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(
                      color: skyAccent,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 7),
                  Text(
                    skill,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: deepNavy,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // ── Section Header ────────────────────────────────────────────────────────────
  Widget _buildSectionHeader(String title, String action) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title,
            style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: deepNavy,
                letterSpacing: -0.2)),
        GestureDetector(
          onTap: () {},
          child: Text(action,
              style: const TextStyle(
                  fontSize: 13,
                  color: skyAccent,
                  fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }

  // ── Info Card ─────────────────────────────────────────────────────────────────
  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String value,
    required String sub,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardWhite,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: deepNavy.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(11),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        color: textMuted,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.3)),
                const SizedBox(height: 3),
                Text(value,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: deepNavy)),
                const SizedBox(height: 2),
                Text(sub,
                    style: const TextStyle(fontSize: 12, color: textMuted)),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: textMuted, size: 20),
        ],
      ),
    );
  }

  // ── Links Card ────────────────────────────────────────────────────────────────
  Widget _buildLinksCard() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: cardWhite,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: deepNavy.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildLinkTile(
            icon: Icons.link_rounded,
            label: 'LinkedIn',
            url: 'linkedin.com/in/username',
            color: const Color(0xFF0077B5),
          ),
          Divider(height: 1, indent: 62, color: Colors.grey.shade100),
          _buildLinkTile(
            icon: Icons.code_rounded,
            label: 'GitHub',
            url: 'github.com/username',
            color: const Color(0xFF24292E),
          ),
          Divider(height: 1, indent: 62, color: Colors.grey.shade100),
          _buildLinkTile(
            icon: Icons.language_rounded,
            label: 'Portfolio',
            url: 'www.johndoe.dev',
            color: const Color(0xFF34C98B),
          ),
        ],
      ),
    );
  }

  Widget _buildLinkTile({
    required IconData icon,
    required String label,
    required String url,
    required Color color,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label,
                        style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                            color: deepNavy)),
                    Text(url,
                        style: const TextStyle(
                            fontSize: 12, color: textMuted)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: softWhite,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.open_in_new_rounded,
                    size: 15, color: textMuted),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Account Settings Button ───────────────────────────────────────────────────
  Widget _buildSettingsButton() {
    return GestureDetector(
      onTap: () {},
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: cardWhite,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: iceBlue.withOpacity(0.5)),
          boxShadow: [
            BoxShadow(
              color: deepNavy.withOpacity(0.05),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.settings_outlined, color: deepNavy, size: 20),
            SizedBox(width: 10),
            Text(
              'Account Settings',
              style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  color: deepNavy),
            ),
          ],
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isAppearanceOn = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            children: [
              // Header with Edit button
              _buildHeader(),
              const SizedBox(height: 30),

              // Group 1: Messages, Archive, Devices
              _buildGroupContainer([
                _buildSettingItem(
                  icon: Iconsax.bookmark,
                  iconBg: const Color(0xFF246BFD),
                  title: 'Save Messages',
                  onTap: () {},
                ),
                _buildDivider(),
                _buildSettingItem(
                  icon: Iconsax.archive_add,
                  iconBg: const Color(0xFFF75555),
                  title: 'Archive Chat',
                  onTap: () {},
                ),
                _buildDivider(),
                _buildSettingItem(
                  icon: Iconsax.mobile,
                  iconBg: const Color(0xFF47D16E),
                  title: 'Devices',
                  onTap: () {},
                ),
              ]),
              const SizedBox(height: 20),

              // Group 2: Notification, Privacy, Language, Appearance
              _buildGroupContainer([
                _buildSettingItem(
                  icon: Iconsax.notification,
                  iconBg: const Color(0xFFFF981F),
                  title: 'Notification',
                  onTap: () {},
                ),
                _buildDivider(),
                _buildSettingItem(
                  icon: Iconsax.lock,
                  iconBg: const Color(0xFFACACAE),
                  title: 'Privacy and Security',
                  onTap: () {},
                ),
                _buildDivider(),
                _buildSettingItem(
                  icon: Iconsax.global,
                  iconBg: const Color(0xFF9145FF),
                  title: 'Language',
                  trailing: _buildLanguageBadge(),
                  onTap: () {},
                ),
                _buildDivider(),
                _buildSettingItem(
                  icon: Iconsax.colorfilter,
                  iconBg: const Color(0xFF47D16E),
                  title: 'Appearance',
                  trailing: Switch(
                    value: _isAppearanceOn,
                    onChanged: (val) => setState(() => _isAppearanceOn = val),
                    activeColor: const Color(0xFF47D16E),
                    activeTrackColor: const Color(0xFF47D16E).withOpacity(0.3),
                  ),
                  onTap: () {},
                ),
              ]),
              const SizedBox(height: 20),

              // Group 3: Premium
              _buildGroupContainer([
                _buildSettingItem(
                  icon: Iconsax.crown,
                  iconBg: const Color(0xFF9145FF),
                  title: 'Chat GPT 4.0 Premium',
                  onTap: () {},
                ),
              ]),
              const SizedBox(height: 20),

              // Group 4: Log Out
              _buildGroupContainer([
                _buildSettingItem(
                  icon: Iconsax.logout,
                  iconBg: const Color(0xFFF75555),
                  title: 'Log Out',
                  onTap: () {},
                ),
              ]),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              onPressed: () {},
              child: const Text(
                'Edit',
                style: TextStyle(
                  color: Color(0xFF246BFD),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const CircleAvatar(
          radius: 60,
          backgroundColor: Color(0xFFE5E7EB),
          backgroundImage: NetworkImage(
            'https://api.dicebear.com/7.x/avataaars/png?seed=Zachery&backgroundColor=b6e3f4',
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Zachery Williamson',
          style: TextStyle(
            color: Color(0xFF1F2937),
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'zachery.williamson94@gmail.com',
          style: TextStyle(color: Color(0xFF6B7280), fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildGroupContainer(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildDivider() {
    return const Divider(
      height: 1,
      thickness: 1,
      color: Color(0xFFE5E7EB),
      indent: 60,
      endIndent: 16,
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required Color iconBg,
    required String title,
    Widget? trailing,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: iconBg,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: Color(0xFF1F2937),
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing:
          trailing ??
          const Icon(Iconsax.arrow_right_3, color: Color(0xFFD1D5DB), size: 18),
    );
  }

  Widget _buildLanguageBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF246BFD).withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Text(
            'English',
            style: TextStyle(
              color: Color(0xFF246BFD),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(width: 4),
          Icon(Iconsax.arrow_right_3, color: Color(0xFF246BFD), size: 14),
        ],
      ),
    );
  }
}

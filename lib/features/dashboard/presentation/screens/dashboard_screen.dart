import 'dart:io';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../core/constants/app_colors.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Dark Header Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 50, 20, 30),
              decoration: const BoxDecoration(
                color: Color(0xFF131E29), // Dark Navy matching photo
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // New Top Bar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Icon(Iconsax.menu_1, color: Colors.white, size: 28),
                      const Text(
                        "Dashboard",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 1.5),
                        ),
                        child: const CircleAvatar(
                          radius: 16,
                          backgroundColor: Colors.transparent,
                          child: Icon(
                            Iconsax.user,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),

                  // Greeting & Headline
                  const Text(
                    "Good Morning! Inam 👋",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    "Let's see what can I do for you?",
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Mosaic Cards Section
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Left: AI Voice Generator (Large)
                      Expanded(
                        flex: 1,
                        child: _buildMosaicCard(
                          title: "AI Voice Generator",
                          subtitle: "Let's see\nwhat can I do\nfor you?",
                          color: const Color(0xFFFFCC33), // Golden Yellow
                          imagePath:
                              'C:/Users/Administrator/.gemini/antigravity/brain/7ac5ae6e-4ea9-43a1-bd99-e2d524234c73/3d_guitar_illustration_1768412635209.png',
                          isLarge: true,
                          icon: Iconsax.microphone_2,
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Right Column: TTS & Music Maker
                      Expanded(
                        flex: 1,
                        child: Column(
                          children: [
                            _buildMosaicCard(
                              title: "Text-to-speech",
                              color: const Color(0xFFFF7A4F), // Salmon Orange
                              imagePath:
                                  'C:/Users/Administrator/.gemini/antigravity/brain/7ac5ae6e-4ea9-43a1-bd99-e2d524234c73/3d_chat_bubble_illustration_1768412649803.png',
                              icon: Iconsax.message_text,
                            ),
                            const SizedBox(height: 8),
                            _buildMosaicCard(
                              title: "Music Maker",
                              color: const Color(0xFF7F3DFF), // Purple
                              imagePath:
                                  'C:/Users/Administrator/.gemini/antigravity/brain/7ac5ae6e-4ea9-43a1-bd99-e2d524234c73/3d_megaphone_illustration_1768412663044.png',
                              icon: Iconsax.user,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 3. Quick Actions
                  const Text(
                    "Quick Actions",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildQuickAction(
                        context,
                        "Upload",
                        Iconsax.document_upload,
                        AppColors.primary,
                        () {
                          // Navigate to Upload tab (controlled by parent) or screen
                          // For now, parent controls tabs, but we can't easily switch tab from here without provider/callback.
                          // But we can push to specific screens if they are separate.
                          // Since standard tabs are indexed, maybe just show snackbar "Go to Content tab"
                        },
                      ),
                      _buildQuickAction(
                        context,
                        "AI Chat",
                        Iconsax.messages_1,
                        Colors.purple,
                        () {},
                      ),
                      _buildQuickAction(
                        context,
                        "Take Quiz",
                        Iconsax.message_question,
                        Colors.teal,
                        () {},
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // 4. Recent Activity
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Continue Learning",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton(
                        onPressed: () {},
                        child: const Text("See All"),
                      ),
                    ],
                  ),
                  _buildRecentItem(
                    "Flutter Architecture.pdf",
                    "PDF • 2 hours ago",
                    0.75,
                  ),
                  _buildRecentItem(
                    "Laravel Basics Quiz",
                    "Quiz • Yesterday",
                    1.0,
                  ),

                  const SizedBox(height: 24),

                  // 5. Recommendations
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        const Icon(Iconsax.lamp_on, color: AppColors.primary),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Recommendation",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "Review 'Solid Principles' to improve your score.",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.primary.withOpacity(0.8),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Iconsax.arrow_right_3,
                          size: 16,
                          color: AppColors.primary,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMosaicCard({
    required String title,
    String? subtitle,
    required Color color,
    required String imagePath,
    bool isLarge = false,
    required IconData icon,
  }) {
    return Container(
      height: isLarge ? 280 : 136, // Slightly taller for premium feel
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color, color.withOpacity(0.8)],
        ),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // 3D Illustration
          Positioned(
            right: isLarge ? -20 : -10,
            bottom: isLarge ? -10 : -5,
            width: isLarge ? 200 : 110,
            height: isLarge ? 200 : 110,
            child: Transform.rotate(
              angle: isLarge ? -0.1 : 0, // Slight tilt for dynamism
              child: Image.file(File(imagePath), fit: BoxFit.contain),
            ),
          ),

          // Content Layer
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon Chip
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.25),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: Colors.white, size: 20),
                ),
                const SizedBox(height: 12),
                // Feature Label (Small/Light)
                Text(
                  title.toUpperCase(),
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.2,
                  ),
                ),
                if (isLarge && subtitle != null) ...[
                  const Spacer(),
                  // Main Typography (Bold/Large)
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      height: 1.1,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAction(
    BuildContext context,
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentItem(String title, String subtitle, double progress) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Iconsax.document, color: Colors.grey),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          if (progress > 0)
            SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                value: progress,
                strokeWidth: 3,
                backgroundColor: Colors.grey[200],
                valueColor: const AlwaysStoppedAnimation<Color>(
                  AppColors.primary,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

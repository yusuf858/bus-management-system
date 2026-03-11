import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Help & Support'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.help_outline,
                    size: 60,
                    color: AppColors.textWhite,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'How can we help you?',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textWhite,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Find answers to common questions',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textWhite.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // FAQ Section
            const Text(
              'Frequently Asked Questions',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),

            _buildFAQItem(
              question: 'How do I track my bus?',
              answer:
              'Go to the "Tracking" tab from the bottom navigation. Select your bus from the list to see its real-time location on the map.',
            ),
            _buildFAQItem(
              question: 'How do I view bus routes?',
              answer:
              'Navigate to the "Routes" tab to see all available bus routes, stops, and schedules.',
            ),
            _buildFAQItem(
              question: 'How do I change my password?',
              answer:
              'Go to Profile → Change Password. Enter your current password and new password to update.',
            ),
            _buildFAQItem(
              question: 'Why am I not receiving notifications?',
              answer:
              'Make sure notifications are enabled in your device settings. Go to Settings → Apps → Bus Management System → Notifications and enable them.',
            ),
            _buildFAQItem(
              question: 'How do I update my profile?',
              answer:
              'Go to the Profile tab and tap on "Edit Profile" to update your information.',
            ),
            _buildFAQItem(
              question: 'What do I do if the bus location is not updating?',
              answer:
              'This might be due to GPS issues on the bus. Contact your administrator if the problem persists.',
            ),

            const SizedBox(height: 32),

            // Contact Support Section
            const Text(
              'Need More Help?',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),

            _buildContactCard(
              icon: Icons.email,
              title: 'Email Support',
              subtitle: 'support@busmanagement.com',
              onTap: () {
                // TODO: Implement email launch
              },
            ),
            const SizedBox(height: 12),
            _buildContactCard(
              icon: Icons.phone,
              title: 'Phone Support',
              subtitle: '+91 1234567890',
              onTap: () {
                // TODO: Implement phone call
              },
            ),
            const SizedBox(height: 12),
            _buildContactCard(
              icon: Icons.chat,
              title: 'Live Chat',
              subtitle: 'Chat with our support team',
              onTap: () {
                // TODO: Implement live chat
              },
            ),

            const SizedBox(height: 32),

            // User Guides Section
            const Text(
              'User Guides',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),

            _buildGuideCard(
              icon: Icons.school,
              title: 'Student Guide',
              description: 'Learn how to use the app as a student',
              onTap: () {
                // TODO: Navigate to student guide
              },
            ),
            const SizedBox(height: 12),
            _buildGuideCard(
              icon: Icons.directions_bus,
              title: 'Driver Guide',
              description: 'Instructions for bus drivers',
              onTap: () {
                // TODO: Navigate to driver guide
              },
            ),
            const SizedBox(height: 12),
            _buildGuideCard(
              icon: Icons.admin_panel_settings,
              title: 'Admin Guide',
              description: 'Administrative features and management',
              onTap: () {
                // TODO: Navigate to admin guide
              },
            ),

            const SizedBox(height: 32),

            // App Info
            Center(
              child: Column(
                children: [
                  Text(
                    'Bus Management System',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Version ${AppStrings.appVersion}',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildFAQItem({
    required String question,
    required String answer,
  }) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Theme(
        data: ThemeData(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          title: Text(
            question,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          iconColor: AppColors.primaryColor,
          collapsedIconColor: AppColors.textSecondary,
          children: [
            Text(
              answer,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: AppColors.primaryColor,
            size: 24,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }

  Widget _buildGuideCard({
    required IconData icon,
    required String title,
    required String description,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: AppColors.textWhite,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
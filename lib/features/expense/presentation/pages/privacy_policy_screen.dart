import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Privacy Policy')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Center(
              child: Column(
                children: [
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color: Colors.deepPurple.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.privacy_tip_outlined,
                      color: Colors.deepPurple,
                      size: 36,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Privacy Policy',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Last updated: March 2026',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // Quick summary card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green.withOpacity(0.3)),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('✅ In Simple Terms:',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 14)),
                  SizedBox(height: 10),
                  Text('• Your data belongs to you'),
                  Text('• We never sell or share your data'),
                  Text('• Stored securely on Google Firebase'),
                  Text('• No ads, no tracking'),
                  Text('• You can delete everything anytime'),
                ],
              ),
            ),
            const SizedBox(height: 24),

            _buildSection(
              '1. Information We Collect',
              'We collect the following information when you use Expense Tracker:\n\n'
              '• Email address (for account creation)\n'
              '• Username (display name)\n'
              '• Expense data you manually enter (title, amount, category, date, description)\n\n'
              'We do NOT collect:\n'
              '• Location data\n'
              '• Device contacts\n'
              '• Payment information\n'
              '• Any data without your knowledge',
            ),

            _buildSection(
              '2. How We Use Your Information',
              '• To create and manage your account\n'
              '• To store and sync your expense data across devices\n'
              '• To provide budget alerts and reports\n'
              '• To generate PDF exports of your data\n\n'
              'We do NOT use your data for advertising or sell it to any third party.',
            ),

            _buildSection(
              '3. Data Storage & Security',
              'Your data is stored securely on Google Firebase (Firestore), a trusted cloud platform by Google.\n\n'
              '• Data is encrypted in transit using HTTPS\n'
              '• Access is restricted to your account only\n'
              '• Firebase security rules ensure no other user can access your data\n'
              '• We follow industry standard security practices',
            ),

            _buildSection(
              '4. Third Party Services',
              'We use the following third party services:\n\n'
              '• Google Firebase — Authentication & Database\n'
              '• Google Fonts — Typography\n\n'
              'These services have their own privacy policies. We encourage you to review them.',
            ),

            _buildSection(
              '5. Your Rights',
              'You have full control over your data:\n\n'
              '• View — All your data is visible within the app\n'
              '• Edit — You can modify any expense at any time\n'
              '• Delete — You can delete individual expenses or all expenses\n'
              '• Account Deletion — You can permanently delete your account and all associated data from the Profile page\n\n'
              'Upon account deletion, all your data is immediately and permanently removed from our servers.',
            ),

            _buildSection(
              '6. Data Retention',
              'Your data is retained as long as your account is active. When you delete your account:\n\n'
              '• All expenses are permanently deleted\n'
              '• Your user profile is permanently deleted\n'
              '• This action cannot be undone',
            ),

            _buildSection(
              '7. Children\'s Privacy',
              'This app is not intended for children under 13 years of age. We do not knowingly collect personal information from children under 13.',
            ),

            _buildSection(
              '8. Changes to This Policy',
              'We may update this Privacy Policy from time to time. We will notify you of any changes by updating the "Last updated" date at the top of this page.',
            ),

            _buildSection(
              '9. Contact Us',
              'If you have any questions about this Privacy Policy, please contact us:\n\n'
              '📧 lingarajgm6@gmail.com\n'
              '🔗 github.com/lingarajgm',
            ),

            const SizedBox(height: 30),

            // Footer
            Center(
              child: Text(
                '© 2026 Expense Tracker by Lingaraj G M\nAll rights reserved.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade500,
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.deepPurple,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: const TextStyle(
              fontSize: 14,
              height: 1.7,
            ),
          ),
          const Divider(height: 32),
        ],
      ),
    );
  }
}
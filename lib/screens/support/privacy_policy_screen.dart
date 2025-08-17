import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFFFA726), Color(0xFFFFD600)],
              begin: Alignment.topLeft,
              end: Alignment.topRight,
            ),
          ),
          child: SafeArea(
            child: Row(
              children: [
                IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.arrow_back, color: Colors.brown),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Text(
                      'Privacy Policy',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.brown,
                      ),
                    ),
                    Text(
                      'Your privacy matters to us',
                      style: TextStyle(fontSize: 14, color: Colors.brown),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Introduction
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.privacy_tip, color: Colors.blue[600], size: 28),
                        const SizedBox(width: 12),
                        const Text(
                          'Our Privacy Commitment',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFFFA726),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'At PlugnPipe, we are committed to protecting your privacy and ensuring the security of your personal information. This privacy policy explains how we collect, use, and safeguard your data.',
                      style: TextStyle(fontSize: 14, height: 1.5),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Last updated: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Information We Collect
            _buildPolicySection(
              'Information We Collect',
              Icons.info,
              [
                'Personal Information: Name, email address, phone number, student ID',
                'Service Requests: Details about repair services you request',
                'Location Data: Address and room information for service delivery',
                'Communication Records: Messages and support interactions',
                'Device Information: App usage data and device identifiers',
              ],
            ),

            // How We Use Information
            _buildPolicySection(
              'How We Use Your Information',
              Icons.settings,
              [
                'Provide and improve our repair services',
                'Process and manage your service requests',
                'Send notifications about service status updates',
                'Provide customer support and respond to inquiries',
                'Analyze app usage to enhance user experience',
                'Ensure security and prevent fraud',
              ],
            ),

            // Information Sharing
            _buildPolicySection(
              'Information Sharing',
              Icons.share,
              [
                'Service Providers: We share necessary information with repair technicians',
                'Emergency Services: Location data may be shared during emergencies',
                'Legal Requirements: We may disclose information when required by law',
                'Business Partners: Limited data sharing with trusted service partners',
                'We never sell your personal information to third parties',
              ],
            ),

            // Data Security
            _buildPolicySection(
              'Data Security',
              Icons.security,
              [
                'Encryption of sensitive data in transit and at rest',
                'Regular security audits and vulnerability assessments',
                'Access controls and authentication measures',
                'Secure servers and data centers',
                'Employee training on data protection practices',
              ],
            ),

            // Your Rights
            _buildPolicySection(
              'Your Privacy Rights',
              Icons.account_circle,
              [
                'Access: Request a copy of your personal information',
                'Correction: Update or correct inaccurate information',
                'Deletion: Request deletion of your personal data',
                'Portability: Receive your data in a portable format',
                'Opt-out: Unsubscribe from marketing communications',
              ],
            ),

            // Data Retention
            _buildPolicySection(
              'Data Retention',
              Icons.schedule,
              [
                'Account information: Retained while your account is active',
                'Service records: Kept for 2 years for warranty purposes',
                'Communication logs: Stored for 1 year for quality assurance',
                'Analytics data: Anonymized and retained for business insights',
                'Deleted data is securely removed from our systems',
              ],
            ),

            // Contact Information
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 2,
              child: Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    colors: [Colors.blue[50]!, Colors.blue[100]!],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.contact_support, color: Colors.blue[600], size: 28),
                        const SizedBox(width: 12),
                        const Text(
                          'Contact Us About Privacy',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFFFA726),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'If you have questions about this privacy policy or your personal information:',
                      style: TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 12),
                    _buildContactItem(Icons.email, 'Email', 'privacy@plugnpipe.com'),
                    const SizedBox(height: 8),
                    _buildContactItem(Icons.phone, 'Phone', '+1 (555) 123-PRIVACY'),
                    const SizedBox(height: 8),
                    _buildContactItem(Icons.location_on, 'Address', '123 University Ave, Student Services'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Agreement
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 2,
              child: Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    colors: [Colors.green[50]!, Colors.green[100]!],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.green[600], size: 28),
                        const SizedBox(width: 12),
                        const Text(
                          'Policy Updates',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFFFA726),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'We may update this privacy policy from time to time. We will notify you of any material changes through the app or via email. By continuing to use our services, you agree to the updated privacy policy.',
                      style: TextStyle(fontSize: 14, height: 1.5),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPolicySection(String title, IconData icon, List<String> points) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: const Color(0xFFFFA726), size: 24),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFFFA726),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...points.map((point) => Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 6),
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: Color(0xFFFFA726),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      point,
                      style: const TextStyle(fontSize: 14, height: 1.4),
                    ),
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildContactItem(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: Colors.blue[600], size: 20),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 14),
          ),
        ),
      ],
    );
  }
}

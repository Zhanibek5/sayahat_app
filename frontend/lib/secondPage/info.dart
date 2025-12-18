import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:easy_localization/easy_localization.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.white, // any color you want
        ),
        title: Text(
          "Sayahat",
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.teal,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Title
            Text(
              'about_header'.tr(),
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            Text(
              'about_description'.tr(),
              style: theme.textTheme.bodyMedium,
            ),

            const SizedBox(height: 25),

            // --- FEATURES SECTION ---
            Text(
              'features_title'.tr(),
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            _featureCard(
              context,
              icon: Icons.map,
              title: 'feature_map_title'.tr(),
              description: 'feature_map_desc'.tr(),
            ),
            _featureCard(
              context,
              icon: Icons.info_outline,
              title: 'feature_info_title'.tr(),
              description: 'feature_info_desc'.tr(),
            ),
            _featureCard(
              context,
              icon: Icons.route,
              title: 'feature_route_title'.tr(),
              description: 'feature_route_desc'.tr(),
            ),
            _featureCard(
              context,
              icon: Icons.language,
              title: 'feature_lang_title'.tr(),
              description: 'feature_lang_desc'.tr(),
            ),
            _featureCard(
              context,
              icon: Icons.notifications_active,
              title: 'feature_extra_title'.tr(),
              description: 'feature_extra_desc'.tr(),
            ),

            const SizedBox(height: 25),

            // --- AUDIO GUIDE SECTION ---
            Text(
              'audio_title'.tr(),
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),

            _audioGuideCard(),

            const SizedBox(height: 25),

            // --- HOW TO USE SECTION ---
            Text(
              'howto_title'.tr(),
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            _howToUseStep(
              number: "1",
              text: 'howto_step1'.tr(),
            ),
            _howToUseStep(
              number: "2",
              text: 'howto_step2'.tr(),
            ),
            _howToUseStep(
              number: "3",
              text: 'howto_step3'.tr(),
            ),
            _howToUseStep(
              number: "4",
              text: 'howto_step4'.tr(),
            ),
            _howToUseStep(
              number: "5",
              text: 'howto_step5'.tr(),
            ),

            const SizedBox(height: 35),
            Center(
              child: Text(
                "Sayahat",
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.grey,
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // --- FEATURE CARD ---
  Widget _featureCard(BuildContext context,
      {required IconData icon,
      required String title,
      required String description}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, size: 36, color: Theme.of(context).primaryColor),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontSize: 17, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(description,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      )),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  // --- AUDIO GUIDE CARD ---
  Widget _audioGuideCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            const Icon(Icons.headphones, size: 40, color: Colors.deepPurple),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('audio_listen'.tr(),
                      style:
                          TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(
                    'audio_desc'.tr(),
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- HOW-TO-USE STEP ---
  Widget _howToUseStep({required String number, required String text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: Colors.blue.shade600,
            child: Text(number,
                style: const TextStyle(color: Colors.white, fontSize: 16)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }
}

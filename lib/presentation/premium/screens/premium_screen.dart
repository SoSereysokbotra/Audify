import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class PremiumScreen extends StatefulWidget {
  const PremiumScreen({Key? key}) : super(key: key);

  @override
  State<PremiumScreen> createState() => _PremiumScreenState();
}

class _PremiumScreenState extends State<PremiumScreen> {
  bool _isYearly = true; // true = Yearly, false = Quarterly

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Pure black background matching image
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Close button
              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: () {
                    // Logic to close or go back if it's a modal, but since it's a tab, it might just stay or switch tabs.
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.close, color: Colors.white, size: 20),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              // Title
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: AppTextStyles.h1.copyWith(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    height: 1.2,
                    color: Colors.white,
                  ),
                  children: const [
                    TextSpan(text: 'Unlock your '),
                    WidgetSpan(
                      child: Icon(Icons.flash_on, color: Colors.white, size: 30),
                      alignment: PlaceholderAlignment.middle,
                    ),
                    TextSpan(text: 'Audify+\n'),
                    TextSpan(text: 'listening superpowers'),
                  ],
                ),
              ),
              const SizedBox(height: 40),

              // Features Container
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF161616), // Dark grey background
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                ),
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  children: [
                    _buildFeatureItem(
                      icon: Icons.all_inclusive,
                      title: "Unlimited skips",
                      subtitle: "Listen without limits",
                    ),
                    _buildFeatureItem(
                      icon: Icons.offline_bolt_outlined,
                      title: "Listen anywhere",
                      subtitle: "Download your favorite tracks offline",
                    ),
                    _buildFeatureItem(
                      icon: Icons.language,
                      title: "High-res audio",
                      subtitle: "Experience studio quality sound",
                    ),
                    _buildFeatureItem(
                      icon: Icons.auto_awesome_mosaic,
                      title: "Ad-free experience",
                      subtitle: "No interruptions, just pure music",
                      isLast: true,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Pricing Selector
              Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.topCenter,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 12), // space for the badge
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF161616),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                    ),
                    child: Row(
                      children: [
                        _buildPricingOption(
                          title: "Yearly",
                          price: "\$27.99",
                          subtitle: "\$2.33 per month",
                          isSelected: _isYearly,
                          onTap: () => setState(() => _isYearly = true),
                        ),
                        _buildPricingOption(
                          title: "Quarterly",
                          price: "\$9.99",
                          subtitle: "\$3.33 per month",
                          isSelected: !_isYearly,
                          onTap: () => setState(() => _isYearly = false),
                        ),
                      ],
                    ),
                  ),
                  // Save 30% Badge
                  Positioned(
                    top: 0,
                    left: 70,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        "Save 30%",
                        style: AppTextStyles.bodySmall.copyWith(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Disclaimer
              Text(
                _isYearly 
                    ? "\$2.33 per month billed yearly.\nAuto-renews unless canceled at least 24 hours before\nrenewal. Cancel anytime in App Store settings."
                    : "\$3.33 per month billed quarterly.\nAuto-renews unless canceled at least 24 hours before\nrenewal. Cancel anytime in App Store settings.",
                textAlign: TextAlign.center,
                style: AppTextStyles.helper.copyWith(
                  color: Colors.white54,
                  fontSize: 12,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 32),

              // CTA Button
              GestureDetector(
                onTap: () {
                  // Handle subscription
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Center(
                    child: Text(
                      _isYearly ? "Get Audify+ Yearly" : "Get Audify+ Quarterly",
                      style: AppTextStyles.button.copyWith(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Footer Links
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildFooterLink("Terms of service"),
                  const SizedBox(width: 12),
                  _buildFooterLink("Privacy policy"),
                  const SizedBox(width: 12),
                  _buildFooterLink("Restore purchase"),
                ],
              ),
              const SizedBox(height: 30), // Bottom padding
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required String title,
    required String subtitle,
    bool isLast = false,
  }) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: isLast ? 20 : 0,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white, size: 28),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: Colors.white54,
                    fontSize: 13,
                  ),
                ),
                if (!isLast)
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Divider(
                      height: 1,
                      thickness: 1,
                      color: Colors.white.withValues(alpha: 0.05),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Container(
            padding: const EdgeInsets.all(2),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check, color: Colors.black, size: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildPricingOption({
    required String title,
    required String price,
    required String subtitle,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            children: [
              Text(
                title,
                style: AppTextStyles.bodySmall.copyWith(
                  color: isSelected ? Colors.black54 : Colors.white54,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                price,
                style: AppTextStyles.h2.copyWith(
                  color: isSelected ? Colors.black : Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: AppTextStyles.bodySmall.copyWith(
                  color: isSelected ? Colors.black54 : Colors.white38,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFooterLink(String text) {
    return GestureDetector(
      onTap: () {},
      child: Text(
        text,
        style: AppTextStyles.helper.copyWith(
          color: Colors.white54,
          fontSize: 12,
        ),
      ),
    );
  }
}

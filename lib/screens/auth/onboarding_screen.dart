import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../screens/auth/welcome_screen.dart';
import '../../utils/constants.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  bool isLastPage = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _controller,
                onPageChanged: (index) {
                  setState(() {
                    isLastPage = index == 2;
                  });
                },
                children: const [
                  _OnboardingPage(
                    image: 'assets/images/1-Photoroom.png',
                    title: 'The Daily Wear with Fashion',
                    subtitle: 'Find all types of shoes at one stop.',
                  ),
                  _OnboardingPage(
                    image: 'assets/images/shoe_store_01.png',
                    title: 'Shop Variety',
                    subtitle:
                        'Shop from a wide range of shoes to get the perfect fit.',
                  ),
                  _OnboardingPage(
                    image: 'assets/images/shoe_store_07.png',
                    title: 'Stay in Trend',
                    subtitle: 'Be on top of your fashion game.',
                  ),
                ],
              ),
            ),

            /// Page Indicator
            SmoothPageIndicator(
              controller: _controller,
              count: 3,
              effect: const SwapEffect(
                activeDotColor: AppConstants.primaryColor,
                dotHeight: 10,
                dotWidth: 10,
              ),
            ),

            const SizedBox(height: 30),

            /// Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    if (isLastPage) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const WelcomeScreen(),
                        ),
                      );
                    } else {
                      _controller.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppConstants.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: Text(
                    isLastPage ? "Get Started" : "Next",
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

/// Single onboarding page widget
class _OnboardingPage extends StatelessWidget {
  final String image;
  final String title;
  final String subtitle;

  const _OnboardingPage({
    required this.image,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(image, height: 500),
          const SizedBox(height: 20),
          Text(
            title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

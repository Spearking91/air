import 'package:air/auth/login_page.dart';
import 'package:flutter/material.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingContent> _contents = [
    OnboardingContent(
      title: 'Welcome to Air',
      description: 'Discover amazing features that will make your life easier',
      background: 'assets/images/pexels-andre-furtado-43594-1263986.jpg',
    ),
    OnboardingContent(
      title: 'Easy to Use',
      description: 'Simple and intuitive interface for the best experience',
      background: 'assets/images/pexels-alexander-dummer-37646-1919030.jpg',
    ),
    OnboardingContent(
      title: 'Get Started',
      description: 'Join us now and start your journey',
      background: 'assets/images/pexels-ben-mack-5326943.jpg',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  itemCount: _contents.length,
                  itemBuilder: (context, index) {
                    return Stack(
                      children: [
                        Image.asset(
                          _contents[index].background,
                          filterQuality: FilterQuality.low,
                          fit: BoxFit.cover,
                          height: double.maxFinite,
                        ),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20.0),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                                begin: Alignment.center,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.black26,
                                  Colors.black,
                                ]),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                _contents[index].title,
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors
                                      .white, // Changed to white for better visibility
                                ),
                              ),
                              const SizedBox(height: 15),
                              Text(
                                _contents[index].description,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors
                                      .white70, // Changed to white with opacity
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
          Container(
            color: Colors.black,
            padding:
                const EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: List.generate(
                    _contents.length,
                    (index) => buildDot(index),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (_currentPage == _contents.length - 1) {
                      // Navigate to home page or next screen
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) {
                            return LoginPage();
                          },
                        ),
                      );
                    } else {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeIn,
                      );
                    }
                  },
                  child: Text(
                    _currentPage == _contents.length - 1
                        ? 'Get Started'
                        : 'Next',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildDot(int index) {
    return Container(
      height: 10,
      width: 10,
      margin: const EdgeInsets.only(right: 5),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _currentPage != index
            ? Theme.of(context).primaryColor.withValues(alpha: 0.5)
            : Colors.grey.shade300,
      ),
    );
  }
}

class OnboardingContent {
  final String title;
  final String description;
  final String background;

  OnboardingContent(
      {required this.title,
      required this.description,
      required this.background});
}

import 'package:flutter/material.dart';

/// Onboarding screen with page view for first-time users.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageController = PageController();
  int _currentPage = 0;

  final _pages = const [
    _OnboardingPage(
      image: 'assets/images/ob1.jpg',
      title: 'Uppgötvaðu Ísland',
      description: 'Finndu faldar perlur og vinsæla staði um allt land.',
    ),
    _OnboardingPage(
      image: 'assets/images/ob2.jpg',
      title: 'Persónulegar leiðir',
      description: 'Fáðu sérhannaðar ferðaáætlanir byggðar á þínum áhugamálum.',
    ),
    _OnboardingPage(
      image: 'assets/images/ob3.jpg',
      title: 'Ellie • AI ferðaráðgjafi',
      description:
          'Spjallaðu við gervigreindarráðgjafann okkar fyrir bestu upplifunina.',
    ),
  ];

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _finishOnboarding();
    }
  }

  void _finishOnboarding() {
    Navigator.of(context).pushReplacementNamed('/home');
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() => _currentPage = index);
            },
            itemCount: _pages.length,
            itemBuilder: (context, index) => _pages[index],
          ),
          Positioned(
            bottom: 80,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    _pages.length,
                    (index) => _PageIndicator(
                      isActive: index == _currentPage,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _nextPage,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        _currentPage == _pages.length - 1
                            ? 'Byrja að ferðast'
                            : 'Áfram',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
                if (_currentPage < _pages.length - 1)
                  TextButton(
                    onPressed: _finishOnboarding,
                    child: const Text('Sleppa'),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OnboardingPage extends StatelessWidget {
  const _OnboardingPage({
    required this.image,
    required this.title,
    required this.description,
  });

  final String image;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(
          image,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: Theme.of(context).colorScheme.primaryContainer,
              child: const Center(
                child: Icon(Icons.image, size: 100),
              ),
            );
          },
        ),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                Colors.black.withOpacity(0.7),
              ],
            ),
          ),
        ),
        Positioned(
          bottom: 200,
          left: 32,
          right: 32,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),
              Text(
                description,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.white.withOpacity(0.9),
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PageIndicator extends StatelessWidget {
  const _PageIndicator({required this.isActive});

  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: isActive ? 24 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: isActive
            ? Theme.of(context).colorScheme.primary
            : Colors.white.withOpacity(0.4),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

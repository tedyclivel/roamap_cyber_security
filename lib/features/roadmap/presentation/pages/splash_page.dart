// lib/features/roadmap/presentation/pages/splash_page.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iron_mind/core/theme/app_theme.dart';
import 'package:iron_mind/features/roadmap/presentation/providers/roadmap_providers.dart';

class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage> {
  final List<String> _logs = [];
  final ScrollController _scrollController = ScrollController();
  bool _showLogo = false;
  double _progress = 0.0;

  final List<String> _bootSequence = [
    '[ OK ] Initializing IronMind OS v1.0.4...',
    '[ OK ] Checking hardware integrity...',
    '[ OK ] Loading Neural Link kernel...',
    '[ OK ] DASM: Direct Access Storage Module -> Online',
    '[ OK ] HIVE: Local Registry -> Synchronized',
    '[ OK ] Bio-Metric Sync: HeartRate/Stress -> Static',
    '[ OK ] Establishing secure uplink...',
    '[ OK ] Decrypting User Profile...',
    '[ OK ] Applying HUD-Elite display drivers...',
    '[ OK ] System ready.',
  ];

  @override
  void initState() {
    super.initState();
    _runBootSequence();
  }

  Future<void> _runBootSequence() async {
    for (var i = 0; i < _bootSequence.length; i++) {
      if (!mounted) return;
      setState(() {
        _logs.add(_bootSequence[i]);
        _progress = (i + 1) / _bootSequence.length;
      });
      
      // Scroll to bottom
      Future.delayed(const Duration(milliseconds: 50), () {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
          );
        }
      });

      await Future.delayed(Duration(milliseconds: 100 + (indexToDelay(i))));
      
      if (i == 4) {
        setState(() => _showLogo = true);
      }
    }

    await Future.delayed(const Duration(milliseconds: 800));
    _navigate();
  }

  int indexToDelay(int i) {
    if (i == 3 || i == 7) return 400; // Simuler un chargement plus long
    return 150;
  }

  Future<void> _navigate() async {
    if (!mounted) return;
    try {
      final repo = ref.read(repositoryProvider);
      final initialized = await repo.isRoadmapInitialized();
      if (!mounted) return;
      if (initialized) {
        context.go('/');
      } else {
        context.go('/onboarding');
      }
    } catch (e) {
      if (mounted) context.go('/onboarding');
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Logo Section
                Expanded(
                  flex: 2,
                  child: Center(
                    child: AnimatedOpacity(
                      opacity: _showLogo ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 1000),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                                  blurRadius: 30,
                                  spreadRadius: 10,
                                ),
                              ],
                            ),
                            child: ClipOval(
                              child: Image.asset(
                                'assets/images/logo.png',
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Icon(Icons.terminal, color: Theme.of(context).colorScheme.primary, size: 60),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'IRON MIND',
                            style: TextStyle(
                              fontFamily: 'Orbitron',
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                              color: Theme.of(context).colorScheme.primary,
                              letterSpacing: 4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
  
                // Boot Logs Section
                Expanded(
                  flex: 3,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      border: Border.all(color: Theme.of(context).colorScheme.primary.withOpacity(0.2)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.terminal, color: Theme.of(context).colorScheme.primary, size: 14),
                            const SizedBox(width: 8),
                            Text(
                              'SYSTEM_BOOT_LOG',
                              style: TextStyle(
                                fontFamily: 'JetBrainsMono',
                                fontSize: 10,
                                color: Theme.of(context).colorScheme.primary.withOpacity(0.7),
                                letterSpacing: 1,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              '${(_progress * 100).toInt()}%',
                              style: TextStyle(
                                fontFamily: 'JetBrainsMono',
                                fontSize: 10,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Divider(color: Theme.of(context).colorScheme.primary, thickness: 0.2),
                        ),
                        Expanded(
                          child: ListView.builder(
                            controller: _scrollController,
                            itemCount: _logs.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 4.0),
                                child: Text(
                                  _logs[index],
                                  style: TextStyle(
                                    fontFamily: 'JetBrainsMono',
                                    fontSize: 11,
                                    color: Theme.of(context).colorScheme.primary.withOpacity(0.9),
                                    height: 1.4,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Progress Line
                LinearProgressIndicator(
                  value: _progress,
                  backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.05),
                  valueColor: AlwaysStoppedAnimation(Theme.of(context).colorScheme.primary),
                  minHeight: 1,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

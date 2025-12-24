import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/providers/auth_provider.dart';
import '../../../shared/theme/app_theme.dart';
import '../../../core/router/app_router.dart';

class PinSetupScreen extends ConsumerStatefulWidget {
  const PinSetupScreen({super.key});

  @override
  ConsumerState<PinSetupScreen> createState() => _PinSetupScreenState();
}

class _PinSetupScreenState extends ConsumerState<PinSetupScreen> {
  final List<TextEditingController> _pinControllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  String _pin = '';
  String _confirmPin = '';
  bool _isConfirmStep = false;
  bool _isLoading = false;

  @override
  void dispose() {
    for (var controller in _pinControllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _onPinChanged(int index, String value) {
    if (value.length == 1 && index < 5) {
      _focusNodes[index + 1].requestFocus();
    }

    final pin = _pinControllers.map((c) => c.text).join();

    if (pin.length == 6) {
      if (!_isConfirmStep) {
        setState(() {
          _pin = pin;
          _isConfirmStep = true;
        });
        _clearPin();
        _focusNodes[0].requestFocus();
      } else {
        _confirmPin = pin;
        _handlePinSetup();
      }
    }
  }

  void _onPinBackspace(int index) {
    if (_pinControllers[index].text.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
  }

  void _clearPin() {
    for (var controller in _pinControllers) {
      controller.clear();
    }
  }

  Future<void> _handlePinSetup() async {
    if (_pin != _confirmPin) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('PINs do not match. Please try again.'),
          backgroundColor: AppColors.error,
        ),
      );
      setState(() {
        _pin = '';
        _confirmPin = '';
        _isConfirmStep = false;
      });
      _clearPin();
      _focusNodes[0].requestFocus();
      return;
    }

    setState(() => _isLoading = true);

    try {
      final success = await ref
          .read(authStateNotifierProvider.notifier)
          .setupPin(_pin);

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('PIN set up successfully'),
            backgroundColor: AppColors.success,
          ),
        );
        context.go(AppRoutes.home);
      } else {
        throw Exception('Failed to set up PIN');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: AppColors.error,
          ),
        );
        setState(() {
          _pin = '';
          _confirmPin = '';
          _isConfirmStep = false;
        });
        _clearPin();
        _focusNodes[0].requestFocus();
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Set Up PIN'),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppSpacing.xl),

              // Icon
              Center(
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.lock_outline,
                    size: 40,
                    color: AppColors.primary,
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.xl),

              // Title
              Text(
                _isConfirmStep ? 'Confirm Your PIN' : 'Create a 6-Digit PIN',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: AppSpacing.sm),

              // Description
              Text(
                _isConfirmStep
                    ? 'Enter your PIN again to confirm'
                    : 'This PIN will be used to access sensitive information like payslips',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: AppSpacing.xxxl),

              // PIN input
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(6, (index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: SizedBox(
                      width: 48,
                      height: 56,
                      child: TextField(
                        controller: _pinControllers[index],
                        focusNode: _focusNodes[index],
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        maxLength: 1,
                        obscureText: true,
                        enabled: !_isLoading,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                        decoration: InputDecoration(
                          counterText: '',
                          filled: true,
                          fillColor: _pinControllers[index].text.isNotEmpty
                              ? AppColors.primary.withOpacity(0.1)
                              : Colors.grey.shade100,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: AppColors.primary,
                              width: 2,
                            ),
                          ),
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        onChanged: (value) => _onPinChanged(index, value),
                        onTap: () {
                          _pinControllers[index].selection = TextSelection(
                            baseOffset: 0,
                            extentOffset: _pinControllers[index].text.length,
                          );
                        },
                      ),
                    ),
                  );
                }),
              ),

              const SizedBox(height: AppSpacing.xl),

              // Loading indicator
              if (_isLoading)
                const Center(child: CircularProgressIndicator()),

              const Spacer(),

              // Skip button (optional)
              TextButton(
                onPressed: _isLoading
                    ? null
                    : () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Skip PIN Setup?'),
                            content: const Text(
                              'You can set up your PIN later from Settings. '
                              'Without a PIN, you won\'t be able to view payslips.',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Cancel'),
                              ),
                              FilledButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  context.go(AppRoutes.home);
                                },
                                child: const Text('Skip'),
                              ),
                            ],
                          ),
                        );
                      },
                child: const Text('Set Up Later'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

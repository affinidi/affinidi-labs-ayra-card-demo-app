import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../application/services/login_service/login_service_state.dart';

class LoginCard extends StatefulWidget {
  const LoginCard({
    super.key,
    required this.organizations,
    required this.onOrganizationChanged,
    required this.onLogin,
    required this.isLoading,
    required this.step,
    this.selectedOrganization,
    this.errorMessage,
    this.statusMessage,
  });

  final List<String> organizations;
  final Future<void> Function(String) onOrganizationChanged;
  final Future<void> Function(String, String) onLogin;
  final bool isLoading;
  final LoginFlowStep step;
  final String? selectedOrganization;
  final String? errorMessage;
  final String? statusMessage;

  @override
  State<LoginCard> createState() => _LoginCardState();
}

class _LoginCardState extends State<LoginCard> {
  final _emailController = TextEditingController();
  final _otpController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String? _currentOrganization;
  bool _otpSent = false;
  bool _isSendingOtp = false;

  @override
  void initState() {
    super.initState();
    _currentOrganization =
        widget.selectedOrganization ??
        (widget.organizations.isNotEmpty ? widget.organizations.first : null);

    _emailController.text = '@sweetlane-bank.com';
    _otpController.text = '123456';
  }

  @override
  void didUpdateWidget(covariant LoginCard oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.selectedOrganization != null &&
        widget.selectedOrganization!.isNotEmpty &&
        widget.selectedOrganization != _currentOrganization) {
      _currentOrganization = widget.selectedOrganization;
    }

    if (_currentOrganization != null &&
        !widget.organizations.contains(_currentOrganization)) {
      _currentOrganization = widget.organizations.isNotEmpty
          ? widget.organizations.first
          : null;
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _sendOtp() async {
    if (!_formKey.currentState!.validate()) return;
    if (_currentOrganization == null) return;

    setState(() {
      _isSendingOtp = true;
    });

    try {
      // Call the onLogin with a special flag or modify to handle OTP request
      // For now, we'll just simulate sending OTP
      await Future<void>.delayed(const Duration(seconds: 1));

      if (mounted) {
        setState(() {
          _otpSent = true;
          _isSendingOtp = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('OTP sent to your email'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSendingOtp = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send OTP: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasOrganizations = widget.organizations.isNotEmpty;
    final effectiveOrganization = _currentOrganization;
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              // Organization Dropdown
              if (hasOrganizations) ...[
                Text(
                  'Organization',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  key: ValueKey(effectiveOrganization),
                  initialValue: effectiveOrganization,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.business_rounded),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Colors.grey.shade700.withValues(alpha: 0.3),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Color(0xFF4F39F6),
                        width: 2,
                      ),
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade900,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                  ),
                  dropdownColor: Colors.grey.shade900,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                  items: widget.organizations.map((String org) {
                    return DropdownMenuItem<String>(
                      value: org,
                      child: Text(org),
                    );
                  }).toList(),
                  onChanged: widget.isLoading
                      ? null
                      : (String? newValue) {
                          if (newValue != null) {
                            setState(() {
                              _currentOrganization = newValue;
                            });
                            unawaited(widget.onOrganizationChanged(newValue));
                          }
                        },
                ),
                const SizedBox(height: 24),
              ] else ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade800.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    'No organizations are available for your account. '
                    'Please contact your administrator.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.grey.shade300,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // Email Field
              Text(
                'Email',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  hintText: 'your.email@company.com',
                  prefixIcon: const Icon(Icons.email_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Colors.grey.shade700.withValues(alpha: 0.3),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Color(0xFF4F39F6),
                      width: 2,
                    ),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade900,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                ),
                style: const TextStyle(color: Colors.white),
                keyboardType: TextInputType.emailAddress,
                autocorrect: false,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // OTP Field (shown after OTP is sent)
              if (_otpSent) ...[
                Text(
                  'Enter OTP',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _otpController,
                  obscureText: true,
                  decoration: InputDecoration(
                    hintText: 'Enter 6-digit OTP',
                    prefixIcon: const Icon(Icons.pin_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Colors.grey.shade700.withValues(alpha: 0.3),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Color(0xFF4F39F6),
                        width: 2,
                      ),
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade900,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                  ),
                  style: const TextStyle(color: Colors.white),
                  keyboardType: TextInputType.number,
                  // maxLength: 6,
                  autocorrect: false,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter OTP';
                    }
                    if (value.length != 6) {
                      return 'OTP must be 6 digits';
                    }
                    return null;
                  },
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: _isSendingOtp ? null : _sendOtp,
                      child: Text(
                        'Resend OTP',
                        style: TextStyle(
                          color: _isSendingOtp
                              ? Colors.grey.shade600
                              : const Color(0xFF4F39F6),
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _otpSent = false;
                          _otpController.clear();
                        });
                      },
                      child: const Text(
                        'Change Email',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],

              // Error Message
              if (widget.errorMessage != null &&
                  widget.errorMessage!.isNotEmpty) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red.shade900.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    widget.errorMessage!,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.red.shade100,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // Status Message
              if (widget.statusMessage != null &&
                  widget.statusMessage!.isNotEmpty &&
                  widget.errorMessage == null) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade800.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    widget.statusMessage!,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: widget.step == LoginFlowStep.completed
                          ? Colors.green.shade300
                          : Colors.grey.shade300,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // Sign In Button
              SizedBox(
                width: double.infinity,
                child: _buildSignInButton(effectiveOrganization),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSignInButton(String? effectiveOrganization) {
    final isDisabled =
        widget.isLoading || _isSendingOtp || effectiveOrganization == null;
    final buttonText = _otpSent ? 'Verify OTP' : 'Send OTP';

    return Container(
      height: 52,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: isDisabled
            ? null
            : const LinearGradient(
                colors: [Color(0xFF4F39F6), Color(0xFF9810FA)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
        color: isDisabled ? Colors.grey.shade700 : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isDisabled
              ? null
              : () async {
                  if (!_otpSent) {
                    // Send OTP
                    await _sendOtp();
                  } else {
                    // Verify OTP
                    if (_formKey.currentState!.validate()) {
                      await widget.onLogin(
                        _emailController.text.trim(),
                        effectiveOrganization,
                      );
                    }
                  }
                },
          borderRadius: BorderRadius.circular(12),
          child: Center(
            child: (widget.isLoading || _isSendingOtp)
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Text(
                    buttonText,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

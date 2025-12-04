import 'dart:convert';
import 'dart:io';
import 'package:affinidi_tdk_vdip/affinidi_tdk_vdip.dart';
import 'package:collection/collection.dart';
import 'package:dcql/dcql.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ssi/ssi.dart';

import '../../../application/services/vault_service/vault_service.dart';
import '../../../application/services/vdip_service/vdip_service.dart';
import '../../../infrastructure/exceptions/app_exception.dart';
import '../../../infrastructure/providers/app_logger_provider.dart';
import '../../../infrastructure/providers/shared_preferences_provider.dart';
import '../../../infrastructure/utils/credential_helper.dart';
import '../../../infrastructure/utils/debug_logger.dart';
import '../../widgets/ayra/ayra_button.dart';

class BusinessCardScreen extends ConsumerStatefulWidget {
  const BusinessCardScreen({super.key});

  @override
  ConsumerState<BusinessCardScreen> createState() => _BusinessCardScreenState();
}

class _BusinessCardScreenState extends ConsumerState<BusinessCardScreen> {
  static const _logKey = 'BusinessCard';
  late final _logger = ref.read(appLoggerProvider);
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _displayNameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _linkedInController;
  late final TextEditingController _bookMeetingController;
  late final TextEditingController _signalController;
  late final TextEditingController _designationController;
  int _designationLevel = 50; // Default to Senior Level
  late final TextEditingController _payloadCredentialController;
  late final TextEditingController _payloadDcqlController;
  File? _selectedImage;
  final _imagePicker = ImagePicker();

  bool _isSubmitting = false;
  bool _isLoadingInitialData = true;
  String? _statusMessage;

  List<Map<String, dynamic>> _availableCredentials = [];
  Map<String, dynamic>? _selectedDcqlCredential;
  Map<String, dynamic>? _selectedEmbeddedCredential1;
  Map<String, dynamic>? _selectedEmbeddedCredential2;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _loadInitialData();
  }

  void _initializeControllers() {
    // Initialize with empty values first
    _displayNameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
    _linkedInController = TextEditingController();
    _bookMeetingController = TextEditingController();
    _signalController = TextEditingController();
    _designationController = TextEditingController();
    _payloadCredentialController = TextEditingController();
    _payloadDcqlController = TextEditingController();
  }

  Future<void> _loadInitialData() async {
    try {
      setState(() {
        _isLoadingInitialData = true;
      });

      // Load all available credentials first
      await _loadAvailableCredentials();

      // Check if editing existing Ayra Card or creating new one
      final ayraCard = await _getExistingAyraCard();

      if (ayraCard != null) {
        // Edit mode: Load existing Ayra Card data
        await _loadAyraCardData(ayraCard);
      } else {
        // Create mode: Load from employment credential and set defaults
        await _loadEmploymentData();
        _setDefaultValues();
      }
    } catch (error, stackTrace) {
      debugLog(
        'Error loading initial data: $error',
        name: _logKey,
        logger: _logger,
        error: error,
        stackTrace: stackTrace,
      );
      // On error, try to set basic defaults so form is still usable
      _setDefaultValues();
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingInitialData = false;
        });
      }
    }
  }

  /// Load all available credentials from vault for dropdowns
  Future<void> _loadAvailableCredentials() async {
    final vaultService = ref.read(vaultServiceProvider.notifier);
    await vaultService.getCredentials();

    final vaultState = ref.read(vaultServiceProvider);
    final allCredentials = vaultState.claimedCredentials ?? [];

    _availableCredentials = allCredentials.map((digitalCredential) {
      final credential = digitalCredential.verifiableCredential;
      final credentialType = credential.type.last;
      final displayName = CredentialHelper.getCredentialTypeName(
        credential.type,
      );

      return {
        'id': digitalCredential.id,
        'type': credentialType.toLowerCase(),
        'displayName': displayName,
        'credential': credential,
      };
    }).toList();

    // Set default credential selections if credentials are available
    if (_availableCredentials.isNotEmpty) {
      // Find Employee credential for first embedded credential
      final employeeCredential = _availableCredentials.firstWhereOrNull(
        (cred) => cred['type'] == CredentialHelper.employment.toLowerCase(),
      );
      _selectedEmbeddedCredential1 = employeeCredential;

      // Find IDV credential for second embedded credential
      final idvCredential = _availableCredentials.firstWhereOrNull(
        (cred) =>
            cred['type'] ==
            CredentialHelper.verifiedIdentityDocument.toLowerCase(),
      );
      _selectedEmbeddedCredential2 = idvCredential;

      // Set DCQL credential to null by default (user can select if needed)
      _selectedDcqlCredential = null;
    } else {
      // No credentials available, set all to null
      _selectedDcqlCredential = null;
      _selectedEmbeddedCredential1 = null;
      _selectedEmbeddedCredential2 = null;
    }
  }

  /// Get existing Ayra Card from vault if it exists
  Future<ParsedVerifiableCredential?> _getExistingAyraCard() async {
    final vaultService = ref.read(vaultServiceProvider.notifier);
    return await vaultService.getCredentialByType(
      CredentialHelper.ayraBusinessCard,
    );
  }

  /// Load data from existing Ayra Card (edit mode)
  Future<void> _loadAyraCardData(ParsedVerifiableCredential ayraCard) async {
    final credentialSubject = ayraCard.credentialSubject[0].toJson();

    // Load basic info
    _displayNameController.text =
        credentialSubject['display_name'] as String? ?? '';
    _emailController.text = credentialSubject['email'] as String? ?? '';

    // Load all payloads
    final payloads = credentialSubject['payloads'] as List<dynamic>? ?? [];

    await _loadPayloadData(payloads);
  }

  /// Extract and load data from payloads array
  Future<void> _loadPayloadData(List<dynamic> payloads) async {
    // Load designation
    final designationPayload = payloads.firstWhereOrNull(
      (p) => p['id'] == 'designation',
    );
    _designationController.text = designationPayload?['data'] as String? ?? '';

    // Load designation level
    final designationLevelPayload = payloads.firstWhereOrNull(
      (p) => p['id'] == 'designation_level',
    );
    if (designationLevelPayload != null) {
      _designationLevel = designationLevelPayload['data'] as int? ?? 50;
    }

    // Load avatar image
    final avatarPayload = payloads.firstWhereOrNull((p) => p['id'] == 'avatar');
    if (avatarPayload != null) {
      await _loadAvatarImage(avatarPayload['data'] as String? ?? '');
    }

    // Load phone
    final phonePayload = payloads.firstWhereOrNull((p) => p['id'] == 'phone');
    _phoneController.text = phonePayload?['data'] as String? ?? '';

    // Load LinkedIn username (extract from full URL)
    final linkedInPayload = payloads.firstWhereOrNull(
      (p) => p['id'] == 'social',
    );
    final linkedInUrl = linkedInPayload?['data'] as String? ?? '';
    _linkedInController.text = _extractLinkedInUsername(linkedInUrl);

    // Load meeting link
    final meetingPayload = payloads.firstWhereOrNull(
      (p) => p['id'] == 'book_meeting',
    );
    _bookMeetingController.text = meetingPayload?['data'] as String? ?? '';

    // Load Signal link
    final signalPayload = payloads.firstWhereOrNull((p) => p['id'] == 'signal');
    _signalController.text = signalPayload?['data'] as String? ?? '';
  }

  /// Load and decode base64 avatar image
  Future<void> _loadAvatarImage(String base64Image) async {
    if (base64Image.isEmpty) return;

    try {
      final bytes = base64Decode(base64Image);
      final tempDir = await Directory.systemTemp.createTemp('ayra_avatar');
      final tempFile = File('${tempDir.path}/avatar.png');
      await tempFile.writeAsBytes(bytes);

      setState(() {
        _selectedImage = tempFile;
      });
    } catch (e) {
      debugLog(
        'Error loading avatar image: $e',
        name: _logKey,
        logger: _logger,
      );
      // Don't throw - avatar is optional
    }
  }

  /// Extract username from LinkedIn URL
  String _extractLinkedInUsername(String linkedInUrl) {
    if (linkedInUrl.isEmpty) return '';
    // Handle both full URLs and just usernames
    return linkedInUrl.split('/').last;
  }

  /// Load basic data from employment credential (create mode)
  Future<void> _loadEmploymentData() async {
    final prefs = await ref.read(sharedPreferencesProvider.future);
    final vaultService = ref.read(vaultServiceProvider.notifier);

    final employmentCredential = await vaultService.getCredentialByType(
      CredentialHelper.employment,
    );

    if (employmentCredential == null) {
      throw Exception('Employment Credential not found in vault');
    }

    final credentialSubject = employmentCredential.credentialSubject[0]
        .toJson();

    // Load basic identity from preferences and employment credential
    _emailController.text =
        prefs.getString(SharedPreferencesKeys.email.name) ?? '';
    _displayNameController.text =
        prefs.getString(SharedPreferencesKeys.displayName.name) ?? '';
    _designationController.text = credentialSubject['role'] as String? ?? '';
  }

  Future<void> _pickImage() async {
    try {
      final pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to pick image: $e'),
            backgroundColor: Colors.red.shade600,
          ),
        );
      }
    }
  }

  void _setDefaultValues() {
    final data = CredentialHelper.getSamplePayload(_emailController.text);
    _phoneController.text = (data['phone'] as String?) ?? '';
    _linkedInController.text = (data['linkedIn'] as String?) ?? '';
    final levelValue = data['level'];
    _designationLevel = (levelValue is int)
        ? levelValue
        : (int.tryParse(levelValue?.toString() ?? '') ?? 50);
    _bookMeetingController.text =
        'https://doodle.com/meeting/participate/id/azljpO8d';
    _signalController.text =
        'https://signal.me/#eu/P9jgWuYX29NhOVgLfbmqAP4y0L1wca09SQ_f0OzO557Gdy_L8BZCe46GPkj9WefD';
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _linkedInController.dispose();
    _bookMeetingController.dispose();
    _signalController.dispose();
    _designationController.dispose();
    _payloadCredentialController.dispose();
    _payloadDcqlController.dispose();
    super.dispose();
  }

  Future<Map<String, dynamic>> _buildCredentialData() async {
    final payloads = <Map<String, dynamic>>[];

    // Add phone if exists
    if (_phoneController.text.trim().isNotEmpty) {
      payloads.add({
        'id': 'phone',
        'description': 'Phone number of the employee',
        'type': 'text',
        'data': _phoneController.text.trim(),
      });
    }

    // Add designation if exists
    if (_designationController.text.trim().isNotEmpty) {
      payloads.add({
        'id': 'designation',
        'description': 'designation of the employee',
        'type': 'text',
        'data': _designationController.text.trim(),
      });

      // Add designation level
      payloads.add({
        'id': 'designation_level',
        'description': 'designation level of the employee',
        'type': 'number',
        'data': _designationLevel,
      });
    } // Add social/LinkedIn if exists
    if (_linkedInController.text.trim().isNotEmpty) {
      payloads.add({
        'id': 'social',
        'description': 'LinkedIn profile of the employee',
        'type': 'url',
        'data': 'https://linkedin.com/in/${_linkedInController.text.trim()}',
      });
    }

    // Add book meeting link if exists
    if (_bookMeetingController.text.trim().isNotEmpty) {
      payloads.add({
        'id': 'book_meeting',
        'description': 'Schedule a meeting with the employee',
        'type': 'url',
        'data': _bookMeetingController.text.trim(),
      });
    }

    // Add Signal link if exists
    if (_signalController.text.trim().isNotEmpty) {
      payloads.add({
        'id': 'signal',
        'description': 'Connect with me on Signal',
        'type': 'url',
        'data': _signalController.text.trim(),
      });
    }

    // Add avatar if image is selected
    if (_selectedImage != null) {
      payloads.add({
        'id': 'avatar',
        'description': 'Avatar of the employee',
        'type': 'image/png;base64',
        'data': base64Encode(_selectedImage!.readAsBytesSync()),
      });
    }

    // Add dcql payload type if selected
    if (_selectedDcqlCredential != null) {
      final credential =
          _selectedDcqlCredential!['credential'] as ParsedVerifiableCredential;
      final type = _selectedDcqlCredential!['type'] as String;
      final name = _selectedDcqlCredential!['displayName'] as String;
      final dcqlQuery = DcqlCredentialQuery(
        credentials: [
          DcqlCredential(
            id: 'dcq_query_1',
            format: CredentialFormat.ldpVc,
            meta: DcqlMeta.forW3C(
              typeValues: [
                [type],
              ],
            ),
            claims: [
              DcqlClaim(
                id: 'holder_id',
                path: ['credentialSubject', 'id'],
                values: [credential.credentialSubject[0].id.toString()],
              ),
            ],
          ),
        ],
      );

      payloads.add({
        'id': '${type}_credential',
        'description': 'DCQL query for how to request my $name credentials',
        'type': 'dcql',
        'data': jsonEncode(dcqlQuery.toJson()),
      });
    }

    // Add first embedded credential if selected
    if (_selectedEmbeddedCredential1 != null) {
      final credential =
          _selectedEmbeddedCredential1!['credential']
              as ParsedVerifiableCredential;
      final name = _selectedEmbeddedCredential1!['displayName'] as String;
      payloads.add({
        'id': 'employment_credential',
        'description': 'Embedded $name credential',
        'type': 'credential/w3ldv2',
        'data': jsonEncode(credential.toJson()),
      });
    }

    // Add second embedded credential if selected
    if (_selectedEmbeddedCredential2 != null) {
      final credential =
          _selectedEmbeddedCredential2!['credential']
              as ParsedVerifiableCredential;
      final name = _selectedEmbeddedCredential2!['displayName'] as String;
      payloads.add({
        'id': 'identity_credential',
        'description': 'Embedded $name credential',
        'type': 'credential/w3ldv2',
        'data': jsonEncode(credential.toJson()),
      });
    }

    return {
      'display_name': _displayNameController.text.trim(),
      'email': _emailController.text.trim(),
      'payloads': payloads,
    };
  }

  Future<void> _submit() async {
    final form = _formKey.currentState;
    if (form == null) return;
    if (!form.validate()) return;

    VdipResult? credentialResult;

    try {
      setState(() {
        _isSubmitting = true;
        _statusMessage = 'Preparing your business card information...';
      });

      final vdipService = ref.read(vdipServiceProvider);

      final credentialData = await _buildCredentialData();

      debugLog(
        'Issuer: requesting credential for AyraBusinessCard',
        name: _logKey,
        logger: _logger,
      );

      final credentialsRequest = RequestCredentialsOptions(
        proposalId: CredentialHelper.ayraBusinessCard,
        credentialMeta: CredentialMeta(data: credentialData),
      );

      await vdipService.requestCredential(
        credentialsRequest: credentialsRequest,
        onProgress: (msg) async {
          if (mounted) {
            setState(() {
              _statusMessage = msg;
            });
          }
        },
        onComplete: (result) async {
          credentialResult = result;
          if (!mounted) return;
          if (result.isSuccess) {
            setState(() {
              _statusMessage = 'Ayra Business Card created successfully!';
            });
          } else if (result.isFailure) {
            setState(() {
              _statusMessage =
                  'Failed to create business card: ${result.message}';
            });
          } else if (result.isCancelled) {
            setState(() {
              _statusMessage = 'Business card creation was cancelled';
            });
          }
        },
      );

      if (!mounted) return;

      // Check if the credential request was successful before showing success message and navigating
      if (credentialResult?.isSuccess == true) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ayra Business Card issued successfully!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );

        // Wait a moment for user to see the success message
        await Future<void>.delayed(const Duration(milliseconds: 500));

        if (!mounted) return;
        // Pop back to dashboard and indicate credential was issued
        Navigator.of(context).pop(true);
      } else {
        // For failures and cancellations, re-enable the button
        setState(() {
          _isSubmitting = false;
        });
      }
    } catch (error, stackTrace) {
      debugLog(
        'Error issuing Ayra Business Card',
        name: _logKey,
        logger: _logger,
        error: error,
        stackTrace: stackTrace,
      );
      if (!mounted) return;
      final message = error is AppException ? error.message : error.toString();
      setState(() {
        _statusMessage = 'Error: $message';
        _isSubmitting = false; // Re-enable button on error
      });
    } finally {
      // Reset _isSubmitting on success
      if (mounted && credentialResult?.isSuccess == true) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/images/ayra-logo.png',
              width: 32,
              height: 32,
              fit: BoxFit.contain,
            ),
            const SizedBox(width: 8),
            const Text(
              'Ayra Business Card Form',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: _isLoadingInitialData
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading employee information...'),
                ],
              ),
            )
          : SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Text(
                            //   'Claim Ayra Business Card',
                            //   style: theme.textTheme.headlineMedium?.copyWith(
                            //     fontWeight: FontWeight.bold,
                            //   ),
                            // ),
                            const SizedBox(height: 8),

                            // Full Name (disabled)
                            _buildDisabledField(
                              label: 'Full Name',
                              controller: _displayNameController,
                              icon: Icons.person_outline_rounded,
                            ),
                            const SizedBox(height: 8),

                            // Email (disabled)
                            _buildDisabledField(
                              label: 'Email',
                              controller: _emailController,
                              icon: Icons.email_outlined,
                            ),
                            const SizedBox(height: 8),

                            // Role (editable)
                            _buildDisabledField(
                              label: 'Role',
                              controller: _designationController,
                              icon: Icons.work_outline_rounded,
                              enabled: true,
                            ),

                            const SizedBox(height: 32),
                            Text(
                              'Ayra Card Payloads',
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: Colors.grey.shade400,
                              ),
                            ),
                            const SizedBox(height: 16),
                            // Photo Upload
                            Text(
                              'Profile Photo',
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            _buildPhotoUpload(theme),
                            const SizedBox(height: 24),

                            // Phone Number (editable)
                            Text(
                              'Phone Number',
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _phoneController,
                              decoration: InputDecoration(
                                hintText: '+1234567890',
                                prefixIcon: const Icon(Icons.phone_outlined),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: Colors.grey.shade700.withValues(
                                      alpha: 0.3,
                                    ),
                                    width: 1,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: Colors.grey.shade700.withValues(
                                      alpha: 0.3,
                                    ),
                                    width: 1,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                    color: Color(0xFF4F39F6),
                                    width: 2,
                                  ),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: Colors.red.shade600,
                                    width: 1,
                                  ),
                                ),
                                focusedErrorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: Colors.red.shade600,
                                    width: 2,
                                  ),
                                ),
                                filled: true,
                                fillColor: theme.brightness == Brightness.dark
                                    ? Colors.grey.shade900
                                    : Colors.grey.shade50,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 16,
                                ),
                              ),
                              keyboardType: TextInputType.phone,
                              validator: _requiredValidator,
                            ),
                            const SizedBox(height: 24),

                            // LinkedIn Profile (editable)
                            Text(
                              'LinkedIn Username',
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Static prefix outside the field
                                Container(
                                  height: 56,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                  ),
                                  alignment: Alignment.centerLeft,
                                  decoration: BoxDecoration(
                                    color: theme.brightness == Brightness.dark
                                        ? Colors.grey.shade800
                                        : Colors.grey.shade200,
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(12),
                                      bottomLeft: Radius.circular(12),
                                    ),
                                    border: Border.all(
                                      color: Colors.grey.shade700.withValues(
                                        alpha: 0.3,
                                      ),
                                      width: 1,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.link_rounded,
                                        color: Colors.grey.shade500,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'linkedin.com/in/',
                                        style: TextStyle(
                                          color: Colors.grey.shade500,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Username input field
                                Expanded(
                                  child: TextFormField(
                                    controller: _linkedInController,
                                    decoration: InputDecoration(
                                      hintText: 'username',
                                      border: OutlineInputBorder(
                                        borderRadius: const BorderRadius.only(
                                          topRight: Radius.circular(12),
                                          bottomRight: Radius.circular(12),
                                        ),
                                        borderSide: BorderSide(
                                          color: Colors.grey.shade700
                                              .withValues(alpha: 0.3),
                                          width: 1,
                                        ),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: const BorderRadius.only(
                                          topRight: Radius.circular(12),
                                          bottomRight: Radius.circular(12),
                                        ),
                                        borderSide: BorderSide(
                                          color: Colors.grey.shade700
                                              .withValues(alpha: 0.3),
                                          width: 1,
                                        ),
                                      ),
                                      focusedBorder: const OutlineInputBorder(
                                        borderRadius: BorderRadius.only(
                                          topRight: Radius.circular(12),
                                          bottomRight: Radius.circular(12),
                                        ),
                                        borderSide: BorderSide(
                                          color: Color(0xFF4F39F6),
                                          width: 2,
                                        ),
                                      ),
                                      errorBorder: OutlineInputBorder(
                                        borderRadius: const BorderRadius.only(
                                          topRight: Radius.circular(12),
                                          bottomRight: Radius.circular(12),
                                        ),
                                        borderSide: BorderSide(
                                          color: Colors.red.shade600,
                                          width: 1,
                                        ),
                                      ),
                                      focusedErrorBorder: OutlineInputBorder(
                                        borderRadius: const BorderRadius.only(
                                          topRight: Radius.circular(12),
                                          bottomRight: Radius.circular(12),
                                        ),
                                        borderSide: BorderSide(
                                          color: Colors.red.shade600,
                                          width: 2,
                                        ),
                                      ),
                                      filled: true,
                                      fillColor:
                                          theme.brightness == Brightness.dark
                                          ? Colors.grey.shade900
                                          : Colors.grey.shade50,
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 16,
                                          ),
                                    ),
                                    keyboardType: TextInputType.text,
                                    validator: (value) {
                                      if (value == null ||
                                          value.trim().isEmpty) {
                                        return 'Please enter your LinkedIn username';
                                      }
                                      if (value.contains('/') ||
                                          value.contains(' ')) {
                                        return 'Enter only your username (no spaces or slashes)';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),

                            // Book a Meeting (editable)
                            Text(
                              'Book a Meeting with me',
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _bookMeetingController,
                              decoration: InputDecoration(
                                hintText:
                                    'https://doodle.com/meeting/participate/id/...',
                                prefixIcon: const Icon(
                                  Icons.calendar_today_outlined,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: Colors.grey.shade700.withValues(
                                      alpha: 0.3,
                                    ),
                                    width: 1,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: Colors.grey.shade700.withValues(
                                      alpha: 0.3,
                                    ),
                                    width: 1,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                    color: Color(0xFF4F39F6),
                                    width: 2,
                                  ),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: Colors.red.shade600,
                                    width: 1,
                                  ),
                                ),
                                focusedErrorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: Colors.red.shade600,
                                    width: 2,
                                  ),
                                ),
                                filled: true,
                                fillColor: theme.brightness == Brightness.dark
                                    ? Colors.grey.shade900
                                    : Colors.grey.shade50,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 16,
                                ),
                              ),
                              keyboardType: TextInputType.url,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Please enter your meeting booking URL';
                                }
                                if (!value.startsWith('http://') &&
                                    !value.startsWith('https://')) {
                                  return 'Please enter a valid URL starting with http:// or https://';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 24),

                            // Signal Contact (editable)
                            Text(
                              'Signal Me',
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _signalController,
                              decoration: InputDecoration(
                                hintText: 'https://signal.me/#...',
                                prefixIcon: const Icon(Icons.message_outlined),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: Colors.grey.shade700.withValues(
                                      alpha: 0.3,
                                    ),
                                    width: 1,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: Colors.grey.shade700.withValues(
                                      alpha: 0.3,
                                    ),
                                    width: 1,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                    color: Color(0xFF4F39F6),
                                    width: 2,
                                  ),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: Colors.red.shade600,
                                    width: 1,
                                  ),
                                ),
                                focusedErrorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: Colors.red.shade600,
                                    width: 2,
                                  ),
                                ),
                                filled: true,
                                fillColor: theme.brightness == Brightness.dark
                                    ? Colors.grey.shade900
                                    : Colors.grey.shade50,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 16,
                                ),
                              ),
                              keyboardType: TextInputType.url,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Please enter your Signal contact URL';
                                }
                                if (!value.startsWith('http://') &&
                                    !value.startsWith('https://')) {
                                  return 'Please enter a valid URL starting with http:// or https://';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 24),

                            // Designation Level (editable)
                            Text(
                              'Designation Level',
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            DropdownButtonFormField<int>(
                              initialValue: _designationLevel,
                              isExpanded: true,
                              decoration: InputDecoration(
                                hintText: 'Select designation level',
                                prefixIcon: const Icon(
                                  Icons.star_border_rounded,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: Colors.grey.shade700.withValues(
                                      alpha: 0.3,
                                    ),
                                    width: 1,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: Colors.grey.shade700.withValues(
                                      alpha: 0.3,
                                    ),
                                    width: 1,
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
                                fillColor: theme.brightness == Brightness.dark
                                    ? Colors.grey.shade900
                                    : Colors.grey.shade50,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 16,
                                ),
                              ),
                              items: const [
                                DropdownMenuItem<int>(
                                  value: 10,
                                  child: Text('Entry Level - 10'),
                                ),
                                DropdownMenuItem<int>(
                                  value: 30,
                                  child: Text('Mid Level - 30'),
                                ),
                                DropdownMenuItem<int>(
                                  value: 50,
                                  child: Text('Senior Level - 50'),
                                ),
                                DropdownMenuItem<int>(
                                  value: 70,
                                  child: Text('Lead Level - 70'),
                                ),
                                DropdownMenuItem<int>(
                                  value: 90,
                                  child: Text('Executive Level - 90'),
                                ),
                              ],
                              onChanged: (int? value) {
                                if (value != null) {
                                  setState(() {
                                    _designationLevel = value;
                                  });
                                }
                              },
                            ),
                            const SizedBox(height: 24),

                            // First Embedded Credential (Employee)
                            Text(
                              'Employee Credential (Embedded)',
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            SizedBox(
                              width: double.infinity,
                              child:
                                  DropdownButtonFormField<
                                    Map<String, dynamic>?
                                  >(
                                    initialValue: _selectedEmbeddedCredential1,
                                    isExpanded: true,
                                    decoration: InputDecoration(
                                      hintText: 'Select employee credential',
                                      prefixIcon: const Icon(
                                        Icons.badge_rounded,
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                          color: Colors.grey.shade700
                                              .withValues(alpha: 0.3),
                                          width: 1,
                                        ),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                          color: Colors.grey.shade700
                                              .withValues(alpha: 0.3),
                                          width: 1,
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
                                      fillColor:
                                          theme.brightness == Brightness.dark
                                          ? Colors.grey.shade900
                                          : Colors.grey.shade50,
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 16,
                                          ),
                                    ),
                                    items: [
                                      const DropdownMenuItem<
                                        Map<String, dynamic>?
                                      >(
                                        value: null,
                                        child: Text(
                                          'None',
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      ..._availableCredentials
                                          .where(
                                            (cred) =>
                                                cred['type'] ==
                                                CredentialHelper.employment
                                                    .toLowerCase(),
                                          )
                                          .map(
                                            (credential) =>
                                                DropdownMenuItem<
                                                  Map<String, dynamic>?
                                                >(
                                                  value: credential,
                                                  child: Text(
                                                    credential['displayName']
                                                        as String,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                          ),
                                    ],
                                    onChanged: (Map<String, dynamic>? value) {
                                      setState(() {
                                        _selectedEmbeddedCredential1 = value;
                                      });
                                    },
                                  ),
                            ),
                            const SizedBox(height: 24),

                            // Second Embedded Credential (IDV)
                            Text(
                              'Identity Credential (Embedded)',
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            SizedBox(
                              width: double.infinity,
                              child:
                                  DropdownButtonFormField<
                                    Map<String, dynamic>?
                                  >(
                                    initialValue: _selectedEmbeddedCredential2,
                                    isExpanded: true,
                                    decoration: InputDecoration(
                                      hintText: 'Select identity credential',
                                      prefixIcon: const Icon(
                                        Icons.verified_user_rounded,
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                          color: Colors.grey.shade700
                                              .withValues(alpha: 0.3),
                                          width: 1,
                                        ),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                          color: Colors.grey.shade700
                                              .withValues(alpha: 0.3),
                                          width: 1,
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
                                      fillColor:
                                          theme.brightness == Brightness.dark
                                          ? Colors.grey.shade900
                                          : Colors.grey.shade50,
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 16,
                                          ),
                                    ),
                                    items: [
                                      const DropdownMenuItem<
                                        Map<String, dynamic>?
                                      >(
                                        value: null,
                                        child: Text(
                                          'None',
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      ..._availableCredentials
                                          .where(
                                            (cred) =>
                                                cred['type'] ==
                                                CredentialHelper
                                                    .verifiedIdentityDocument
                                                    .toLowerCase(),
                                          )
                                          .map(
                                            (credential) =>
                                                DropdownMenuItem<
                                                  Map<String, dynamic>?
                                                >(
                                                  value: credential,
                                                  child: Text(
                                                    credential['displayName']
                                                        as String,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                          ),
                                    ],
                                    onChanged: (Map<String, dynamic>? value) {
                                      setState(() {
                                        _selectedEmbeddedCredential2 = value;
                                      });
                                    },
                                  ),
                            ),
                            const SizedBox(height: 24),

                            // DCQL Credential Selection (optional) - Moved to last
                            Text(
                              'Request more Credential (DCQL)',
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            SizedBox(
                              width: double.infinity,
                              child:
                                  DropdownButtonFormField<
                                    Map<String, dynamic>?
                                  >(
                                    initialValue: _selectedDcqlCredential,
                                    isExpanded: true,
                                    decoration: InputDecoration(
                                      hintText:
                                          'Select credential for DCQL query',
                                      prefixIcon: const Icon(
                                        Icons.query_builder_rounded,
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                          color: Colors.grey.shade700
                                              .withValues(alpha: 0.3),
                                          width: 1,
                                        ),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                          color: Colors.grey.shade700
                                              .withValues(alpha: 0.3),
                                          width: 1,
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
                                      fillColor:
                                          theme.brightness == Brightness.dark
                                          ? Colors.grey.shade900
                                          : Colors.grey.shade50,
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 16,
                                          ),
                                    ),
                                    items: [
                                      const DropdownMenuItem<
                                        Map<String, dynamic>?
                                      >(
                                        value: null,
                                        child: Text(
                                          'None',
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                    onChanged: (Map<String, dynamic>? value) {
                                      setState(() {
                                        _selectedDcqlCredential = value;
                                      });
                                    },
                                  ),
                            ),
                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Fixed Submit Button at bottom
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: theme.scaffoldBackgroundColor,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 10,
                          offset: const Offset(0, -5),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Status Message (shown when submitting or on error)
                        if (_statusMessage != null) ...[
                          _buildStatusMessage(theme),
                          const SizedBox(height: 16),
                        ],

                        // Submit Button
                        SizedBox(
                          width: double.infinity,
                          child: AyraButton(
                            onPressed: _isSubmitting ? null : _submit,
                            height: 52,
                            borderRadius: BorderRadius.circular(12),
                            gradient: const LinearGradient(
                              colors: [Color(0xFF4F39F6), Color(0xFF9810FA)],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                            child: _isSubmitting
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text(
                                    'Claim My Ayra Card',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  String? _requiredValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'This field is required';
    }
    return null;
  }

  Widget _buildDisabledField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    bool enabled = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          enabled: enabled,
          decoration: InputDecoration(
            prefixIcon: Icon(icon),
            suffixIcon: Icon(
              Icons.lock_outline_rounded,
              color: Colors.grey.shade600,
              size: 20,
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
            fillColor: Colors.grey.shade800.withValues(alpha: 0.3),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Colors.grey.shade700.withValues(alpha: 0.3),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Colors.grey.shade700.withValues(alpha: 0.3),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Colors.grey.shade700.withValues(alpha: 0.3),
              ),
            ),
          ),
          style: TextStyle(color: Colors.grey.shade500),
        ),
      ],
    );
  }

  Widget _buildPhotoUpload(ThemeData theme) {
    return Center(
      child: GestureDetector(
        onTap: _pickImage,
        child: Stack(
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: theme.brightness == Brightness.dark
                    ? Colors.grey.shade900
                    : Colors.grey.shade50,
                border: Border.all(
                  color: Colors.grey.shade700.withValues(alpha: 0.3),
                  width: 2,
                ),
              ),
              child: _selectedImage != null
                  ? ClipOval(
                      child: Image.file(
                        _selectedImage!,
                        width: 120,
                        height: 120,
                        fit: BoxFit.cover,
                      ),
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add_photo_alternate_outlined,
                          size: 40,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Upload Photo',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
            ),
            if (_selectedImage != null)
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.red.shade600,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: IconButton(
                    icon: const Icon(
                      Icons.close_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 32,
                      minHeight: 32,
                    ),
                    onPressed: () {
                      setState(() {
                        _selectedImage = null;
                      });
                    },
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusMessage(ThemeData theme) {
    final isError =
        _statusMessage?.startsWith('Error:') == true ||
        _statusMessage?.startsWith('Failed to') == true ||
        _statusMessage?.contains('cancelled') == true;

    final colorScheme = theme.colorScheme;
    final backgroundColor = isError
        ? colorScheme.error.withValues(alpha: 0.15)
        : colorScheme.primary.withValues(alpha: 0.15);
    final borderColor = isError
        ? colorScheme.error.withValues(alpha: 0.4)
        : colorScheme.primary.withValues(alpha: 0.4);
    final iconColor = isError ? colorScheme.error : colorScheme.primary;
    final icon = isError ? Icons.error_outline : Icons.info_outline;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [backgroundColor, backgroundColor.withValues(alpha: 0.05)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _statusMessage!,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

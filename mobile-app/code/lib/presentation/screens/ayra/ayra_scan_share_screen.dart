import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../infrastructure/providers/shared_preferences_provider.dart';
import '../../../navigation/routes/dashboard_routes.dart';

class AyraScanShareScreen extends ConsumerWidget {
  const AyraScanShareScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final sharedPrefsAsync = ref.watch(sharedPreferencesProvider);

    final name = sharedPrefsAsync.when(
      data: (prefs) => prefs.getString(SharedPreferencesKeys.displayName.name),
      loading: () => null,
      error: (_, _) => null,
    );

    return Scaffold(
      // backgroundColor: Colors.grey.shade900,
      appBar: AppBar(
        // backgroundColor: Colors.grey.shade900,
        // title: const Text('Scan & Share'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(
              Icons.qr_code_scanner,
              size: 120,
              color: Color(0xFF4F39F6),
            ),
            const SizedBox(height: 48),
            Text(
              'Hi $name!',
              style: textTheme.headlineMedium?.copyWith(
                color: Colors.grey.shade100,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            // const SizedBox(height: 16),
            // Text(
            //   'Scan the QR code on the meeting room door to share your employee credential and unlock access.',
            //   style: textTheme.bodyLarge?.copyWith(
            //     color: Colors.grey.shade400,
            //     height: 1.5,
            //   ),
            //   textAlign: TextAlign.center,
            // ),
            const SizedBox(height: 48),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade800.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade700, width: 1),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.security,
                        color: Colors.grey.shade400,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Your credentials are shared securely',
                          style: TextStyle(
                            color: Colors.grey.shade300,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(
                        Icons.verified_user,
                        color: Colors.grey.shade400,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Only authorized personnel can access',
                          style: TextStyle(
                            color: Colors.grey.shade300,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 48),
            ElevatedButton(
              onPressed: () {
                const ScanCameraRoute().go(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4F39F6),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(Icons.qr_code_scanner),
                  SizedBox(width: 12),
                  Text(
                    'Start Scanning',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

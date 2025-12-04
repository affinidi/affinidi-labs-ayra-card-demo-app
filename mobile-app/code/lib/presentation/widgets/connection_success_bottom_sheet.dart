import 'dart:convert';

import 'package:flutter/material.dart';

import '../../domain/models/contacts/contact.dart';
import '../../infrastructure/extensions/build_context_extensions.dart';
import '../../infrastructure/extensions/vcard_extensions.dart';
import '../widgets/images/default_profile_image.dart';

class ConnectionSuccessBottomSheet extends StatefulWidget {
  const ConnectionSuccessBottomSheet({
    super.key,
    required this.contact,
    required this.onChatPressed,
  });

  final Contact contact;
  final VoidCallback onChatPressed;

  static void show({
    required BuildContext context,
    required Contact contact,
    required VoidCallback onChatPressed,
  }) {
    showModalBottomSheet<void>(
      backgroundColor: Colors.black,
      context: context,
      isDismissible: true,
      builder: (context) => ConnectionSuccessBottomSheet(
        contact: contact,
        onChatPressed: onChatPressed,
      ),
    );
  }

  @override
  State<ConnectionSuccessBottomSheet> createState() =>
      _ConnectionSuccessBottomSheetState();
}

class _ConnectionSuccessBottomSheetState
    extends State<ConnectionSuccessBottomSheet> {
  bool isBusy = false;

  @override
  Widget build(BuildContext context) {
    final profilePic = widget.contact.vCard.hasProfilePic
        ? MemoryImage(base64.decode(widget.contact.vCard.profilePic))
        : defaultProfileImage;
    final hasDisplayName = widget.contact.displayName?.isNotEmpty ?? false;

    final displayName = hasDisplayName
        ? widget.contact.displayName!
        : context.l10n.anonymous;

    return StatefulBuilder(
      builder: (BuildContext context, StateSetter setState) {
        return Stack(
          children: [
            Container(
              height: 180,
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(10)),
                gradient: RadialGradient(
                  center: Alignment.bottomCenter,
                  radius: 1.3,
                  colors: [
                    Color.fromARGB(249, 3, 104, 192),
                    Color.fromARGB(120, 5, 19, 94),
                  ],
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: CircleAvatar(
                        maxRadius: 40,
                        backgroundImage: profilePic,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: SizedBox(
                        width: 180,
                        child: Text(
                          'You are now connected to $displayName!',
                          maxLines: 3,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 36,
              right: 25,
              child: isBusy
                  ? const CircularProgressIndicator(color: Colors.white)
                  : ElevatedButton(
                      onPressed: isBusy
                          ? null
                          : () {
                              setState(() {
                                isBusy = true;
                              });
                              // TODO: handle chat pressed button
                              widget.onChatPressed();
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(249, 3, 104, 192),
                      ),
                      child: const Text(
                        'Chat',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
            ),
          ],
        );
      },
    );
  }
}

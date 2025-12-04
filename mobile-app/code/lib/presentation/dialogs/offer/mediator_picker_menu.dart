import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../application/services/settings_service/settings_service.dart';
import '../../../infrastructure/extensions/build_context_extensions.dart';
import '../../widgets/bottom_sheet_menu.dart';

class MediatorPickerMenu extends HookConsumerWidget {
  const MediatorPickerMenu({super.key, this.currentId});

  final String? currentId;

  static Future<String?> show({
    required BuildContext context,
    required String? currentId,
  }) {
    return showModalBottomSheet<String>(
      backgroundColor: context.colorScheme.inverseSurface,
      useRootNavigator: true,
      isScrollControlled: true,
      showDragHandle: true,
      useSafeArea: true,
      context: context,
      builder: (context) => MediatorPickerMenu(currentId: currentId),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsState = ref.watch(settingsServiceProvider);
    final configs = settingsState.mediators;

    return BottomSheetMenu(
      header: context.l10n.selectMediator,
      itemCount: configs.length,
      itemBuilder: (context, index) {
        final entry = configs.entries.elementAt(index);
        final friendlyName = entry.value;
        final did = entry.key;
        final isSelected = did == currentId;
        return ListTile(
          leading: isSelected
              ? Icon(
                  Icons.check_circle,
                  color: context.listTileTheme.selectedColor,
                )
              : Icon(
                  Icons.circle_outlined,
                  color: context.listTileTheme.iconColor,
                ),
          title: Text(friendlyName),
          onTap: () {
            if (!context.mounted) return;
            Navigator.of(context, rootNavigator: true).pop(did);
          },
          selected: isSelected,
        );
      },
    );
  }
}

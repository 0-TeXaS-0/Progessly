import 'package:flutter/material.dart';
import '../../services/sound_service.dart';

class SwipeToDismiss extends StatelessWidget {
  final Widget child;
  final VoidCallback onDismissed;
  final String itemName;
  final Color? backgroundColor;
  final IconData? icon;

  const SwipeToDismiss({
    super.key,
    required this.child,
    required this.onDismissed,
    required this.itemName,
    this.backgroundColor,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final soundService = SoundService();

    return Dismissible(
      key: ValueKey(itemName),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: backgroundColor ?? Colors.red,
        child: Icon(icon ?? Icons.delete, color: Colors.white, size: 28),
      ),
      confirmDismiss: (direction) async {
        soundService.playButtonTap();
        return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Confirm Delete'),
            content: Text('Are you sure you want to delete "$itemName"?'),
            actions: [
              TextButton(
                onPressed: () {
                  soundService.playButtonTap();
                  Navigator.of(context).pop(false);
                },
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  soundService.playTaskDelete();
                  Navigator.of(context).pop(true);
                },
                style: TextButton.styleFrom(
                  foregroundColor: theme.colorScheme.error,
                ),
                child: const Text('Delete'),
              ),
            ],
          ),
        );
      },
      onDismissed: (direction) {
        onDismissed();
      },
      child: child,
    );
  }
}

class LongPressMenu extends StatelessWidget {
  final Widget child;
  final List<PopupMenuEntry<String>> menuItems;
  final Function(String) onSelected;

  const LongPressMenu({
    super.key,
    required this.child,
    required this.menuItems,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final soundService = SoundService();

    return GestureDetector(
      onLongPress: () async {
        soundService.playButtonTap();
        final RenderBox renderBox = context.findRenderObject() as RenderBox;
        final position = renderBox.localToGlobal(Offset.zero);
        final size = renderBox.size;

        final selected = await showMenu<String>(
          context: context,
          position: RelativeRect.fromLTRB(
            position.dx,
            position.dy + size.height,
            position.dx + size.width,
            position.dy,
          ),
          items: menuItems,
        );

        if (selected != null) {
          soundService.playButtonTap();
          onSelected(selected);
        }
      },
      child: child,
    );
  }
}

class DraggableListItem extends StatelessWidget {
  final Widget child;
  final int index;
  final Function(int oldIndex, int newIndex) onReorder;
  final String dragKey;

  const DraggableListItem({
    super.key,
    required this.child,
    required this.index,
    required this.onReorder,
    required this.dragKey,
  });

  @override
  Widget build(BuildContext context) {
    final soundService = SoundService();

    return LongPressDraggable<int>(
      data: index,
      feedback: Material(
        elevation: 6,
        borderRadius: BorderRadius.circular(12),
        child: Opacity(opacity: 0.8, child: child),
      ),
      childWhenDragging: Opacity(opacity: 0.3, child: child),
      onDragStarted: () {
        soundService.playButtonTap();
      },
      onDragEnd: (details) {
        if (!details.wasAccepted) {
          soundService.playError();
        }
      },
      child: DragTarget<int>(
        onWillAcceptWithDetails: (data) => data.data != index,
        onAcceptWithDetails: (data) {
          soundService.playButtonTap();
          onReorder(data.data, index);
        },
        builder: (context, candidateData, rejectedData) {
          return Container(
            decoration: BoxDecoration(
              border: candidateData.isNotEmpty
                  ? Border.all(
                      color: Theme.of(context).colorScheme.primary,
                      width: 2,
                    )
                  : null,
              borderRadius: BorderRadius.circular(12),
            ),
            child: child,
          );
        },
      ),
    );
  }
}

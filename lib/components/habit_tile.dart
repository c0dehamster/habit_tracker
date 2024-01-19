import 'package:flutter/material.dart';

class HabitTile extends StatelessWidget {
  const HabitTile({
    super.key,
    required this.text,
    required this.isCompleted,
    required this.onChanged,
  });

  final String text;
  final bool isCompleted;
  final void Function(bool?)? onChanged;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (onChanged != null) {
          // Toggle completion status
          onChanged!(!isCompleted);
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: isCompleted ? Colors.green : Theme.of(context).colorScheme.secondary,
          borderRadius: BorderRadius.circular(4),
        ),
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.symmetric(
          vertical: 8,
          horizontal: 24,
        ),
        child: ListTile(
          title: Text(text),
          leading: Checkbox(
            value: isCompleted,
            onChanged: onChanged,
            activeColor: Colors.green,
          ),
        ),
      ),
    );
  }
}

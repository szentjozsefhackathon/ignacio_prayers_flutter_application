import 'package:flutter/material.dart';

/// A card that presents a set of switches for the user to toggle.
class SwitchCard<T extends Object?> extends StatelessWidget {
  const SwitchCard({
    super.key,
    required this.values,
    required this.onChanged,
    required this.switchLabels,
    required this.title,
  });

  final Map<T, bool> values; // Holds the current state of each switch
  final Map<T, String> switchLabels; // Labels for each switch
  final String title;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  title,
                  // style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
              for (final T choice in values.keys)
                SwitchSelection<T>(
                  value: choice,
                  isSelected: values[choice]!,
                  onChanged: onChanged,
                  label: switchLabels[choice]!,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A switch with a label that the user can toggle on or off.
class SwitchSelection<T extends Object?> extends StatelessWidget {
  const SwitchSelection({
    super.key,
    required this.value,
    required this.isSelected,
    required this.onChanged,
    required this.label,
  });

  final T value;
  final bool isSelected;
  final ValueChanged<T> onChanged;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[
        Expanded(
          child: Text(label),
        ),
        Switch(
          value: isSelected,
          onChanged: (bool newValue) => onChanged(value),
        ),
      ],
    );
  }
}
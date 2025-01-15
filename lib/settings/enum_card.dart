import 'package:flutter/material.dart';

// This aggregates a ChoiceCard so that it presents a set of radio buttons for
// the allowed enum values for the user to select from.
class EnumCard<T extends Enum> extends StatelessWidget {
  const EnumCard({
    super.key,
    required this.value,
    required this.choices,
    required this.onChanged,
  });

  final T value;
  final Iterable<T> choices;
  final ValueChanged<T?> onChanged;

  @override
  Widget build(BuildContext context) => ChoiceCard<T>(
        value: value,
        choices: choices,
        onChanged: onChanged,
        choiceLabels: <T, String>{
          for (final T choice in choices) choice: choice.name,
        },
        title: value.runtimeType.toString(),
      );
}

// This is a simple card that presents a set of radio buttons (inside of a
// RadioSelection, defined below) for the user to select from.
class ChoiceCard<T extends Object?> extends StatelessWidget {
  const ChoiceCard({
    super.key,
    required this.value,
    required this.choices,
    required this.onChanged,
    required this.choiceLabels,
    required this.title,
  });

  final T value;
  final Iterable<T> choices;
  final Map<T, String> choiceLabels;
  final String title;
  final ValueChanged<T?> onChanged;

  @override
  Widget build(BuildContext context) => Card(
        // If the card gets too small, let it scroll both directions.
        child: SingleChildScrollView(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(title),
                  ),
                  for (final T choice in choices)
                    RadioSelection<T>(
                      value: choice,
                      groupValue: value,
                      onChanged: onChanged,
                      child: Text(choiceLabels[choice]!),
                    ),
                ],
              ),
            ),
          ),
        ),
      );
}

// A button that has a radio button on one side and a label child. Tapping on
// the label or the radio button selects the item.
class RadioSelection<T extends Object?> extends StatefulWidget {
  const RadioSelection({
    super.key,
    required this.value,
    required this.groupValue,
    required this.onChanged,
    required this.child,
  });

  final T value;
  final T? groupValue;
  final ValueChanged<T?> onChanged;
  final Widget child;

  @override
  State<RadioSelection<T>> createState() => _RadioSelectionState<T>();
}

class _RadioSelectionState<T extends Object?> extends State<RadioSelection<T>> {
  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Padding(
            padding: const EdgeInsetsDirectional.only(end: 8),
            child: Radio<T>(
              groupValue: widget.groupValue,
              value: widget.value,
              onChanged: widget.onChanged,
            ),
          ),
          GestureDetector(
            onTap: () => widget.onChanged(widget.value),
            child: widget.child,
          ),
        ],
      );
}

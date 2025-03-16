import 'package:flutter/material.dart';
import 'package:kinnow_mqtt/kinnow_mqtt.dart';
import 'package:hex/hex.dart';
import 'package:kinnow_mqtt_flutter_example/disconnect_action.dart';
import 'package:kinnow_mqtt_flutter_example/publish_action.dart';
import 'package:kinnow_mqtt_flutter_example/subscribe_action.dart';

import 'connect_action.dart';

enum MqttActions { connect, publish, subscribe, unsubscribe, disconnect }

class ActionSelector extends StatefulWidget {
  const ActionSelector({
    super.key,
  });

  @override
  State<ActionSelector> createState() => _ActionSelectorState();
}

class _ActionSelectorState extends State<ActionSelector> {
  MqttActions selectedAction = MqttActions.connect;
  late PageController pageController;

  @override
  void initState() {
    pageController = PageController();
    super.initState();
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SegmentedButton<MqttActions>(
            segments: MqttActions.values
                .map(
                  (e) => ButtonSegment(value: e, label: Text(e.name)),
                )
                .toList(),
            selected: {selectedAction},
            onSelectionChanged: (selection) {
              pageController.animateToPage(selection.first.index,
                  duration: const Duration(milliseconds: 150),
                  curve: Easing.standard);
              setState(() {
                selectedAction = selection.first;
              });
            },
          ),
        ),
        Expanded(
          child: PageView(
            controller: pageController,
            onPageChanged: (value) {
              setState(() {
                selectedAction = MqttActions.values[value];
              });
            },
            children: const [
              SingleChildScrollView(child: ConnectActionMaker()),
              SingleChildScrollView(child: PublishAction()),
              SingleChildScrollView(child: SubscribeAction()),
              SingleChildScrollView(child: Placeholder()),
              SingleChildScrollView(child: DisconnectAction()),
            ],
          ),
        )
      ],
    );
  }
}

class StringNullableFormField extends StatelessWidget {
  final String title;
  final bool isRequired;
  final void Function(String?) onSave;

  const StringNullableFormField(this.title, this.isRequired, this.onSave,
      {super.key});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Text(title),
      if (!isRequired)
        Text(" (Optional)",
            style: TextStyle(
                fontStyle: FontStyle.italic,
                color: Theme.of(context).colorScheme.shadow)),
      const SizedBox(
        width: 10,
      ),
      Expanded(
          child: TextFormField(
        validator: (value) {
          if (isRequired && (value == null || value.isEmpty)) {
            return "$title cannot be empty";
          }
          return null;
        },
        onSaved: (newValue) {
          if (newValue == null || newValue.isEmpty) {
            onSave(null);
          } else {
            onSave(newValue);
          }
        },
      ))
    ]);
  }
}

class IntNullableFormField extends StatelessWidget {
  final String title;
  final bool isRequired;
  final void Function(int?) onSave;

  const IntNullableFormField(this.title, this.isRequired, this.onSave,
      {super.key});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Text(title),
      if (!isRequired)
        Text(" (Optional)",
            style: TextStyle(
                fontStyle: FontStyle.italic,
                color: Theme.of(context).colorScheme.shadow)),
      const SizedBox(
        width: 10,
      ),
      Expanded(
          child: TextFormField(
        keyboardType: TextInputType.number,
        validator: (value) {
          if (isRequired) {
            if (value == null || value.isEmpty) {
              return "$title cannot be empty";
            }
            if (int.tryParse(value) == null) {
              return "$title must be a number";
            }
            return null;
          }
          //not required and empty
          if (value == null || value.isEmpty) {
            return null;
          }
          //not required but invalid
          if (int.tryParse(value) == null) {
            return "$title must be a number";
          }
          return null;
        },
        onSaved: (newValue) {
          if (newValue == null || newValue.isEmpty) {
            onSave(null);
          } else {
            onSave(int.tryParse(newValue));
          }
        },
      ))
    ]);
  }
}

class BoolNullableFormField extends StatelessWidget {
  final String title;
  final bool? state;
  final void Function(bool?) onStateUpdate;

  const BoolNullableFormField(this.title, this.state, this.onStateUpdate,
      {super.key});

  @override
  Widget build(BuildContext context) {
    final String label;
    label = (state == null) ? "(Unspecified)" : "(${state.toString()})";
    return Row(children: [
      Text(title),
      Expanded(
        child: Text(label,
            textAlign: TextAlign.end,
            style: TextStyle(
                fontStyle: FontStyle.italic,
                color: Theme.of(context).colorScheme.shadow)),
      ),
      Checkbox(
        value: state,
        onChanged: onStateUpdate,
        tristate: true,
      )
    ]);
  }
}

class BoolFormField extends StatelessWidget {
  final String title;
  final bool value;
  final void Function(bool) onChanged;

  const BoolFormField(this.title, this.value, this.onChanged, {super.key});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Text(title),
      const Spacer(),
      Switch(
        value: value,
        onChanged: onChanged,
      )
    ]);
  }
}

class EnumFormField<T extends Enum> extends StatelessWidget {
  final String title;
  final bool isRequired;
  final void Function(T?) onChange;
  final Map<String, T> nameValueMap;

  const EnumFormField(
      this.title, this.isRequired, this.nameValueMap, this.onChange,
      {super.key});

  @override
  Widget build(BuildContext context) {
    final Map<String, T?> options;// = nameValueMap.cast<String, T?>();
    if (isRequired) {
      options = nameValueMap.cast<String, T?>();
    } else {
      options = nameValueMap.map<String, T?>((key, value) => MapEntry(key, value))
        ..addEntries([const MapEntry("None", null)]);
    }
    return Row(children: [
      Text(title),
      if (!isRequired)
        Text(" (Optional)",
            style: TextStyle(
                fontStyle: FontStyle.italic,
                color: Theme.of(context).colorScheme.shadow)),
      const SizedBox(width: 10),
      Expanded(
        child: DropdownButtonFormField<T?>(
          isExpanded: true,
          items: options.entries
              .map((e) => DropdownMenuItem(
                  value: e.value,
                  child: Text(
                    e.key,
                    overflow: TextOverflow.ellipsis,
                  )))
              .toList(),
          onChanged: onChange,
          validator: (value) {
            if (value == null && isRequired) {
              return "$title is required";
            }
            return null;
          },
        ),
      )
    ]);
  }
}

class StringOrBytesNullableFormField extends StatefulWidget {
  final String title;
  final bool isRequired;
  final void Function(StringOrBytes?) onSave;

  const StringOrBytesNullableFormField(this.title, this.isRequired, this.onSave,
      {super.key});

  @override
  State<StringOrBytesNullableFormField> createState() =>
      _StringOrBytesNullableFormFieldState();
}

class _StringOrBytesNullableFormFieldState
    extends State<StringOrBytesNullableFormField> {
  bool hexMode = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 10),
        Row(children: [
          Text(widget.title),
          if (!widget.isRequired)
            Text(" (Optional)",
                style: TextStyle(
                    fontStyle: FontStyle.italic,
                    color: Theme.of(context).colorScheme.shadow)),
          const Spacer(),
          SegmentedButton(
            segments: const [
              ButtonSegment(value: false, label: Text("Ascii")),
              ButtonSegment(value: true, label: Text("Hex"))
            ],
            selected: {hexMode},
            onSelectionChanged: (p0) => setState(() => hexMode = p0.first),
          )
        ]),
        Row(
          children: [
            const Spacer(flex: 1),
            Expanded(
                flex: 2,
                child: TextFormField(
                  validator: (value) {
                    if (widget.isRequired && (value == null || value.isEmpty)) {
                      return "${widget.title} cannot be empty";
                    }
                    if (hexMode && value != null) {
                      value = value.trim().toLowerCase();
                      value = value.replaceAll("0x", "");
                      try {
                        HEX.decode(value);
                      } on FormatException {
                        return "Invalid Hex Value";
                      }
                    }
                    return null;
                  },
                  onSaved: (newValue) {
                    if (hexMode) {
                      newValue = newValue!.trim().toLowerCase();
                      newValue = newValue.replaceAll("0x", "");
                      final bytes = HEX.decode(newValue);
                      widget.onSave(StringOrBytes.fromBytes(bytes));
                    } else {
                      widget.onSave(StringOrBytes.fromString(newValue!));
                    }
                  },
                )),
          ],
        )
      ],
    );
  }
}

import "package:flutter/material.dart";
import "package:scouting_frontend/models/map_nullable.dart";
import "package:scouting_frontend/views/constants.dart";

class Selector<T> extends StatelessWidget {
  Selector({
    required final List<T> options,
    required final String placeholder,
    required final void Function(T) onChange,
    required final String Function(T) makeItem,
    required final String? Function(T?) validate,
    required final T? value,
  }) : this._inner(
          validate: validate,
          onChange: onChange,
          options: options,
          placeholder: placeholder,
          makeItem: makeItem,
          value: value,
        );

  Selector._inner({
    required this.options,
    required this.placeholder,
    required this.value,
    required this.makeItem,
    required this.onChange,
    required this.validate,
  });

  final List<T> options;
  final String placeholder;
  final void Function(T) onChange;
  final String Function(T) makeItem;
  final String? Function(T?) validate;
  final T? value;

  @override
  Widget build(final BuildContext context) {
    DropdownMenuItem<V> itemizeRaw<V>(final V choice, final String title) =>
        DropdownMenuItem<V>(
          value: choice,
          child: Text(title, style: TextStyle(color: Colors.white)),
        );
    DropdownMenuItem<V> itemize<V>(final V choice) =>
        itemizeRaw(choice, makeItem(choice));

    final List<DropdownMenuItem<T>> choices = options.map(itemize).toList();
    final DropdownMenuItem<T?> placeholderItem = itemizeRaw(null, placeholder);

    return DropdownButtonFormField<T?>(
      validator: validate,
      isExpanded: true,
      value: value,
      elevation: 24,
      style: const TextStyle(color: primaryColor, fontSize: 20),
      onChanged: (final T? selection) => selection.mapNullable(onChange),
      items: <DropdownMenuItem<T?>>[placeholderItem, ...choices],
    );
  }
}

import 'package:flutter/material.dart';

class DropDownButtonFormField extends FormField<String> {
  DropDownButtonFormField(
      {String hint,
      List<DropdownMenuItem> items,
      Function onChanged,
      FormFieldSetter<String> onSaved,
      FormFieldValidator<String> validator,
      bool autovalidate = false})
      : super(
            onSaved: onSaved,
            validator: validator,
            initialValue: null,
            autovalidate: autovalidate,
            builder: (FormFieldState<String> state) {
              return Column(
                children: <Widget>[
                  DropdownButton(
                    hint: Text(hint),
                    items: items,
                    onChanged: (value) {
                      state.didChange(value);
                      onChanged(value);
                    },
                    value: state.value,
                  ),
                  state.hasError
                      ? Text(
                          state.errorText,
                          style: TextStyle(color: Colors.red),
                        )
                      : Container(),
                ],
              );
            });
}

class DropDownButton extends StatefulWidget {
  final String _hint;
  final List<DropdownMenuItem> _items;
  final Function _callback;

  DropDownButton(this._hint, this._items, this._callback);

  @override
  State<StatefulWidget> createState() {
    return _DropDownButtonState();
  }
}

class _DropDownButtonState extends State<DropDownButton> {
  String _value;

  @override
  Widget build(BuildContext context) {
    return DropdownButton(
      isExpanded: true,
      hint: Text(widget._hint),
      items: widget._items,
      onChanged: (value) {
        setState(() {
          print(value);
          _value = value;
          widget._callback(_value);
        });
      },
      value: _value,
    );
  }
}

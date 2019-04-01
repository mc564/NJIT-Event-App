import 'package:flutter/material.dart';

class DropDownButtonFormField extends FormField<String> {
  DropDownButtonFormField(
      {String hint,
      @required List<DropdownMenuItem> items,
      @required Color color,
      @required Color textColor,
      Function onChanged,
      String initialValue,
      FormFieldSetter<String> onSaved,
      FormFieldValidator<String> validator,
      bool autovalidate = false})
      : super(
          onSaved: onSaved,
          validator: validator,
          initialValue: initialValue,
          autovalidate: autovalidate,
          builder: (FormFieldState<String> state) {
            return Column(
              children: <Widget>[
                Container(
                  color: color,
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton(
                      hint: Padding(
                        padding: EdgeInsets.only(left: 10),
                        child: Text(
                          hint,
                          style: TextStyle(
                              color: textColor, fontWeight: FontWeight.w600),
                        ),
                      ),
                      items: items,
                      isExpanded: true,
                      onChanged: (value) {
                        state.didChange(value);
                        onChanged(value);
                      },
                      value: state.value,
                    ),
                  ),
                ),
                state.hasError
                    ? Text(
                        state.errorText,
                        style: TextStyle(color: Colors.red),
                      )
                    : Container(),
              ],
            );
          },
        );
}

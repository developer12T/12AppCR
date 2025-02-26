import 'package:_12sale_app/core/styles/style.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Customtextinput extends StatefulWidget {
  final String label;
  final String? hint;
  final String? initialValue;
  final int? max;
  final bool readonly;
  final List<TextInputFormatter>? inputFormatters;
  VoidCallback? onFieldTap; // Callback for custom actions
  final ValueChanged<String> onChanged;
  final TextInputType? keypadType;
  // final ValueChanged<String> onFieldSubmitted; // Accepts the submitted text

  final TextEditingController? controller; // Add controller as an option
  Customtextinput(
    BuildContext context, {
    super.key,
    required this.label,
    this.hint,
    this.initialValue,
    this.max,
    this.readonly = false,
    this.onFieldTap,
    this.inputFormatters,
    required this.onChanged,
    this.keypadType,
    // required this.onFieldSubmitted,
    this.controller,
  });

  @override
  State<Customtextinput> createState() => _CustomtextinputState();
}

class _CustomtextinputState extends State<Customtextinput> {
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      inputFormatters: widget.inputFormatters,
      focusNode: _focusNode,
      maxLength: widget.max,
      keyboardType: widget.keypadType,
      onChanged: widget.onChanged, // Pass the onChanged callback
      // onEditingComplete: widget.onChanged,
      onTap: () {
        // Check if onFieldTap is not null before calling it
        if (widget.onFieldTap != null) {
          widget.onFieldTap!();
        }
      },

      initialValue: widget.controller != null ? null : 'กรุณากรอกข้อมูล',
      validator: (value) => value!.isEmpty ? 'กรุณากรอกข้อมูล' : null,
      // onFieldSubmitted: widget.onFieldSubmitted,
      readOnly: widget.readonly,
      enabled: !widget.readonly,
      style: Styles.black18(context),
      controller: widget.controller, // Use controller if provided
      decoration: InputDecoration(
        fillColor: widget.readonly ? Colors.grey[200] : Colors.white,
        counterText: '',
        labelText: widget.label,
        labelStyle: Styles.grey18(context),
        hintText: widget.hint,
        hintStyle: Styles.grey18(context),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        contentPadding:
            const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:sync_together/core/resources/strings.dart';

class IField extends StatelessWidget {
  const IField({
    required this.controller,
    this.filled = false,
    this.obscureText = false,
    this.readOnly = false,
    this.validator,
    this.fillColor,
    this.focusColor,
    this.borderColor,
    this.contentPadding,
    this.prefixIcon,
    this.prefix,
    this.suffixIcon,
    this.suffix,
    this.hintText,
    this.keyboardType,
    this.hintStyle,
    this.overrideValidator = false,
    this.maxLines = 1,
    this.minLines,
    this.borderRadius,
    this.textInputAction = TextInputAction.next,
    this.onEditingComplete,
    this.onFieldSubmitted,
    this.onTap,
    this.onChanged,
    this.fontSize,
    super.key,
  });

  final String? Function(String?)? validator;
  final void Function()? onEditingComplete;
  final void Function(String)? onFieldSubmitted;
  final void Function()? onTap;
  final void Function(String)? onChanged;
  final TextEditingController controller;
  final bool filled;
  final Color? fillColor;
  final Color? focusColor;
  final Color? borderColor;
  final bool obscureText;
  final EdgeInsetsGeometry? contentPadding;
  final TextInputAction? textInputAction;
  final bool readOnly;
  final Widget? prefixIcon;
  final Widget? prefix;
  final Widget? suffixIcon;
  final Widget? suffix;
  final String? hintText;
  final TextInputType? keyboardType;
  final bool overrideValidator;
  final TextStyle? hintStyle;
  final BorderRadius? borderRadius;
  final int? maxLines;
  final int? minLines;
  final double? fontSize;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: overrideValidator
          ? validator
          : (value) {
              if (value == null || value.isEmpty) {
                return Strings.fieldRequiredText;
              }
              return validator?.call(value);
            },
      minLines: minLines,
      maxLines: maxLines,
      onTap: onTap,
      onChanged: onChanged,
      onTapOutside: (_) {
        FocusScope.of(context).unfocus();
      },
      style: TextStyle(
        fontWeight: FontWeight.normal,
        fontSize: fontSize ?? 14,
      ),
      keyboardType: keyboardType,
      obscureText: obscureText,
      textInputAction: textInputAction,
      readOnly: readOnly,
      onEditingComplete: onEditingComplete,
      onFieldSubmitted: onFieldSubmitted,
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: borderRadius ?? BorderRadius.circular(15),
          borderSide: BorderSide(
            color: borderColor ?? Colors.grey,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: borderRadius ?? BorderRadius.circular(15),
          borderSide: BorderSide(color: borderColor ?? Colors.grey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: borderRadius ?? BorderRadius.circular(15),
          borderSide: BorderSide(
            color: focusColor ?? Colors.grey,
          ),
        ),
        // overriding the default padding helps with that puffy look
        contentPadding: contentPadding ??
            const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 15,
            ),

        filled: filled,
        fillColor: fillColor,
        focusColor: focusColor,
        prefixIcon: prefixIcon,
        prefix: prefix,
        suffixIcon: suffixIcon,
        suffix: suffix,
        hintText: hintText,
        hintStyle: hintStyle ??
            const TextStyle(
              fontSize: 16,
              // color: Colours.softGreyColor,
            ),
      ),
    );
  }
}

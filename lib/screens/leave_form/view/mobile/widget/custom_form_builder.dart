import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Custom Form Builder for reusable form components
class CustomFormBuilder {
  /// Build a dropdown field
  static Widget buildDropdownField({
    required String label,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
    String? hint,
    IconData? prefixIcon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300, width: 1.5),
          ),
          child: DropdownButtonFormField<String>(
            value: value,
            hint: Text(hint ?? 'Select $label'),
            decoration: InputDecoration(
              prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
            items: items.map((String item) {
              return DropdownMenuItem<String>(
                value: item,
                child: Text(item),
              );
            }).toList(),
            onChanged: onChanged,
            isExpanded: true,
          ),
        ),
      ],
    );
  }

  /// Build a date picker field
  static Widget buildDateField({
    required BuildContext context,
    required String label,
    required DateTime? selectedDate,
    required Function(DateTime) onDateSelected,
    DateTime? firstDate,
    DateTime? lastDate,
    IconData? prefixIcon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () async {
            final DateTime? picked = await showDatePicker(
              context: context,
              initialDate: selectedDate ?? DateTime.now(),
              firstDate: firstDate ?? DateTime(2000),
              lastDate: lastDate ?? DateTime(2100),
              builder: (context, child) {
                return Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: const ColorScheme.light(
                      primary: Color(0xFF5B6FED),
                      onPrimary: Colors.white,
                      onSurface: Colors.black,
                    ),
                  ),
                  child: child!,
                );
              },
            );
            if (picked != null) {
              onDateSelected(picked);
            }
          },
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300, width: 1.5),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    if (prefixIcon != null) ...[
                      Icon(prefixIcon, color: Colors.grey.shade600),
                      const SizedBox(width: 12),
                    ],
                    Text(
                      selectedDate != null
                          ? DateFormat('MM/dd/yyyy').format(selectedDate)
                          : 'Select Date',
                      style: TextStyle(
                        fontSize: 16,
                        color: selectedDate != null
                            ? Colors.black87
                            : Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
                Icon(Icons.calendar_today, color: Colors.grey.shade600, size: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Build a text field
  static Widget buildTextField({
    required String label,
    required TextEditingController controller,
    String? hint,
    int maxLines = 1,
    IconData? prefixIcon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300, width: 1.5),
          ),
          child: TextFormField(
            controller: controller,
            maxLines: maxLines,
            keyboardType: keyboardType,
            validator: validator,
            decoration: InputDecoration(
              hintText: hint,
              prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Build a custom button
  static Widget buildButton({
    required String text,
    required VoidCallback onPressed,
    Color? backgroundColor,
    Color? textColor,
    IconData? icon,
    bool isOutlined = false,
    double? width,
  }) {
    final bgColor = backgroundColor ?? const Color(0xFF00D9B5);
    final txtColor = textColor ?? Colors.white;

    return SizedBox(
      width: width,
      height: 50,
      child: isOutlined
          ? OutlinedButton(
              onPressed: onPressed,
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: Colors.grey.shade400, width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            )
          : ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: bgColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(icon, color: txtColor),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    text,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: txtColor,
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
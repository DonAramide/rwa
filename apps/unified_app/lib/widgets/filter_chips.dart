import 'package:flutter/material.dart';

class FilterChips extends StatelessWidget {
  final List<String> options;
  final String? selectedValue;
  final String label;
  final ValueChanged<String?> onChanged;
  final bool allowClear;

  const FilterChips({
    super.key,
    required this.options,
    required this.selectedValue,
    required this.label,
    required this.onChanged,
    this.allowClear = true,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isNarrowScreen = screenWidth < 600;

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: isNarrowScreen ? double.infinity : 400,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header with label and clear button
          Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (allowClear && selectedValue != null) ...[
                const SizedBox(width: 8),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => onChanged(null),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.close,
                            size: 14,
                            color: Colors.grey[600],
                          ),
                          if (!isNarrowScreen) ...[
                            const SizedBox(width: 4),
                            Text(
                              'Clear',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),

          // Responsive filter chips layout
          LayoutBuilder(
            builder: (context, constraints) {
              // Calculate optimal chip layout based on available width
              final availableWidth = constraints.maxWidth;
              final estimatedChipWidth = 100.0; // Average chip width
              final chipsPerRow = (availableWidth / estimatedChipWidth).floor().clamp(1, options.length);

              return Container(
                width: double.infinity,
                constraints: BoxConstraints(
                  maxHeight: isNarrowScreen ? 120 : 80, // Limit height on small screens
                ),
                child: SingleChildScrollView(
                  scrollDirection: isNarrowScreen && options.length > 4 ? Axis.horizontal : Axis.vertical,
                  child: isNarrowScreen && options.length > 4
                      ? _buildHorizontalChips(context, isNarrowScreen)
                      : _buildWrappedChips(context, isNarrowScreen),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHorizontalChips(BuildContext context, bool isNarrowScreen) {
    return Row(
      children: options.map((option) {
        final isSelected = selectedValue == option;
        return Padding(
          padding: const EdgeInsets.only(right: 8),
          child: _buildFilterChip(context, option, isSelected, isNarrowScreen),
        );
      }).toList(),
    );
  }

  Widget _buildWrappedChips(BuildContext context, bool isNarrowScreen) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: options.map((option) {
        final isSelected = selectedValue == option;
        return _buildFilterChip(context, option, isSelected, isNarrowScreen);
      }).toList(),
    );
  }

  Widget _buildFilterChip(BuildContext context, String option, bool isSelected, bool isNarrowScreen) {
    return Material(
      color: Colors.transparent,
      child: FilterChip(
        label: Text(
          option.toUpperCase(),
          style: TextStyle(
            fontSize: isNarrowScreen ? 11 : 12,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : Colors.grey[700],
          ),
        ),
        selected: isSelected,
        onSelected: (selected) {
          onChanged(selected ? option : null);
        },
        selectedColor: Theme.of(context).primaryColor,
        checkmarkColor: Colors.white,
        backgroundColor: Colors.grey[50],
        elevation: isSelected ? 2 : 0,
        pressElevation: 4,
        side: BorderSide(
          color: isSelected ? Theme.of(context).primaryColor : Colors.grey[300]!,
          width: isSelected ? 2 : 1,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(isNarrowScreen ? 16 : 20),
        ),
        padding: EdgeInsets.symmetric(
          horizontal: isNarrowScreen ? 8 : 12,
          vertical: isNarrowScreen ? 2 : 4,
        ),
        labelPadding: EdgeInsets.symmetric(
          horizontal: isNarrowScreen ? 4 : 6,
        ),
      ),
    );
  }
}

class CustomSearchBar extends StatelessWidget {
  final String? hintText;
  final String? value;
  final ValueChanged<String?> onChanged;
  final VoidCallback? onClear;

  const CustomSearchBar({
    super.key,
    this.hintText,
    this.value,
    required this.onChanged,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isNarrowScreen = screenWidth < 600;

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: isNarrowScreen ? double.infinity : 500,
        minHeight: 48,
      ),
      child: TextField(
        onChanged: onChanged,
        style: TextStyle(
          fontSize: isNarrowScreen ? 14 : 16,
        ),
        decoration: InputDecoration(
          hintText: hintText ?? 'Search assets...',
          hintStyle: TextStyle(
            fontSize: isNarrowScreen ? 14 : 16,
            color: Colors.grey[500],
          ),
          prefixIcon: Padding(
            padding: const EdgeInsets.all(12),
            child: Icon(
              Icons.search,
              size: isNarrowScreen ? 20 : 24,
              color: Colors.grey[600],
            ),
          ),
          suffixIcon: value != null && value!.isNotEmpty
              ? IconButton(
                  icon: Icon(
                    Icons.clear,
                    size: isNarrowScreen ? 20 : 24,
                  ),
                  onPressed: () {
                    onChanged(null);
                    onClear?.call();
                  },
                  padding: const EdgeInsets.all(8),
                  constraints: const BoxConstraints(
                    minWidth: 40,
                    minHeight: 40,
                  ),
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(isNarrowScreen ? 8 : 12),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(isNarrowScreen ? 8 : 12),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(isNarrowScreen ? 8 : 12),
            borderSide: BorderSide(
              color: Theme.of(context).primaryColor,
              width: 2,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(isNarrowScreen ? 8 : 12),
            borderSide: const BorderSide(color: Colors.red),
          ),
          filled: true,
          fillColor: Colors.grey[50],
          contentPadding: EdgeInsets.symmetric(
            horizontal: isNarrowScreen ? 12 : 16,
            vertical: isNarrowScreen ? 10 : 12,
          ),
        ),
      ),
    );
  }
}
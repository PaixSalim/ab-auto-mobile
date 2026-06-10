import 'dart:ui';
import 'package:flutter/material.dart';

class MultiSelectFilterModal extends StatefulWidget {
  final String title;
  final List<String> allOptions;
  final List<String> selectedOptions;
  final Function(List<String>) onApply;

  const MultiSelectFilterModal({
    super.key,
    required this.title,
    required this.allOptions,
    required this.selectedOptions,
    required this.onApply,
  });

  @override
  MultiSelectFilterModalState createState() => MultiSelectFilterModalState();
}

class MultiSelectFilterModalState extends State<MultiSelectFilterModal> {
  TextEditingController searchController = TextEditingController();
  List<String> filteredOptions = [];
  Set<String> localSelectedOptions = {};

  @override
  void initState() {
    super.initState();
    filteredOptions = List.from(widget.allOptions);
    localSelectedOptions = Set.from(widget.selectedOptions);
  }

  void _filterOptions(String query) {
    setState(() {
      filteredOptions =
          widget.allOptions
              .where(
                (option) => option.toLowerCase().contains(query.toLowerCase()),
              )
              .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.7,
          ),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 10,
                spreadRadius: 2,
              )
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Title
              Text(
                widget.title,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              const SizedBox(height: 16),
              
              // Header with search
              TextField(
                controller: searchController,
                onChanged: _filterOptions,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.search, color: Theme.of(context).primaryColor),
                  hintText: "Chercher...",
                  hintStyle: TextStyle(color: Colors.grey[600]),
                  filled: true,
                  fillColor: Colors.white.withValues(alpha: 0.5),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.3)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.3)),
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 0),
                ),
              ),
              const SizedBox(height: 16),

          // Select All option
          ListTile(
            title: const Text(
              "Tout",
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            trailing: Checkbox(
              value:
                  localSelectedOptions.length == widget.allOptions.length &&
                  widget.allOptions.isNotEmpty,
              activeColor: Theme.of(context).primaryColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
              onChanged: (bool? value) {
                setState(() {
                  if (value == true) {
                    localSelectedOptions = Set.from(widget.allOptions);
                  } else {
                    localSelectedOptions.clear();
                  }
                });
              },
            ),
            contentPadding: EdgeInsets.zero,
            dense: true,
          ),
          const Divider(),

          // List of options
          Expanded(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: filteredOptions.length,
              itemBuilder: (context, index) {
                final option = filteredOptions[index];
                final isSelected = localSelectedOptions.contains(option);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected 
                          ? Theme.of(context).primaryColor.withValues(alpha: 0.1) 
                          : Colors.white.withValues(alpha: 0.5),
                      border: Border.all(
                        color: isSelected 
                            ? Theme.of(context).primaryColor 
                            : Colors.grey.withValues(alpha: 0.2),
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ListTile(
                      title: Text(
                        option,
                        style: TextStyle(
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected ? Theme.of(context).primaryColor : Colors.black87,
                        ),
                      ),
                      trailing: Checkbox(
                        value: isSelected,
                        activeColor: Theme.of(context).primaryColor,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                        onChanged: (bool? value) {
                          setState(() {
                            if (value == true) {
                              localSelectedOptions.add(option);
                            } else {
                              localSelectedOptions.remove(option);
                            }
                          });
                        },
                      ),
                      dense: true,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 16),

          // Apply Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                widget.onApply(localSelectedOptions.toList());
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 16),
                elevation: 4,
                shadowColor: Theme.of(context).primaryColor.withValues(alpha: 0.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                "Valider",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
        ),
      ),
    );
  }
}

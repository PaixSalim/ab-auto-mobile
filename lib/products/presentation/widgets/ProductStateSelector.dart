import 'package:flutter/material.dart';

class ProductStateSelector extends StatefulWidget {
  final String? initialState;
  final ValueChanged<String?>? onStateChanged;

  const ProductStateSelector({
    super.key,
    this.initialState,
    this.onStateChanged,
  });

  @override
  State<ProductStateSelector> createState() => _ProductStateSelectorState();
}

class _ProductStateSelectorState extends State<ProductStateSelector> {
  String? selectedState;

  @override
  void initState() {
    super.initState();
    selectedState = widget.initialState ?? 'new';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'État du produit',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              // Neuf button
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedState = 'new';
                    });
                    widget.onStateChanged?.call('new');
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    decoration: BoxDecoration(
                      color: selectedState == 'new'
                          ? const Color(0xFF3B82F6)
                          : Colors.white,
                      border: Border.all(
                        color: selectedState == 'new'
                            ? const Color(0xFF3B82F6)
                            : const Color(0xFFE5E7EB),
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.new_releases_outlined,
                          size: 18,
                          color: selectedState == 'new'
                              ? Colors.white
                              : const Color(0xFF6B7280),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Neuf',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: selectedState == 'new'
                                ? Colors.white
                                : const Color(0xFF374151),
                          ),
                        ),
                        if (selectedState == 'new') ...[
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.check,
                            size: 16,
                            color: Colors.white,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
              
              const SizedBox(width: 12),
              
              // Occasion button
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedState = 'used';
                    });
                    widget.onStateChanged?.call('used');
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    decoration: BoxDecoration(
                      color: selectedState == 'used'
                          ? const Color(0xFF3B82F6)
                          : Colors.white,
                      border: Border.all(
                        color: selectedState == 'used'
                            ? const Color(0xFF3B82F6)
                            : const Color(0xFFE5E7EB),
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.inventory_2_outlined,
                          size: 18,
                          color: selectedState == 'used'
                              ? Colors.white
                              : const Color(0xFF6B7280),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Occasion',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: selectedState == 'used'
                                ? Colors.white
                                : const Color(0xFF374151),
                          ),
                        ),
                        if (selectedState == 'used') ...[
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.check,
                            size: 16,
                            color: Colors.white,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          
          // Additional info for used state
          if (selectedState == 'used') ...[
            const SizedBox(height: 8),
            Text(
              'Prix variable selon l\'état',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

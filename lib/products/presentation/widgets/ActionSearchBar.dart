import 'dart:async';

import 'package:auto/config/routes/custom_navigation.dart';
import 'package:auto/products/data/utils/getProductPrice.dart';
import 'package:auto/products/domain/entities/product_entity.dart';
import 'package:auto/products/presentation/pages/ProductDetailPage.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'dart:ui';

class ActionSearchBar extends StatefulWidget {
  final List<ProductEntity> products;
  final double? width;

  const ActionSearchBar({super.key, required this.products, this.width});

  @override
  State<ActionSearchBar> createState() => _ActionSearchBarState();
}

class _ActionSearchBarState extends State<ActionSearchBar>
    with SingleTickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final LayerLink _layerLink = LayerLink();
  String _query = "";
  bool _isFocused = false;
  List<ProductEntity> _filteredActions = [];
  late AnimationController _animationController;
  late Animation<double> _animation;
  OverlayEntry? _overlayEntry;

  // Debounce timer
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();

    // Initialize animation controller
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    // Set up focus listener
    _focusNode.addListener(_onFocusChange);

    // Initialize with all actions
    _filteredActions = widget.products;
  }

  @override
  void dispose() {
    _removeOverlay();
    _controller.dispose();
    _focusNode.dispose();
    _animationController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onFocusChange() {
    if (_focusNode.hasFocus) {
      setState(() {
        _isFocused = true;
      });
      _animationController.forward();
      _filteredActions = widget.products;
      _showOverlay();
    } else {
      setState(() {
        _isFocused = false;
      });
      _animationController.reverse().then((_) {
        _removeOverlay();
      });
    }
  }

  void _onQueryChanged(String value) {
    setState(() {
      _query = value;
    });

    // Implement debouncing
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 200), () {
      _filterActions();
    });
  }

  void _filterActions() {
    if (_query.isEmpty) {
      setState(() {
        _filteredActions = widget.products;
      });
      _updateOverlay();
      return;
    }

    final normalizedQuery = _query.toLowerCase().trim();
    final filtered =
        (widget.products).where((action) {
          final searchableText = (action.name ?? '').toLowerCase();
          return searchableText.contains(normalizedQuery);
        }).toList();

    setState(() {
      _filteredActions = filtered;
    });
    _updateOverlay();
  }

  void _showOverlay() {
    _removeOverlay();

    final overlay = Overlay.of(context);
    final renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;

    _overlayEntry = OverlayEntry(
      builder:
          (context) => Stack(
            children: [
              Positioned.fill(
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () {
                    _focusNode.unfocus();
                  },
                  child: Container(color: Colors.transparent),
                ),
              ),
              Positioned(
                width: widget.width ?? size.width,
                child: CompositedTransformFollower(
                  link: _layerLink,
                  showWhenUnlinked: false,
                  offset: Offset(0, size.height + 4),
                  child: Material(
                    elevation: 4,
                    color: Colors.transparent,
                    child: _buildSuggestionsList(),
                  ),
                ),
              ),
            ],
          ),
    );

    if (_overlayEntry != null) {
      overlay.insert(_overlayEntry!);
    }
  }

  void _updateOverlay() {
    _removeOverlay();
    if (_isFocused) {
      _showOverlay();
    }
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  Widget _buildSuggestionsList() {
    //final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return FadeTransition(
          opacity: _animation,
          child: SizeTransition(
            sizeFactor: _animation,
            child:
                _filteredActions.isNotEmpty
                    ? Container(
                      margin: EdgeInsets.all(0),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.85),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: Colors.white.withOpacity(0.8), width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                          child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            constraints: const BoxConstraints(maxHeight: 250),
                            child: ListView.builder(
                              shrinkWrap: true,
                              padding: EdgeInsets.zero,
                              itemCount: _filteredActions.length,
                              itemBuilder: (context, index) {
                                final action = _filteredActions[index];
                                return InkWell(
                                  onTap: () {
                                    goTo(
                                      context,
                                      ProductDetailPage(product: action),
                                      AnimationType.fade,
                                    );
                                    _removeOverlay();
                                  },
                                  borderRadius: BorderRadius.circular(8),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        if (action.medias != null && action.medias!.isNotEmpty)
                                          CachedNetworkImage(
                                            width: 18,
                                            imageUrl: action.medias![0],
                                            progressIndicatorBuilder:
                                                (
                                                  context,
                                                  url,
                                                  downloadProgress,
                                                ) => Lottie.asset(
                                                  'assets/animations/lottie/loading-image.json',
                                                  width: 15,
                                                ),
                                            errorWidget:
                                                (
                                                  context,
                                                  url,
                                                  error,
                                                ) => Lottie.asset(
                                                  'assets/animations/lottie/error-network.json',
                                                  width: 15,
                                                ),
                                          )
                                        else
                                          const SizedBox(width: 18),
                                        const SizedBox(width: 8),

                                        /// Partie extensible contenant nom + marque
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              /// Nom du produit
                                              Text(
                                                action.name ?? '',
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 1,
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w500,
                                                  color: Colors.grey[900],
                                                ),
                                              ),

                                              /// Marque (si disponible)
                                              if (action.brand?.name != null)
                                                Text(
                                                  action.brand!.name!,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  maxLines: 1,
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.grey[400],
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),

                                        const SizedBox(width: 8),

                                        if (action.price != null &&
                                            (action.cta == null || action.cta!.isEmpty || action.cta == 'none'))
                                          Text(
                                            '${getProductPrice(action.price!, 0)} Fcfa',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey[400],
                                            ),
                                          ),
                                        if (action.cta != null && action.cta!.isNotEmpty && action.cta != 'none')
                                          Text(
                                            action.cta!,
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey[400],
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              border: Border(
                                top: BorderSide(color: Colors.grey[200]!),
                              ),
                            ),
                            child: GestureDetector(
                              onTap: () {
                                _controller.clear();
                                _removeOverlay();
                              },
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Appuyer sur Entrée',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[500],
                                    ),
                                  ),
                                  Text(
                                    'pour fermer',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[500],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
                : const SizedBox.shrink(),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: SizedBox(
        width: widget.width,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              onChanged: _onQueryChanged,
              decoration: InputDecoration(
                hintText: "Rechercher une pièce",
                hintStyle: TextStyle(color: Colors.black54, fontSize: 14),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white.withOpacity(0.6), width: 1.5),
                  borderRadius: BorderRadius.circular(20),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                fillColor: Colors.white.withOpacity(0.4),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Theme.of(context).primaryColor,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
                prefixIcon: const Icon(Icons.search, size: 20, color: Colors.black87),
                suffixIcon:
                    _controller.text.isNotEmpty
                        ? IconButton(
                          onPressed: () {
                            _controller.clear();
                            _removeOverlay();
                          },
                          icon: Icon(
                            Icons.close,
                            size: 18,
                            color: Theme.of(context).primaryColor,
                          ),
                        )
                        : null,
              ),
              style: TextStyle(fontSize: 14, color: Colors.black87),
            ),
          ),
        ),
      ),
    );
  }
}

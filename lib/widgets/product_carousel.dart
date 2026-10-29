import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../app/routes/app_routes.dart';
import '../cubits/cart/cart_cubit.dart';
import '../cubits/cart/cart_state.dart';
import '../cubits/home/home_cubit.dart';
import '../cubits/home/home_state.dart';
import '../core/constants/app_strings.dart';
import '../data/models/product_model.dart';
import '../data/models/product_details_args.dart';
import 'product_card.dart';

/// Center-focused horizontal product carousel.
///
/// Swipe browses collapsed juan_valdez only (both directions).
/// Expand happens only on an intentional tap/click — never from scrolling.
class ProductCarousel extends StatefulWidget {
  const ProductCarousel({
    super.key,
    required this.juan_valdez,
  });

  final List<ProductModel> juan_valdez;

  @override
  State<ProductCarousel> createState() => _ProductCarouselState();
}

class _ProductCarouselState extends State<ProductCarousel> {
  static const Duration _animDuration = Duration(milliseconds: 260);
  static const double _viewportFraction = 0.76;

  late final PageController _controller;
  double _page = 0;
  bool _dragging = false;

  @override
  void initState() {
    super.initState();
    _controller = PageController(viewportFraction: _viewportFraction);
    _controller.addListener(_onScroll);
  }

  @override
  void didUpdateWidget(covariant ProductCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.juan_valdez != widget.juan_valdez &&
        widget.juan_valdez.isNotEmpty &&
        _controller.hasClients) {
      final max = widget.juan_valdez.length - 1;
      if (_page > max) _controller.jumpToPage(max);
    }
  }

  void _onScroll() {
    if (!_controller.hasClients || !_controller.position.haveDimensions) {
      return;
    }
    final page = _controller.page ?? _page;
    if ((page - _page).abs() > 0.001) {
      setState(() => _page = page);
    }
  }

  double _focusScale(int index) {
    final distance = (_page - index).abs();
    return (1.0 - distance * 0.38).clamp(0.68, 1.0);
  }

  double _focusOpacity(int index) {
    final distance = (_page - index).abs();
    return (1.0 - distance * 0.45).clamp(0.4, 1.0);
  }

  void _collapseIfNeeded() {
    final cubit = context.read<HomeCubit>();
    if (cubit.state.expandedProductId != null) {
      cubit.collapseExpanded();
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onScroll);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.juan_valdez.isEmpty) return const SizedBox.shrink();

    final width = MediaQuery.sizeOf(context).width;
    final height = width >= 700 ? 380.0 : 340.0;

    return SizedBox(
      height: height,
      child: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          // Any user drag (left or right) exits expand mode.
          if (notification is ScrollStartNotification &&
              notification.dragDetails != null) {
            _dragging = true;
            _collapseIfNeeded();
          } else if (notification is ScrollUpdateNotification &&
              notification.dragDetails != null) {
            if (!_dragging) {
              _dragging = true;
              _collapseIfNeeded();
            }
          } else if (notification is ScrollEndNotification) {
            if (_dragging) {
              setState(() => _dragging = false);
            }
          }
          return false;
        },
        child: BlocBuilder<HomeCubit, HomeState>(
          builder: (context, homeState) {
            final expandedMode = homeState.expandedProductId != null;

            return BlocBuilder<CartCubit, CartState>(
              builder: (context, cartState) {
                return PageView.builder(
                  controller: _controller,
                  padEnds: true,
                  clipBehavior: Clip.none,
                  physics: const BouncingScrollPhysics(
                    parent: PageScrollPhysics(),
                  ),
                  itemCount: widget.juan_valdez.length,
                  itemBuilder: (context, index) {
                    final product = widget.juan_valdez[index];
                    final baseScale = _focusScale(index);
                    final baseOpacity = _focusOpacity(index);
                    final isExpanded = homeState.isExpanded(product.id);

                    // Keep side peeks visible while the center card expands —
                    // only soft-dim them slightly so focus stays on the center.
                    final displayScale = isExpanded ? 1.0 : baseScale;
                    final displayOpacity = expandedMode && !isExpanded
                        ? (baseOpacity * 0.85).clamp(0.35, 1.0)
                        : baseOpacity;

                    final carouselHeroTag = 'hero_carousel_${product.id}';
                    return AnimatedOpacity(
                      duration: _animDuration,
                      curve: Curves.easeOutCubic,
                      opacity: displayOpacity,
                      child: AnimatedScale(
                        duration: _animDuration,
                        curve: Curves.easeOutCubic,
                        scale: displayScale,
                        alignment: Alignment.center,
                        child: Align(
                          alignment: Alignment.center,
                          child: ProductCard(
                            product: product,
                            isExpanded: isExpanded,
                            quantity: cartState.quantityOf(product.id),
                            heroTag: carouselHeroTag,
                            onToggleExpand: () {
                              // Ignore expand if this "tap" is really a swipe.
                              if (_dragging) return;
                              context
                                  .read<HomeCubit>()
                                  .toggleExpanded(product.id);
                              _controller.animateToPage(
                                index,
                                duration: const Duration(
                                    milliseconds: 300),
                                curve: Curves.easeOutCubic,
                              );
                            },
                            onOpenDetails: () {
                              Navigator.of(context).pushNamed(
                                AppRoutes.details,
                                arguments: ProductDetailsArgs.fromSection(
                                  product: product,
                                  products: widget.juan_valdez,
                                  sectionTitle: AppStrings.whatAreYouCraving,
                                  heroTag: carouselHeroTag,
                                ),
                              );
                            },
                            onIncrement: () {
                              if (cartState.quantityOf(product.id) ==
                                  0) {
                                context
                                    .read<CartCubit>()
                                    .addToCart(product);
                              } else {
                                context
                                    .read<CartCubit>()
                                    .increment(product.id);
                              }
                            },
                            onDecrement: () {
                              context
                                  .read<CartCubit>()
                                  .decrement(product.id);
                            },
                            onAdd: () {
                              if (cartState.quantityOf(product.id) ==
                                  0) {
                                context
                                    .read<CartCubit>()
                                    .addToCart(product);
                              }
                              Navigator.of(context)
                                  .pushNamed(AppRoutes.cart);
                            },
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}

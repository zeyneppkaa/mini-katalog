import 'package:flutter/material.dart';

import '../models/product_model.dart';

class ProductDetailScreen extends StatefulWidget {
  final Data product;
  final bool isInCart;
  final VoidCallback onAddToCart;
  final VoidCallback onRemoveFromCart;

  const ProductDetailScreen({
    super.key,
    required this.product,
    required this.isInCart,
    required this.onAddToCart,
    required this.onRemoveFromCart,
  });

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  // Visual feedback only; cartIds in HomeScreen stays the single source of truth
  late bool added = widget.isInCart;

  void toggleCart() {
    if (added) {
      widget.onRemoveFromCart();
    } else {
      widget.onAddToCart();
    }
    setState(() {
      added = !added;
    });

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(added ? 'Added to cart' : 'Removed from cart'),
          duration: const Duration(milliseconds: 1200),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final specs = product.specs ?? {};

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        title: Text(
          product.name ?? 'Detail',
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Container(
                width: double.infinity,
                height: 260,
                color: Colors.grey.shade100,
                // Tag must match the one used in ProductsCardTile
                child: Hero(
                  tag: product.id ?? product.hashCode,
                  child: Image.network(
                    product.image ?? '',
                    fit: BoxFit.contain,
                    loadingBuilder: (context, child, progress) {
                      if (progress == null) return child;
                      return const Center(
                        child: SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) => Center(
                      child: Icon(
                        Icons.image_not_supported_outlined,
                        size: 40,
                        color: Colors.grey.shade400,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 28),
            Text(
              product.name ?? '-',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
                height: 1.25,
              ),
            ),
            if ((product.tagline ?? '').isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                product.tagline!,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                  letterSpacing: 0.2,
                ),
              ),
            ],
            const SizedBox(height: 14),
            Text(
              '${product.currency ?? '\$'}${product.price ?? 0}',
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: Colors.black,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 32),
            _sectionTitle('Description'),
            const SizedBox(height: 10),
            Text(
              product.description ?? 'No description available',
              style: TextStyle(
                fontSize: 14,
                height: 1.6,
                color: Colors.grey.shade800,
              ),
            ),
            if (specs.isNotEmpty) ...[
              const SizedBox(height: 32),
              _sectionTitle('Specifications'),
              const SizedBox(height: 10),
              _specsCard(specs),
            ],
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Colors.grey.shade200)),
        ),
        child: SafeArea(
          minimum: const EdgeInsets.fromLTRB(20, 12, 20, 12),
          child: SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: toggleCart,
              style: ElevatedButton.styleFrom(
                backgroundColor: added ? Colors.white : Colors.black,
                foregroundColor: added ? Colors.red.shade400 : Colors.white,
                elevation: 0,
                side: added
                    ? BorderSide(color: Colors.red.shade200)
                    : BorderSide.none,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(
                added ? 'Remove from Cart' : 'Add to Cart',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
    );
  }

  Widget _specValue(String key, dynamic value) {
    const style = TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: Colors.black87,
    );

    if (key == 'Rating') {
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text('$value', style: style),
          const SizedBox(width: 4),
          const Icon(Icons.star, size: 16, color: Colors.amber),
        ],
      );
    }

    return Text('$value', textAlign: TextAlign.right, style: style);
  }

  Widget _specsCard(Map<String, dynamic> specs) {
    final entries = specs.entries.toList();

    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          for (int i = 0; i < entries.length; i++) ...[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entries[i].key,
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                  ),
                  const SizedBox(width: 16),
                  Flexible(
                    child: _specValue(entries[i].key, entries[i].value),
                  ),
                ],
              ),
            ),
            if (i != entries.length - 1)
              Divider(height: 1, thickness: 1, color: Colors.grey.shade200),
          ],
        ],
      ),
    );
  }
}

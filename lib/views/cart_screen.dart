import 'package:flutter/material.dart';

import '../components/cart_empty_box.dart';
import '../components/cart_info_box.dart';
import '../components/mini_card_tile.dart';
import '../models/product_model.dart';

class CartScreen extends StatefulWidget {
  final List<Data> allProducts;
  final Set<int> cartIds;
  final void Function(int productId) onRemoveFromCart;

  const CartScreen({
    super.key,
    required this.allProducts,
    required this.cartIds,
    required this.onRemoveFromCart,
  });

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  // Local copy so this screen repaints instantly; HomeScreen is kept in sync
  // through onRemoveFromCart on every removal.
  late Set<int> currentCartIds = {...widget.cartIds};

  void removeItem(int id) {
    setState(() {
      currentCartIds.remove(id);
    });
    widget.onRemoveFromCart(id);
  }

  @override
  Widget build(BuildContext context) {
    final cartProducts = widget.allProducts
        .where((e) => currentCartIds.contains(e.id))
        .toList();

    final total = cartProducts.fold<num>(0, (sum, e) => sum + (e.price ?? 0));
    final currency =
        cartProducts.isEmpty ? '\$' : (cartProducts.first.currency ?? '\$');

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        title: const Text(
          'Cart',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
        ),
      ),
      body: cartProducts.isEmpty
          ? const CartEmptyBox()
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              itemCount: cartProducts.length,
              itemBuilder: (context, index) {
                final product = cartProducts[index];
                return MiniCardTile(
                  product: product,
                  onRemove: () => removeItem(product.id!),
                );
              },
            ),
      bottomNavigationBar: cartProducts.isEmpty
          ? null
          : Container(
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Colors.grey.shade200)),
              ),
              child: SafeArea(
                minimum: const EdgeInsets.fromLTRB(20, 12, 20, 12),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CartInfoBox(total: total, currency: currency),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        // Simulation only, no real checkout flow
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Checkout is not implemented in this demo',
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text(
                          'Checkout',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
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

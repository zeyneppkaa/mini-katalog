import 'package:flutter/material.dart';

import '../components/products_card_tile.dart';
import '../models/product_model.dart';
import '../services/api_service.dart';
import 'cart_screen.dart';
import 'product_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiService apiService = ApiService();

  List<Data> allProducts = [];
  Set<int> cartIds = {};
  bool isLoading = false;
  String errorMessage = '';
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    loadProducts();
  }

  Future<void> loadProducts() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final response = await apiService.fetchProducts();
      setState(() {
        allProducts = response.data ?? [];
      });
    } catch (e) {
      // Keep the raw error in the console, show a friendly message in the UI
      debugPrint('loadProducts failed: $e');
      final raw = e.toString();
      final isConnectionError =
          raw.contains('SocketException') || raw.contains('Connection error');
      setState(() {
        errorMessage = isConnectionError
            ? 'No internet connection. Please check your network and try again.'
            : 'Something went wrong. Please try again.';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void addToCart(Data product) {
    final id = product.id;
    if (id == null) return;
    setState(() {
      cartIds.add(id);
    });
  }

  void removeFromCart(int id) {
    setState(() {
      cartIds.remove(id);
    });
  }

  void openCart() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CartScreen(
          allProducts: allProducts,
          cartIds: cartIds,
          onRemoveFromCart: removeFromCart,
        ),
      ),
    );
  }

  void openDetail(Data product) {
    final id = product.id;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProductDetailScreen(
          product: product,
          isInCart: cartIds.contains(id),
          onAddToCart: () => addToCart(product),
          onRemoveFromCart: () {
            if (id != null) removeFromCart(id);
          },
        ),
      ),
    );
  }

  List<Data> get filteredProducts {
    if (searchQuery.trim().isEmpty) return allProducts;
    final query = searchQuery.toLowerCase();
    return allProducts
        .where((e) => (e.name ?? '').toLowerCase().contains(query))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Discover',
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Find your perfect product',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildCartButton(),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                onChanged: (value) {
                  setState(() {
                    searchQuery = value;
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Search products',
                  hintStyle: TextStyle(color: Colors.grey.shade500),
                  prefixIcon: Icon(Icons.search, color: Colors.grey.shade600),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _buildGiftBanner(),
              const SizedBox(height: 16),
              Expanded(child: _buildContent()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCartButton() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        IconButton(
          onPressed: openCart,
          icon: const Icon(Icons.shopping_bag_outlined, color: Colors.black),
        ),
        if (cartIds.isNotEmpty)
          Positioned(
            right: 4,
            top: 4,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '${cartIds.length}',
                style: const TextStyle(color: Colors.white, fontSize: 10),
              ),
            ),
          ),
      ],
    );
  }

  // Decorative only, not interactive
  Widget _buildGiftBanner() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Image.asset(
        'assets/images/online-store-banner.png',
        width: double.infinity,
        height: 110,
        fit: BoxFit.cover,
      ),
    );
  }

  Widget _buildContent() {
    if (isLoading) {
      return const Center(
          child: CircularProgressIndicator(color: Colors.black));
    }

    if (errorMessage.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              errorMessage,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: loadProducts,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    final products = filteredProducts;
    if (products.isEmpty) {
      return Center(
        child: Text(
          'No products found',
          style: TextStyle(color: Colors.grey.shade600),
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.only(bottom: 16),
      itemCount: products.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.72,
      ),
      itemBuilder: (context, index) {
        final product = products[index];
        return ProductsCardTile(
          product: product,
          onTap: () => openDetail(product),
        );
      },
    );
  }
}

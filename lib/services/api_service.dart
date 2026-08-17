import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/product_model.dart';

class ApiService {
  static const String url = 'https://dummyjson.com/products';

  Future<ProductResponse> fetchProducts() async {
    http.Response response;

    try {
      response = await http.get(Uri.parse(url));
    } catch (e) {
      throw Exception('Connection error: $e');
    }

    // Status check kept outside try to avoid nested exception wrapping
    if (response.statusCode != 200) {
      throw Exception('Failed to load products: ${response.statusCode}');
    }

    try {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return ProductResponse.fromJson(json);
    } catch (e) {
      throw Exception('Failed to parse products: $e');
    }
  }
}

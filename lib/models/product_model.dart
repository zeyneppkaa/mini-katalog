class ProductResponse {
  List<Data>? data;

  ProductResponse({this.data});

  factory ProductResponse.fromJson(Map<String, dynamic> json) {
    final list = json['products'] as List?;
    return ProductResponse(
      data: list == null
          ? []
          : list.map((e) => Data.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }
}

class Data {
  int? id;
  String? name;
  String? tagline;
  String? description;
  num? price;
  String? currency;
  String? image;
  Map<String, dynamic>? specs;

  Data({
    this.id,
    this.name,
    this.tagline,
    this.description,
    this.price,
    this.currency,
    this.image,
    this.specs,
  });

  factory Data.fromJson(Map<String, dynamic> json) {
    // Only include non-null fields in specs
    final Map<String, dynamic> specs = {};
    if (json['brand'] != null) specs['Brand'] = json['brand'];
    if (json['category'] != null) specs['Category'] = json['category'];
    if (json['rating'] != null) specs['Rating'] = json['rating'];
    if (json['stock'] != null) specs['Stock'] = json['stock'];

    final dimensions = json['dimensions'];
    if (dimensions is Map) {
      final w = dimensions['width'];
      final h = dimensions['height'];
      final d = dimensions['depth'];
      if (w != null && h != null && d != null) {
        specs['Dimensions'] = '$w x $h x $d';
      }
    }

    return Data(
      id: json['id'],
      name: json['title'],
      tagline: json['brand'] ?? json['category'],
      description: json['description'],
      price: json['price'],
      currency: '\$',
      image: json['thumbnail'],
      specs: specs,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'tagline': tagline,
      'description': description,
      'price': price,
      'currency': currency,
      'image': image,
      'specs': specs,
    };
  }
}

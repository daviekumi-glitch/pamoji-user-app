class Order {
  final String id;
  final Product product;
  final User buyer;
  final User seller;
  final int quantity;
  final double totalAmount;
  final String status;
  final String? deliveryAddress;
  final String? paymentMethod;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Order({
    required this.id,
    required this.product,
    required this.buyer,
    required this.seller,
    required this.quantity,
    required this.totalAmount,
    required this.status,
    this.deliveryAddress,
    this.paymentMethod,
    required this.createdAt,
    this.updatedAt,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['_id'] ?? json['id'] ?? '',
      product: Product.fromJson(json['product']),
      buyer: User.fromJson(json['buyer']),
      seller: User.fromJson(json['seller']),
      quantity: json['quantity'] ?? 1,
      totalAmount: (json['totalAmount'] ?? 0).toDouble(),
      status: json['status'] ?? 'pending',
      deliveryAddress: json['deliveryAddress'],
      paymentMethod: json['paymentMethod'],
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product': product.toJson(),
      'buyer': buyer.toJson(),
      'seller': seller.toJson(),
      'quantity': quantity,
      'totalAmount': totalAmount,
      'status': status,
      'deliveryAddress': deliveryAddress,
      'paymentMethod': paymentMethod,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}

class User {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String? avatar;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.avatar,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      avatar: json['avatar'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'avatar': avatar,
    };
  }
}

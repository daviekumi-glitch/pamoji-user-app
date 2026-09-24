// Shared data models — match the backend contracts exactly.
class PListing {
  final String id;
  final String title;
  final double price;
  final String condition;
  final String location;
  final String categoryName;
  final List<String> images;
  final String sellerName;
  final String sellerId;
  final bool deliveryAvailable;
  final int quantity;
  PListing({
    required this.id, required this.title, required this.price,
    required this.condition, required this.location, required this.categoryName,
    required this.images, required this.sellerName, required this.sellerId,
    required this.deliveryAvailable, required this.quantity,
  });
  factory PListing.fromJson(Map<String, dynamic> j) => PListing(
    id: j['id'] as String,
    title: (j['title'] ?? '') as String,
    price: (j['price'] as num? ?? 0).toDouble(),
    condition: (j['condition'] ?? '') as String,
    location: (j['location'] ?? '') as String,
    categoryName: (j['categoryName'] ?? '') as String,
    images: ((j['images'] ?? []) as List).map((e) => e as String).toList(),
    sellerName: (j['sellerName'] ?? '') as String,
    sellerId: (j['sellerId'] ?? '') as String,
    deliveryAvailable: (j['deliveryAvailable'] ?? false) as bool,
    quantity: (j['quantity'] as num? ?? 1).toInt(),
  );
}

class PUser {
  final String id;
  final String displayName;
  final String? photoUrl;
  final String location;
  final bool isSeller;
  final bool emailVerified;
  final double rating;
  final int reviewCount;
  final String? email;
  final String? whatsapp;
  final String accountStatus;
  PUser({
    required this.id, required this.displayName, required this.photoUrl,
    required this.location, required this.isSeller, required this.emailVerified,
    required this.rating, required this.reviewCount, required this.email,
    required this.whatsapp, required this.accountStatus,
  });
  factory PUser.fromJson(Map<String, dynamic> j) => PUser(
    id: j['id'] as String,
    displayName: (j['displayName'] ?? '') as String,
    photoUrl: j['photoUrl'] as String?,
    location: (j['location'] ?? '') as String,
    isSeller: (j['isSeller'] ?? false) as bool,
    emailVerified: (j['emailVerified'] ?? false) as bool,
    rating: (j['rating'] as num? ?? 0).toDouble(),
    reviewCount: (j['reviewCount'] as num? ?? 0).toInt(),
    email: j['email'] as String?,
    whatsapp: j['whatsapp'] as String?,
    accountStatus: (j['accountStatus'] ?? 'active') as String,
  );
}

class PSeller {
  final String id;
  final String? businessName;
  final String contactPerson;
  final String location;
  final String verificationStatus;
  final double rating;
  final int reviewCount;
  PSeller({
    required this.id, required this.businessName, required this.contactPerson,
    required this.location, required this.verificationStatus,
    required this.rating, required this.reviewCount,
  });
  factory PSeller.fromJson(Map<String, dynamic> j) => PSeller(
    id: j['id'] as String,
    businessName: j['businessName'] as String?,
    contactPerson: (j['contactPerson'] ?? '') as String,
    location: (j['location'] ?? '') as String,
    verificationStatus: (j['verificationStatus'] ?? 'not_submitted') as String,
    rating: (j['rating'] as num? ?? 0).toDouble(),
    reviewCount: (j['reviewCount'] as num? ?? 0).toInt(),
  );
}

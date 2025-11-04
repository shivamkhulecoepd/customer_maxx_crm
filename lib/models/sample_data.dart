class Product {
  final int id;
  final String name;
  final String category;
  final double price;
  final int stock;
  final String status;
  final DateTime createdAt;

  Product({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.stock,
    required this.status,
    required this.createdAt,
  });
}

class User {
  final int id;
  final String name;
  final String email;
  final String role;
  final String department;
  final DateTime joinDate;
  final bool isActive;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.department,
    required this.joinDate,
    required this.isActive,
  });
}

class Order {
  final int id;
  final String customerName;
  final double totalAmount;
  final String status;
  final DateTime orderDate;
  final String paymentMethod;
  final String shippingAddress;

  Order({
    required this.id,
    required this.customerName,
    required this.totalAmount,
    required this.status,
    required this.orderDate,
    required this.paymentMethod,
    required this.shippingAddress,
  });
}
import 'package:flutter/material.dart';
import 'package:customer_maxx_crm/widgets/generic_table_view.dart';
import 'package:customer_maxx_crm/models/sample_data.dart';

class SampleGenericTableScreen extends StatelessWidget {
  const SampleGenericTableScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Generic Table Examples'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Products'),
              Tab(text: 'Users'),
              Tab(text: 'Orders'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Products Table
            _buildProductsTable(),
            // Users Table
            _buildUsersTable(),
            // Orders Table
            _buildOrdersTable(),
          ],
        ),
      ),
    );
  }

  Widget _buildProductsTable() {
    final products = [
      Product(
        id: 1,
        name: 'iPhone 15 Pro',
        category: 'Electronics',
        price: 999.99,
        stock: 25,
        status: 'In Stock',
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
      ),
      Product(
        id: 2,
        name: 'MacBook Air M2',
        category: 'Computers',
        price: 1199.99,
        stock: 10,
        status: 'Low Stock',
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
      ),
      Product(
        id: 3,
        name: 'Samsung Galaxy S24',
        category: 'Electronics',
        price: 899.99,
        stock: 0,
        status: 'Out of Stock',
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
    ];

    return GenericTableView<Product>(
      title: 'Products',
      data: products,
      columns: [
        GenericTableColumn(
          title: 'ID',
          value: (product) => product.id,
          width: 60,
        ),
        GenericTableColumn(
          title: 'Name',
          value: (product) => product.name,
        ),
        GenericTableColumn(
          title: 'Category',
          value: (product) => product.category,
        ),
        GenericTableColumn(
          title: 'Price',
          value: (product) => '\$${product.price.toStringAsFixed(2)}',
        ),
        GenericTableColumn(
          title: 'Stock',
          value: (product) => product.stock,
        ),
        GenericTableColumn(
          title: 'Status',
          value: (product) => product.status,
          builder: (product) {
            Color statusColor = Colors.grey;
            if (product.status == 'In Stock') {
              statusColor = Colors.green;
            } else if (product.status == 'Low Stock') {
              statusColor = Colors.orange;
            } else if (product.status == 'Out of Stock') {
              statusColor = Colors.red;
            }
            
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                product.status,
                style: TextStyle(
                  color: statusColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            );
          },
        ),
      ],
      onRowTap: (product) {
        // Handle product tap
        print('Tapped on product: ${product.name}');
      },
      onRowEdit: (product) {
        // Handle product edit
        print('Edit product: ${product.name}');
      },
      onRowDelete: (product) {
        // Handle product delete
        print('Delete product: ${product.name}');
      },
    );
  }

  Widget _buildUsersTable() {
    final users = [
      User(
        id: 1,
        name: 'John Doe',
        email: 'john.doe@example.com',
        role: 'Admin',
        department: 'IT',
        joinDate: DateTime.now().subtract(const Duration(days: 365)),
        isActive: true,
      ),
      User(
        id: 2,
        name: 'Jane Smith',
        email: 'jane.smith@example.com',
        role: 'Manager',
        department: 'Sales',
        joinDate: DateTime.now().subtract(const Duration(days: 180)),
        isActive: true,
      ),
      User(
        id: 3,
        name: 'Robert Johnson',
        email: 'robert.j@example.com',
        role: 'Employee',
        department: 'Marketing',
        joinDate: DateTime.now().subtract(const Duration(days: 30)),
        isActive: false,
      ),
    ];

    return GenericTableView<User>(
      title: 'Users',
      data: users,
      columns: [
        GenericTableColumn(
          title: 'ID',
          value: (user) => user.id,
          width: 60,
        ),
        GenericTableColumn(
          title: 'Name',
          value: (user) => user.name,
        ),
        GenericTableColumn(
          title: 'Email',
          value: (user) => user.email,
        ),
        GenericTableColumn(
          title: 'Role',
          value: (user) => user.role,
        ),
        GenericTableColumn(
          title: 'Department',
          value: (user) => user.department,
        ),
        GenericTableColumn(
          title: 'Join Date',
          value: (user) => '${user.joinDate.day}/${user.joinDate.month}/${user.joinDate.year}',
        ),
        GenericTableColumn(
          title: 'Status',
          value: (user) => user.isActive ? 'Active' : 'Inactive',
          builder: (user) {
            final status = user.isActive ? 'Active' : 'Inactive';
            final color = user.isActive ? Colors.green : Colors.red;
            
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                status,
                style: TextStyle(
                  color: color,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            );
          },
        ),
      ],
      onRowTap: (user) {
        // Handle user tap
        print('Tapped on user: ${user.name}');
      },
      onRowEdit: (user) {
        // Handle user edit
        print('Edit user: ${user.name}');
      },
      onRowDelete: (user) {
        // Handle user delete
        print('Delete user: ${user.name}');
      },
    );
  }

  Widget _buildOrdersTable() {
    final orders = [
      Order(
        id: 1001,
        customerName: 'Alice Johnson',
        totalAmount: 299.99,
        status: 'Delivered',
        orderDate: DateTime.now().subtract(const Duration(days: 5)),
        paymentMethod: 'Credit Card',
        shippingAddress: '123 Main St, New York, NY',
      ),
      Order(
        id: 1002,
        customerName: 'Bob Smith',
        totalAmount: 149.50,
        status: 'Shipped',
        orderDate: DateTime.now().subtract(const Duration(days: 2)),
        paymentMethod: 'PayPal',
        shippingAddress: '456 Oak Ave, Los Angeles, CA',
      ),
      Order(
        id: 1003,
        customerName: 'Carol Davis',
        totalAmount: 89.99,
        status: 'Processing',
        orderDate: DateTime.now(),
        paymentMethod: 'Debit Card',
        shippingAddress: '789 Pine Rd, Chicago, IL',
      ),
    ];

    return GenericTableView<Order>(
      title: 'Orders',
      data: orders,
      columns: [
        GenericTableColumn(
          title: 'Order ID',
          value: (order) => order.id,
          width: 100,
        ),
        GenericTableColumn(
          title: 'Customer',
          value: (order) => order.customerName,
        ),
        GenericTableColumn(
          title: 'Amount',
          value: (order) => '\$${order.totalAmount.toStringAsFixed(2)}',
        ),
        GenericTableColumn(
          title: 'Status',
          value: (order) => order.status,
          builder: (order) {
            Color statusColor = Colors.grey;
            if (order.status == 'Delivered') {
              statusColor = Colors.green;
            } else if (order.status == 'Shipped') {
              statusColor = Colors.blue;
            } else if (order.status == 'Processing') {
              statusColor = Colors.orange;
            }
            
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                order.status,
                style: TextStyle(
                  color: statusColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            );
          },
        ),
        GenericTableColumn(
          title: 'Order Date',
          value: (order) => '${order.orderDate.day}/${order.orderDate.month}/${order.orderDate.year}',
        ),
        GenericTableColumn(
          title: 'Payment',
          value: (order) => order.paymentMethod,
        ),
      ],
      onRowTap: (order) {
        // Handle order tap
        print('Tapped on order: ${order.id}');
      },
      onRowEdit: (order) {
        // Handle order edit
        print('Edit order: ${order.id}');
      },
      onRowDelete: (order) {
        // Handle order delete
        print('Delete order: ${order.id}');
      },
    );
  }
}
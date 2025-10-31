# Generic Table View Documentation

## Overview

The `GenericTableView` is a flexible Flutter widget that can display any type of data in a tabular format. Unlike the previous implementation which was specific to Leads, this generic version can handle any data model.

## Features

- **Generic Type Support**: Works with any data type `<T>`
- **Customizable Columns**: Define columns with custom rendering
- **Search Functionality**: Built-in search across all columns
- **Responsive Design**: Adapts to different screen sizes
- **Action Buttons**: Support for edit and delete actions
- **Custom Widths**: Set specific widths for columns
- **Dark Mode Support**: Automatically adapts to theme

## Usage

### Basic Implementation

```dart
GenericTableView<YourDataType>(
  title: 'Your Data Title',
  data: yourDataList,
  columns: [
    GenericTableColumn(
      title: 'Column Name',
      value: (item) => item.propertyName,
    ),
  ],
)
```

### Advanced Implementation with Custom Rendering

```dart
GenericTableView<YourDataType>(
  title: 'Your Data Title',
  data: yourDataList,
  columns: [
    GenericTableColumn(
      title: 'ID',
      value: (item) => item.id,
      width: 60, // Custom width
    ),
    GenericTableColumn(
      title: 'Name',
      value: (item) => item.name,
      builder: (item) => Row(
        children: [
          CircleAvatar(child: Text(item.name[0])),
          Text(item.name),
        ],
      ),
    ),
    GenericTableColumn(
      title: 'Status',
      value: (item) => item.status,
      builder: (item) => Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: getStatusColor(item.status),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(item.status),
      ),
    ),
  ],
  onRowTap: (item) => handleRowTap(item),
  onRowEdit: (item) => handleEdit(item),
  onRowDelete: (item) => handleDelete(item),
)
```

## Parameters

### GenericTableView

| Parameter | Type | Description |
|-----------|------|-------------|
| `data` | `List<T>` | The data to display in the table |
| `columns` | `List<GenericTableColumn<T>>` | Column definitions |
| `title` | `String` | Table title |
| `showSearch` | `bool` | Show/hide search bar (default: true) |
| `showFilter` | `bool` | Show/hide filter button (default: true) |
| `showExport` | `bool` | Show/hide export button (default: true) |
| `onRowTap` | `Function(T)?` | Callback when row is tapped |
| `onRowEdit` | `Function(T)?` | Callback when edit button is pressed |
| `onRowDelete` | `Function(T)?` | Callback when delete button is pressed |
| `emptyWidget` | `Widget?` | Widget to show when no data |
| `isLoading` | `bool` | Show loading indicator |
| `searchHint` | `String?` | Custom search hint text |

### GenericTableColumn

| Parameter | Type | Description |
|-----------|------|-------------|
| `title` | `String` | Column header text |
| `value` | `Function(T)` | Function to extract value from data item |
| `builder` | `Widget Function(T)?` | Custom widget builder for cell content |
| `width` | `double?` | Custom column width |

## Examples

### Example 1: Simple Product List

```dart
class Product {
  final int id;
  final String name;
  final double price;
  
  Product({required this.id, required this.name, required this.price});
}

final products = [
  Product(id: 1, name: 'iPhone', price: 999.99),
  Product(id: 2, name: 'MacBook', price: 1299.99),
];

GenericTableView<Product>(
  title: 'Products',
  data: products,
  columns: [
    GenericTableColumn(title: 'ID', value: (p) => p.id),
    GenericTableColumn(title: 'Name', value: (p) => p.name),
    GenericTableColumn(title: 'Price', value: (p) => '\$${p.price}'),
  ],
)
```

### Example 2: User List with Custom Rendering

```dart
class User {
  final int id;
  final String name;
  final bool isActive;
  
  User({required this.id, required this.name, required this.isActive});
}

final users = [
  User(id: 1, name: 'John Doe', isActive: true),
  User(id: 2, name: 'Jane Smith', isActive: false),
];

GenericTableView<User>(
  title: 'Users',
  data: users,
  columns: [
    GenericTableColumn(title: 'ID', value: (u) => u.id),
    GenericTableColumn(
      title: 'Name',
      value: (u) => u.name,
      builder: (u) => Row(
        children: [
          Icon(u.isActive ? Icons.check_circle : Icons.cancel),
          Text(u.name),
        ],
      ),
    ),
    GenericTableColumn(
      title: 'Status',
      value: (u) => u.isActive ? 'Active' : 'Inactive',
    ),
  ],
)
```

## Best Practices

1. **Performance**: For large datasets, consider pagination or virtualization
2. **Responsive Design**: Use relative widths for better screen adaptation
3. **Accessibility**: Provide meaningful column titles and values
4. **Customization**: Use the `builder` parameter for complex cell content
5. **Type Safety**: Leverage Dart's generics for compile-time type checking

## Customization

You can customize the appearance by:
- Setting custom column widths
- Using the `builder` parameter for custom cell widgets
- Providing a custom `emptyWidget`
- Modifying the search hint text
- Enabling/disabling features like search, filter, export

## Migration from StandardTableView

If you're migrating from `StandardTableView`:

1. Replace `StandardTableView` with `GenericTableView`
2. Replace `TableColumn` with `GenericTableColumn`
3. Update import statements
4. The API is nearly identical, so most code will work with minimal changes

## Support

For issues or feature requests, please contact the development team.
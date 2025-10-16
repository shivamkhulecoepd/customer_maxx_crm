import 'package:flutter/material.dart';

class ModernTableView<T> extends StatefulWidget {
  final List<T> data;
  final List<TableColumn> columns;
  final String title;
  final bool showSearch;
  final bool showFilter;
  final bool showExport;
  final Function(T)? onRowTap;
  final Function(T)? onRowEdit;
  final Function(T)? onRowDelete;
  final Widget? emptyWidget;
  final bool isLoading;

  const ModernTableView({
    super.key,
    required this.data,
    required this.columns,
    required this.title,
    this.showSearch = true,
    this.showFilter = true,
    this.showExport = true,
    this.onRowTap,
    this.onRowEdit,
    this.onRowDelete,
    this.emptyWidget,
    this.isLoading = false,
  });

  @override
  State<ModernTableView<T>> createState() => _ModernTableViewState<T>();
}

class _ModernTableViewState<T> extends State<ModernTableView<T>> {
  String _searchQuery = '';
  List<T> _filteredData = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filteredData = List<T>.from(widget.data);
  }

  @override
  void didUpdateWidget(ModernTableView<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.data != widget.data) {
      _filteredData = List<T>.from(widget.data);
      _filterData();
    }
  }

  void _filterData() {
    setState(() {
      if (_searchQuery.isEmpty) {
        _filteredData = List<T>.from(widget.data);
      } else {
        _filteredData = widget.data.where((item) {
          return widget.columns.any((column) {
            final value = column.value(item);
            return value.toString().toLowerCase().contains(
              _searchQuery.toLowerCase(),
            );
          });
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      color: isDarkMode ? const Color(0xFF1A1A1A) : Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTableHeader(context, isDarkMode),
          if (widget.showSearch) _buildSearchBar(context, isDarkMode),
          Expanded(
            child: widget.isLoading
                ? _buildLoadingWidget()
                : _filteredData.isEmpty
                    ? _buildEmptyWidget()
                    : _buildHorizontalScrollTable(isDarkMode),
          ),
        ],
      ),
    );
  }

  Widget _buildHorizontalScrollTable(bool isDarkMode) {
    // Calculate total table width
    final totalWidth = _calculateTotalTableWidth();

    return Scrollbar(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SizedBox(
          width: totalWidth,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTableHeaderRow(isDarkMode, totalWidth),
              SizedBox(
                height: 400,
                child: ListView.builder(
                  itemCount: _filteredData.length,
                  itemBuilder: (context, index) {
                    return _buildTableRow(_filteredData[index], index, isDarkMode, totalWidth);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  double _calculateTotalTableWidth() {
    // Sum of all column widths + actions column if present
    double totalWidth = widget.columns.fold(0.0, (sum, column) => sum + _getColumnWidth(column));
    if (widget.onRowEdit != null || widget.onRowDelete != null) {
      totalWidth += 100; // Actions column width
    }
    // Add padding (32px) to account for the horizontal padding in the container
    totalWidth += 32; // 16px left padding + 16px right padding
    // Ensure minimum width to prevent layout issues
    final minWidth = MediaQuery.of(context).size.width;
    return totalWidth < minWidth ? minWidth : totalWidth;
  }

  Widget _buildTableHeaderRow(bool isDarkMode, double totalWidth) {
    return Container(
      width: totalWidth,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF2D2D2D) : const Color(0xFFF8FAFC),
        border: Border(
          bottom: BorderSide(
            color: isDarkMode
                ? Colors.white.withValues(alpha: 0.1)
                : Colors.grey.withValues(alpha: 0.2),
          ),
        ),
      ),
      child: Row(
        children: [
          ...widget.columns.map(
            (col) => SizedBox(
              width: _getColumnWidth(col),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  col.title,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: isDarkMode ? Colors.white : const Color(0xFF1A1A1A),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ),
          if (widget.onRowEdit != null || widget.onRowDelete != null)
            SizedBox(
              width: 100,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  'Actions',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: isDarkMode ? Colors.white : const Color(0xFF1A1A1A),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTableRow(T item, int index, bool isDarkMode, double totalWidth) {
    return GestureDetector(
      onTap: () => widget.onRowTap?.call(item),
      child: Container(
        width: totalWidth,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: index.isEven
              ? (isDarkMode ? const Color(0xFF1A1A1A) : Colors.white)
              : (isDarkMode ? const Color(0xFF242424) : const Color(0xFFFAFAFA)),
          border: Border(
            bottom: BorderSide(
              color: isDarkMode
                  ? Colors.white.withValues(alpha: 0.05)
                  : Colors.grey.withValues(alpha: 0.1),
            ),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ...widget.columns.map(
              (col) => SizedBox(
                width: _getColumnWidth(col),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: col.builder?.call(item) ??
                      Text(
                        col.value(item).toString(),
                        style: TextStyle(
                          fontSize: 14,
                          color: isDarkMode ? Colors.white70 : Colors.grey[800],
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                      ),
                ),
              ),
            ),
            if (widget.onRowEdit != null || widget.onRowDelete != null)
              SizedBox(
                width: 100,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: _buildRowActions(item, isDarkMode),
                ),
              ),
          ],
        ),
      ),
    );
  }

  double _getColumnWidth(TableColumn column) {
    switch (column.title.toLowerCase()) {
      case 'name':
        return 200.0;
      case 'email':
        return 250.0;
      case 'phone':
        return 150.0;
      case 'status':
        return 120.0;
      case 'date':
        return 150.0;
      default:
        return 150.0;
    }
  }

  Widget _buildTableHeader(BuildContext context, bool isDarkMode) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      padding: EdgeInsets.all(screenWidth * 0.04),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.black : const Color(0xFFF8FAFC),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              widget.title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: isDarkMode ? Colors.white : const Color(0xFF1A1A1A),
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (widget.showFilter)
            _buildActionButton(
              context,
              Icons.filter_list_rounded,
              'Filter',
              () => _showFilterDialog(context),
              isDarkMode,
            ),
          if (widget.showExport)
            _buildActionButton(
              context,
              Icons.download_rounded,
              'Export',
              () => _exportData(),
              isDarkMode,
            ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    IconData icon,
    String tooltip,
    VoidCallback onPressed,
    bool isDarkMode,
  ) {
    return Container(
      margin: const EdgeInsets.only(left: 8),
      decoration: BoxDecoration(
        color: isDarkMode
            ? Colors.white.withValues(alpha: 0.1)
            : Colors.grey.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: IconButton(
        icon: Icon(
          icon,
          color: isDarkMode ? Colors.white70 : Colors.grey[700],
          size: 20,
        ),
        onPressed: onPressed,
        tooltip: tooltip,
        padding: const EdgeInsets.all(12),
        constraints: const BoxConstraints(
          minWidth: 44,
          minHeight: 44,
        ),
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context, bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search ${widget.title.toLowerCase()}...',
          prefixIcon: Icon(
            Icons.search_rounded,
            color: isDarkMode ? Colors.white54 : Colors.grey[600],
            size: 24,
          ),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: Icon(
                    Icons.clear_rounded,
                    color: isDarkMode ? Colors.white54 : Colors.grey[600],
                    size: 24,
                  ),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _searchQuery = '';
                    });
                    _filterData();
                  },
                )
              : null,
          filled: true,
          fillColor: isDarkMode
              ? const Color(0xFF2D2D2D)
              : const Color(0xFFF8FAFC),
          enabledBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.zero,
            borderSide: BorderSide.none,
          ),
          focusedBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.zero,
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
          _filterData();
        },
      ),
    );
  }

  Widget _buildRowActions(T item, bool isDarkMode) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.onRowEdit != null)
          SizedBox(
            width: 40,
            child: IconButton(
              icon: const Icon(
                Icons.edit_rounded,
                size: 18,
                color: Color(0xFF00BCD4),
              ),
              onPressed: () => widget.onRowEdit?.call(item),
              padding: EdgeInsets.zero,
            ),
          ),
        if (widget.onRowDelete != null)
          SizedBox(
            width: 40,
            child: IconButton(
              icon: Icon(Icons.delete_rounded, size: 18, color: Colors.red[400]),
              onPressed: () => _showDeleteConfirmation(item),
              padding: EdgeInsets.zero,
            ),
          ),
      ],
    );
  }

  Widget _buildLoadingWidget() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Loading data...'),
        ],
      ),
    );
  }

  Widget _buildEmptyWidget() {
    return widget.emptyWidget ??
        const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.inbox_rounded, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                'No data available',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'There are no items to display at the moment.',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
          ),
        );
  }

  void _showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Options'),
        content: const Text('Filter functionality coming soon...'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _exportData() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Export functionality coming soon...')),
    );
  }

  void _showDeleteConfirmation(T item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: const Text('Are you sure you want to delete this item?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              widget.onRowDelete?.call(item);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class TableColumn {
  final String title;
  final Function(dynamic) value;
  final Widget Function(dynamic)? builder;

  const TableColumn({required this.title, required this.value, this.builder});
}


// import 'package:flutter/material.dart';

// class ModernTableView<T> extends StatefulWidget {
//   final List<T> data;
//   final List<TableColumn> columns;
//   final String title;
//   final bool showSearch;
//   final bool showFilter;
//   final bool showExport;
//   final Function(T)? onRowTap;
//   final Function(T)? onRowEdit;
//   final Function(T)? onRowDelete;
//   final Widget? emptyWidget;
//   final bool isLoading;

//   const ModernTableView({
//     super.key,
//     required this.data,
//     required this.columns,
//     required this.title,
//     this.showSearch = true,
//     this.showFilter = true,
//     this.showExport = true,
//     this.onRowTap,
//     this.onRowEdit,
//     this.onRowDelete,
//     this.emptyWidget,
//     this.isLoading = false,
//   });

//   @override
//   State<ModernTableView<T>> createState() => _ModernTableViewState<T>();
// }

// class _ModernTableViewState<T> extends State<ModernTableView<T>> {
//   String _searchQuery = '';
//   List<T> _filteredData = [];
//   final TextEditingController _searchController = TextEditingController();

//   @override
//   void initState() {
//     super.initState();
//     _filteredData = widget.data;
//   }

//   @override
//   void didUpdateWidget(ModernTableView<T> oldWidget) {
//     super.didUpdateWidget(oldWidget);
//     if (oldWidget.data != widget.data) {
//       _filterData();
//     }
//   }

//   void _filterData() {
//     setState(() {
//       if (_searchQuery.isEmpty) {
//         _filteredData = widget.data;
//       } else {
//         _filteredData = widget.data.where((item) {
//           return widget.columns.any((column) {
//             final value = column.value(item);
//             return value.toString().toLowerCase().contains(
//               _searchQuery.toLowerCase(),
//             );
//           });
//         }).toList();
//       }
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     final isDarkMode = Theme.of(context).brightness == Brightness.dark;

//     return Container(
//       decoration: BoxDecoration(
//         color: isDarkMode ? const Color(0xFF1A1A1A) : Colors.white,
//         // borderRadius: BorderRadius.circular(16),
//         // boxShadow: [
//         //   BoxShadow(
//         //     color: isDarkMode
//         //         ? Colors.black.withValues(alpha: 0.3)
//         //         : Colors.grey.withValues(alpha: 0.1),
//         //     blurRadius: 10,
//         //     offset: const Offset(0, 4),
//         //   ),
//         // ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           _buildTableHeader(context, isDarkMode),
//           if (widget.showSearch) _buildSearchBar(context, isDarkMode),
//           Expanded(
//             child: widget.isLoading
//                 ? _buildLoadingWidget()
//                 : _filteredData.isEmpty
//                 ? _buildEmptyWidget()
//                 : _buildTable(context, isDarkMode),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildTableHeader(BuildContext context, bool isDarkMode) {
//     final width = MediaQuery.of(context).size.width;
//     final padding = width < 360 ? 16.0 : 20.0;
//     final fontSize = width < 360 ? 20.0 : 24.0;
//     final screenWidth = MediaQuery.of(context).size.width;

//     return Container(
//       padding: EdgeInsets.all(screenWidth * 0.04),
//       decoration: BoxDecoration(
//         // color: isDarkMode ? const Color(0xFF2D2D2D) : const Color(0xFFF8FAFC),
//         color: isDarkMode ? Colors.black : const Color(0xFFF8FAFC),
//         // borderRadius: BorderRadius.only(
//         //   topLeft: Radius.circular(width < 360 ? 12 : 16),
//         //   topRight: Radius.circular(width < 360 ? 12 : 16),
//         // ),
//       ),
//       child: Row(
//         children: [
//           Expanded(
//             child: Text(
//               widget.title,
//               style: TextStyle(
//                 fontSize: fontSize,
//                 fontWeight: FontWeight.w600,
//                 color: isDarkMode ? Colors.white : const Color(0xFF1A1A1A),
//               ),
//               overflow: TextOverflow.ellipsis,
//             ),
//           ),
//           if (widget.showFilter)
//             _buildActionButton(
//               context,
//               Icons.filter_list_rounded,
//               'Filter',
//               () => _showFilterDialog(context),
//               isDarkMode,
//             ),
//           if (widget.showExport)
//             _buildActionButton(
//               context,
//               Icons.download_rounded,
//               'Export',
//               () => _exportData(),
//               isDarkMode,
//             ),
//         ],
//       ),
//     );
//   }

//   Widget _buildActionButton(
//     BuildContext context,
//     IconData icon,
//     String tooltip,
//     VoidCallback onPressed,
//     bool isDarkMode,
//   ) {
//     final width = MediaQuery.of(context).size.width;
//     final iconSize = width < 360 ? 18.0 : 20.0;
//     final margin = width < 360 ? 6.0 : 8.0;

//     return Container(
//       margin: EdgeInsets.only(left: margin),
//       decoration: BoxDecoration(
//         color: isDarkMode
//             ? Colors.white.withValues(alpha: 0.1)
//             : Colors.grey.withValues(alpha: 0.1),
//         borderRadius: BorderRadius.circular(width < 360 ? 6 : 8),
//       ),
//       child: IconButton(
//         icon: Icon(
//           icon,
//           color: isDarkMode ? Colors.white70 : Colors.grey[700],
//           size: iconSize,
//         ),
//         onPressed: onPressed,
//         tooltip: tooltip,
//         padding: EdgeInsets.all(width < 360 ? 8 : 12),
//         constraints: BoxConstraints(
//           minWidth: width < 360 ? 36 : 44,
//           minHeight: width < 360 ? 36 : 44,
//         ),
//       ),
//     );
//   }

//   Widget _buildSearchBar(BuildContext context, bool isDarkMode) {
//     final width = MediaQuery.of(context).size.width;
//     final padding = width < 360 ? 16.0 : 20.0;
//     final iconSize = width < 360 ? 20.0 : 24.0;

//     return TextField(
//       controller: _searchController,
//       decoration: InputDecoration(
//         hintText: 'Search ${widget.title.toLowerCase()}...',
//         prefixIcon: Icon(
//           Icons.search_rounded,
//           color: isDarkMode ? Colors.white54 : Colors.grey[600],
//           size: iconSize,
//         ),
//         suffixIcon: _searchQuery.isNotEmpty
//             ? IconButton(
//                 icon: Icon(
//                   Icons.clear_rounded,
//                   color: isDarkMode ? Colors.white54 : Colors.grey[600],
//                   size: iconSize,
//                 ),
//                 onPressed: () {
//                   _searchController.clear();
//                   setState(() {
//                     _searchQuery = '';
//                   });
//                   _filterData();
//                 },
//               )
//             : null,
//         filled: true,
//         fillColor: isDarkMode
//             ? const Color(0xFF2D2D2D)
//             : const Color(0xFFF8FAFC),

//         // 👇 No border radius, no visible border color
//         enabledBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.zero, // Square corners
//           borderSide: BorderSide.none, // Transparent border
//         ),
//         focusedBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.zero,
//           borderSide: BorderSide.none,
//         ),
//         disabledBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.zero,
//           borderSide: BorderSide.none,
//         ),
//         contentPadding: EdgeInsets.symmetric(
//           horizontal: width < 360 ? 12 : 16,
//           vertical: width < 360 ? 10 : 12,
//         ),
//       ),
//       onChanged: (value) {
//         setState(() {
//           _searchQuery = value;
//         });
//         _filterData();
//       },
//     );
//   }

//   Widget _buildTable(BuildContext context, bool isDarkMode) {
//     return ListView.builder(
//       padding: EdgeInsets.zero,
//       itemCount: _filteredData.length + 1,
//       itemBuilder: (context, index) {
//         if (index == 0) {
//           return _buildTableHeaderRow(isDarkMode);
//         }
//         final item = _filteredData[index - 1];
//         return _buildTableRow(item, index - 1, isDarkMode);
//       },
//     );
//   }

//   Widget _buildTableHeaderRow(bool isDarkMode) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//       decoration: BoxDecoration(
//         color: isDarkMode ? const Color(0xFF2D2D2D) : const Color(0xFFF8FAFC),
//         border: Border(
//           bottom: BorderSide(
//             color: isDarkMode
//                 ? Colors.white.withValues(alpha: 0.1)
//                 : Colors.grey.withValues(alpha: 0.2),
//           ),
//         ),
//       ),
//       child: Row(
//         children: widget.columns
//             .map(
//               (col) => Expanded(
//                 child: Text(
//                   col.title,
//                   style: TextStyle(
//                     fontWeight: FontWeight.w600,
//                     fontSize: 14,
//                     color: isDarkMode ? Colors.white : const Color(0xFF1A1A1A),
//                   ),
//                 ),
//               ),
//             )
//             .toList(),
//       ),
//     );
//   }

//   Widget _buildTableRow(T item, int index, bool isDarkMode) {
//     final width = MediaQuery.of(context).size.width;
//     final fontSize = width < 360 ? 13.0 : 14.0;
//     final padding = width < 360 ? 12.0 : 16.0;

//     return GestureDetector(
//       onTap: () => widget.onRowTap?.call(item),
//       child: Container(
//         padding: EdgeInsets.symmetric(horizontal: padding, vertical: 12),
//         decoration: BoxDecoration(
//           color: index.isEven
//               ? (isDarkMode ? const Color(0xFF1A1A1A) : Colors.white)
//               : (isDarkMode
//                     ? const Color(0xFF242424)
//                     : const Color(0xFFFAFAFA)),
//           border: Border(
//             bottom: BorderSide(
//               color: isDarkMode
//                   ? Colors.white.withValues(alpha: 0.05)
//                   : Colors.grey.withValues(alpha: 0.1),
//             ),
//           ),
//         ),
//         child: Row(
//           children: [
//             ...widget.columns.map(
//               (col) => Expanded(
//                 child:
//                     col.builder?.call(item) ??
//                     Text(
//                       col.value(item).toString(),
//                       style: TextStyle(
//                         fontSize: fontSize,
//                         color: isDarkMode ? Colors.white70 : Colors.grey[800],
//                       ),
//                       overflow: TextOverflow.ellipsis,
//                     ),
//               ),
//             ),
//             if (widget.onRowEdit != null || widget.onRowDelete != null)
//               _buildRowActions(item, isDarkMode),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildRowActions(T item, bool isDarkMode) {
//     return Row(
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         if (widget.onRowEdit != null)
//           IconButton(
//             icon: Icon(
//               Icons.edit_rounded,
//               size: 18,
//               color: const Color(0xFF00BCD4),
//             ),
//             onPressed: () => widget.onRowEdit?.call(item),
//           ),
//         if (widget.onRowDelete != null)
//           IconButton(
//             icon: Icon(Icons.delete_rounded, size: 18, color: Colors.red[400]),
//             onPressed: () => _showDeleteConfirmation(item),
//           ),
//       ],
//     );
//   }

//   Widget _buildLoadingWidget() {
//     return const Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           CircularProgressIndicator(),
//           SizedBox(height: 16),
//           Text('Loading data...'),
//         ],
//       ),
//     );
//   }

//   Widget _buildEmptyWidget() {
//     return widget.emptyWidget ??
//         Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Icon(Icons.inbox_rounded, size: 64, color: Colors.grey[400]),
//               const SizedBox(height: 16),
//               Text(
//                 'No data available',
//                 style: TextStyle(
//                   fontSize: 18,
//                   fontWeight: FontWeight.w500,
//                   color: Colors.grey[600],
//                 ),
//               ),
//               const SizedBox(height: 8),
//               Text(
//                 'There are no items to display at the moment.',
//                 style: TextStyle(fontSize: 14, color: Colors.grey[500]),
//               ),
//             ],
//           ),
//         );
//   }

//   void _showFilterDialog(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Filter Options'),
//         content: const Text('Filter functionality coming soon...'),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('Close'),
//           ),
//         ],
//       ),
//     );
//   }

//   void _exportData() {
//     // Export functionality
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(content: Text('Export functionality coming soon...')),
//     );
//   }

//   void _showDeleteConfirmation(T item) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Confirm Delete'),
//         content: const Text('Are you sure you want to delete this item?'),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('Cancel'),
//           ),
//           TextButton(
//             onPressed: () {
//               Navigator.pop(context);
//               widget.onRowDelete?.call(item);
//             },
//             child: const Text('Delete'),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class TableColumn {
//   final String title;
//   final Function(dynamic) value;
//   final Widget Function(dynamic)? builder;

//   const TableColumn({required this.title, required this.value, this.builder});
// }

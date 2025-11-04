import 'package:flutter/material.dart';
import 'package:customer_maxx_crm/models/lead.dart';

/// A generic table view that can display any kind of data
class GenericTableView<T> extends StatefulWidget {
  final List<T> data;
  final List<GenericTableColumn<T>> columns;
  final String title;
  final bool showSearch;
  final bool showFilter;
  final bool showExport;
  final Function(T)? onRowTap;
  final Function(T)? onRowEdit;
  final Function(T)? onRowDelete;
  final Widget? emptyWidget;
  final bool isLoading;
  final String? searchHint;
  final List<String>? filterOptions; // New parameter for filter options
  final Function(String)? onFilterChanged; // New parameter for filter callback

  const GenericTableView({
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
    this.searchHint,
    this.filterOptions, // New parameter
    this.onFilterChanged, // New parameter
  });

  @override
  State<GenericTableView<T>> createState() => _GenericTableViewState<T>();
}

class _GenericTableViewState<T> extends State<GenericTableView<T>> {
  String _searchQuery = '';
  String _selectedFilter = 'All'; // New filter state
  List<T> _filteredData = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filteredData = List<T>.from(widget.data);
  }

  @override
  void didUpdateWidget(GenericTableView<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.data != widget.data) {
      _filteredData = List<T>.from(widget.data);
      _filterData();
    }
  }

  void _filterData() {
    setState(() {
      if (_searchQuery.isEmpty && _selectedFilter == 'All') {
        _filteredData = List<T>.from(widget.data);
      } else {
        _filteredData = widget.data.where((item) {
          bool matchesSearch = true;
          bool matchesFilter = true;

          // Apply search filter
          if (_searchQuery.isNotEmpty) {
            matchesSearch = widget.columns.any((column) {
              final value = column.value(item);
              return value.toString().toLowerCase().contains(
                _searchQuery.toLowerCase(),
              );
            });
          }

          // Apply status filter
          if (_selectedFilter != 'All' && T == Lead) {
            // Special handling for Lead objects
            final lead = item as Lead;
            matchesFilter = lead.status == _selectedFilter;
          }

          return matchesSearch && matchesFilter;
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final screen = MediaQuery.of(context).size;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // Wrap the entire table in a scrollable widget for refresh indicator support
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Container(
        color: isDarkMode ? const Color(0xFF1A1A1A) : Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTableHeader(context, isDarkMode, screen),
            if (widget.showSearch) _buildSearchBar(context, isDarkMode, screen),
            widget.isLoading
                ? _buildLoadingWidget()
                : _filteredData.isEmpty
                ? _buildEmptyWidget()
                : _buildHorizontalScrollTable(isDarkMode, screen),
          ],
        ),
      ),
    );
  }

  Widget _buildHorizontalScrollTable(bool isDarkMode, Size screen) {
    final totalWidth = _calculateTotalTableWidth(screen);

    return Scrollbar(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SizedBox(
          width: totalWidth,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTableHeaderRow(isDarkMode, totalWidth, screen),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _filteredData.length,
                itemBuilder: (context, index) {
                  return _buildTableRow(
                    _filteredData[index],
                    index,
                    isDarkMode,
                    totalWidth,
                    screen,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  double _calculateTotalTableWidth(Size screen) {
    double totalWidth = widget.columns.fold(
      0.0,
      (sum, column) => sum + _getColumnWidth(column, screen),
    );
    if (widget.onRowEdit != null || widget.onRowDelete != null) {
      totalWidth +=
          screen.width * 0.18; // increased action column width responsive
    }
    totalWidth += screen.width * 0.08; // left-right padding
    return totalWidth < screen.width ? screen.width : totalWidth;
  }

  Widget _buildTableHeaderRow(bool isDarkMode, double totalWidth, Size screen) {
    return Container(
      width: totalWidth,
      padding: EdgeInsets.symmetric(
        horizontal: screen.width * 0.04,
        vertical: screen.height * 0.015,
      ),
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
              width: _getColumnWidth(col, screen),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: screen.width * 0.02),
                child: Text(
                  col.title,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: screen.width * 0.035,
                    color: isDarkMode ? Colors.white : const Color(0xFF1A1A1A),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ),
          if (widget.onRowEdit != null || widget.onRowDelete != null)
            SizedBox(
              width: screen.width * 0.18,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: screen.width * 0.02),
                child: Text(
                  'Actions',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: screen.width * 0.035,
                    color: isDarkMode ? Colors.white : const Color(0xFF1A1A1A),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTableRow(
    T item,
    int index,
    bool isDarkMode,
    double totalWidth,
    Size screen,
  ) {
    return GestureDetector(
      onTap: () => widget.onRowTap?.call(item),
      child: Container(
        width: totalWidth,
        padding: EdgeInsets.symmetric(
          horizontal: screen.width * 0.04,
          vertical: screen.height * 0.015,
        ),
        decoration: BoxDecoration(
          color: index.isEven
              ? (isDarkMode ? const Color(0xFF1A1A1A) : Colors.white)
              : (isDarkMode
                    ? const Color(0xFF242424)
                    : const Color(0xFFFAFAFA)),
          border: Border(
            bottom: BorderSide(
              color: isDarkMode
                  ? Colors.white.withValues(alpha: 0.05)
                  : Colors.grey.withValues(alpha: 0.1),
            ),
          ),
        ),
        child: Row(
          children: [
            ...widget.columns.map(
              (col) => SizedBox(
                width: _getColumnWidth(col, screen),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: screen.width * 0.02,
                  ),
                  child:
                      col.builder?.call(item) ??
                      Text(
                        col.value(item).toString(),
                        style: TextStyle(
                          fontSize: screen.width * 0.035,
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
                width: screen.width * 0.18,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: screen.width * 0.02,
                  ),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: _buildRowActions(item, isDarkMode),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  double _getColumnWidth(GenericTableColumn<T> column, Size screen) {
    // If column has a custom width, use it
    if (column.width != null) {
      return column.width!;
    }

    // Otherwise, use default width based on title (reduced to prevent overflow)
    switch (column.title.toLowerCase()) {
      case 'name':
        return screen.width * 0.25;
      case 'email':
        return screen.width * 0.25;
      case 'phone':
        return screen.width * 0.15;
      case 'status':
        return screen.width * 0.15;
      case 'date':
        return screen.width * 0.2;
      default:
        return screen.width * 0.2;
    }
  }

  Widget _buildTableHeader(BuildContext context, bool isDarkMode, Size screen) {
    return Container(
      padding: EdgeInsets.all(screen.width * 0.04),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.black : const Color(0xFFF8FAFC),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              widget.title,
              style: TextStyle(
                fontSize: screen.width * 0.05,
                fontWeight: FontWeight.w600,
                color: isDarkMode ? Colors.white : const Color(0xFF1A1A1A),
              ),
            ),
          ),
          if (widget.showFilter)
            _buildActionButton(
              Icons.filter_list_rounded,
              'Filter',
              () => _showFilterDialog(context),
              isDarkMode,
              screen,
            ),
          if (widget.showExport)
            _buildActionButton(
              Icons.download_rounded,
              'Export',
              _exportData,
              isDarkMode,
              screen,
            ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    IconData icon,
    String tooltip,
    VoidCallback onPressed,
    bool isDarkMode,
    Size screen,
  ) {
    return Container(
      margin: EdgeInsets.only(left: screen.width * 0.02),
      decoration: BoxDecoration(
        color: isDarkMode
            ? Colors.white.withValues(alpha: 0.1)
            : Colors.grey.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(screen.width * 0.02),
      ),
      child: IconButton(
        icon: Icon(
          icon,
          color: isDarkMode ? Colors.white70 : Colors.grey[700],
          size: screen.width * 0.05,
        ),
        onPressed: onPressed,
        tooltip: tooltip,
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context, bool isDarkMode, Size screen) {
    return Padding(
      padding: EdgeInsets.all(screen.width * 0.04),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText:
              widget.searchHint ?? 'Search ${widget.title.toLowerCase()}...',
          prefixIcon: Icon(
            Icons.search_rounded,
            color: isDarkMode ? Colors.white54 : Colors.grey[600],
            size: screen.width * 0.06,
          ),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: Icon(
                    Icons.clear_rounded,
                    color: isDarkMode ? Colors.white54 : Colors.grey[600],
                    size: screen.width * 0.06,
                  ),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _searchQuery = '');
                    _filterData();
                  },
                )
              : null,
          filled: true,
          fillColor: isDarkMode
              ? const Color(0xFF2D2D2D)
              : const Color(0xFFF8FAFC),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: screen.width * 0.04,
            vertical: screen.height * 0.015,
          ),
        ),
        onChanged: (value) {
          setState(() => _searchQuery = value);
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
          IconButton(
            icon: const Icon(Icons.edit_rounded, color: Color(0xFF00BCD4)),
            onPressed: () => widget.onRowEdit?.call(item),
            iconSize: 18,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        if (widget.onRowDelete != null)
          IconButton(
            icon: Icon(Icons.delete_rounded, color: Colors.red[400]),
            onPressed: () => _showDeleteConfirmation(item),
            iconSize: 18,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
      ],
    );
  }

  Widget _buildLoadingWidget() =>
      const Center(child: CircularProgressIndicator());

  Widget _buildEmptyWidget() =>
      widget.emptyWidget ??
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
          ],
        ),
      );

  void _showFilterDialog(BuildContext context) {
    // If specific filter options are provided, use them
    List<String> filterOptions = ['All'];
    if (widget.filterOptions != null && widget.filterOptions!.isNotEmpty) {
      filterOptions.addAll(widget.filterOptions!);
    } else if (T == Lead) {
      // Default lead status options
      filterOptions.addAll([
        'Not Connected',
        'Follow-up Planned',
        'Follow-up Completed',
        'Demo Attended',
        'Warm Lead',
        'Hot Lead',
        'Converted',
      ]);
    } else {
      // Generic options
      filterOptions.addAll(['Option 1', 'Option 2', 'Option 3']);
    }

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Filter by Status'),
            content: SizedBox(
              width: double.maxFinite,
              child: RadioGroup<String>(
                groupValue: _selectedFilter,
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedFilter = value;
                    });
                  }
                },
                child: ListView(
                  shrinkWrap: true,
                  children: filterOptions.map((option) {
                    return RadioListTile<String>.adaptive(
                      title: Text(option),
                      value: option,
                    );
                  }).toList(),
                ),
              ),
            ),
            actions: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      // Reset filter
                      setState(() {
                        _selectedFilter = 'All';
                      });
                      _filterData();
                    },
                    child: const Text('Reset'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('Cancel'),
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _filterData();
                  // Call the external filter callback if provided
                  if (widget.onFilterChanged != null) {
                    widget.onFilterChanged!(_selectedFilter);
                  }
                },
                child: const Text('Apply'),
              ),
            ],
          );
        },
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

/// Represents a column in the generic table
class GenericTableColumn<T> {
  final String title;
  final Function(T) value;
  final Widget Function(T)? builder;
  final double? width;

  const GenericTableColumn({
    required this.title,
    required this.value,
    this.builder,
    this.width,
  });
}

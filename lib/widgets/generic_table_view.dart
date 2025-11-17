import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:customer_maxx_crm/models/lead.dart';
import 'package:flutter/foundation.dart';

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
    log('GenericTableView initState - Data length: ${widget.data.length}');
    _filteredData = List<T>.from(widget.data);
    _searchController.addListener(_onSearchChanged);
    log('GenericTableView initState - Filtered data length: ${_filteredData.length}');
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text;
    });
    _filterData();
  }

  void _filterData() {
    log('GenericTableView _filterData - Search query: $_searchQuery, Selected filter: $_selectedFilter');
    setState(() {
      if (_searchQuery.isEmpty && _selectedFilter == 'All') {
        log('GenericTableView _filterData - No filters, using all data');
        _filteredData = List<T>.from(widget.data);
      } else {
        log('GenericTableView _filterData - Applying filters');
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

          log('GenericTableView _filterData - Item matches search: $matchesSearch, matches filter: $matchesFilter');
          return matchesSearch && matchesFilter;
        }).toList();
      }
      log('GenericTableView _filterData - Filtered data length: ${_filteredData.length}');
    });
  }

  @override
  void didUpdateWidget(GenericTableView<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    log('GenericTableView didUpdateWidget - Old data length: ${oldWidget.data.length}, New data length: ${widget.data.length}');
    // Only update filtered data if the data actually changed
    if (!listEquals(oldWidget.data, widget.data)) {
      _filteredData = List<T>.from(widget.data);
      _filterData();
    }
  }

  @override
  Widget build(BuildContext context) {
    final screen = MediaQuery.of(context).size;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    log('GenericTableView build - Data length: ${widget.data.length}, Filtered data length: ${_filteredData.length}');
    log('GenericTableView build - Is loading: ${widget.isLoading}');

    // Wrap the entire table in a scrollable widget for refresh indicator support
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Container(
        padding: EdgeInsets.only(bottom: screen.height * 0.08),
        color: isDarkMode ? const Color(0xFF1A1A1A) : Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTableHeader(context, isDarkMode, screen),
            if (widget.showSearch) _buildSearchBar(context, isDarkMode, screen),
            widget.isLoading
                ? _buildLoadingWidget()
                : _filteredData.isEmpty && widget.data.isNotEmpty
                ? _buildEmptySearchResultWidget(context)
                : _filteredData.isEmpty
                ? _buildEmptyWidget(context)
                : _buildHorizontalScrollTable(isDarkMode, screen),
          ],
        ),
      ),
    );
  }

  Widget _buildHorizontalScrollTable(bool isDarkMode, Size screen) {
    final totalWidth = _calculateTotalTableWidth(screen);
    
    log('GenericTableView _buildHorizontalScrollTable - Total width: $totalWidth, Screen width: ${screen.width}');
    log('GenericTableView _buildHorizontalScrollTable - Filtered data length: ${_filteredData.length}');

    // Always allow horizontal scrolling to prevent overflow
    return Scrollbar(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SizedBox(
          width: totalWidth < screen.width ? screen.width : totalWidth,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTableHeaderRow(isDarkMode, totalWidth, screen),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _filteredData.length,
                itemBuilder: (context, index) {
                  log('GenericTableView building row $index');
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
    
    log('GenericTableView _calculateTotalTableWidth - Columns: ${widget.columns.length}, Initial width: $totalWidth');

    // Calculate action column width based on number of actions
    int actionCount = 0;
    if (widget.onRowEdit != null) actionCount++;
    if (widget.onRowDelete != null) actionCount++;

    if (actionCount > 0) {
      // Each action needs ~50px + some padding
      double actionColumnWidth = actionCount * 50.0 + 20.0;
      totalWidth += actionColumnWidth;
      log('GenericTableView _calculateTotalTableWidth - Added action column width: $actionColumnWidth');
    }

    totalWidth += screen.width * 0.08; // left-right padding
    log('GenericTableView _calculateTotalTableWidth - Final width: $totalWidth, Screen width: ${screen.width}');
    return totalWidth < screen.width ? screen.width : totalWidth;
  }

  double _getColumnWidth(GenericTableColumn<T> column, Size screen) {
    // If column has a custom width, use it
    if (column.width != null) {
      log('GenericTableView _getColumnWidth - Using custom width: ${column.width}');
      return column.width!;
    }

    // Otherwise, use default width based on title (reduced to prevent overflow)
    switch (column.title.toLowerCase()) {
      case 'name':
        log('GenericTableView _getColumnWidth - Using name width: ${screen.width * 0.25}');
        return screen.width * 0.25;
      case 'email':
        log('GenericTableView _getColumnWidth - Using email width: ${screen.width * 0.25}');
        return screen.width * 0.25;
      case 'phone':
        log('GenericTableView _getColumnWidth - Using phone width: ${screen.width * 0.15}');
        return screen.width * 0.15;
      case 'status':
        log('GenericTableView _getColumnWidth - Using status width: ${screen.width * 0.15}');
        return screen.width * 0.15;
      case 'date':
        log('GenericTableView _getColumnWidth - Using date width: ${screen.width * 0.2}');
        return screen.width * 0.2;
      default:
        log('GenericTableView _getColumnWidth - Using default width: ${screen.width * 0.2}');
        return screen.width * 0.2;
    }
  }

  Widget _buildTableHeaderRow(bool isDarkMode, double totalWidth, Size screen) {
    log('GenericTableView _buildTableHeaderRow - Building header row, Total width: $totalWidth, Columns: ${widget.columns.length}');
    
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
            LayoutBuilder(
              builder: (context, constraints) {
                int actionCount = 0;
                if (widget.onRowEdit != null) actionCount++;
                if (widget.onRowDelete != null) actionCount++;

                double actionColumnWidth = actionCount * 50.0 + 20.0;

                return SizedBox(
                  width: actionColumnWidth,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Text(
                      'Actions',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: screen.width * 0.035,
                        color: isDarkMode
                            ? Colors.white
                            : const Color(0xFF1A1A1A),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                );
              },
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
    log('GenericTableView _buildTableRow - Building row $index');
    
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
              LayoutBuilder(
                builder: (context, constraints) {
                  int actionCount = 0;
                  if (widget.onRowEdit != null) actionCount++;
                  if (widget.onRowDelete != null) actionCount++;

                  double actionColumnWidth = actionCount * 50.0 + 20.0;

                  return SizedBox(
                    width: actionColumnWidth,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: _buildRowActions(item, isDarkMode),
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
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
            padding: const EdgeInsets.all(4),
            constraints: const BoxConstraints.tightFor(width: 40, height: 40),
          ),
        if (widget.onRowDelete != null)
          IconButton(
            icon: Icon(Icons.delete_rounded, color: Colors.red[400]),
            onPressed: () => _showDeleteConfirmation(item),
            iconSize: 18,
            padding: const EdgeInsets.all(4),
            constraints: const BoxConstraints.tightFor(width: 40, height: 40),
          ),
      ],
    );
  }

  Widget _buildLoadingWidget() {
    log('GenericTableView _buildLoadingWidget - Building loading widget');
    return const Center(child: CircularProgressIndicator());
  }

  Widget _buildEmptyWidget(BuildContext context) {
    log('GenericTableView _buildEmptyWidget - Building empty widget');
    return widget.emptyWidget ??
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.62,
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
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
  }

  Widget _buildEmptySearchResultWidget(BuildContext context) {
    log('GenericTableView _buildEmptySearchResultWidget - Building empty search result widget');
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.62,
      width: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.search_off_rounded, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          const Text(
            'No matching results found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () {
              _searchController.clear();
              setState(() => _searchQuery = '');
              _filterData();
            },
            child: const Text('Clear search'),
          ),
        ],
      ),
    );
  }

  void _showFilterDialog(BuildContext context) {
    // If specific filter options are provided, use them
    List<String> filterOptions = ['All'];
    if (widget.filterOptions != null && widget.filterOptions!.isNotEmpty) {
      filterOptions.addAll(widget.filterOptions!);
    } else if (T == Lead) {
      // Default lead status options
      filterOptions.addAll([
        'Pending',
        'Connected',
        'Not Connected',
        'Demo Interested',
        'Demo Attended',
        'Follow Up Planned',
        'Follow Up Completed',
        'Converted Warm Lead',
        'Converted Hot Lead',
        'Registered',
      ]);
    } else {
      // Generic options
      filterOptions.addAll(['Option 1', 'Option 2', 'Option 3']);
    }

    String tempSelectedFilter = _selectedFilter;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Filter by Status'),
            content: SizedBox(
              width: double.maxFinite,
              child: ListView(
                shrinkWrap: true,
                children: filterOptions.map((option) {
                  return RadioListTile<String>.adaptive(
                    title: Text(option),
                    value: option,
                    groupValue: tempSelectedFilter,
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          tempSelectedFilter = value;
                        });
                      }
                    },
                  );
                }).toList(),
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
                  setState(() {
                    _selectedFilter = tempSelectedFilter;
                  });
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

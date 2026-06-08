import 'package:flutter/material.dart';

class LocationSearchBar extends StatefulWidget {
  final ValueChanged<String> onChanged;
  final String hintText;
  const LocationSearchBar({
    super.key,
    required this.onChanged,
    this.hintText = "Search locations...",
  });
  @override
  State<LocationSearchBar> createState() => _LocationSearchBarState();
}

class _LocationSearchBarState extends State<LocationSearchBar> {
  final TextEditingController _controller = TextEditingController();
  bool _showClearButton = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    // forward the text changes to the parent widget
    widget.onChanged(_controller.text);
    // Show or hide the clear button based on whether there's text
    setState(() {
      _showClearButton = _controller.text.isNotEmpty;
    });
  }

  @override
  void dispose() {
    _controller.dispose(); // Prevents memory leaks
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: SearchBar(
        controller: _controller,
        hintText: widget.hintText,
        trailing: _showClearButton
          ? [
              IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () => _controller.clear(),
              )
            ]
          : null,
      ),  
    );
}
}

/*
      child: SearchBar(
        controller: _searchController,
        hintText: 'Search locations',
        trailing: _searchQuery.isNotEmpty
          ? [
              IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () => _searchController.clear(),
              )
            ]
          : null,
      ),
      */
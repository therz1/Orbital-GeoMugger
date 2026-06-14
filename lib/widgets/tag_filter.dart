import 'package:flutter/material.dart';

class TagFilter extends StatefulWidget {
  final Map<String, List<String>> tagMap;
  final List<String> initialSelectedTags;

  const TagFilter({
    super.key,
    required this.tagMap,
    required this.initialSelectedTags,
  });

  @override
  State<TagFilter> createState() => _TagFilterState();
}

class _TagFilterState extends State<TagFilter> {
  final List<String> _localSelectedTags = [];
  String _tagSearchQuery = '';

  @override
  void initState() {
    super.initState();
    _localSelectedTags.addAll(widget.initialSelectedTags);
  }

  @override
  Widget build(BuildContext context) {
    final List<String> allUniqueTags = widget.tagMap.values.expand((tagList) => tagList).toSet().toList();
    final List<String> filteredTags = allUniqueTags
    .where((tagName) => tagName.toLowerCase().contains(_tagSearchQuery.toLowerCase()))
    .toList();
    return AlertDialog(
      title: const Text('Filter by Tags'),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(
                hintText: 'Type tag name',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (val) {
                setState(() => _tagSearchQuery = val);
              },
              ),
              const SizedBox(height: 16),

              Expanded(
                child: SingleChildScrollView(
                  child: Wrap(
                    spacing: 6.0,
                    runSpacing: 6.0,
                    children: filteredTags.map((tagName) {
                      final isSelected = _localSelectedTags.contains(tagName);
                      return FilterChip(
                        label: Text(tagName),
                        selected: isSelected,
                        showCheckmark: true,
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              _localSelectedTags.add(tagName);
                            } else {
                              _localSelectedTags.remove(tagName);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
                ),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
          onPressed: () {
            Navigator.pop(context, _localSelectedTags);
          },
          child: const Text('Apply Filters', style: TextStyle(color: Colors.white)),
        )
      ],
    );
  }
}

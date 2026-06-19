import 'package:flutter/material.dart';

class TagSelection extends StatelessWidget {
  final String categoryTitle;
  final List<String> tags;
  final List<Map<String, String>> selectedTags;
  final Function(Map<String, String>) onTagsAdded;
  final Function(String) onTagRemoved;
  final Color Function(String) getTagColor;

  const TagSelection({
    super.key,
    required this.categoryTitle,
    required this.tags,
    required this.selectedTags,
    required this.onTagsAdded,
    required this.onTagRemoved,
    required this.getTagColor,
  });
  @override
  Widget build(BuildContext context) {
    if(tags.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Text(
          categoryTitle,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8.0,
          runSpacing: 8.0,
          children: tags.map((tagName) {
            final bool isSelected = selectedTags.any((t) => t['name'] ==  tagName);
            return FilterChip(
              label: Text(tagName, style: TextStyle(color: isSelected? Colors.white: Colors.black, fontSize: 13),),
              selected: isSelected,
              onSelected: (bool selected) {
                if (selected) {
                  onTagsAdded({'name': tagName, 'category': categoryTitle});
                } else{
                  onTagRemoved(tagName);
                }
              },
          backgroundColor: Colors.grey,
          selectedColor: getTagColor(categoryTitle),
          showCheckmark: false,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: isSelected? Colors.transparent: Colors.grey),
          ),
          );
  }).toList(),
  ),
  ],
  );
  }
}

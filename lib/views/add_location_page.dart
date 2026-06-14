import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart' ;
import '../services/location_service.dart';
import '../widgets/tag_selection.dart';

class AddLocationPage extends StatefulWidget {
  final String locationId;
  const AddLocationPage({super.key, required this.locationId});
  

  @override
  State<AddLocationPage> createState() => _AddLocationPageState();
}

class _AddLocationPageState extends State<AddLocationPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _locationNameController = TextEditingController();
  final TextEditingController _reviewController = TextEditingController();

  int _currentRating = 0; // Default rating value
  bool _isSaving  = false;
  bool _isLoadingTags = true;
  
  //create a tagMap to store categories and tags
  Map<String, List<String>> _tagMap = {};

  final List<Map<String, String>> _selectedTags = [];

    Color _tagColor(String cateogry) {
    switch(cateogry) {
      case 'Vibes':
        return const Color.fromARGB(255, 2, 224, 254);
      case 'Amenities':
        return const Color.fromARGB(255, 255, 153, 0);
      case 'Facilities near-by':
        return const Color.fromARGB(255, 112, 187, 69);
      default:
        return Colors.transparent;
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchTags();
  }

  @override
  void dispose() {
    _locationNameController.dispose();
    _reviewController.dispose();
    super.dispose();
  }

  Future<void> _fetchTags() async {
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance.collection('metadata').doc('tags_list').get();
      if(doc.exists) {
        setState(() {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          _tagMap = data.map((key, value) => MapEntry(key, List<String>.from(value),));
          _isLoadingTags = false;
        });
      }
    } catch(error) {
      debugPrint("Error fetching tag Map : $error");
      setState(() => _isLoadingTags = false);
    }
  }

//   Widget _buildCategoryGroup(String categoryTitle, List<String> tags) {
//     if(tags.isEmpty) return const SizedBox.shrink();

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const SizedBox(height: 16),
//         Text(
//           categoryTitle,
//           style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
//         ),
//         const SizedBox(height: 8),
//         Wrap(
//           spacing: 8.0,
//           runSpacing: 8.0,
//           children: tags.map((tagName) {
//             final bool isSelected = _selectedTags.any((t) => t['name'] ==  tagName);
//             return FilterChip(
//               label: Text(tagName, style: TextStyle(color: isSelected? Colors.white: Colors.black, fontSize: 13),),
//               selected: isSelected,
//               onSelected: (bool selected) {
//                 setState(() {
//                 if (selected) {
//                   _selectedTags.add({'name': tagName, 'category': categoryTitle});
//                 } else{
//                   _selectedTags.removeWhere((t) => t['name'] == tagName);
//                 }
//               });
//           },
//           backgroundColor: Colors.grey,
//           selectedColor: _tagColor(categoryTitle),
//           showCheckmark: false,
//           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20),
//           side: BorderSide(color: isSelected? Colors.transparent: Colors.grey),
//           ),
//           );
//   }).toList(),
//   ),
//   ],
//   );
// }
          

  void _submitLocation() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final String locationName = _locationNameController.text.trim();
    final String review = _reviewController.text.trim();

    final String? errorResult = await LocationService().addLocation(
      locationId: widget.locationId,
      locationName: locationName,
      review: review,
      rating: _currentRating,
      userSelectedTags: _selectedTags,
    );

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (errorResult != null) {
      // Handle error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorResult), backgroundColor: Colors.red),
      );
      //Navigator.pop(context);
    } else {
        setState(() {
          _selectedTags.clear();
          _currentRating = 0;
        });
        
        //Success
        ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("'$locationName' added successfully"), backgroundColor: Colors.green),
        );

        _locationNameController.clear();
        _reviewController.clear();

      } 
    }
  

  // Future<void> _submitCategorizedTags({
  //   required String locationId,
  //   required List<Map<String, String>> userSelectedTags,
  // }) async {
  //   // return nothing if no tags selected.
  //   if(userSelectedTags.isEmpty) return; // No tags to process, skip the function
  //   DocumentReference locationRef = FirebaseFirestore.instance.collection('locations').doc(locationId);
  //   return FirebaseFirestore.instance.runTransaction((transaction) async {
  //     DocumentSnapshot snapshot = await transaction.get(locationRef);
  //     if(! snapshot.exists) {
  //       throw Exception("Location record profile not found!");
  //   }
  //   final Map<String, dynamic> data = snapshot.data() as Map<String, dynamic> ? ?? {};
  //   final Map<String, dynamic> allTags = snapshot.get('allTags') != null ?
  //     Map<String, dynamic>.from(snapshot.get('allTags')) : {} ;
    
  //   for (var tag in userSelectedTags) {
  //     String tagName = tag['name']!;
  //     String tagCategory = tag['category']!;

  //     if(allTags.containsKey(tagName)) {
  //       final Map<String, dynamic> currentTagData = Map<String, dynamic>.from(allTags[tagName] as Map);
  //       final int currentCount = currentTagData['count'] ?? 0.toInt();
  //       currentTagData['count'] = currentCount + 1;
  //       allTags[tagName]['count'] = (allTags[tagName]['count'] ?? 0 ) + 1;
  //     } else {
  //       allTags[tagName] = {'category': tagCategory, 'count' : 1};
  //     }
  //     }
  //     final List<Map<String, dynamic>> sortedTagList = allTags.entries.map((entry) {
  //       final Map<String, dynamic> tagVal = Map<String, dynamic>.from(entry.value as Map);
  //       return {
  //         'name': entry.key,
  //         'category': tagVal['category'] ?? 'Vibes',
  //         'count' : tagVal['count']?? 1 ,
  //       };
  //     }).toList();

  //     sortedTagList.sort((a,b) => b['count'].compareTo(a['count']));
  //     List<Map<String,dynamic>> updatedTopTags = sortedTagList.take(5)
  //           .map((item) => {'name' : item['name'], 'category': item['category']}).toList();
  //     transaction.update(locationRef,{'allTags': allTags, 'topTags': updatedTopTags});
  //     });
  //   }

    void _customTagInputDialog() {
      final TextEditingController customController = TextEditingController();
      String selectedCategory = 'Vibes';
      showDialog(
        context: context,
        builder: (contex) {
          return AlertDialog(
            title: const Text('Add Custom Tag'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: customController,
                  decoration: const InputDecoration(hintText: 'e.g. Quiet Zone, Charging Dock'),
                ),
                const SizedBox(height: 16),
                StatefulBuilder(
                  builder: (context, setDialogState) {
                    return DropdownButton<String>(
                      value: selectedCategory,
                      isExpanded: true,
                      items: ['Vibes', 'Amenities', 'Facilities near-by'].map((cat) {
                        return DropdownMenuItem(value: cat, child: Text(cat));
                      }).toList(),
                      onChanged: (val) => setDialogState(() => selectedCategory = val!),
                    );
                  },
                ),
              ],
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
              ElevatedButton(
                onPressed: () {
                  final text = customController.text.trim();
                  if(text.isNotEmpty) {
                    setState(() {
                      if(!_tagMap[selectedCategory]!.contains(text)) {
                        _tagMap[selectedCategory]?.add(text);
                      }
                      if(!_selectedTags.any((t) => t['name'] == text)) {
                        _selectedTags.add({'name' : text, 'category': selectedCategory});
                      }
                  });
                  }
                  Navigator.pop(context);
                  },
                child: const Text('Add'),
                )
              ],
            );
          },
        );
      }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Location')
      ),
      body: _isLoadingTags
      ? const Center(child: CircularProgressIndicator())
      : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [

                // location name section
                const Text(
                  'Location Name', 
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)
                ),
                const SizedBox(height: 10),

                TextFormField(
                  controller: _locationNameController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Enter location name',
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a location name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // rating section
                const Text(
                  'Rating', 
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: List.generate(5, (index) {
                    final int starValue = index + 1;
                    return IconButton(
                      icon: Icon(
                        Icons.star,
                        color: starValue <= _currentRating ? Colors.amber : Colors.grey,
                        size: 32,
                      ),
                      onPressed: (){ 
                        setState(() => _currentRating = starValue);
                      },
                    );
                  }),
                ),
                const Divider(height: 20, thickness: 1),
                const Text('Features of study spots',
                style: TextStyle(fontSize:18, fontWeight: FontWeight.bold, color: Colors.purple),
                ),
                TagSelection(categoryTitle: 'Vibes', tags: _tagMap['Vibes'] ?? [], selectedTags: _selectedTags, 
                getTagColor: _tagColor,
                onTagsAdded: (tag) => setState(() => _selectedTags.add(tag)), 
                onTagRemoved: (tagName) => setState(() => _selectedTags.removeWhere((t) => t['name'] == tagName)),),

                TagSelection(categoryTitle: 'Amenities', tags: _tagMap['Amenities'] ?? [], selectedTags: _selectedTags, 
                getTagColor: _tagColor,
                onTagsAdded: (tag) => setState(() => _selectedTags.add(tag)), 
                onTagRemoved: (tagName) => setState(() => _selectedTags.removeWhere((t) => t['name'] == tagName)),),

                TagSelection(categoryTitle: 'Facilities near-by', tags: _tagMap['Facilities near-by'] ?? [], selectedTags: _selectedTags, 
                getTagColor: _tagColor,
                onTagsAdded: (tag) => setState(() => _selectedTags.add(tag)), 
                onTagRemoved: (tagName) => setState(() => _selectedTags.removeWhere((t) => t['name'] == tagName)),),

                const SizedBox(height: 14),

                TextButton.icon(
                  style: TextButton.styleFrom(alignment: Alignment.centerLeft, padding: EdgeInsets.zero),
                  icon: const Icon(Icons.add_circle_outline, color: Colors.purple),
                  label: const Text('Cannot find a tag? Add Custom Tag', style: TextStyle(color: Colors.purple)),
                  onPressed: _customTagInputDialog,
                  ),
    
                const SizedBox(height: 20),

                // review section
                const Text(
                  'Review', 
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)
                ),
                const SizedBox(height: 10),
          
                TextFormField(
                  //expands: true,
                  minLines: 5,
                  maxLines: null,

                  textAlignVertical: TextAlignVertical.top,
                  textAlign: TextAlign.left,

                  controller: _reviewController,
                  decoration: const InputDecoration(
                    //contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 80),
                    border: OutlineInputBorder(),
                    hintText: 'Enter review',
                    //contentPadding: EdgeInsets.all(12),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please give your honest review';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),


                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.brown,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),

                  onPressed: _isSaving ? null : _submitLocation,
                  child: _isSaving 
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('Add Location', style: TextStyle(fontSize: 16)),
                )
              ]
            ),
          )
        ),
      ),
    );
  }
}

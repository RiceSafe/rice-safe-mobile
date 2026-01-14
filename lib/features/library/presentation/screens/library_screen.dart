import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ricesafe_app/main.dart';
import 'package:ricesafe_app/features/library/presentation/screens/library_detail_screen.dart';
import 'package:ricesafe_app/features/library/data/mock_library_data.dart';

class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.all(1.0),
          child: Image.asset('assets/rice_icon.png'),
        ),
        title: const Text('คลังความรู้'),
        centerTitle: false,
        titleSpacing: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: InkWell(
              onTap: () {
                GoRouter.of(context).push('/settings');
              },
              borderRadius: BorderRadius.circular(20),
              child: const CircleAvatar(
                radius: 18,
                backgroundColor: riceSafeGreen,
                child: Icon(Icons.person, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar & Filter
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(20),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  decoration: InputDecoration(
                    hintText: 'ค้นหาโรคข้าว, อาการ...',
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                ),
                const SizedBox(height: 16),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip('ทั้งหมด', true),
                      const SizedBox(width: 8),
                      _buildFilterChip('เชื้อรา', false),
                      const SizedBox(width: 8),
                      _buildFilterChip('แบคทีเรีย', false),
                      const SizedBox(width: 8),
                      _buildFilterChip('ไวรัส', false),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Content Grid
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.75, // Taller cards
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: _libraryItems.length,
              itemBuilder: (context, index) {
                final item = _libraryItems[index];
                return _buildLibraryCard(context, item);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? riceSafeGreen : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isSelected ? riceSafeGreen : Colors.grey[300]!,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.grey[700],
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildLibraryCard(BuildContext context, LibraryItem item) {
    final Map<String, Color> categoryColors = {
      'เชื้อรา': Colors.orange,
      'แบคทีเรีย': Colors.blue,
      'ไวรัส': Colors.red,
    };
    final Color tagColor = categoryColors[item.category] ?? Colors.grey;

    return GestureDetector(
      onTap: () {
        DiseaseDetail? detail;
        try {
          detail = mockDiseaseList.firstWhere((d) => d.name == item.title);
        } catch (e) {
          detail = mockDiseaseList.first;
        }

        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => LibraryDetailScreen(disease: detail!),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                child: Image.asset(
                  item.imagePath,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[300],
                      child: const Icon(
                        Icons.image_not_supported,
                        color: Colors.grey,
                      ),
                    );
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: tagColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      item.category,
                      style: TextStyle(
                        color: tagColor,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class LibraryItem {
  final String title;
  final String imagePath;
  final String category;

  LibraryItem({
    required this.title,
    required this.imagePath,
    required this.category,
  });
}

final List<LibraryItem> _libraryItems = [
  LibraryItem(
    title: 'โรคไหม้\n(Rice Blast Disease)',
    imagePath: 'assets/mock/rice_blast.jpg',
    category: 'เชื้อรา',
  ),
  LibraryItem(
    title: 'โรคใบจุดสีน้ำตาล\n(Brown Spot Disease)',
    imagePath: 'assets/mock/brown_spot.jpg',
    category: 'เชื้อรา',
  ),
  LibraryItem(
    title: 'โรคขอบใบแห้ง\n(Leaf Blight Disease)',
    imagePath: 'assets/mock/leaf_blight.jpg',
    category: 'แบคทีเรีย',
  ),
  LibraryItem(
    title: 'โรคใบขีดโปร่งแสง\n(Leaf Streak Disease)',
    imagePath: 'assets/mock/leaf_streak.jpg',
    category: 'แบคทีเรีย',
  ),
];

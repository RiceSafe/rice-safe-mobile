import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ricesafe_app/core/error/user_error_message.dart';
import 'package:ricesafe_app/core/widgets/app_bar_profile_button.dart';
import 'package:ricesafe_app/main.dart';
import 'package:ricesafe_app/features/library/data/models/library_disease.dart';
import 'package:ricesafe_app/features/library/presentation/providers/disease_library_provider.dart';
import 'package:ricesafe_app/features/library/presentation/screens/library_detail_screen.dart';

class LibraryScreen extends ConsumerStatefulWidget {
  const LibraryScreen({super.key});

  @override
  ConsumerState<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends ConsumerState<LibraryScreen> {
  String _searchQuery = '';
  /// Empty string = ทั้งหมด (all categories).
  String _categoryKey = '';

  static Color _tagColorForCategory(String category) {
    const map = {
      'เชื้อรา': Colors.orange,
      'แบคทีเรีย': Colors.blue,
      'ไวรัส': Colors.red,
      'fungal': Colors.orange,
      'bacterial': Colors.blue,
      'virus': Colors.red,
    };
    return map[category] ?? Colors.grey;
  }

  List<LibraryDisease> _filter(List<LibraryDisease> items) {
    final q = _searchQuery.trim().toLowerCase();
    if (q.isEmpty) return items;
    return items.where((d) {
      return d.name.toLowerCase().contains(q) ||
          d.alias.toLowerCase().contains(q) ||
          d.description.toLowerCase().contains(q);
    }).toList();
  }

  void _retry() {
    ref.invalidate(diseaseCategoriesProvider);
    ref.invalidate(diseaseListProvider(_categoryKey));
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(diseaseCategoriesProvider);
    final listAsync = ref.watch(diseaseListProvider(_categoryKey));

    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.all(1.0),
          child: Image.asset('assets/rice_icon.png'),
        ),
        title: const Text('คลังความรู้'),
        centerTitle: false,
        titleSpacing: 0,
        actions: const [AppBarProfileButton()],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(20),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  onChanged: (v) => setState(() => _searchQuery = v),
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
                categoriesAsync.when(
                  data: (categories) {
                    final sorted = [...categories]..sort();
                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildFilterChip(
                            label: 'ทั้งหมด',
                            selected: _categoryKey.isEmpty,
                            onTap: () =>
                                setState(() => _categoryKey = ''),
                          ),
                          const SizedBox(width: 8),
                          ...sorted.map(
                            (c) => Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: _buildFilterChip(
                                label: c,
                                selected: _categoryKey == c,
                                onTap: () =>
                                    setState(() => _categoryKey = c),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                  loading: () => const SizedBox(
                    height: 40,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                  ),
                  error: (e, _) => Row(
                    children: [
                      _buildFilterChip(
                        label: 'ทั้งหมด',
                        selected: _categoryKey.isEmpty,
                        onTap: () => setState(() => _categoryKey = ''),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          userFacingMessage(
                            e,
                            contextFallback: 'โหลดหมวดหมู่ไม่สำเร็จ',
                          ),
                          style: TextStyle(color: Colors.red[700], fontSize: 12),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      TextButton(
                        onPressed: _retry,
                        child: const Text('ลองอีกครั้ง'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: listAsync.when(
              data: (items) {
                final filtered = _filter(items);
                if (filtered.isEmpty) {
                  return Center(
                    child: Text(
                      items.isEmpty
                          ? 'ยังไม่มีข้อมูลโรคในหมวดนี้'
                          : 'ไม่พบผลการค้นหา',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  );
                }
                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.75,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    return _buildLibraryCard(context, filtered[index]);
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        userFacingMessage(
                          e,
                          contextFallback: 'โหลดคลังโรคไม่สำเร็จ',
                        ),
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.red[800]),
                      ),
                      const SizedBox(height: 16),
                      FilledButton(
                        onPressed: _retry,
                        child: const Text('ลองอีกครั้ง'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? riceSafeGreen : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? riceSafeGreen : Colors.grey[300]!,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : Colors.grey[700],
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildLibraryCard(BuildContext context, LibraryDisease item) {
    final tagColor = _tagColorForCategory(item.category);

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (context) => LibraryDetailScreen(diseaseId: item.id),
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
                child: item.imageUrl != null && item.imageUrl!.isNotEmpty
                    ? Image.network(
                        item.imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return _imagePlaceholder();
                        },
                      )
                    : _imagePlaceholder(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.displayTitle,
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
                      color: tagColor.withValues(alpha: 0.1),
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

  Widget _imagePlaceholder() {
    return Container(
      color: Colors.grey[300],
      child: const Icon(
        Icons.image_not_supported,
        color: Colors.grey,
      ),
    );
  }
}

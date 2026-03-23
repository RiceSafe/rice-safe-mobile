import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ricesafe_app/core/error/user_error_message.dart';
import 'package:ricesafe_app/main.dart';
import 'package:ricesafe_app/features/library/data/models/library_disease.dart';
import 'package:ricesafe_app/features/library/presentation/providers/disease_library_provider.dart';

class LibraryDetailScreen extends ConsumerWidget {
  const LibraryDetailScreen({super.key, required this.diseaseId});

  final String diseaseId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(diseaseDetailProvider(diseaseId));

    return async.when(
      data: (disease) => _LibraryDetailBody(disease: disease),
      loading: () => Scaffold(
        appBar: AppBar(
          backgroundColor: riceSafeGreen,
          leading: IconButton(
            icon: const CircleAvatar(
              backgroundColor: Colors.black45,
              child: Icon(Icons.arrow_back, color: Colors.white),
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: const Text('กำลังโหลด...'),
        ),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        appBar: AppBar(
          backgroundColor: riceSafeGreen,
          leading: IconButton(
            icon: const CircleAvatar(
              backgroundColor: Colors.black45,
              child: Icon(Icons.arrow_back, color: Colors.white),
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: const Text('ข้อผิดพลาด'),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  userFacingMessage(
                    e,
                    contextFallback: 'ไม่พบข้อมูลโรค',
                  ),
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.red[800]),
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () =>
                      ref.invalidate(diseaseDetailProvider(diseaseId)),
                  child: const Text('ลองอีกครั้ง'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LibraryDetailBody extends StatelessWidget {
  const _LibraryDetailBody({required this.disease});

  final LibraryDisease disease;

  @override
  Widget build(BuildContext context) {
    final List<Widget> tabs = [const Tab(text: 'ข้อมูลทั่วไป')];
    final List<Widget> tabViews = [_buildGeneralTab()];

    if (disease.symptoms.isNotEmpty) {
      tabs.add(const Tab(text: 'อาการ'));
      tabViews.add(
        _buildSectionTab(disease.symptoms, Icons.check_circle, riceSafeGreen),
      );
    }

    if (disease.prevention.isNotEmpty) {
      tabs.add(const Tab(text: 'การป้องกัน'));
      tabViews.add(
        _buildSectionTab(disease.prevention, Icons.shield, Colors.blueAccent),
      );
    }

    if (disease.treatment.isNotEmpty) {
      tabs.add(const Tab(text: 'การรักษา'));
      tabViews.add(
        _buildSectionTab(
          disease.treatment,
          Icons.medical_services,
          Colors.redAccent,
        ),
      );
    }

    return Scaffold(
      body: DefaultTabController(
        length: tabs.length,
        child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverAppBar(
                expandedHeight: 250.0,
                floating: false,
                pinned: true,
                backgroundColor: riceSafeGreen,
                leading: IconButton(
                  icon: const CircleAvatar(
                    backgroundColor: Colors.black45,
                    child: Icon(Icons.arrow_back, color: Colors.white),
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
                  title: Text(
                    disease.displayTitle,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      shadows: [Shadow(color: Colors.black, blurRadius: 4)],
                    ),
                  ),
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      _headerImage(),
                      const DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Colors.transparent, Colors.black87],
                            stops: [0.6, 1.0],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverPersistentHeader(
                delegate: _SliverAppBarDelegate(
                  TabBar(
                    labelColor: riceSafeGreen,
                    unselectedLabelColor: Colors.grey,
                    indicatorColor: riceSafeGreen,
                    isScrollable: true,
                    padding: EdgeInsets.zero,
                    tabAlignment: TabAlignment.start,
                    labelPadding: const EdgeInsets.symmetric(horizontal: 20),
                    tabs: tabs,
                  ),
                ),
                pinned: true,
              ),
            ];
          },
          body: TabBarView(children: tabViews),
        ),
      ),
    );
  }

  Widget _headerImage() {
    final url = disease.imageUrl;
    if (url != null && url.isNotEmpty) {
      return Image.network(
        url,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _headerImagePlaceholder();
        },
      );
    }
    return _headerImagePlaceholder();
  }

  Widget _headerImagePlaceholder() {
    return Container(
      color: Colors.grey[300],
      alignment: Alignment.center,
      child: const Icon(Icons.image_not_supported, color: Colors.grey, size: 64),
    );
  }

  Widget _buildGeneralTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            disease.description,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black87,
              height: 1.5,
            ),
          ),
          if (disease.spreadDetails != null &&
              disease.spreadDetails!.isNotEmpty) ...[
            const SizedBox(height: 24),
            const Text(
              'การแพร่ระบาด',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: riceSafeDarkGreen,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              disease.spreadDetails!,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black87,
                height: 1.5,
              ),
            ),
          ],
          if (disease.matchWeather.isNotEmpty) ...[
            const SizedBox(height: 24),
            _buildEnvironmentBox(),
          ],
        ],
      ),
    );
  }

  Widget _buildEnvironmentBox() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'สภาพแวดล้อมที่พบบ่อย',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: riceSafeDarkGreen,
            ),
          ),
          const SizedBox(height: 16),
          ...disease.matchWeather.map(
            (condition) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildEnvRow(condition),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnvRow(String text) {
    return Row(
      children: [
        const Icon(Icons.cloud, color: Colors.black87, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 14, color: Colors.black87),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTab(
    List<LibraryInfoSection> sections,
    IconData icon,
    Color iconColor,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: sections.map((section) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Icon(icon, color: iconColor, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        section.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        section.description,
                        style: const TextStyle(
                          color: Colors.black87,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;

  _SliverAppBarDelegate(this._tabBar);

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(color: Colors.white, child: _tabBar);
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}

import 'package:flutter/material.dart';
import 'package:ricesafe_app/main.dart';
import 'package:ricesafe_app/features/library/data/mock_library_data.dart';

class LibraryDetailScreen extends StatelessWidget {
  final DiseaseDetail disease;

  const LibraryDetailScreen({super.key, required this.disease});

  @override
  Widget build(BuildContext context) {
    final List<Widget> tabs = [const Tab(text: 'ข้อมูลทั่วไป')];
    final List<Widget> tabViews = [_buildGeneralTab()];

    // Symptoms Tab
    if (disease.symptoms.isNotEmpty) {
      tabs.add(const Tab(text: 'อาการ'));
      tabViews.add(
        _buildSectionTab(disease.symptoms, Icons.check_circle, riceSafeGreen),
      );
    }

    // Prevention Tab
    if (disease.prevention.isNotEmpty) {
      tabs.add(const Tab(text: 'การป้องกัน'));
      tabViews.add(
        _buildSectionTab(disease.prevention, Icons.shield, Colors.blueAccent),
      );
    }

    // Treatment Tab
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
                    disease.name.replaceAll('\n', ' '),
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
                      Image.asset(disease.imagePath, fit: BoxFit.cover),
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

          if (disease.epidemiology != null) ...[
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
              disease.epidemiology!,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black87,
                height: 1.5,
              ),
            ),
          ],

          if (disease.matchWeather != null &&
              disease.matchWeather!.isNotEmpty) ...[
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
          ...disease.matchWeather!
              .map(
                (condition) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildEnvRow(Icons.thermostat, condition),
                ),
              )
              .toList(),
        ],
      ),
    );
  }

  Widget _buildEnvRow(IconData icon, String text) {
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
    List<InfoSection> sections,
    IconData icon,
    Color iconColor,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children:
            sections.map((section) {
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

  Widget _buildPreventionItem(String title, String description) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 2),
          child: Icon(Icons.shield, color: Colors.blueAccent, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: const TextStyle(color: Colors.black87, height: 1.5),
              ),
            ],
          ),
        ),
      ],
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

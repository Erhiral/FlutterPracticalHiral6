import 'package:flutter/material.dart';
import 'package:hiralfutterpractical/core/app_colors.dart';
import 'package:hiralfutterpractical/core/size_utils.dart';
import 'package:hiralfutterpractical/widgets/fab_button.dart';
import 'package:get/get.dart';
import 'package:hiralfutterpractical/routes/app_routes.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(
              Icons.arrow_back_ios_new, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text('PROFILE', style: TextStyle(
            color: AppColors.textPrimary, fontSize: Screen.sp(16))),
        centerTitle: true,
        actions: const [
          Icon(Icons.more_horiz, color: AppColors.textSecondary),
          SizedBox(width: 12),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.only(bottom: Screen.hp(2)),
        children: [
          // Half-screen CardView with background image and all content inside
          const _ProfileHeaderCard(),
          Gap.h(Screen.hp(2)),
          const _CreatedRemixedPager(),
        ],
      ),
    );
  }
}

class _CreatedRemixedPager extends StatefulWidget {
  const _CreatedRemixedPager();
  @override
  State<_CreatedRemixedPager> createState() => _CreatedRemixedPagerState();
}

class _CreatedRemixedPagerState extends State<_CreatedRemixedPager> {
  final _controller = PageController();
  int _index = 0;
  final _titles = const ['CREATED', 'REMIXED'];
  final List<String> _featured = const [
    'assets/images/one.webp',
    'assets/images/two.webp',
    'assets/images/three.webp',
  ];

  List<String> _gridPoolFor(int i) {
    const pool = [
      'assets/images/one.webp',
      'assets/images/two.webp',
      'assets/images/three.webp',
      'assets/images/four.jpg',
      'assets/images/five.jpg',
      'assets/images/six.jpg',
    ];
    if (i == 0) return pool; // explore
    if (i == 1) return [...pool.skip(2), ...pool.take(2)]; // groups rotated
    return pool.reversed.toList(); // following reversed
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _go(int i) {
    setState(() => _index = i);
    _controller.animateToPage(i, duration: const Duration(milliseconds: 250), curve: Curves.easeInOut);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Tabs
        Padding(
          padding: EdgeInsets.symmetric(horizontal: Screen.wp(4)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              for (int i = 0; i < _titles.length; i++)
                GestureDetector(
                  onTap: () => _go(i),
                  child: _Tab(title: _titles[i], selected: _index == i),
                ),
            ],
          ),
        ),
        Gap.h(6),
        // Underline indicator sized/positioned to match tab spacing
        Padding(
          padding: EdgeInsets.symmetric(horizontal: Screen.wp(4)),
          child: Stack(
            children: [
              Container(height: 2, color: AppColors.divider),
              LayoutBuilder(
                builder: (context, constraints) {
                  final tabWidth = constraints.maxWidth / _titles.length;
                  final underlineWidth = tabWidth * 0.28; // visual width similar to mock
                  final left = _index * tabWidth + (tabWidth - underlineWidth) / 2;
                  return AnimatedPositioned(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeInOut,
                    left: left,
                    child: Container(width: underlineWidth, height: 2, color: AppColors.textPrimary),
                  );
                },
              ),
            ],
          ),
        ),
        Gap.h(Screen.hp(1)),
        // Pager with featured card + grid, per-tab assets
        SizedBox(
          height: Screen.hp(50),
          child: PageView.builder(
            controller: _controller,
            onPageChanged: (i) => setState(() => _index = i),
            itemCount: _titles.length,
            itemBuilder: (context, i) => _GridSection(pool: _gridPoolFor(i)),
          ),
        ),
      ],
    );
  }
}

class _TabPage extends StatelessWidget {
  final String featuredImage;
  final List<String> gridPool;
  const _TabPage({required this.featuredImage, required this.gridPool});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: Screen.wp(4)),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    featuredImage,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(color: Colors.black12),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.05),
                          Colors.black.withOpacity(0.25),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Gap.h(Screen.hp(1.5)),
        _GridSection(pool: gridPool),
      ],
    );
  }
}

class _GridSection extends StatelessWidget {
  final List<String> pool;
  const _GridSection({required this.pool});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: Screen.wp(4)),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: Screen.wp(3),
          crossAxisSpacing: Screen.wp(3),
          childAspectRatio: 1,
        ),
        itemCount: 6,
        itemBuilder: (_, i) => _GridCard(index: i, pool: pool),
      ),
    );
  }
}
 

class _ProfileHeaderCard extends StatelessWidget {
  const _ProfileHeaderCard();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: Screen.wp(4)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Container(
          height: Screen.hp(38),
          color: Colors.black,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Background image
              Image.asset(
                'assets/images/four.jpg',
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(color: Colors.black12),
              ),
              // Gradient overlay for readability
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.15),
                      Colors.black.withOpacity(0.55),
                    ],
                  ),
                ),
              ),
              // Content inside card
              Padding(
                padding: EdgeInsets.all(Screen.wp(4)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top row: Follow pill, avatar, upload icon
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: Screen.wp(4), vertical: Screen.hp(0.8)),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.35),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: Colors.white70, width: 1),
                            boxShadow: [
                              BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 2)),
                            ],
                          ),
                          child: Text(
                            'FOLLOW',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: Screen.sp(12),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Gap.w(Screen.wp(3)),
                        Container(
                          width: Screen.wp(16),
                          height: Screen.wp(16),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.black.withOpacity(0.35),
                            border: Border.all(color: Colors.white70, width: 2),
                            boxShadow: [
                              BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 2)),
                            ],
                          ),
                          padding: EdgeInsets.all(2),
                          child: ClipOval(
                            child: Image.asset(
                              'assets/images/logo.png',
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => const Icon(Icons.person, color: Colors.white),
                            ),
                          ),
                        ),
                        const Spacer(),
                        Container(
                          width: Screen.wp(10.5),
                          height: Screen.wp(10.5),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.35),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white70, width: 1),
                            boxShadow: [
                              BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 2)),
                            ],
                          ),
                          child: const Center(
                            child: Icon(Icons.file_upload_outlined, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    // Name and bio stacked towards bottom
                    Center(
                      child: Column(
                        children: [
                          Text(
                            'MAJAMAJAALEJAJA',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.bold,
                              fontSize: Screen.sp(18),
                            ),
                          ),
                          Gap.h(Screen.hp(0.5)),
                          Text(
                            'she / her',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: Screen.sp(12),
                            ),
                          ),
                          Gap.h(Screen.hp(0.8)),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: Screen.wp(4)),
                            child: Text(
                              'Just here to drop goofy variants 😈🤖👑 | Remix > Create | 19.5k ppl somehow vibin 🔥🔥',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: Screen.sp(12),
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Gap.h(Screen.hp(1.2)),
                          // Stats row styled as rounded dark chips
                          Row(
                            children: [
                              _StatChip(value: '505', label: 'Following'),
                              Gap.w(Screen.wp(3)),
                              _StatChip(value: '19.5K', label: 'Followers'),
                              Gap.w(Screen.wp(3)),
                              _StatChip(value: '1M', label: 'Reactions'),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String value;
  final String label;
  const _StatChip({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: Screen.hp(1.2)),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.35),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white24, width: 0.5),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
                fontSize: Screen.sp(16),
              ),
            ),
            Gap.h(4),
            Text(
              label,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: Screen.sp(11),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
class _StatTile extends StatelessWidget {
  final String value;
  final String label;
  const _StatTile({required this.value, required this.label});
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: Screen.sp(18))),
        Gap.h(4),
        Text(label, style: TextStyle(color: AppColors.textSecondary, fontSize: Screen.sp(12))),
      ],
    );
  }
}

class _Tab extends StatelessWidget {
  final String title;
  final bool selected;
  const _Tab({required this.title, this.selected = false});
  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        color: selected ? AppColors.textPrimary : AppColors.textSecondary,
        fontWeight: selected ? FontWeight.bold : FontWeight.normal,
        fontSize: Screen.sp(14),
      ),
    );
  }
}

class _GridCard extends StatelessWidget {
  final int index;
  final List<String>? pool;
  const _GridCard({required this.index, this.pool});

  @override
  Widget build(BuildContext context) {
    // Choose from provided pool or default global set
    const defaultPool = [
      'assets/images/one.webp',
      'assets/images/two.webp',
      'assets/images/three.webp',
      'assets/images/four.jpg',
      'assets/images/five.jpg',
      'assets/images/six.jpg',
    ];
    final source = pool ?? defaultPool;
    final img = source[index % source.length];
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            img,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(color: Colors.black12),
          ),
          Positioned(
            left: 8,
            bottom: 8,
            child: Row(
              children: [
                const Icon(Icons.remove_red_eye_outlined, size: 16, color: AppColors.textPrimary),
                Gap.w(6),
                Text(index.isOdd ? '256' : '1K', style: TextStyle(color: AppColors.textPrimary, fontSize: Screen.sp(11))),
              ],
            ),
          )
        ],
      ),
    );
  }
}

 

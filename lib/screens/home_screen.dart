import 'package:flutter/material.dart';
import 'package:hiralfutterpractical/core/app_colors.dart';
import 'package:hiralfutterpractical/core/size_utils.dart';
import 'package:hiralfutterpractical/widgets/fab_button.dart';
import 'package:hiralfutterpractical/screens/event_calendar_screen.dart';
import 'package:get/get.dart';
import 'package:hiralfutterpractical/routes/app_routes.dart';
import 'package:hiralfutterpractical/controllers/bottom_bar_controller.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bb = Get.put(BottomBarController(), permanent: true);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const SizedBox.shrink(), // hide to align tab row like mock
        centerTitle: false,
      ),
      body: Padding(
        padding: EdgeInsets.all(Screen.wp(4)),
        child: const _HomePager(),
      ),
      // Bottom bar with floating center FAB above icons
      bottomNavigationBar: SizedBox(
        height: Screen.hp(9.5),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Bar background and icons row
            Positioned.fill(
              child: Container(
                padding: EdgeInsets.fromLTRB(Screen.wp(4), Screen.hp(0.8), Screen.wp(4), Screen.hp(1.2)),
                decoration: const BoxDecoration(
                  color: AppColors.background,
                  border: Border(top: BorderSide(color: AppColors.divider)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.bubble_chart_outlined, color: AppColors.textSecondary),
                    SizedBox(width: Screen.wp(6)),
                    const Icon(Icons.search, color: AppColors.textSecondary),
                    // Center gap reserved for FAB
                    SizedBox(width: Screen.wp(24)),
                    GestureDetector(
                      onTap: () => Get.toNamed(Routes.profile),
                      child: const Icon(Icons.person_outline, color: AppColors.textSecondary),
                    ),
                    SizedBox(width: Screen.wp(6)),
                    GestureDetector(
                      onTap: () {
                        bb.markRead();
                        Get.toNamed(Routes.calendar);
                      },
                      child: Obx(() => Stack(
                            clipBehavior: Clip.none,
                            children: [
                              const Icon(Icons.notifications_none, color: AppColors.textSecondary),
                              if (bb.hasUnread.value)
                                const Positioned(
                                  right: -2,
                                  top: -2,
                                  child: CircleAvatar(radius: 3.5, backgroundColor: Colors.pinkAccent),
                                ),
                            ],
                          )),
                    ),
                  ],
                ),
              ),
            ),
            // Floating FAB centered and raised above the bar
            Positioned(
              top: -Screen.hp(1.2),
              left: 0,
              right: 0,
              child: Center(
                child: GestureDetector(
                  onTap: () => Get.offAllNamed(Routes.home),
                  child: const FabButton(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TopTab extends StatelessWidget {
  final String label;
  final bool selected;
  const _TopTab({required this.label, this.selected = false});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: TextStyle(
        color: selected ? AppColors.textPrimary : AppColors.textSecondary,
        fontWeight: selected ? FontWeight.bold : FontWeight.normal,
        fontSize: Screen.sp(14),
      ),
    );
  }
}

class _HomePager extends StatefulWidget {
  const _HomePager();
  @override
  State<_HomePager> createState() => _HomePagerState();
}

class _HomePagerState extends State<_HomePager> {
  final PageController _controller = PageController();
  int _index = 0;
  final _titles = const ['EXPLORE', 'GROUPS', 'FOLLOWING'];
  final _images = const [
    'assets/images/five.jpg',
  ];
  final _badgeTop = const [13];
  final _badgeBottom = const [7];

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
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            for (int i = 0; i < _titles.length; i++) ...[
              GestureDetector(
                onTap: () => _go(i),
                child: _TopTab(label: _titles[i], selected: _index == i),
              ),
              if (i < _titles.length - 1) Gap.w(Screen.wp(4)),
            ],
          ],
        ),
        Gap.h(Screen.hp(1)),
        // Underline sized to selected tab text width
        LayoutBuilder(
          builder: (context, constraints) {
            final gap = Screen.wp(4);
            // Measure each tab text width using the same styles as _TopTab
            final widths = <double>[];
            for (int i = 0; i < _titles.length; i++) {
              final style = TextStyle(
                fontSize: Screen.sp(14),
                fontWeight: i == _index ? FontWeight.bold : FontWeight.normal,
              );
              final tp = TextPainter(
                text: TextSpan(text: _titles[i], style: style),
                textDirection: TextDirection.ltr,
                maxLines: 1,
              )..layout();
              widths.add(tp.size.width);
            }

            // Compute left offset as sum of previous widths + gaps
            double left = 0;
            for (int i = 0; i < _index; i++) {
              left += widths[i] + gap;
            }
            final underlineWidth = widths[_index];

            return Stack(
              children: [
                Container(height: 2, color: AppColors.divider),
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeInOut,
                  left: left,
                  child: Container(width: underlineWidth, height: 2, color: AppColors.textPrimary),
                ),
              ],
            );
          },
        ),
        Gap.h(Screen.hp(1.2)),
        // Pager
        Expanded(
          child: PageView.builder(
            controller: _controller,
            onPageChanged: (i) => setState(() => _index = i),
            itemCount: _titles.length,
            itemBuilder: (_, i) => SingleChildScrollView(
              child: _HomeCard(
                images: _images,
                badgeTop: _badgeTop[i % _badgeTop.length],
                badgeBottom: _badgeBottom[i % _badgeBottom.length],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _HomeCard extends StatefulWidget {
  final List<String> images;
  final int badgeTop;
  final int badgeBottom;
  const _HomeCard({required this.images, required this.badgeTop, required this.badgeBottom});

  @override
  State<_HomeCard> createState() => _HomeCardState();
}

class _HomeCardState extends State<_HomeCard> {
  late final PageController _cardController;
  int _page = 0;

  @override
  void initState() {
    super.initState();
    _cardController = PageController();
  }

  @override
  void dispose() {
    _cardController.dispose();
    super.dispose();
  }

  void _openCalendarDialog() {
    Get.dialog(
      Dialog(
        insetPadding: EdgeInsets.symmetric(horizontal: Screen.wp(4), vertical: Screen.hp(6)),
        backgroundColor: Colors.white,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: SizedBox(
          width: double.infinity,
          height: Screen.hp(70),
          child: const EventCalendarScreen(),
        ),
      ),
      barrierColor: Colors.black.withOpacity(0.6),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Soft oval shadow under the card to mimic mock background glow (gray tone)
        Positioned(
          left: 10,
          right: 10,
          bottom: -10,
          child: Container(
            height: 28,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.45),
                  blurRadius: 28,
                  spreadRadius: -2,
                  offset: const Offset(0, 18),
                ),
              ],
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(color: Colors.grey.withOpacity(0.50), blurRadius: 18, offset: const Offset(0, 10), spreadRadius: -6),
              BoxShadow(color: Colors.grey.withOpacity(0.25), blurRadius: 30, offset: const Offset(0, 18), spreadRadius: -10),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                child: AspectRatio(
                  aspectRatio: 1 / 1.40,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Swipeable image slider inside the card (inset with subtle gray outline)
                      Center(
                        child: FractionallySizedBox(
                          widthFactor: 0.92,
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(color: AppColors.divider, width: 1),
                            ),
                            padding: const EdgeInsets.all(2), // inner image padding = 2
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16), // 18 - padding for tighter inner image
                              child: PageView.builder(
                                controller: _cardController,
                                onPageChanged: (p) => setState(() => _page = p),
                                itemCount: widget.images.length,
                                itemBuilder: (_, idx) => Image.asset(
                                  widget.images[idx],
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(color: Colors.black12),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      // Top-center badge overlay (dynamic values)
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            GestureDetector(
                              onTap: _openCalendarDialog,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: const [
                                    BoxShadow(color: Colors.black38, blurRadius: 10, offset: Offset(0, 4)),
                                  ],
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 42,
                                      padding: const EdgeInsets.symmetric(vertical: 4),
                                      decoration: const BoxDecoration(
                                        color: Colors.pink,
                                        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                                      ),
                                      child: Center(
                                        child: Text(
                                          '${widget.badgeTop}',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Container(
                                      width: 42,
                                      padding: const EdgeInsets.symmetric(vertical: 4),
                                      decoration: const BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.vertical(bottom: Radius.circular(12)),
                                      ),
                                      child: Center(
                                        child: Text(
                                          '${widget.badgeBottom}',
                                          style: const TextStyle(
                                            color: Colors.pink,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Small page indicator dots
                      if (widget.images.length > 1)
                        Positioned(
                          bottom: Screen.hp(6.5),
                          left: 0,
                          right: 0,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              for (int i = 0; i < widget.images.length; i++)
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 250),
                                  margin: const EdgeInsets.symmetric(horizontal: 3),
                                  width: _page == i ? 8 : 6,
                                  height: _page == i ? 8 : 6,
                                  decoration: BoxDecoration(
                                    color: _page == i ? Colors.white : Colors.white54,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              // Content section below the image (matches inner image inset)
              Gap.h(Screen.hp(1.0)),
              Center(
                child: FractionallySizedBox(
                  widthFactor: 0.92,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Stats + Remix + small avatar
                      Row(
                        children: [
                           _IconStat(icon: Icons.remove_red_eye_outlined, label: '11,3K'),
                          Gap.w(Screen.wp(3)),
                           _IconStat(icon: Icons.mode_comment_outlined, label: '64'),
                          Gap.w(Screen.wp(3)),
                           _IconStat(icon: Icons.download,),
                          const Spacer(),
                          const _RemixButton(),

                        ],
                      ),
                      Gap.h(Screen.hp(1.0)),
                      // Author row
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () => Get.toNamed(Routes.profile),
                            child: const CircleAvatar(
                              radius: 14,
                              backgroundImage: NetworkImage('https://i.pravatar.cc/100?img=12'),
                            ),
                          ),
                          Gap.w(Screen.wp(2)),
                          Text('SZYMЕK', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: Screen.sp(14))),
                          Gap.w(Screen.wp(1.5)),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: AppColors.textSecondary, width: 1),
                            ),
                            child: Text('FOLLOW', style: TextStyle(color: AppColors.textPrimary, fontSize: Screen.sp(11), fontWeight: FontWeight.w600)),
                          ),
                          const Spacer(),

                          const CircleAvatar(
                            radius: 12,
                            backgroundImage: NetworkImage('https://i.pravatar.cc/100?img=3'),
                          ),
                          const Icon(Icons.more_horiz, color: AppColors.textSecondary),
                        ],
                      ),
                      Gap.h(Screen.hp(0.6)),
                      // Description row
                      Row(
                        children: [
                          Expanded(
                            child: RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: 'This is the variant description...',
                                    style: TextStyle(color: AppColors.textSecondary, fontSize: Screen.sp(12)),
                                  ),
                                  TextSpan(
                                    text: ' MORE',
                                    style: TextStyle(color: AppColors.textPrimary, fontSize: Screen.sp(12), fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      Gap.h(Screen.hp(1.0)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _IconStat extends StatelessWidget {
  final IconData icon; 
   String? label;
   _IconStat({required this.icon,  this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.textSecondary, size: Screen.sp(18)),
        Gap.w(Screen.wp(1.5)),
        Text(label ?? "", style: TextStyle(color: AppColors.textSecondary, fontSize: Screen.sp(12))),
      ],
    );
  }
}

class _RemixButton extends StatelessWidget {
  const _RemixButton();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.loop, color: AppColors.textPrimary, size: Screen.sp(16)),
          Gap.w(Screen.wp(1.5)),
          Text('REMIX (3)', style: TextStyle(color: AppColors.textPrimary, fontSize: Screen.sp(12))),
        ],
      ),
    );
  }
}

import 'dart:ui';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/motion/app_motion.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/create_options_sheet.dart';
import '../../data/collaborative_store.dart';
import '../home/screens/home_screen.dart';
import '../library/screens/collaborative_playlist_screen.dart';
import '../search/screens/search_screen.dart';
import '../library/screens/library_screen.dart';
import '../profile/screens/profile_screen.dart';
import '../player/widgets/mini_player.dart';

class _InviteLinkPayload {
  final String playlistId;
  final bool inviteAsCollaborator;

  const _InviteLinkPayload({
    required this.playlistId,
    required this.inviteAsCollaborator,
  });
}

class MainLayoutScreen extends StatefulWidget {
  const MainLayoutScreen({super.key});

  @override
  State<MainLayoutScreen> createState() => _MainLayoutScreenState();
}

class _MainLayoutScreenState extends State<MainLayoutScreen> {
  static const MethodChannel _deepLinkChannel = MethodChannel(
    'audify/deep_links',
  );

  int _currentIndex = 0;
  final Set<String> _handledInviteLinks = {};

  final List<Widget> _screens = [
    const HomeScreen(),
    const SearchScreen(),
    const LibraryScreen(),
    const ProfileScreen(showBackButton: false),
  ];

  int get _selectedTabIndex =>
      _currentIndex >= 2 ? _currentIndex + 1 : _currentIndex;

  @override
  void initState() {
    super.initState();
    _deepLinkChannel.setMethodCallHandler(_handleDeepLinkMethodCall);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _handleInitialInviteLink();
    });
  }

  @override
  void dispose() {
    _deepLinkChannel.setMethodCallHandler(null);
    super.dispose();
  }

  Future<dynamic> _handleDeepLinkMethodCall(MethodCall call) async {
    if (call.method != 'onLink') return null;
    final link = call.arguments as String?;
    if (link != null) {
      await _handleInviteLink(link);
    }
    return null;
  }

  Future<void> _handleInitialInviteLink() async {
    try {
      final link = await _deepLinkChannel.invokeMethod<String>(
        'getInitialLink',
      );
      if (link != null) {
        await _handleInviteLink(link);
      }
    } on MissingPluginException {
      return;
    } on PlatformException {
      return;
    }
  }

  Future<void> _handleInviteLink(String link) async {
    final invite = _invitePayloadFromLink(link);
    if (invite == null || _handledInviteLinks.contains(link)) return;
    _handledInviteLinks.add(link);

    try {
      if (invite.inviteAsCollaborator) {
        await CollaborativeStore.instance.joinCollaborativePlaylist(
          invite.playlistId,
        );
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            invite.inviteAsCollaborator
                ? 'Joined collaborative playlist'
                : 'Opening playlist',
          ),
        ),
      );
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) =>
              CollaborativePlaylistScreen(playlistId: invite.playlistId),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      final message = e is FirebaseException
          ? e.message ?? 'Could not join this playlist'
          : 'Could not join this playlist';
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  _InviteLinkPayload? _invitePayloadFromLink(String link) {
    final uri = Uri.tryParse(link.trim());
    if (uri == null) return null;
    final inviteAsCollaborator =
        uri.queryParameters['invite'] == 'collaborator' ||
        uri.queryParameters['collaborator'] == 'true';

    if (uri.scheme == 'audify' &&
        uri.host == 'collab' &&
        uri.pathSegments.isNotEmpty) {
      return _InviteLinkPayload(
        playlistId: uri.pathSegments.first,
        inviteAsCollaborator: inviteAsCollaborator,
      );
    }

    if ((uri.scheme == 'https' || uri.scheme == 'http') &&
        (uri.host == 'audify-f9365.web.app' || uri.host == 'audify.app') &&
        uri.pathSegments.length >= 2 &&
        uri.pathSegments.first == 'collab') {
      return _InviteLinkPayload(
        playlistId: uri.pathSegments[1],
        inviteAsCollaborator: inviteAsCollaborator,
      );
    }

    return null;
  }

  void _onTabSelected(int index) {
    if (index == 2) {
      CreateOptionsSheet.show(context);
      return;
    }

    setState(() {
      _currentIndex = index > 2 ? index - 1 : index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: Stack(
        children: [
          ...List.generate(_screens.length, (index) {
            final isActive = index == _currentIndex;
            return IgnorePointer(
              ignoring: !isActive,
              child: AnimatedOpacity(
                opacity: isActive ? 1 : 0,
                duration: AppMotion.standard,
                curve: AppMotion.entranceCurve,
                child: AnimatedSlide(
                  offset: isActive ? Offset.zero : const Offset(0, 0.02),
                  duration: AppMotion.standard,
                  curve: AppMotion.entranceCurve,
                  child: TickerMode(
                    enabled: isActive,
                    child: RepaintBoundary(child: _screens[index]),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const MiniPlayer(),
          Theme(
            data: Theme.of(context).copyWith(
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
            ),
            child: Container(
              color: Colors.transparent, // No solid color, pure blur
              child: ClipRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(
                    sigmaX: 15.0,
                    sigmaY: 15.0,
                  ), // Increased blur
                  child: BottomNavigationBar(
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    type: BottomNavigationBarType.fixed,
                    currentIndex: _selectedTabIndex,
                    selectedItemColor: Colors.white,
                    unselectedItemColor: AppColors.secondaryText,
                    selectedLabelStyle: AppTextStyles.helper.copyWith(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                    unselectedLabelStyle: AppTextStyles.helper.copyWith(
                      fontSize: 10,
                    ),
                    onTap: _onTabSelected,
                    items: const [
                      BottomNavigationBarItem(
                        icon: Icon(Icons.home_filled),
                        label: "Home",
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(Icons.search),
                        label: "Search",
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(Icons.add_circle),
                        label: "Create",
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(Icons.library_music),
                        label: "Your Library",
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(Icons.person),
                        label: "Profile",
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
}

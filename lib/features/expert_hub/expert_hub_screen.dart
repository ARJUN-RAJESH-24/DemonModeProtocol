import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../../core/theme/app_pallete.dart';

class ExpertHubScreen extends StatefulWidget {
  const ExpertHubScreen({super.key});

  @override
  State<ExpertHubScreen> createState() => _ExpertHubScreenState();
}

class _ExpertHubScreenState extends State<ExpertHubScreen> {
  final ScrollController _scrollController = ScrollController();
  
  // Base Data
  final List<Map<String, String>> _allVideos = [
    {'id': 'vc1E5CfRfos', 'title': 'The Most Effective Way To Build Muscle', 'category': 'Hypertrophy'},
    {'id': 'Pok0Jg2JAkE', 'title': 'How Much Protein Do You ACTUALLY Need?', 'category': 'Nutrition'},
    {'id': '0o0k1XF9pX0', 'title': 'The Perfect Push Workout', 'category': 'Training'},
    {'id': 'e1tB3z0r2hE', 'title': 'Stop Wasting Time in the Gym', 'category': 'Mistakes'},
    {'id': '3v1d-1w1w1w', 'title': 'How to Cut Fat Without Losing Muscle', 'category': 'Fat Loss'}, // Mock
    {'id': 'X_9V9i1', 'title': 'Scientific Glute Training', 'category': 'Hypertrophy'}, // Mock
    {'id': 'Y_8U8u2', 'title': 'Creatine: Everything You Need to Know', 'category': 'Nutrition'}, // Mock
  ];

  List<Map<String, String>> _displayVideos = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _displayVideos = List.from(_allVideos);
    _scrollController.addListener(_onScroll);
  }
  
  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200 && !_isLoading) {
      _loadMoreContent();
    }
  }

  Future<void> _loadMoreContent() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 1)); // Simulate Network
    
    // Simulate finding "new" content by reshuffling/repeating base content
    // In a real app, this hits the API.
    final newBatch = List<Map<String, String>>.from(_allVideos)..shuffle();
    
    if (mounted) {
      setState(() {
        _displayVideos.addAll(newBatch);
        _isLoading = false;
      });
    }
  }

  Future<void> _refreshContent() async {
    await Future.delayed(const Duration(seconds: 1)); // Simulate Network
    
    // Shuffle the "source" to make it look like we fetched new recommendations
    final shuffled = List<Map<String, String>>.from(_allVideos)..shuffle();
    
    if (mounted) {
      setState(() {
        _displayVideos = shuffled;
        _isLoading = false;
        // Reset scroll position if needed, though RefreshIndicator usually handles top bounce
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("EXPERT KNOWLEDGE HUB")),
      body: RefreshIndicator(
        onRefresh: _refreshContent,
        color: AppPallete.primaryColor,
        backgroundColor: AppPallete.surfaceColor,
        child: ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.all(16),
          itemCount: _displayVideos.length + 1,
          itemBuilder: (context, index) {
            if (index == _displayVideos.length) {
              return _isLoading 
                  ? const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator())) 
                  : const SizedBox(height: 50);
            }
            
            final video = _displayVideos[index];
            return Card(
              color: AppPallete.surfaceColor,
              margin: const EdgeInsets.only(bottom: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                    child: AspectRatio(
                      aspectRatio: 16 / 9,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                           // Fallback placeholder since network thumbnail might fail on mocks
                          Container(color: Colors.grey[900]), 
                          Image.network(
                            YoutubePlayer.getThumbnail(videoId: video['id']!),
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (_,__,___) => Container(color: Colors.grey[900]),
                          ),
                          Container(
                            color: Colors.black45,
                            child: const Center(
                              child: Icon(Icons.play_circle_fill, color: Colors.redAccent, size: 48),
                            ),
                          ),
                          Positioned.fill(
                               child: Material(
                                 color: Colors.transparent,
                                 child: InkWell(
                                   onTap: () {
                                     Navigator.push(
                                       context, 
                                       MaterialPageRoute(builder: (_) => VideoPlayerScreen(videoId: video['id']!))
                                     );
                                   },
                                 ),
                               ),
                          )
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.redAccent.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(4)
                          ),
                          child: Text(
                            video['category']!.toUpperCase(),
                            style: const TextStyle(color: Colors.redAccent, fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          video['title']!,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class VideoPlayerScreen extends StatefulWidget {
  final String videoId;
  const VideoPlayerScreen({super.key, required this.videoId});

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController(
      initialVideoId: widget.videoId,
      flags: const YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: YoutubePlayer(
          controller: _controller,
          showVideoProgressIndicator: true,
          progressIndicatorColor: Colors.redAccent,
        ),
      ),
    );
  }
}

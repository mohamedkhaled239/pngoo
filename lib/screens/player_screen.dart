import 'dart:io';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class PlayerScreen extends StatefulWidget {
  final String videoPath;

  const PlayerScreen({super.key, required this.videoPath});

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  late VideoPlayerController _controller;
  bool _isPlaying = false;
  bool _showControls = true;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.file(File(widget.videoPath))
      ..initialize().then((_) {
        setState(() {});
        _controller.addListener(() {
          setState(() {});
        });
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('مشغل الفيديو',style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Center(
        child: _controller.value.isInitialized
            ? GestureDetector(
          onTap: () {
            setState(() {
              _showControls = !_showControls;
            });
          },
          child: Stack(
            alignment: Alignment.center,
            children: [
              
              AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: VideoPlayer(_controller),
              ),

              
              if (_showControls && !_controller.value.isPlaying)
                Container(
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(
                      Icons.play_arrow,
                      size: 60,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      _controller.play();
                      setState(() {
                        _isPlaying = true;
                      });
                    },
                  ),
                ),

              
              if (_showControls)
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.black87,
                          Colors.transparent,
                        ],
                      ),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        
                        Row(
                          children: [
                            Text(
                              _formatDuration(_controller.value.position),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                            Expanded(
                              child: Slider(
                                value: _controller.value.position.inSeconds
                                    .toDouble(),
                                max: _controller.value.duration.inSeconds
                                    .toDouble(),
                                onChanged: (value) {
                                  _controller.seekTo(
                                      Duration(seconds: value.toInt()));
                                },
                                activeColor: Colors.blue,
                                inactiveColor: Colors.grey,
                              ),
                            ),
                            Text(
                              _formatDuration(_controller.value.duration),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),

                        
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            
                            IconButton(
                              icon: const Icon(
                                  Icons.replay_10, color: Colors.white),
                              iconSize: 32,
                              onPressed: () {
                                final newPosition = _controller.value.position -
                                    const Duration(seconds: 10);
                                _controller.seekTo(newPosition < Duration.zero
                                    ? Duration.zero
                                    : newPosition);
                              },
                            ),

                            
                            IconButton(
                              icon: const Icon(
                                  Icons.replay, color: Colors.white),
                              iconSize: 32,
                              onPressed: () {
                                _controller.seekTo(Duration.zero);
                                _controller.play();
                                setState(() {
                                  _isPlaying = true;
                                });
                              },
                            ),

                            
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.blue,
                                shape: BoxShape.circle,
                              ),
                              child: IconButton(
                                icon: Icon(
                                  _controller.value.isPlaying
                                      ? Icons.pause
                                      : Icons.play_arrow,
                                  color: Colors.white,
                                ),
                                iconSize: 32,
                                onPressed: () {
                                  if (_controller.value.isPlaying) {
                                    _controller.pause();
                                  } else {
                                    _controller.play();
                                  }
                                  setState(() {
                                    _isPlaying = !_isPlaying;
                                  });
                                },
                              ),
                            ),

                            
                            IconButton(
                              icon: const Icon(
                                  Icons.forward_10, color: Colors.white),
                              iconSize: 32,
                              onPressed: () {
                                final newPosition = _controller.value.position +
                                    const Duration(seconds: 10);
                                _controller.seekTo(
                                    newPosition > _controller.value.duration
                                        ? _controller.value.duration
                                        : newPosition);
                              },
                            ),

                            
                            PopupMenuButton<double>(
                              icon: const Icon(
                                  Icons.speed, color: Colors.white, size: 32),
                              initialValue: _controller.value.playbackSpeed,
                              itemBuilder: (context) =>
                              [
                                const PopupMenuItem(
                                    value: 0.5, child: Text('0.5x')),
                                const PopupMenuItem(
                                    value: 0.75, child: Text('0.75x')),
                                const PopupMenuItem(
                                    value: 1.0, child: Text('عادي')),
                                const PopupMenuItem(
                                    value: 1.25, child: Text('1.25x')),
                                const PopupMenuItem(
                                    value: 1.5, child: Text('1.5x')),
                                const PopupMenuItem(
                                    value: 2.0, child: Text('2.0x')),
                              ],
                              onSelected: (speed) {
                                _controller.setPlaybackSpeed(speed);
                                setState(() {});
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
            ],
                ),
        )
            : Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(
              color: Colors.blue,
            ),
            const SizedBox(height: 20),
            const Text(
              'جاري تحميل الفيديو...',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}

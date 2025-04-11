import 'package:flutter/material.dart';
import 'dart:math';
import 'package:audiobook_player/player/player_service.dart';

class PlayerControls extends StatelessWidget {
  final PlayerService playerService;

  const PlayerControls({
    Key? key,
    required this.playerService,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // File name at the top
        StreamBuilder<String>(
          stream: playerService.fileNameStream,
          builder: (context, snapshot) {
            final fileName = snapshot.data ?? 'No file playing';
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                fileName,
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            );
          },
        ),
        
        // Progress bar with seeking capability
        StreamBuilder<PositionData>(
          stream: playerService.positionDataStream,
          builder: (context, snapshot) {
            final positionData = snapshot.data ?? 
                PositionData(
                  position: Duration.zero, 
                  duration: Duration.zero,
                  bufferedPosition: Duration.zero,
                );
            
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  SliderTheme(
                    data: SliderThemeData(
                      trackHeight: 4.0,
                      thumbShape: RoundSliderThumbShape(enabledThumbRadius: 8.0),
                    ),
                    child: Slider(
                      min: 0.0,
                      max: positionData.duration.inMilliseconds.toDouble(),
                      value: min(
                        positionData.position.inMilliseconds.toDouble(),
                        positionData.duration.inMilliseconds.toDouble(),
                      ),
                      onChanged: (value) {
                        playerService.seekTo(Duration(milliseconds: value.toInt()));
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _formatDuration(positionData.position),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        Text(
                          _formatDuration(positionData.duration),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    
    return duration.inHours > 0 
        ? '$hours:$minutes:$seconds' 
        : '$minutes:$seconds';
  }
}

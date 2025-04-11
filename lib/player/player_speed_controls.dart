import 'package:flutter/material.dart';
import 'player_service.dart';

class PlaybackSpeedControls extends StatelessWidget {
  final PlayerService playerService;

  const PlaybackSpeedControls({
    Key? key,
    required this.playerService,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<double>(
      stream: playerService.playbackSpeedStream,
      builder: (context, snapshot) {
        final speed = snapshot.data ?? PlayerService.defaultSpeed;
        
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.remove),
              onPressed: playerService.decreaseSpeed,
              tooltip: 'Decrease speed',
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Theme.of(context).primaryColor.withOpacity(0.1),
              ),
              child: Text(
                '${speed.toStringAsFixed(2)}x',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: playerService.increaseSpeed,
              tooltip: 'Increase speed',
            ),
          ],
        );
      },
    );
  }
}

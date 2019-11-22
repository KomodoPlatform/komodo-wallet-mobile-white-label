import 'dart:math';

import 'package:audioplayers/audio_cache.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:komodo_dex/model/order.dart';
import 'package:komodo_dex/model/swap.dart';
import 'package:komodo_dex/utils/log.dart';

MusicService musicService = MusicService();

enum MusicMode {
  /// Trying to match with an existing order.
  TAKER,

  /// Having orders.
  MAKER,

  /// There are active swaps.
  ACTIVE,

  /// There was a failed swap recently.
  FAILED,

  /// There was a finished swap recently.
  APPLAUSE,

  /// No active orders or swaps, we can stay silent
  /// (and allow the application to be suspended, saving battery life).
  SILENT
}

class MusicService {
  MusicMode musicMode = MusicMode.SILENT;

  static final AudioPlayer _audioPlayer =
      AudioPlayer(mode: PlayerMode.MEDIA_PLAYER);
  static final AudioCache _player =
      AudioCache(prefix: 'audio/', fixedPlayer: _audioPlayer);

  /// Pick the current music mode based on the list of all the orders and SWAPs.
  MusicMode pickMode(
      List<Order> orders, List<Swap> swaps, List<Swap> allSwaps) {
    final Set<String> active = {};
    for (final Swap swap in swaps) {
      // Active swaps.
      final String uuid = swap.result.uuid;
      active.add(uuid);
      final String shortId = uuid.substring(0, 4);
      Log.println('',
          'pickMode] swap $shortId status: ${swap.status}, MusicMode.ACTIVE');
      return MusicMode.ACTIVE;
    }

    for (final Swap swap in allSwaps) {
      final String uuid = swap.result.uuid;
      if (active.contains(uuid)) {
        // Already seen this swap in the list of active swaps.
        continue;
      }
      final String shortId = uuid.substring(0, 4);
      if (musicMode == MusicMode.ACTIVE) {
        if (swap.status == Status.SWAP_FAILED ||
            swap.status == Status.TIME_OUT) {
          Log.println('', 'pickMode] failed swap $shortId, MusicMode.FAILED');
          return MusicMode.FAILED;
        } else if (swap.status == Status.SWAP_SUCCESSFUL) {
          Log.println(
              '', 'pickMode] finished swap $shortId, MusicMode.APPLAUSE');
          return MusicMode.APPLAUSE;
        }
      }
    }

    for (final Order order in orders) {
      final String shortId = order.uuid.substring(0, 4);
      if (order.orderType == OrderType.TAKER) {
        Log.println('', 'pickMode] taker order $shortId, MusicMode.TAKER');
        return MusicMode.TAKER;
      } else if (order.orderType == OrderType.MAKER) {
        Log.println('', 'pickMode] maker order $shortId, MusicMode.MAKER');
        return MusicMode.MAKER;
      }
    }

    Log.println('', 'pickMode] no active orders or swaps, MusicMode.SILENT');
    return MusicMode.SILENT;
  }

  void play(List<Order> orders, List<Swap> swaps, List<Swap> allSwaps) {
    // ^ Triggered by page transitions and certain log events (via `onLogsmm2`),
    //   but for reliability we should also add a periodic update independent from MM logs.
    final MusicMode newMode = pickMode(orders, swaps, allSwaps);
    if (newMode != musicMode) {
      Log.println('', 'play] mode changed from $musicMode to $newMode');

      final Random rng = Random();

      if (newMode == MusicMode.TAKER) {
        _player.loop(rng.nextBool()
            ? '15427__lg__fax.mp3'
            : 'Coin_Drop-Willem_Hunt-569197907.mp3');
      } else if (newMode == MusicMode.MAKER) {
        _player.loop('162196__rickmk2__coin-rustle.mp3');
      } else if (newMode == MusicMode.ACTIVE) {
        _player.loop('362272__zabuhailo__street-musician-money.mp3');
      } else if (newMode == MusicMode.FAILED) {
        _player.loop(rng.nextBool()
            ? '376196__euphrosyyn__futuristic-robotic-voice-sentences.mp3'
            : '213901__garzul__robotic-arp-sequence.mp3');
      } else if (newMode == MusicMode.APPLAUSE) {
        _player.loop('Cash-Register-Cha-Ching-SoundBible.com-184076484.mp3');
      } else if (newMode == MusicMode.SILENT) {
        _player.play('poker-chips-daniel_simon.mp3');
      }

      musicMode = newMode;
    }

/*
    // TODO: Add the listeners *once*? Remove old listeners?
    _audioPlayer.onPlayerCompletion.listen((_) {
      Log.println('', 'onPlayerCompletion');
    });
    _audioPlayer.onPlayerError.listen((String ev) {
      Log.println('', 'onPlayerError: ' + ev);
    });

    Log.println('', 'Playing home.mp3');
    //_player.loop('home.mp3', isNotification: false);

    Future<void>.delayed(const Duration(seconds: 22), () {
      Log.println('', 'stopping');
      _audioPlayer.stop();
    });
*/
  }
}

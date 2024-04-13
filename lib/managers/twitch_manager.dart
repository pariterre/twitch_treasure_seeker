import 'package:flutter/material.dart';
import 'package:twitch_manager/twitch_manager.dart' as tm;

final _twitchMockerOptions = tm.TwitchDebugPanelOptions(
  chatters: [
    tm.TwitchChatterMock(displayName: 'modo1', isModerator: true),
    tm.TwitchChatterMock(displayName: 'follower1'),
    tm.TwitchChatterMock(displayName: 'follower2'),
    tm.TwitchChatterMock(displayName: 'follower3'),
    tm.TwitchChatterMock(displayName: 'follower4'),
    tm.TwitchChatterMock(displayName: 'follower5'),
    tm.TwitchChatterMock(displayName: 'follower6'),
    tm.TwitchChatterMock(displayName: 'follower7'),
    tm.TwitchChatterMock(displayName: 'follower8'),
    tm.TwitchChatterMock(displayName: 'follower9'),
    tm.TwitchChatterMock(displayName: 'follower10'),
  ],
  chatMessages: [
    '!chercheursDeBleuets',
    '!joindre',
    '!start',
    '!stop',
    '!reset',
    '!setup',
  ],
);

final _twitchAppInfo = tm.TwitchAppInfo(
  appName: 'Minesweeper',
  twitchAppId: 's88tkbc2bsddutwte7bbnj616mhgqx',
  scope: [
    tm.TwitchScope.chatRead,
    tm.TwitchScope.chatEdit,
    tm.TwitchScope.chatters,
    tm.TwitchScope.readFollowers,
    tm.TwitchScope.readModerator,
    tm.TwitchScope.readModerator,
  ],
  redirectUri: 'twitchauthentication.pariterre.net',
);

class TwitchManager {
  tm.TwitchManager? _manager;
  tm.TwitchManager? get manager => _manager;

  // Prepare the singleton
  static final TwitchManager _singleton = TwitchManager._internal();
  static TwitchManager get instance => _singleton;
  TwitchManager._internal();

  // Initialize
  Future<void> init(BuildContext context,
      {required bool loadPreviousSession}) async {
    _manager = (await showDialog<tm.TwitchManager>(
      context: context,
      builder: (context) => tm.TwitchAuthenticationDialog(
        isMockActive: false,
        debugPanelOptions: _twitchMockerOptions,
        onConnexionEstablished: (manager) {
          Navigator.pop(context, manager);
        },
        appInfo: _twitchAppInfo,
        reload: loadPreviousSession,
      ),
    ));
  }
}

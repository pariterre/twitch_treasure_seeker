import 'package:flutter/material.dart';
import 'package:twitch_manager/twitch_app.dart';

final _twitchMockerOptions = TwitchDebugPanelOptions(
  chatters: [
    TwitchChatterMock(displayName: 'modo1', isModerator: true),
    TwitchChatterMock(displayName: 'follower1'),
    TwitchChatterMock(displayName: 'follower2'),
    TwitchChatterMock(displayName: 'follower3'),
    TwitchChatterMock(displayName: 'follower4'),
    TwitchChatterMock(displayName: 'follower5'),
    TwitchChatterMock(displayName: 'follower6'),
    TwitchChatterMock(displayName: 'follower7'),
    TwitchChatterMock(displayName: 'follower8'),
    TwitchChatterMock(displayName: 'follower9'),
    TwitchChatterMock(displayName: 'follower10'),
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

final _twitchAppInfo = TwitchAppInfo(
  appName: 'Minesweeper',
  twitchClientId: 's88tkbc2bsddutwte7bbnj616mhgqx',
  twitchRedirectUri:
      Uri.https('twitchauthentication.pariterre.net', 'twitch_redirect.html'),
  authenticationServerUri:
      Uri.https('twitchserver.pariterre.net:3000', 'token'),
  scope: [
    TwitchAppScope.chatRead,
    TwitchAppScope.chatEdit,
    TwitchAppScope.chatters,
    TwitchAppScope.readFollowers,
    TwitchAppScope.readModerator,
    TwitchAppScope.readModerator,
  ],
);

class TwitchManager {
  TwitchAppManager? _manager;
  TwitchAppManager? get manager => _manager;

  // Prepare the singleton
  static final TwitchManager _singleton = TwitchManager._internal();
  static TwitchManager get instance => _singleton;
  TwitchManager._internal();

  // Initialize
  Future<void> init(BuildContext context,
      {required bool loadPreviousSession, required bool useMock}) async {
    _manager = (await showDialog<TwitchAppManager>(
      context: context,
      builder: (context) => TwitchAppAuthenticationDialog(
        isMockActive: useMock,
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

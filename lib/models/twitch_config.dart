import 'package:twitch_manager/twitch_manager.dart';

final twitchMocker = TwitchDebugPanelOptions(
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

final twitchAppInfo = TwitchAppInfo(
  appName: 'Minesweeper',
  twitchAppId: 's88tkbc2bsddutwte7bbnj616mhgqx',
  scope: [
    TwitchScope.chatRead,
    TwitchScope.chatEdit,
    TwitchScope.chatters,
    TwitchScope.readFollowers,
    TwitchScope.readModerator,
    TwitchScope.readModerator,
  ],
  redirectUri: 'twitchauthentication.pariterre.net',
);

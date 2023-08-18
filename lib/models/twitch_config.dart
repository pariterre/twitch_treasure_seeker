import 'package:twitch_manager/twitch_manager.dart';

const twitchMocker = TwitchMockOptions(
  isActive: false,
  moderators: ['modo1'],
  messagesModerators: [
    '!chercheursDeBleuets',
    '!joindre',
    '!start',
    '!stop',
    '!reset',
    '!setup',
  ],
  followers: [
    'follower1',
    'follower2',
    'follower3',
    'follower4',
    'follower5',
    'follower6',
    'follower7',
    'follower8',
    'follower9',
    'follower10',
  ],
  messagesFollowers: [
    '!joindre',
    '!chercheursDeBleuets',
    '!start',
  ],
);

final twitchAppInfo = TwitchAppInfo(
  appName: 'Minesweeper',
  twitchAppId: 'eqt0u8wre5boab7thsjb6b8sh57qy3',
  scope: [
    TwitchScope.chatRead,
    TwitchScope.chatEdit,
    TwitchScope.chatters,
    TwitchScope.readFollowers,
    TwitchScope.readSubscribers,
    TwitchScope.readModerator,
  ],
  redirectAddress: 'https://twitchauthentication.pariterre.net:3000',
  useAuthenticationService: true,
  authenticationServiceAddress: 'wss://twitchauthentication.pariterre.net:3002',
);

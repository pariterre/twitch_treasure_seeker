import 'package:common/models/custom_callback.dart';
import 'package:flutter/material.dart';
import 'package:twitch_manager/twitch_app.dart';
import 'package:twitch_manager/twitch_utils.dart';

TwitchDebugPanelOptions get _twitchDebugPanelOptions =>
    TwitchDebugPanelOptions(chatters: [
      TwitchChatterMock(displayName: 'Viewer1'),
      TwitchChatterMock(displayName: 'Viewer2'),
      TwitchChatterMock(displayName: 'Viewer3'),
      TwitchChatterMock(displayName: 'ViewerWithAVeryVeryVeryLongName'),
    ]);

class TwitchManager {
  final onTwitchManagerHasConnected = CustomCallback();
  final onTwitchManagerHasDisconnected = CustomCallback();

  void initialize({bool useMock = false}) {
    _isMockActive = useMock;
  }

  ///
  /// Get if the manager is connected or not
  bool get isConnected => _manager != null;
  bool get isNotConnected => !isConnected;

  ///
  /// Call all the listeners when a message is received
  void addChatListener(Function(String sender, String message) callback) {
    _chatListeners.listen(callback);
  }

  ///
  /// Provide an easy access to the Debug Overlay Widget
  Widget debugOverlay({required child}) => _manager == null
      ? child
      : TwitchAppDebugOverlay(manager: _manager!, child: child);

  ///
  /// Provide an easy access to the TwitchManager connect dialog
  Future<bool> showConnectManagerDialog(BuildContext context,
      {bool reloadIfPossible = true}) async {
    if (_manager != null) {
      // Already connected
      return true;
    }

    final manager = await showDialog<TwitchAppManager>(
        context: context,
        builder: (context) => TwitchAppAuthenticationDialog(
              useMocker: _isMockActive,
              debugPanelOptions: _twitchDebugPanelOptions,
              onConnexionEstablished: (manager) {
                if (context.mounted) Navigator.of(context).pop(manager);
              },
              appInfo: _appInfo,
              reload: reloadIfPossible,
            ));
    if (manager == null) return false;

    _manager = manager;
    _manager!.chat.onMessageReceived.listen(_onMessageReceived);
    onTwitchManagerHasConnected.notifyListeners();

    return true;
  }

  Future<bool> disconnect() {
    if (_manager == null) {
      return Future.value(true);
    }

    _manager!.disconnect();
    _manager = null;
    onTwitchManagerHasDisconnected.notifyListeners();

    return Future.value(true);
  }

  /// -------- ///
  /// INTERNAL ///
  /// -------- ///
  TwitchAppManager? _manager;

  ///
  /// Declare the singleton
  static final TwitchManager _instance = TwitchManager._();
  TwitchManager._();
  static TwitchManager get instance => _instance;

  ///
  /// Twitch options
  bool _isMockActive = false;
  final _appInfo = TwitchAppInfo(
      appName: 'Chercheur de bleuets',
      twitchClientId: 's88tkbc2bsddutwte7bbnj616mhgqx',
      scope: const [
        TwitchAppScope.chatRead,
        TwitchAppScope.readFollowers,
      ],
      twitchRedirectUri: Uri.https(
          'twitchauthentication.pariterre.net', 'twitch_redirect.html'),
      authenticationServerUri:
          Uri.https('twitchserver.pariterre.net:3000', 'token'));

  ///
  /// Get the broadcaster id
  int get broadcasterId => _manager!.api.streamerId;

  ///
  /// Holds the callback to call when a message is received
  final _chatListeners =
      TwitchListener<Function(String sender, String message)>();
  void _onMessageReceived(String sender, String message) =>
      _chatListeners.notifyListeners((callback) => callback(sender, message));
}

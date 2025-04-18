/*
 * SPDX-FileCopyrightText: 2024 Open Alert Viewer authors
 *
 * SPDX-License-Identifier: MIT
 */

import 'dart:async';
import 'dart:io';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../../domain/alerts.dart';
import '../../data/repositories/settings_repo.dart';
import '../../domain/platform_channel.dart';
import '../../utils/utils.dart';
import '../domain/background_shared.dart';

const alertsNotificationId = 2;
const alertsNotificationTitle = "Open Alert Viewer";
const alertsNotificationChannelId = "Open Alert Viewer";
const alertsNotificationChannelName = "Alerts";
const alertsNotificationChannelDescription = "Alert Notifications";

const notificationIcon = "@drawable/notification_icon";

class NotificationsBackgroundRepo {
  NotificationsBackgroundRepo({
    required SettingsRepo settings,
    required PlatformChannel platformChannel,
  }) : _settings = settings,
       _platformChannel = platformChannel,
       _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin() {
    _updateAlertDetails(important: true);
  }

  final SettingsRepo _settings;
  final PlatformChannel _platformChannel;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin;
  NotificationDetails? _notificationDetails;

  Future<void> initializeAlertNotifications() async {
    if (Platform.isLinux) {
      var initializationSettingsLinux = const LinuxInitializationSettings(
        defaultActionName: "Launch app",
      );
      var initializationSettings = InitializationSettings(
        linux: initializationSettingsLinux,
      );
      await _flutterLocalNotificationsPlugin.initialize(initializationSettings);
    } else if (Platform.isAndroid) {
      const AndroidNotificationChannel alertChannel =
          AndroidNotificationChannel(
            alertsNotificationChannelId,
            alertsNotificationChannelName,
            description: alertsNotificationChannelDescription,
            importance: Importance.max,
          );
      await _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.createNotificationChannel(alertChannel);
    } else {
      throw Exception("Unsupported platform for notifications.");
    }
  }

  Future<void> _showNotification({required String message}) async {
    if (!await _settings.notificationsEnabledSafe) {
      return;
    }
    await _flutterLocalNotificationsPlugin.show(
      alertsNotificationId,
      alertsNotificationTitle,
      message,
      _notificationDetails,
    );
  }

  Future<void> _removeAlertNotification() async {
    await _flutterLocalNotificationsPlugin.cancel(alertsNotificationId);
  }

  Future<void> _playDesktopSound(
    StreamController<IsolateMessage>? alertStream,
    bool important,
  ) async {
    if (await _settings.notificationsEnabledSafe &&
        important &&
        _settings.soundEnabled &&
        !Platform.isAndroid &&
        !Platform.isIOS) {
      alertStream?.add(
        const IsolateMessage(
          name: MessageName.playDesktopSound,
          destination: MessageDestination.notifications,
        ),
      );
    }
  }

  Future<void> showFilteredNotifications({
    required List<Alert> alerts,
    required List<AlertSourceData> allSources,
    StreamController<IsolateMessage>? alertStream,
  }) async {
    Map<int?, Duration> sinceLookedPerSource = {};
    for (var sourceData in allSources) {
      sinceLookedPerSource[sourceData.id!] = sourceData.lastFetch.difference(
        sourceData.lastSeen,
      );
    }
    Map<int?, Duration> sincePriorFetchPerSource = {};
    for (var sourceData in allSources) {
      sincePriorFetchPerSource[sourceData.id!] = sourceData.lastFetch
          .difference(sourceData.priorFetch);
    }
    Duration globalSinceLooked = _settings.lastFetched.difference(
      _settings.lastSeen,
    );
    Duration globalSincePriorFetch = _settings.lastFetched.difference(
      _settings.priorFetch,
    );
    Duration? sinceLooked;
    Duration? sincePriorFetch;
    int newSyncFailureCount = 0, newDownCount = 0, newErrorCount = 0;
    int brandNew = 0, brandNewInc = 0;
    List<String> messages = [];
    for (var alert in alerts) {
      if (alert.kind == AlertType.syncFailure) {
        sinceLooked = globalSinceLooked;
        sincePriorFetch = globalSincePriorFetch;
      } else {
        sinceLooked = sinceLookedPerSource[alert.source];
        sincePriorFetch = sincePriorFetchPerSource[alert.source];
      }
      if (sinceLooked == null || sincePriorFetch == null) {
        continue;
      }
      if (alert.age.compareTo(sinceLooked) > 0) {
        continue;
      }
      if (alert.silenced || alert.downtimeScheduled || !alert.active) {
        continue;
      }
      if (allSources
              .where((e) => e.id == alert.source)
              .firstOrNull
              ?.notifications !=
          true) {
        continue;
      }
      brandNewInc = (alert.age.compareTo(sincePriorFetch) <= 0) ? 1 : 0;
      if (alert.kind == AlertType.syncFailure) {
        newSyncFailureCount += 1;
        brandNew += brandNewInc;
      } else if (alert.kind == AlertType.down ||
          alert.kind == AlertType.unreachable) {
        newDownCount += 1;
        brandNew += brandNewInc;
      } else if (alert.kind == AlertType.error) {
        newErrorCount += 1;
        brandNew += brandNewInc;
      }
    }
    if (newSyncFailureCount > 0) {
      messages.add(
        "$newSyncFailureCount New Sync Failure${newSyncFailureCount == 1 ? "" : "s"}",
      );
    }
    if (newDownCount > 0) {
      messages.add("$newDownCount Recently Down");
    }
    if (newErrorCount > 0) {
      messages.add("$newErrorCount New Error${newErrorCount == 1 ? "" : "s"}");
    }
    final important = (brandNew > 0);
    final didDetailsChange = _updateAlertDetails(important: important);
    if (messages.isNotEmpty) {
      if (Platform.isLinux && didDetailsChange) {
        await _removeAlertNotification();
      }
      await _showNotification(message: messages.join(", "));
      await _playDesktopSound(alertStream, important);
    } else {
      await _removeAlertNotification();
    }
    await updateAnroidStickyNotification();
  }

  Future<void> startOrStopStickyNotification() async {
    if (!await _settings.notificationsEnabledSafe ||
        _settings.refreshInterval == -1) {
      await disableNotifications();
    } else {
      await startAnroidStickyNotification();
    }
  }

  Future<void> startAnroidStickyNotification() async {
    if (!Platform.isAndroid ||
        !await _settings.notificationsEnabledSafe ||
        _settings.refreshInterval == -1) {
      return;
    }
    _platformChannel.startForegroundService();
    Util.runWithDelay(1, updateAnroidStickyNotification);
    Util.runWithDelay(3, updateAnroidStickyNotification);
    Util.runWithDelay(9, updateAnroidStickyNotification);
  }

  Future<void> updateAnroidStickyNotification() async {
    if (!Platform.isAndroid ||
        !await _settings.notificationsEnabledSafe ||
        _settings.refreshInterval == -1) {
      return;
    }
    var duration = Util.prettyPrintDuration(
      duration: Duration(seconds: _settings.refreshInterval),
      longForm: true,
      stripLeadingOne: true,
    );
    final text =
        "Sync every $duration "
        "- last: ${Util.getTimeString(_settings.lastFetched)}";
    _platformChannel.updateNotification(text);
  }

  Future<void> disableNotifications() async {
    if (Platform.isAndroid) {
      _platformChannel.stopForegroundService();
    }
    await _removeAlertNotification();
  }

  bool _updateAlertDetails({required bool important}) {
    final linuxUrgency =
        important
            ? LinuxNotificationUrgency.normal
            : LinuxNotificationUrgency.low;
    final androidImportance = important ? Importance.max : Importance.low;
    bool changed = false;
    if (Platform.isLinux &&
            linuxUrgency != _notificationDetails?.linux?.urgency ||
        Platform.isAndroid &&
            androidImportance != _notificationDetails?.android?.importance) {
      changed = true;
    }
    final linuxNotificationDetails = LinuxNotificationDetails(
      urgency: linuxUrgency,
    );
    var androidNotificationDetails = AndroidNotificationDetails(
      alertsNotificationChannelId,
      alertsNotificationChannelName,
      icon: notificationIcon,
      channelDescription: alertsNotificationChannelDescription,
      importance: androidImportance,
      silent: !(important && _settings.soundEnabled),
    );
    _notificationDetails = NotificationDetails(
      linux: linuxNotificationDetails,
      android: androidNotificationDetails,
    );
    return changed;
  }
}

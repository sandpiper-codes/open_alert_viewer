/*
 * SPDX-FileCopyrightText: 2024 Open Alert Viewer authors
 *
 * SPDX-License-Identifier: MIT
 */

import 'dart:async';
import 'dart:convert';

import '../../data/repositories/notifications_repo.dart';
import '../../domain/alerts.dart';
import '../services/database.dart';

class SettingsRepo {
  SettingsRepo({required LocalDatabase db})
    : _db = db,
      streamController = StreamController(),
      ready = Completer() {
    stream = streamController.stream.asBroadcastStream();
    ready.complete();
  }

  final StreamController<String> streamController;
  Stream<String>? stream;
  final Completer ready;
  static String? appVersion;
  final LocalDatabase _db;

  DateTime get lastFetched => _getSetting<DateTime>(
    "last_fetch_time",
    DateTime.fromMillisecondsSinceEpoch(0),
  );
  set lastFetched(value) => _setSetting<DateTime>("last_fetch_time", value);
  int get refreshInterval => _getSetting<int>("refresh_interval", 60);
  set refreshInterval(value) => _setSetting<int>("refresh_interval", value);
  int get syncTimeout => _getSetting<int>("sync_timeout", 10);
  set syncTimeout(value) => _setSetting<int>("sync_timeout", value);
  bool get notificationsRequested =>
      _getSetting<bool>("notifications_requested", false);
  set notificationsRequested(value) =>
      _setSetting<bool>("notifications_requested", value);
  bool get notificationsEnabledUnsafe =>
      _getSetting<bool>("notifications_enabled", false);
  Future<bool> get notificationsEnabledSafe async =>
      await NotificationsRepo.areNotificationsAllowed() &&
      notificationsEnabledUnsafe;
  set notificationsEnabled(value) =>
      _setSetting<bool>("notifications_enabled", value);
  DateTime get lastSeen => _getSetting<DateTime>(
    "last_seen",
    DateTime.fromMillisecondsSinceEpoch(0),
  );
  set lastSeen(value) => _setSetting<DateTime>("last_seen", value);
  DateTime get priorFetch => _getSetting<DateTime>(
    "prior_fetch_time",
    DateTime.fromMillisecondsSinceEpoch(0),
  );
  set priorFetch(value) => _setSetting<DateTime>("prior_fetch_time", value);
  List<bool> get alertFilter => _getSetting<List<bool>>("alert_filter", [
    true,
  ], opt: AlertType.values.length);
  set alertFilter(value) => _setSetting<List<bool>>("alert_filter", value);
  void setAlertFilterAt(bool value, int index) =>
      _setListAt<bool>("alert_filter", value, [true], index);
  int get darkMode => _getSetting<int>("dark_mode", -1);
  set darkMode(value) => _setSetting<int>("dark_mode", value);
  int get latestModalShown => _getSetting<int>("latest_modal_shown", 0);
  set latestModalShown(value) => _setSetting<int>("latest_modal_shown", value);
  bool get soundEnabled => _getSetting<bool>("sound_enabled", true);
  set soundEnabled(value) => _setSetting<bool>("sound_enabled", value);
  List<bool> get silenceFilter => _getSetting<List<bool>>("silence_filter", [
    true,
  ], opt: SilenceTypes.values.length);
  set silenceFilter(value) => _setSetting<List<bool>>("silence_filter", value);
  void setSilenceFilterAt(bool value, int index) =>
      _setListAt<bool>("silence_filter", value, [true], index);
  bool get batteryPermissionRequested =>
      _getSetting<bool>("battery_permission_requested", false);
  set batteryPermissionRequested(value) =>
      _setSetting<bool>("battery_permission_requested", value);

  T _getSetting<T>(String name, T defaultValue, {int? opt}) {
    String storedValue = _db.getSetting(setting: name);
    T value;
    try {
      if (T == int) {
        value = int.parse(storedValue) as T;
      } else if (T == bool) {
        value = bool.parse(storedValue) as T;
      } else if (T == String) {
        value = storedValue as T;
      } else if (T == DateTime) {
        value =
            DateTime.fromMillisecondsSinceEpoch(int.parse(storedValue)) as T;
      } else if (T == List<bool>) {
        value = List<bool>.from(jsonDecode(storedValue)) as T;
      } else {
        value = defaultValue;
      }
    } catch (e) {
      if (name == "alert_filter") {
        value =
            [false, true, true, false, true, false, true, true, false, true]
                as T;
      } else if (name == "silence_filter") {
        value = [true, true, true, true] as T;
      } else {
        value = defaultValue;
      }
    }
    if (T == DateTime && (value as DateTime).compareTo(DateTime.now()) > 0) {
      value = defaultValue;
    } else if ((name == "refresh_interval" || name == "sync_timeout") &&
        (value == 0 || value as int < -1)) {
      value = defaultValue;
    } else if (T == List<bool>) {
      int oldLength = (value as List).length;
      if (opt != null && opt > oldLength) {
        for (var i = oldLength; i < opt; i++) {
          (value as List).add((defaultValue as List)[0]);
        }
      }
    }
    return value;
  }

  void _setSetting<T>(String name, T newValue) {
    if (T == DateTime) {
      _setSetting<int>(name, (newValue as DateTime).millisecondsSinceEpoch);
    } else if (T == List<bool>) {
      _setSetting<String>(name, jsonEncode(newValue as List));
    } else {
      _db.setSetting(setting: name, value: newValue.toString());
    }
    streamController.add(name);
  }

  void _setListAt<T>(String name, T newValue, List<T> defaultValue, int index) {
    List<T> currentSetting = _getSetting<List<T>>(
      name,
      defaultValue,
      opt: index + 1,
    );
    currentSetting[index] = newValue;
    _setSetting<List<T>>(name, currentSetting);
  }
}

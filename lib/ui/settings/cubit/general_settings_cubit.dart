/*
 * SPDX-FileCopyrightText: 2024 Open Alert Viewer authors
 *
 * SPDX-License-Identifier: MIT
 */

import 'dart:async';

import 'package:app_settings/app_settings.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter/widgets.dart';

import '../../../background/domain/background_external.dart';
import '../../../background/domain/background_shared.dart';
import '../../../data/repositories/battery_repo.dart';
import '../../../data/repositories/settings_repo.dart';
import '../../../data/repositories/alerts_repo.dart';
import '../../../domain/settings.dart';
import '../../core/widgets/shared_widgets.dart';
import '../../../data/repositories/notifications_repo.dart';
import 'general_settings_state.dart';

class GeneralSettingsCubit extends Cubit<GeneralSettingsCubitState> {
  GeneralSettingsCubit({
    required SettingsRepo settings,
    required BackgroundChannel bgChannel,
    required NotificationsRepo notificationsRepo,
    required AlertsRepo alertsRepo,
  }) : _settingsRepo = settings,
       _bgChannel = bgChannel,
       _notificationsRepo = notificationsRepo,
       _alertsRepo = alertsRepo,
       super(GeneralSettingsCubitState.init()) {
    _state = state;
    refreshStateAsync();
  }

  final SettingsRepo _settingsRepo;
  final BackgroundChannel _bgChannel;
  final NotificationsRepo _notificationsRepo;
  final AlertsRepo _alertsRepo;
  GeneralSettingsCubitState? _state;

  Future<void> refreshStateAsync({BatterySetting? overrideBattery}) async {
    _state = _state!.copyWith(
      refreshIntervalSubtitle: () {
        for (var option in RefreshFrequencies.values) {
          if (option.value == _settingsRepo.refreshInterval) {
            return option.text;
          }
        }
        return "Every ${_settingsRepo.refreshInterval} seconds";
      }(),
    );
    _state = _state!.copyWith(
      syncTimeoutSubtitle: () {
        for (var option in SyncTimeouts.values) {
          if (option.value == _settingsRepo.syncTimeout) {
            return option.text;
          }
        }
        return "Every ${_settingsRepo.syncTimeout} seconds";
      }(),
    );
    _state = _state!.copyWith(
      darkModeSubtitle: () {
        for (var option in ColorModes.values) {
          if (option.value == _settingsRepo.darkMode) {
            return option.text;
          }
        }
        return "Unknown";
      }(),
    );
    _state = _state!.copyWith(
      notificationsEnabledSubtitle:
          (await _settingsRepo.notificationsEnabledSafe)
              ? "Enabled globally in app"
              : "Disabled globally",
    );
    _state = _state!.copyWith(
      soundEnabledSubtitle:
          _settingsRepo.soundEnabled ? "Enabled within app" : "Disabled",
    );
    _state = _state!.copyWith(
      batteryPermissionSubtitle:
          overrideBattery?.name ??
          (await BatteryPermissionRepo.getStatus()).name,
    );
    _state = _state!.copyWith(
      settings: {
        "refreshInterval": _settingsRepo.refreshInterval,
        "syncTimeout": _settingsRepo.syncTimeout,
        "notificationsEnabled": await _settingsRepo.notificationsEnabledSafe,
        "soundEnabled": _settingsRepo.soundEnabled,
        "alertFilter": _settingsRepo.alertFilter,
        "silenceFilter": _settingsRepo.silenceFilter,
        "darkMode": _settingsRepo.darkMode,
      },
    );
    emit(_state!);
  }

  Future<void> onTapRefreshIntervalButton(int? result) async {
    if (result == -1) {
      await _notificationsRepo.enableOrDisableNotifications(false);
    } else if (result != null) {
      await _notificationsRepo.enableOrDisableNotifications(true);
    }
    if (result != null) {
      _settingsRepo.refreshInterval = result;
      _alertsRepo.refreshTimer();
    }
    await refreshStateAsync();
  }

  Future<void> onTapSyncTimeoutButton(int? result) async {
    if (result != null) {
      _settingsRepo.syncTimeout = result;
      await refreshStateAsync();
      _alertsRepo.fetchAlerts(forceRefreshNow: true);
    }
  }

  Future<void> onTapNotificationsEnabled(BuildContext context) async {
    if (await _settingsRepo.notificationsEnabledSafe) {
      await _notificationsRepo.enableOrDisableNotifications(false);
    } else {
      if (context.mounted) {
        await requestAndEnableNotifications(askAgain: true, context: context);
      }
    }
    await refreshStateAsync();
  }

  void openAppSettings() {
    AppSettings.openAppSettings(type: AppSettingsType.notification);
  }

  Future<void> onTapPlaySoundEnabled() async {
    _settingsRepo.soundEnabled = !_settingsRepo.soundEnabled;
    await refreshStateAsync();
  }

  Future<void> onTapDarkMode(int? result) async {
    if (result != null) {
      _settingsRepo.darkMode = result;
      await refreshStateAsync();
    }
  }

  Future<void> _notifyAlertFiltersChanged() async {
    await _bgChannel.makeRequest(
      IsolateMessage(name: MessageName.alertFiltersChanged),
    );
  }

  Future<void> setAlertFilterAt(
    BuildContext _,
    bool? newValue,
    int index,
  ) async {
    _settingsRepo.setAlertFilterAt(newValue!, index);
    await refreshStateAsync();
    _notifyAlertFiltersChanged();
  }

  Future<void> setSilenceFilterAt(
    BuildContext _,
    bool? newValue,
    int index,
  ) async {
    _settingsRepo.setSilenceFilterAt(newValue!, index);
    await refreshStateAsync();
    _notifyAlertFiltersChanged();
  }

  Future<void> batteryRequest(
    Future<BatterySetting> Function() callback,
  ) async {
    await refreshStateAsync();
    refreshStateAsync(overrideBattery: await callback());
  }
}

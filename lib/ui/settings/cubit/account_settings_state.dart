/*
 * SPDX-FileCopyrightText: 2024 Open Alert Viewer authors
 *
 * SPDX-License-Identifier: MIT
 */

import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../domain/alerts.dart';

part 'account_settings_state.freezed.dart';

enum CheckStatus { needsCheck, checkingNow, responded }

@freezed
class AccountSettingsState with _$AccountSettingsState {
  const factory AccountSettingsState(
      {required AlertSourceData? sourceData,
      required CheckStatus status,
      required String statusText,
      required IconData? statusIcon,
      required bool allowClickAccept,
      required String acceptButtonText}) = _AccountSettingsState;

  factory AccountSettingsState.init() {
    return AccountSettingsState(
        sourceData: null,
        status: CheckStatus.needsCheck,
        statusText: "",
        statusIcon: null,
        allowClickAccept: true,
        acceptButtonText: "Pending...");
  }
}

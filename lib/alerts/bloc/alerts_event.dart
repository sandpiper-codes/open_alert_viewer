/*
 * SPDX-FileCopyrightText: 2024 Andrew Engelbrecht <andrew@sourceflow.dev>
 *
 * SPDX-License-Identifier: MIT
 */

abstract class AlertEvent {
  const AlertEvent();
}

final class FetchAlerts implements AlertEvent {
  FetchAlerts({required this.forceRefreshNow});

  final bool forceRefreshNow;
}

final class AddAlertSource implements AlertEvent {
  AddAlertSource({required this.source});

  final List<String> source;
}

final class UpdateAlertSource implements AlertEvent {
  UpdateAlertSource({required this.id, required this.source});

  final int id;
  final List<String> source;
}

final class RemoveAlertSource implements AlertEvent {
  RemoveAlertSource({required this.id});

  final int id;
}

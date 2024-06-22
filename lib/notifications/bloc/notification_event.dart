/*
 * SPDX-FileCopyrightText: 2024 Andrew Engelbrecht <andrew@sourceflow.dev>
 *
 * SPDX-License-Identifier: MIT
 */

part of 'notification_bloc.dart';

abstract class NotificationEvent {
  const NotificationEvent();
}

final class InitializeNotificationEvent extends NotificationEvent {
  InitializeNotificationEvent();
}

final class RequestAndEnableNotificationEvent extends NotificationEvent {
  RequestAndEnableNotificationEvent(
      {required this.askAgain, required this.callback, this.isAppVisible});

  final bool askAgain;
  final void Function() callback;
  final bool? isAppVisible;
}

final class ShowNotificationEvent extends NotificationEvent {
  ShowNotificationEvent({required this.message});

  final String message;
}

final class RemoveNotificationEvent extends NotificationEvent {
  RemoveNotificationEvent();
}

final class DisableNotificationsEvent extends NotificationEvent {
  DisableNotificationsEvent();
}

final class ShowFilteredNotificationsEvent extends NotificationEvent {
  ShowFilteredNotificationsEvent(
      {required this.timeSince, required this.alerts});

  final Duration timeSince;
  final List<Alert> alerts;
}

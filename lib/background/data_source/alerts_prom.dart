/*
 * SPDX-FileCopyrightText: 2024 okaycode.dev LLC and Open Alert Viewer authors
 *
 * SPDX-License-Identifier: MIT
 */

import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart';

import '../../alerts/model/alerts.dart';
import '../../app/data_source/network_fetch.dart';

class PromAlerts with NetworkFetch implements AlertSource {
  PromAlerts(
      {required this.id,
      required this.name,
      required this.type,
      required this.baseURL,
      required this.path,
      required this.username,
      required this.password})
      : _alerts = [];

  @override
  final int id;
  @override
  final String name;
  @override
  final int type;
  @override
  final String baseURL;
  @override
  final String path;
  @override
  final String username;
  @override
  final String password;
  List<Alert> _alerts;

  @override
  Future<List<Alert>> fetchAlerts() async {
    Response response;
    List<Alert> nextAlerts;
    PromAlertsData alertDatum;
    nextAlerts = [];
    try {
      response = await networkFetch(baseURL, path, username, password);
    } on SocketException catch (e) {
      nextAlerts = [
        Alert(
            source: id,
            kind: AlertType.syncFailure,
            hostname: name,
            service: "OAV",
            message: "Error fetching alerts: ${e.message}",
            url: generateURL(baseURL, path),
            age: Duration.zero)
      ];
      _alerts = nextAlerts;
      return _alerts;
    }
    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      for (var datum in data) {
        alertDatum = PromAlertsData.fromJSON(datum);
        var severity = alertDatum.labels['severity'] ?? "";
        var type = alertDatum.labels['oav_type'] ?? "";
        AlertType kind;
        if (RegExp(r"^(error|page|critical)$").hasMatch(severity)) {
          kind = RegExp(r"^(ping|icmp)$").hasMatch(type)
              ? AlertType.down
              : AlertType.error;
        } else if (RegExp(r"^(warning)$").hasMatch(severity)) {
          kind = AlertType.warning;
        } else {
          kind = AlertType.unknown;
        }
        nextAlerts.add(Alert(
            source: id,
            kind: kind,
            hostname: alertDatum.labels['instance'] ?? "",
            service: alertDatum.labels['alertname'] ?? "",
            message: alertDatum.annotations['summary'] ?? "",
            url: alertDatum.generatorURL,
            age: DateTime.now()
                .difference(DateTime.parse(alertDatum.startsAt))));
      }
    } else {
      nextAlerts = [
        Alert(
            source: id,
            kind: AlertType.syncFailure,
            hostname: name,
            service: "OAV",
            message: "Error fetching alerts: HTTP status code "
                "${response.statusCode}",
            url: generateURL(baseURL, path),
            age: Duration.zero)
      ];
    }
    _alerts = nextAlerts;
    return _alerts;
  }
}

class PromAlertsData {
  const PromAlertsData(
      {required this.fingerprint,
      required this.startsAt,
      required this.updatedAt,
      required this.endsAt,
      required this.generatorURL,
      required this.annotations,
      required this.labels});

  factory PromAlertsData.fromJSON(Map<String, dynamic> data) {
    return PromAlertsData(
        fingerprint: data["fingerprint"],
        startsAt: data["startsAt"],
        updatedAt: data["updatedAt"],
        endsAt: data["endsAt"],
        generatorURL: data["generatorURL"],
        annotations: mapConvert(data["annotations"]),
        labels: mapConvert(data["labels"]));
  }

  static Map<String, T> mapConvert<T>(Map<String, dynamic> data) {
    return {for (var MapEntry(:key, :value) in data.entries) key: value as T};
  }

  final String fingerprint;
  final String startsAt;
  final String updatedAt;
  final String endsAt;
  final String generatorURL;
  final Map<String, String> annotations;
  final Map<String, String> labels;
}

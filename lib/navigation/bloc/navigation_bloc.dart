/*
 * SPDX-FileCopyrightText: 2024 Open Alert Viewer authors
 *
 * SPDX-License-Identifier: MIT
 */

import 'package:bloc/bloc.dart';
import 'navigation_event.dart';
import 'navigation_state.dart';

class NavBloc extends Bloc<NavEvent, NavState> {
  NavBloc() : super(ShowAlertsPage()) {
    on<OpenAlertsPageEvent>(_openAlertsPage);
    on<OpenSettingsPageEvent>(_openSettingsPage);
    on<OpenGeneralSettingsPageEvent>(_openGeneralSettingsPage);
    on<OpenAboutPageEvent>(_openAboutPage);
    on<OpenAccountSettingsPageEvent>(_openAccountSettingsPage);
    on<OpenLicensingPageEvent>(_openLicensingPage);
    on<OpenPrivacyPageEvent>(_openPrivacyPage);
  }

  void _openAlertsPage(OpenAlertsPageEvent event, Emitter<NavState> emit) {
    emit(ShowAlertsPage());
  }

  void _openSettingsPage(OpenSettingsPageEvent event, Emitter<NavState> emit) {
    emit(ShowSettingsPage());
  }

  void _openGeneralSettingsPage(
      OpenGeneralSettingsPageEvent event, Emitter<NavState> emit) {
    emit(ShowGeneralSettingsPage());
  }

  void _openAboutPage(OpenAboutPageEvent event, Emitter<NavState> emit) {
    emit(ShowAboutPage());
  }

  void _openAccountSettingsPage(
      OpenAccountSettingsPageEvent event, Emitter<NavState> emit) {
    emit(ShowAccountSettingsPage(source: event.source));
  }

  void _openLicensingPage(
      OpenLicensingPageEvent event, Emitter<NavState> emit) {
    emit(ShowLicensingPage());
  }

  void _openPrivacyPage(OpenPrivacyPageEvent event, Emitter<NavState> emit) {
    emit(ShowPrivacyPage());
  }
}

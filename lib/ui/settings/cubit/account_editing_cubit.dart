/*
 * SPDX-FileCopyrightText: 2024 Open Alert Viewer authors
 *
 * SPDX-License-Identifier: MIT
 */

import 'package:bloc/bloc.dart';
import 'package:open_alert_viewer/data/services/network_fetch.dart';

import '../../../background/domain/background_external.dart';
import '../../../data/repositories/account_repo.dart';
import '../../../domain/alerts.dart';
import '../../../background/domain/background_shared.dart';
import '../../../utils/utils.dart';
import 'account_editing_state.dart';

class AccountEditingCubit extends Cubit<AccountEditingState> with NetworkFetch {
  AccountEditingCubit({
    required BackgroundChannel bgChannel,
    required AccountsRepo accountsRepo,
  }) : _bgChannel = bgChannel,
       _accountsRepo = accountsRepo,
       accountCheckSerial = -1,
       lastNeedsCheck = true,
       super(AccountEditingState.init()) {
    _state = state;
    _listenForConfirmations();
  }

  AccountEditingState? _state;
  final BackgroundChannel _bgChannel;
  final AccountsRepo _accountsRepo;
  int accountCheckSerial;
  bool lastNeedsCheck;

  void confirmSource({
    required AlertSourceDataUpdate newSourceData,
    bool? needsCheck,
    bool? checkNow,
  }) {
    needsCheck = lastNeedsCheck = needsCheck ?? false;
    checkNow = checkNow ?? false;
    if (needsCheck) {
      emit(
        _state = _state!.copyWith(
          sourceData: newSourceData,
          status: CheckStatus.needsCheck,
        ),
      );
    } else if (checkNow) {
      emit(
        _state = _state!.copyWith(
          sourceData: newSourceData,
          status: CheckStatus.checkingNow,
        ),
      );
      newSourceData = newSourceData.copyWith(
        serial: accountCheckSerial = Util.genRandom(),
      );
      _bgChannel.makeRequest(
        IsolateMessage(
          name: MessageName.confirmSources,
          sourceData: newSourceData,
        ),
      );
    }
  }

  void addSource(AlertSourceDataUpdate sourceData) {
    _bgChannel.makeRequest(
      IsolateMessage(name: MessageName.addSource, sourceData: sourceData),
    );
  }

  void updateSource(AlertSourceDataUpdate sourceData) {
    _bgChannel.makeRequest(
      IsolateMessage(name: MessageName.updateSource, sourceData: sourceData),
    );
  }

  void removeSource(int id) {
    _bgChannel.makeRequest(
      IsolateMessage(name: MessageName.removeSource, id: id),
    );
  }

  bool _checkUniqueSource({int? id, required String name}) {
    return _accountsRepo.checkUniqueSource(id: id, name: name);
  }

  String? Function(String?) generateAccountNameValidator(int? id) {
    return (String? value) {
      if (value == null || value == "") {
        return "Please enter a name";
      }
      return _checkUniqueSource(id: id, name: value)
          ? null
          : "Name already used";
    };
  }

  String? baseUrlValidator(String? value) {
    if (value == null || value == "") {
      return "Please enter a valid URL";
    }
    try {
      if (Uri.parse(generateURL(value, "")).isAbsolute) {
        return null;
      }
    } catch (e) {
      // fall through
    }
    return "Please enter a valid URL";
  }

  void cleanOut() {
    accountCheckSerial = Util.genRandom();
    lastNeedsCheck = true;
    emit(_state = AccountEditingState.init());
  }

  void getStatusDetails(Function() onResponseCallback) {
    String status;
    IconType? icon;
    if (state.status == CheckStatus.responded) {
      onResponseCallback();
      if (state.sourceData!.isValid ?? false) {
        status = "Found API endpoint";
        icon = IconType.valid;
      } else {
        var error = state.sourceData!.errorMessage;
        if (error == "") {
          error = "Unkown Error";
        }
        status = "Error: $error";
        icon = IconType.invalid;
      }
    } else if (state.status == CheckStatus.needsCheck) {
      status = "";
      icon = null;
    } else {
      status = "Checking...";
      icon = IconType.checking;
    }
    emit(_state = _state!.copyWith(statusText: status, statusIcon: icon));
  }

  void setAcceptButtonText(AlertSourceData? originalSource, bool isValid) {
    bool allowClick;
    if (_state!.status == CheckStatus.needsCheck ||
        _state!.status == CheckStatus.responded) {
      allowClick = true;
    } else {
      allowClick = false;
    }
    String title;
    if (_state!.status == CheckStatus.needsCheck) {
      title = "Check Account";
    } else if (_state!.status == CheckStatus.responded) {
      if (isValid) {
        if (originalSource == null) {
          title = "Add Account";
        } else {
          title = "Update Account";
        }
      } else {
        title = "Try Again";
      }
    } else {
      title = "Checking...";
    }
    emit(
      _state = _state!.copyWith(
        allowClickAccept: allowClick,
        acceptButtonText: title,
      ),
    );
  }

  Future<void> _listenForConfirmations() async {
    await for (final message
        in _bgChannel
            .isolateStreams[MessageDestination.accountEditing]!
            .stream) {
      if (message.name == MessageName.confirmSourcesReply) {
        if (message.sourceData!.serial == accountCheckSerial &&
            !lastNeedsCheck) {
          emit(
            _state = _state!.copyWith(
              sourceData: message.sourceData,
              status: CheckStatus.responded,
            ),
          );
        }
      } else {
        throw Exception(
          "OAV Invalid 'accounts' stream message name: ${message.name}",
        );
      }
    }
  }
}

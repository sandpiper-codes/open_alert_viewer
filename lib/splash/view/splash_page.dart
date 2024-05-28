/*
 * SPDX-FileCopyrightText: 2024 Andrew Engelbrecht <andrew@sourceflow.dev>
 *
 * SPDX-License-Identifier: MIT
 */

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../app/bloc/navigation_bloc.dart';
import '../../app/bloc/navigation_event.dart';
import '../../app/data_provider/database.dart';
import '../bloc/splash_bloc.dart';
import '../bloc/splash_state.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key, required this.title});

  final String title;

  static Route<void> route({required title}) {
    return MaterialPageRoute<void>(builder: (_) => SplashPage(title: title));
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        create: (_) => SplashBloc(localDatabase: context.read<LocalDatabase>()),
        child: BlocListener<SplashBloc, SplashState>(
            listener: (context, state) {
              switch (state) {
                case SplashComplete():
                  context.read<NavBloc>().add(OpenAlertsPageEvent());
              }
            },
            child: const Scaffold(
                body: Align(
                    alignment: Alignment.center,
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(
                            size: 96,
                            Icons.swap_calls,
                          ),
                          Text(
                              style: TextStyle(fontSize: 24),
                              textAlign: TextAlign.center,
                              "Open Alert Viewer"),
                        ])))));
  }
}

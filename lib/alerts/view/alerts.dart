import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/alert_events.dart';
import '../bloc/alert_state.dart';
import '../bloc/alerts.dart';
import '../model/alerts.dart';
import 'alert.dart';

class AlertsPage extends StatelessWidget {
  const AlertsPage({super.key, required this.title, required this.sources});

  final String title;
  final List<AlertSource> sources;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        create: (context) => AlertsBloc(),
        child:
            Scaffold(appBar: Header(title: title), body: const AlertsList()));
  }
}

class Header extends StatelessWidget implements PreferredSizeWidget {
  const Header({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        title: Text(title),
        actions: [
          Ink(
              decoration: const ShapeDecoration(
                color: Colors.black,
                shape: CircleBorder(),
              ),
              child: IconButton(
                  icon: const Icon(Icons.add),
                  color: Colors.white,
                  onPressed: () => context
                      .read<AlertsBloc>()
                      .add(AddAlertSource(source: RandomAlerts())))),
          const SizedBox(width: 10),
          Ink(
              decoration: const ShapeDecoration(
                color: Colors.black,
                shape: CircleBorder(),
              ),
              child: IconButton(
                  icon: const Icon(Icons.refresh),
                  color: Colors.white,
                  onPressed: () => context
                      .read<AlertsBloc>()
                      .add(const FetchAlerts(maxCacheAge: Duration.zero)))),
          const SizedBox(width: 10)
        ]);
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class AlertsList extends StatelessWidget {
  const AlertsList({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AlertsBloc, AlertState>(builder: (context, state) {
      List<Widget> alertWidgets = [];
      for (var alert in state.alerts) {
        alertWidgets.add(AlertWidget(alert: alert));
      }
      return ListView(children: alertWidgets);
    });
  }
}

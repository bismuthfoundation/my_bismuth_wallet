// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:event_taxi/event_taxi.dart';

// Project imports:
import 'package:my_bismuth_wallet/bus/events.dart';
import 'package:my_bismuth_wallet/styles.dart';

class SyncInfoView extends StatefulWidget {
  const SyncInfoView({
    Key? key,
    this.showServerName = true,
    this.iconSize = 20,
    this.dotSize = 10,
  }) : super(key: key);

  final bool showServerName;
  final double iconSize;
  final double dotSize;

  @override
  _SyncInfoViewState createState() => _SyncInfoViewState();
}

class _SyncInfoViewState extends State<SyncInfoView> {
  bool connected = false;
  String serverName = "";

  // Subscriptions
  late final StreamSubscription<ConnStatusEvent> _connStatusEventSub;

  @override
  void initState() {
    _registerBus();
    super.initState();
  }

  void _registerBus() {
    _connStatusEventSub =
        EventTaxiImpl.singleton().registerTo<ConnStatusEvent>().listen((event) {
      setState(() {
        serverName = event.server ?? "";
        if (event.status == ConnectionStatus.CONNECTED) {
          connected = true;
        } else {
          connected = false;
        }
      });
    });
  }

  @override
  void dispose() {
    _destroyBus();
    super.dispose();
  }

  void _destroyBus() {
    _connStatusEventSub.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return _buildChild();
  }

  Widget _buildChild() {
    final Color indicatorColor = connected ? Colors.green : Colors.red;
    final String statusLabel = connected ? "API connected" : "API disconnected";

    if (!widget.showServerName) {
      return Tooltip(
        message: statusLabel,
        child: Container(
          width: widget.dotSize,
          height: widget.dotSize,
          decoration: BoxDecoration(
            color: indicatorColor,
            shape: BoxShape.circle,
          ),
        ),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(serverName, style: AppStyles.textStyleTiny(context)),
        Icon(
          Icons.signal_cellular_alt_rounded,
          color: indicatorColor,
          size: widget.iconSize,
        ),
      ],
    );
  }
}

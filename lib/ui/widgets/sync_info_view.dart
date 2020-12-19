import 'dart:async';

import 'package:flutter/material.dart';
import 'package:my_bismuth_wallet/network/model/response/wstatusget_response.dart';
import 'package:my_bismuth_wallet/service/app_service.dart';

class SyncInfoView extends StatefulWidget {
  const SyncInfoView({Key key}) : super(key: key);

  @override
  _SyncInfoViewState createState() => _SyncInfoViewState();
}

class _SyncInfoViewState extends State<SyncInfoView> {
  Timer _timerSync;
  WStatusGetResponse wStatusGetResponse;
  AppService appService = new AppService();

  @override
  void initState() {
    _timeSyncUpdate();
    super.initState();
  }

  @override
  void dispose() {
    _timerSync.cancel();
    super.dispose();
  }

  _timeSyncUpdate() {
    _timerSync = Timer(const Duration(seconds: 2), () async {
      wStatusGetResponse = await appService.getWStatusGetResponse();
      if (!mounted) return;
      setState(() {});
      _timeSyncUpdate();
    });
  }

  @override
  Widget build(BuildContext context) {
    return _buildChild();
  }

  Widget _buildChild() {
    if (wStatusGetResponse == null) {
      return Icon(Icons.signal_cellular_connected_no_internet_4_bar_rounded,
          color: Colors.red);
    } else {
      return Icon(Icons.signal_cellular_alt_rounded, color: Colors.green);
    }
  }
}

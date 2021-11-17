// @dart=2.9

// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:my_bismuth_wallet/appstate_container.dart';
import 'package:my_bismuth_wallet/localization.dart';
import 'package:my_bismuth_wallet/styles.dart';
import 'package:my_bismuth_wallet/ui/widgets/app_simpledialog.dart';

class AppDialogs {
  static void showConfirmDialog(
      var context, var title, var content, var buttonText, Function onPressed,
      {String cancelText, Function cancelAction}) {
    if (cancelText == null) {
      cancelText = AppLocalization.of(context).cancel.toUpperCase();
    }
    showAppDialog(
      context: context,
      builder: (BuildContext context) {
        return AppAlertDialog(
          title: Text(
            title,
            style: AppStyles.textStyleButtonPrimaryOutline(context),
          ),
          content: Text(content, style: AppStyles.textStyleParagraph(context)),
          actions: <Widget>[
            FlatButton(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4.0)),
              padding: EdgeInsets.all(12),
              child: Container(
                constraints: BoxConstraints(maxWidth: 100),
                child: Text(
                  cancelText,
                  style: AppStyles.textStyleDialogButtonText(context),
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                if (cancelAction != null) {
                  cancelAction();
                }
              },
            ),
            FlatButton(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4.0)),
              padding: EdgeInsets.all(12),
              child: Container(
                constraints: BoxConstraints(maxWidth: 100),
                child: Text(
                  buttonText,
                  style: AppStyles.textStyleDialogButtonText(context),
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                onPressed();
              },
            ),
          ],
        );
      },
    );
  }
}

enum AnimationType {
  SEND,
}

class AnimationLoadingOverlay extends ModalRoute<void> {
  AnimationType type;
  Function onPoppedCallback;
  Color overlay85;
  Color overlay70;

  AnimationLoadingOverlay(this.type, this.overlay85, this.overlay70,
      {this.onPoppedCallback});

  @override
  Duration get transitionDuration => Duration(milliseconds: 0);

  @override
  bool get opaque => false;

  @override
  bool get barrierDismissible => false;

  @override
  Color get barrierColor {
    return overlay70;
  }

  @override
  String get barrierLabel => null;

  @override
  bool get maintainState => false;

  @override
  void didComplete(void result) {
    if (this.onPoppedCallback != null) {
      this.onPoppedCallback();
    }
    super.didComplete(result);
  }

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return Material(
      type: MaterialType.transparency,
      child: SafeArea(
        child: _buildOverlayContent(context),
      ),
    );
  }

  Widget _getAnimation(BuildContext context) {
    switch (type) {
      case AnimationType.SEND:
        return Center();
      default:
        return CircularProgressIndicator(
            valueColor: new AlwaysStoppedAnimation<Color>(
                StateContainer.of(context).curTheme.primary60));
    }
  }

  Widget _buildOverlayContent(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: type == AnimationType.SEND
          ? MainAxisAlignment.end
          : MainAxisAlignment.center,
      children: <Widget>[
        Container(
          margin: type == AnimationType.SEND
              ? EdgeInsets.only(bottom: 10.0, left: 90, right: 90)
              : EdgeInsets.zero,
          //Widgth/Height ratio is needed because BoxFit is not working as expected
          width: type == AnimationType.SEND ? double.infinity : 100,
          height: type == AnimationType.SEND
              ? MediaQuery.of(context).size.width
              : 100,
          child: _getAnimation(context),
        ),
      ],
    );
  }

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    return child;
  }
}

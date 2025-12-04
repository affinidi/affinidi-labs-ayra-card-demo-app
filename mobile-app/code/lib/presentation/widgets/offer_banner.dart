import 'package:flutter/material.dart';

import '../helpers/screensize_helper.dart';

class OfferBanner extends StatelessWidget {
  const OfferBanner({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO(MA): make image transparent and use a gradient derived from theme
    return Container(
      constraints: BoxConstraints(
        maxHeight: ScreensizeHelper.getConstrainedWidth(context) * 0.25,
      ),
      child: Row(
        children: [
          Expanded(
            child: Image.asset(
              'assets/images/meetingplace-banner.jpg',
              fit: BoxFit.fitWidth,
              alignment: Alignment.center,
            ),
          ),
        ],
      ),
    );
  }
}

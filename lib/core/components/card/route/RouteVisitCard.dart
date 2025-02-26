import 'package:_12sale_app/core/components/chart/CircularChart.dart';
import 'package:_12sale_app/core/components/layout/BoxShadowCustom.dart';
import 'package:_12sale_app/core/styles/style.dart';
import 'package:_12sale_app/data/models/Store.dart';
import 'package:_12sale_app/data/models/route/RouteVisit.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:skeletonizer/skeletonizer.dart';

class RouteVisitCard extends StatelessWidget {
  final RouteVisit item;
  final VoidCallback onDetailsPressed;
  const RouteVisitCard({
    required this.item,
    required this.onDetailsPressed,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onDetailsPressed,
      child: Container(
        height: 170,
        margin: EdgeInsets.all(8.0),
        child: BoxShadowCustom(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 8),
            // color: Colors.cyan,
            decoration: BoxDecoration(
              // color: Styles.successTextColor,
              borderRadius: BorderRadius.circular(16.0),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Row(
                    // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: 100,
                        child: Column(
                          children: [
                            Row(
                              // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'R${item.day}',
                                  style: Styles.headerBlack24(context),
                                ),
                                // Text(
                                //   'R${item.day}',
                                //   style: Styles.headerBlack24(context),
                                // ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'ทั้งหมด',
                                  style: Styles.black18(context),
                                ),
                                Text(
                                  '${item.storeAll}',
                                  style: Styles.black18(context),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'ซื้อ',
                                  style: Styles.black18(context),
                                ),
                                Text(
                                  '${item.storeSell}',
                                  style: Styles.black18(context),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'ไม่ซื้อ',
                                  style: Styles.black18(context),
                                ),
                                Text(
                                  '${item.storeNotSell}',
                                  style: Styles.black18(context),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'รอเยี่ยม',
                                  style: Styles.black18(context),
                                ),
                                Text(
                                  '${item.storePending}',
                                  style: Styles.black18(context),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Row(
                          children: [
                            Container(
                              padding: EdgeInsets.only(
                                bottom: 35,
                                top: 35,
                                left: 45,
                              ),
                              child: CustomPaint(
                                size: Size(200, 200),
                                painter: CircularChartPainter(
                                    completionPercentage: item.percentComplete,
                                    effectivenessPercentage:
                                        item.percentEffective),
                                child: Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        "${item.storeTotal}/${item.storeAll}",
                                        style: Styles.black18(context),
                                      ),
                                      SizedBox(
                                        width: 60,
                                      )
                                      // Text(
                                      //   "150,000 ฿",
                                      //   style: Styles.black18(context),
                                      // ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

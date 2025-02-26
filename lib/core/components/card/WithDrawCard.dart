import 'package:_12sale_app/core/components/layout/BoxShadowCustom.dart';
import 'package:_12sale_app/core/styles/style.dart';
import 'package:_12sale_app/data/models/order/OrderDetail.dart';
import 'package:_12sale_app/data/models/order/Orders.dart';
import 'package:_12sale_app/data/models/withdraw/Withdraw.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:skeletonizer/skeletonizer.dart';

class WithDrawCard extends StatelessWidget {
  final Withdraw item;
  final VoidCallback onDetailsPressed;
  const WithDrawCard({
    required this.item,
    required this.onDetailsPressed,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return GestureDetector(
      onTap: onDetailsPressed,
      child: Container(
        height: screenWidth / 4,
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: BoxShadowCustom(
          child: Container(
            // color: Colors.cyan,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FaIcon(
                        FontAwesomeIcons.clock,
                        color: Styles.primaryColor,
                        size: 35,
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Expanded(
                        flex: 8,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      "เลขที่: ${item.orderId} ",
                                      style: Styles.headerBlack18(context),
                                    ),
                                  ],
                                ),
                                Skeleton.ignore(
                                  child: Container(
                                    width: screenWidth / 6,
                                    padding: EdgeInsets.all(2),

                                    // height: screenWidth / ,
                                    decoration: BoxDecoration(
                                      color: item.status == 'completed'
                                          ? Styles.success
                                          : item.status == 'canceled'
                                              ? Styles.fail
                                              : Styles.warning,
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                    child: Text(
                                      '${item.status.toUpperCase()}',
                                      style: Styles.white16(context),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              "จำนวนเบิก: ${item.total.toStringAsFixed(0)} หีบ",
                              style: Styles.black16(context),
                            ),
                            Text(
                              "วันที่เบิก: ${DateFormat('dd/MM/yyyy | HH:mm:ss').format(item.created)}",
                              style: Styles.black16(context),
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    "วันที่รับ:   ${DateFormat("dd/MM/yyyy").format(DateTime.parse(item.sendDate))}",
                                    style: Styles.black16(context),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Text(
                                  "ประเภท: ${item.orderTypeName}",
                                  style: Styles.black16(context),
                                ),
                              ],
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

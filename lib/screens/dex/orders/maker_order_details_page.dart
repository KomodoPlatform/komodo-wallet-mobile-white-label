import 'package:flutter/material.dart';
import 'package:komodo_dex/localizations.dart';
import 'package:komodo_dex/model/cex_provider.dart';
import 'package:komodo_dex/model/coin.dart';
import 'package:komodo_dex/model/order.dart';
import 'package:komodo_dex/model/order_book_provider.dart';
import 'package:komodo_dex/utils/utils.dart';
import 'package:komodo_dex/widgets/cex_data_marker.dart';
import 'package:komodo_dex/widgets/theme_data.dart';
import 'package:provider/provider.dart';

class MakerOrderDetailsPage extends StatefulWidget {
  const MakerOrderDetailsPage(this.order);

  final Order order;

  @override
  _MakerOrderDetailsPageState createState() => _MakerOrderDetailsPageState();
}

class _MakerOrderDetailsPageState extends State<MakerOrderDetailsPage> {
  CexProvider cexProvider;

  @override
  Widget build(BuildContext context) {
    cexProvider ??= Provider.of<CexProvider>(context);

    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).makerDetailsTitle),
      ),
      body: Container(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: <Widget>[
            Card(
              elevation: 8,
              child: Container(
                padding: const EdgeInsets.only(
                  left: 16,
                  right: 12,
                  top: 12,
                  bottom: 24,
                ),
                child: Table(
                  columnWidths: const {
                    0: IntrinsicColumnWidth(),
                    1: FlexColumnWidth(1.0),
                  },
                  defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                  children: [
                    ..._buildBase(),
                    ..._buildRel(),
                    ..._buildPrice(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<TableRow> _buildBase() {
    return [
      TableRow(children: [
        Container(
          height: 40,
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.only(right: 6),
          child: Text(
            AppLocalizations.of(context).makerDetailsSell + ':',
            style: Theme.of(context).textTheme.body2,
          ),
        ),
        Container(
          padding: const EdgeInsets.only(left: 6),
          child: Row(
            children: <Widget>[
              CircleAvatar(
                radius: 7,
                backgroundColor: Colors.transparent,
                backgroundImage: AssetImage('assets/'
                    '${widget.order.base.toLowerCase()}.png'),
              ),
              const SizedBox(width: 4),
              Text(widget.order.base),
              const SizedBox(width: 12),
              Text(
                formatPrice(double.parse(widget.order.baseAmount)),
                style: Theme.of(context).textTheme.subtitle.copyWith(
                      fontWeight: FontWeight.normal,
                    ),
              ),
            ],
          ),
        )
      ])
    ];
  }

  List<TableRow> _buildRel() {
    return [
      TableRow(children: [
        Container(
          height: 40,
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.only(right: 6),
          child: Text(
            AppLocalizations.of(context).makerDetailsFor + ':',
            style: Theme.of(context).textTheme.body2,
          ),
        ),
        Container(
          padding: const EdgeInsets.only(left: 6),
          child: Row(
            children: <Widget>[
              CircleAvatar(
                radius: 7,
                backgroundColor: Colors.transparent,
                backgroundImage: AssetImage('assets/'
                    '${widget.order.rel.toLowerCase()}.png'),
              ),
              const SizedBox(width: 4),
              Text(widget.order.rel),
              const SizedBox(width: 12),
              Text(
                formatPrice(double.parse(widget.order.relAmount)),
                style: Theme.of(context).textTheme.subtitle.copyWith(
                      fontWeight: FontWeight.normal,
                    ),
              ),
            ],
          ),
        )
      ])
    ];
  }

  List<TableRow> _buildPrice() {
    return [
      TableRow(
        children: [
          Container(
            height: 30,
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.only(right: 6),
            child: Text(AppLocalizations.of(context).makerDetailsPrice + ':',
                style: Theme.of(context).textTheme.body2),
          ),
          Container(
            padding: const EdgeInsets.only(left: 6),
            child: Row(
              children: <Widget>[
                Text(
                  formatPrice(double.parse(widget.order.relAmount) /
                      double.parse(widget.order.baseAmount)),
                  style: TextStyle(color: Colors.red),
                ),
                const SizedBox(width: 6),
                Text(
                  '${widget.order.rel} / 1${widget.order.base}',
                ),
              ],
            ),
          ),
        ],
      ),
      TableRow(
        children: [
          Container(),
          Container(
            padding: const EdgeInsets.only(left: 6),
            child: Row(
              children: <Widget>[
                Text(
                  formatPrice(double.parse(widget.order.baseAmount) /
                      double.parse(widget.order.relAmount)),
                  style: const TextStyle(
                    fontSize: 13,
                  ),
                ),
                const SizedBox(width: 6),
                Text('${widget.order.base} / 1${widget.order.rel}',
                    style: const TextStyle(
                      fontSize: 13,
                    )),
              ],
            ),
          ),
        ],
      ),
      ..._buildCexchangeRate(),
    ];
  }

  List<TableRow> _buildCexchangeRate() {
    final double cexPrice = cexProvider.getCexRate(CoinsPair(
          sell: Coin(abbr: widget.order.base),
          buy: Coin(abbr: widget.order.rel),
        )) ??
        0.0;
    if (cexPrice == 0) return [];

    final double price = double.parse(widget.order.relAmount) /
        double.parse(widget.order.relAmount);
    final double delta = (cexPrice - price) * 100 / price;
    final num sign = delta.sign;

    String message;
    switch (sign) {
      case -1:
        {
          message = AppLocalizations.of(context)
              .orderDetailsExpedient(formatPrice(delta, 2));
          break;
        }
      case 1:
        {
          message = AppLocalizations.of(context)
              .orderDetailsExpensive(formatPrice(delta, 2));
          break;
        }
      default:
        {
          message = AppLocalizations.of(context).orderDetailsIdentical;
        }
    }

    return [
      TableRow(
        children: [
          Container(
            height: 40,
            alignment: Alignment.centerLeft,
            child: CexMarker(context),
          ),
          Container(
            padding: const EdgeInsets.only(left: 6),
            height: 40,
            alignment: Alignment.centerLeft,
            child: Text(
              message,
              style: const TextStyle(color: cexColor),
            ),
          ),
        ],
      )
    ];
  }
}

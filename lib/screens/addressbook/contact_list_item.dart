import 'package:flutter/material.dart';
import 'package:komodo_dex/blocs/coins_bloc.dart';
import 'package:komodo_dex/blocs/dialog_bloc.dart';
import 'package:komodo_dex/localizations.dart';
import 'package:komodo_dex/model/addressbook_provider.dart';
import 'package:komodo_dex/model/coin.dart';
import 'package:komodo_dex/model/coin_balance.dart';
import 'package:komodo_dex/screens/addressbook/contact_edit.dart';
import 'package:komodo_dex/screens/portfolio/coin_detail/coin_detail.dart';
import 'package:komodo_dex/utils/utils.dart';
import 'package:komodo_dex/widgets/custom_simple_dialog.dart';
import 'package:provider/provider.dart';

class ContactListItem extends StatefulWidget {
  const ContactListItem(
    this.contact, {
    Key key,
    this.shouldPop = false,
    this.coin,
    this.expanded = false,
  }) : super(key: key);

  final Contact contact;
  final bool shouldPop;
  final Coin coin;
  final bool expanded;

  @override
  _ContactListItemState createState() => _ContactListItemState();
}

class _ContactListItemState extends State<ContactListItem> {
  bool expanded = false;
  AddressBookProvider addressBookProvider;

  @override
  void initState() {
    expanded = widget.expanded;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    addressBookProvider = Provider.of<AddressBookProvider>(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        ListTile(
          onTap: () {
            setState(() {
              expanded = !expanded;
            });
          },
          title: Text(widget.contact.name),
        ),
        if (expanded)
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16),
            child: Column(
              children: <Widget>[
                _buildAddressesList(),
                SizedBox(height: 8),
                TextButton.icon(
                  onPressed: () => Navigator.push<dynamic>(
                    context,
                    MaterialPageRoute<dynamic>(
                      builder: (BuildContext context) =>
                          ContactEdit(contact: widget.contact),
                    ),
                  ),
                  icon: const Icon(Icons.edit, size: 16),
                  label: Text(AppLocalizations.of(context).contactEdit),
                )
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildAddressesList() {
    final List<Widget> addresses = [];

    widget.contact.addresses?.forEach(
      (String abbr, String value) {
        if (widget.coin != null) {
          String coinAbbr = widget.coin.abbr;
          if (widget.coin.type == 'erc') coinAbbr = 'ETH';
          if (widget.coin.type == 'bep') coinAbbr = 'BNB';
          if (widget.coin.type == 'plg') coinAbbr = 'MATIC';
          if (widget.coin.type == 'qrc') coinAbbr = 'QTUM';
          if (widget.coin.type == 'ftm') coinAbbr = 'FTM';
          if (widget.coin.type == 'smartChain') coinAbbr = 'KMD';

          if (coinAbbr != abbr) return;
        }

        addresses.add(
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: <Widget>[
                CircleAvatar(
                  maxRadius: 6,
                  foregroundImage: AssetImage(
                      'assets/coin-icons/${abbr2Ticker(abbr.toLowerCase())}.png'),
                ),
                const SizedBox(width: 8),
                Text(
                  '$abbr: ',
                  style: Theme.of(context).textTheme.subtitle1,
                ),
                Flexible(
                  child: InkWell(
                    onTap: () => _tryToSend(abbr, value),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 8,
                      ),
                      child: Row(
                        children: <Widget>[
                          Flexible(
                            child: truncateMiddle(
                              value,
                              style: Theme.of(context)
                                  .textTheme
                                  .subtitle2
                                  .copyWith(
                                    color:
                                        Theme.of(context).colorScheme.secondary,
                                  ),
                            ),
                          ),
                          Icon(
                            Icons.chevron_right,
                            color: Theme.of(context).colorScheme.secondary,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (addresses.isEmpty) {
      addresses.add(Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          children: <Widget>[
            Text(
              AppLocalizations.of(context).addressNotFound,
              style: TextStyle(
                color: Theme.of(context).disabledColor,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ));
    }

    return Column(
      children: addresses,
    );
  }

  void _tryToSend(String abbr, String value) {
    final CoinBalance coinBalance = coinsBloc.coinBalance.firstWhere(
      (CoinBalance balance) {
        return balance.coin.abbr == abbr;
      },
      orElse: () => null,
    );
    if (widget.coin == null && coinBalance == null) {
      _showWarning(
        title: AppLocalizations.of(context).noSuchCoin,
        message: AppLocalizations.of(context).addressCoinInactive(abbr),
      );
      return;
    }

    addressBookProvider.clipboard = value;
    if (widget.shouldPop) {
      Navigator.of(context).pop();
    } else {
      Navigator.push<dynamic>(
          context,
          MaterialPageRoute<dynamic>(
            builder: (BuildContext context) => CoinDetail(
              coinBalance: coinBalance,
              isSendIsActive: true,
            ),
          ));
    }
  }

  void _showWarning({String title, String message}) {
    dialogBloc.dialog = showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return CustomSimpleDialog(
          title: Row(
            children: <Widget>[
              const Icon(Icons.warning),
              const SizedBox(width: 8),
              Text(title),
            ],
          ),
          children: <Widget>[
            Row(
              children: <Widget>[
                Flexible(
                    child: Text(
                  message,
                  textAlign: TextAlign.justify,
                  style: const TextStyle(
                    height: 1.4,
                  ),
                )),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: () => dialogBloc.closeDialog(context),
                  child: Text(AppLocalizations.of(context).warningOkBtn),
                ),
              ],
            ),
          ],
        );
      },
    ).then((dynamic _) => dialogBloc.dialog = null);
  }
}

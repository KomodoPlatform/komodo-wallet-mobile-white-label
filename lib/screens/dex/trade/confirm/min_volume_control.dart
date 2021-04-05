import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:komodo_dex/localizations.dart';
import 'package:komodo_dex/screens/dex/trade/trade_form.dart';
import 'package:komodo_dex/utils/decimal_text_input_formatter.dart';

class MinVolumeControl extends StatefulWidget {
  const MinVolumeControl({@required this.coin, this.onChange, this.validator});

  final String coin;
  final Function(String) onChange;
  final Function(String) validator;

  @override
  _MinVolumeControlState createState() => _MinVolumeControlState();
}

class _MinVolumeControlState extends State<MinVolumeControl> {
  final TextEditingController _valueCtrl = TextEditingController();
  bool _isActive = false;
  String _value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (_isActive) _buildControl(),
        _buildToggle(),
      ],
    );
  }

  Widget _buildControl() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 12, 8, 4),
          child: Text(
            '${AppLocalizations.of(context).minVolumeTitle}:',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyText1,
          ),
        ),
        Container(
          width: double.infinity,
          color: Theme.of(context).primaryColor,
          padding: EdgeInsets.fromLTRB(32, 8, 32, 8),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(top: 8.0),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 7,
                          backgroundImage: AssetImage('assets/'
                              '${widget.coin.toLowerCase()}.png'),
                        ),
                        SizedBox(width: 2),
                        Text(widget.coin),
                      ],
                    ),
                  ),
                  SizedBox(width: 6),
                  Expanded(
                    child: TextFormField(
                      controller: _valueCtrl,
                      keyboardType:
                          TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        isDense: true,
                        focusedBorder: UnderlineInputBorder(
                          borderSide:
                              BorderSide(color: Theme.of(context).accentColor),
                        ),
                      ),
                      maxLines: 1,
                      inputFormatters: <TextInputFormatter>[
                        LengthLimitingTextInputFormatter(16),
                        DecimalTextInputFormatter(decimalRange: 8),
                      ],
                      autovalidateMode: AutovalidateMode.always,
                      validator: widget.validator,
                      onChanged: (String text) {
                        setState(() {
                          _value = text;
                        });
                        widget.onChange(_value);
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        )
      ],
    );
  }

  Widget _buildToggle() {
    return InkWell(
      onTap: () {
        setState(() {
          _isActive = !_isActive;
          if (_isActive) {
            _value ??= '${tradeForm.minVolumeDefault(widget.coin)}';
            _valueCtrl.text = _value;
            widget.onChange(_value);
          } else {
            widget.onChange(null);
          }
        });
      },
      child: Padding(
        padding: EdgeInsets.fromLTRB(30, 8, 30, 8),
        child: Row(
          children: <Widget>[
            Icon(
              _isActive ? Icons.check_box : Icons.check_box_outline_blank,
              size: 18,
            ),
            const SizedBox(width: 3),
            Expanded(
              child: Text(
                AppLocalizations.of(context).minVolumeToggle,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

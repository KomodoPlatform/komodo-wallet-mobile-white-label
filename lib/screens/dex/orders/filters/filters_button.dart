import 'package:flutter/material.dart';
import 'package:komodo_dex/screens/dex/orders/filters/filters.dart';

class FiltersButton extends StatelessWidget {
  const FiltersButton({
    this.onPressed,
    this.activeFilters,
    this.isActive,
  });

  final Function onPressed;
  final ActiveFilters activeFilters;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final Color color = Theme.of(context).textTheme.bodyText1.color;

    return InkWell(
      onTap: onPressed,
      child: Container(
        padding: EdgeInsets.fromLTRB(0, 8, 8, 8),
        child: Row(
          children: [
            Icon(
              Icons.filter_alt_outlined,
              size: 14,
              color: color,
            ),
            SizedBox(width: 2),
            Text(
              'Filter',
              style: Theme.of(context).textTheme.bodyText1.copyWith(
                    color: color,
                  ),
            ),
            Icon(isActive ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                size: 14, color: color),
          ],
        ),
      ),
    );
  }
}

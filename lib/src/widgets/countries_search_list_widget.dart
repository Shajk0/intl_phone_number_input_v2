import 'package:flutter/material.dart';
import 'package:intl_phone_number_input_v2/src/models/country_model.dart';
import 'package:intl_phone_number_input_v2/src/utils/test/test_helper.dart';
import 'package:intl_phone_number_input_v2/src/utils/util.dart';

/// Creates a list of Countries with a search textfield.
class CountrySearchListWidget extends StatefulWidget {
  final List<Country> countries;
  final InputDecoration? searchBoxDecoration;
  final String? locale;
  final ScrollController? scrollController;
  final bool autoFocus;
  final bool? showFlags;
  final bool? useEmoji;
  final EdgeInsetsGeometry? searchBoxPadding;
  final List<String>? favoriteCountries;
  final Widget? favoriteHeadlineWidget;
  final Widget? countryListHeadlineWidget;

  CountrySearchListWidget(
    this.countries,
    this.locale, {
    this.searchBoxDecoration,
    this.scrollController,
    this.showFlags,
    this.useEmoji,
    this.autoFocus = false,
    this.searchBoxPadding,
    this.favoriteCountries,
    this.favoriteHeadlineWidget,
    this.countryListHeadlineWidget,
  });

  @override
  _CountrySearchListWidgetState createState() =>
      _CountrySearchListWidgetState();
}

class _CountrySearchListWidgetState extends State<CountrySearchListWidget> {
  late TextEditingController _searchController = TextEditingController();
  late List<Country> filteredCountries;
  List<Country>? favoriteCountries;

  @override
  void initState() {
    final String value = _searchController.text.trim();
    filteredCountries = Utils.filterCountries(
      countries: widget.countries,
      locale: widget.locale,
      value: value,
    );
    if (widget.favoriteCountries != null &&
        widget.favoriteCountries!.isNotEmpty) {
      favoriteCountries = widget.countries
          .where((country) =>
              widget.favoriteCountries!.contains(country.alpha2Code))
          .toList();
    }

    super.initState();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Returns [InputDecoration] of the search box
  InputDecoration getSearchBoxDecoration() {
    return widget.searchBoxDecoration ??
        InputDecoration(labelText: 'Search by country name or dial code');
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Padding(
          padding: widget.searchBoxPadding ??
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: TextFormField(
            key: Key(TestHelper.CountrySearchInputKeyValue),
            decoration: getSearchBoxDecoration(),
            controller: _searchController,
            autofocus: widget.autoFocus,
            cursorColor: Colors.black,
            onChanged: (value) {
              final String value = _searchController.text.trim();
              return setState(
                () => filteredCountries = Utils.filterCountries(
                  countries: widget.countries,
                  locale: widget.locale,
                  value: value,
                ),
              );
            },
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            controller: widget.scrollController,
            child: Column(
              children: [
                if (favoriteCountries != null &&
                    favoriteCountries!.isNotEmpty) ...{
                  if (widget.favoriteHeadlineWidget != null)
                    widget.favoriteHeadlineWidget!,
                  ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: widget.favoriteCountries?.length,
                    itemBuilder: (context, index) {
                      return DirectionalCountryListTile(
                        country: favoriteCountries![index],
                        locale: widget.locale,
                        showFlags: widget.showFlags!,
                        useEmoji: widget.useEmoji!,
                      );
                    },
                  ),
                },
                if (widget.countryListHeadlineWidget != null)
                  widget.countryListHeadlineWidget!,
                ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  controller: widget.scrollController,
                  shrinkWrap: true,
                  itemCount: filteredCountries.length,
                  itemBuilder: (BuildContext context, int index) {
                    Country country = filteredCountries[index];

                    return DirectionalCountryListTile(
                      country: country,
                      locale: widget.locale,
                      showFlags: widget.showFlags!,
                      useEmoji: widget.useEmoji!,
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }
}

class DirectionalCountryListTile extends StatelessWidget {
  final Country country;
  final String? locale;
  final bool showFlags;
  final bool useEmoji;

  const DirectionalCountryListTile({
    Key? key,
    required this.country,
    required this.locale,
    required this.showFlags,
    required this.useEmoji,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      key: Key(TestHelper.countryItemKeyValue(country.alpha2Code)),
      leading: (showFlags
          ? _Flag(country: country, useEmoji: useEmoji, circleFlags: false)
          : null),
      title: Align(
        alignment: AlignmentDirectional.centerStart,
        child: Text(
          '${Utils.getCountryName(country, locale)}',
          textDirection: Directionality.of(context),
          textAlign: TextAlign.start,
        ),
      ),
      // subtitle: Align(
      //   alignment: AlignmentDirectional.centerStart,
      //   child: Text(
      //     '${country.dialCode ?? ''}',
      //     textDirection: TextDirection.ltr,
      //     textAlign: TextAlign.start,
      //   ),
      // ),
      trailing: Text(
        '${country.dialCode ?? ''}',
      ),
      onTap: () => Navigator.of(context).pop(country),
    );
  }
}

class _Flag extends StatelessWidget {
  final Country? country;
  final bool? useEmoji;
  final bool? circleFlags;

  const _Flag({Key? key, this.country, this.useEmoji, this.circleFlags})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return country != null
        ? Container(
            child: useEmoji!
                ? Text(
                    Utils.generateFlagEmojiUnicode(country?.alpha2Code ?? ''),
                    style: Theme.of(context).textTheme.headlineSmall,
                  )
                : country?.flagUri != null
                    ? circleFlags == true
                        ? CircleAvatar(
                            backgroundImage: AssetImage(
                              country!.flagUri,
                              package: 'intl_phone_number_input_v2',
                            ),
                          )
                        : Image.asset(
                            country!.flagUri,
                            package: 'intl_phone_number_input_v2',
                            width: 32,
                            height: 32,
                          )
                    : SizedBox.shrink(),
          )
        : SizedBox.shrink();
  }
}

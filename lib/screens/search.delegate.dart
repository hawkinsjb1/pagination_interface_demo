import 'package:flutter/material.dart';
import 'package:pagination_interface_demo/components/spinner.dart';
import 'package:pagination_interface_demo/services/api.service.dart';
import 'package:pagination_interface_demo/screens/demo.bloc.dart';
import 'package:pagination_interface_demo/components/debouncer.dart';
import 'package:pagination_interface_demo/main.dart';
import 'package:pagination_interface_demo/paged.dart';

class SearchDelegatePagination extends SearchDelegate {
  late Paged<Country> searchedCountries;
  final ScrollController _scrollController = ScrollController();
  final _debounce = Debouncer();

  SearchDelegatePagination() {
    searchedCountries = Paged(
        expectedPageSize: kPageSize,
        load: (page) => ApiService.loadCountries(page, kPageSize, true, query));

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >
          _scrollController.position.maxScrollExtent * .9)
        searchedCountries.next();
    });
  }

  @override
  List<Widget> buildActions(BuildContext context) => [];
  @override
  Widget buildLeading(BuildContext context) => BackButton();
  @override
  Widget buildResults(BuildContext context) => content(query);

  @override
  Widget buildSuggestions(BuildContext context) {
    _debounce.run(() async => searchedCountries.reload());
    return content(query);
  }

  content(query) {
    return StreamBuilder(
      stream: searchedCountries.notifier.stream,
      builder: (context, snapshot) {
        return Column(
          children: [
            (searchedCountries.loadingInitial)
                ? Spinner(
                    label: 'Searching Countries...',
                  )
                : Expanded(
                    child: ListView(
                      // use ListView.builder in production app
                      controller: _scrollController,
                      children: [
                        ...searchedCountries.items
                            .map((country) =>
                                ListTile(title: Text(country.name)))
                            .toList(),
                        if (searchedCountries.loadingMore) Spinner(),
                      ],
                    ),
                  ),
          ],
        );
      },
    );
  }
}

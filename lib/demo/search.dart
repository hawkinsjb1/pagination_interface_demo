import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pagination_interface_demo/demo/api.service.dart';
import 'package:pagination_interface_demo/paged.dart';

class SearchDelegatePagination extends SearchDelegate {
  late Paged<Country> searchedCountries;
  final ScrollController _scrollController = ScrollController();
  final _debounce = Debouncer();

  SearchDelegatePagination() {
    searchedCountries =
        Paged(load: (page) => ApiService.loadCountries(page, true, query));

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >
          _scrollController.position.maxScrollExtent * .9)
        searchedCountries.next();
    });
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return [];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return BackButton();
  }

  @override
  Widget buildResults(BuildContext context) {
    return content(query);
  }

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
                ? Container(
                    width: double.infinity,
                    child: Column(
                      children: [
                        _buildProgressIndicator(),
                        Text('Searching Countries...')
                      ],
                    ),
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
                        if (searchedCountries.loadingMore)
                          _buildProgressIndicator(),
                      ],
                    ),
                  ),
          ],
        );
      },
    );
  }

  _buildProgressIndicator() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: CircularProgressIndicator(
          color: Colors.grey,
        ),
      ),
    );
  }
}

class Debouncer {
  final int milliseconds;
  Timer? _timer;
  Debouncer({this.milliseconds = 500});
  run(VoidCallback action) {
    if (_timer != null) {
      _timer!.cancel();
    } else {
      action();
    }
    _timer = Timer(Duration(milliseconds: milliseconds), action);
  }
}

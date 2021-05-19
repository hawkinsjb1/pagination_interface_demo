import 'package:flutter/material.dart';
import 'package:pagination_interface_demo/demo/api.service.dart';
import 'package:pagination_interface_demo/paged.dart';

class SearchDelegatePagination extends SearchDelegate {
  late Paged<Country> searchedCountries;
  final ScrollController _scrollController = ScrollController();

  SearchDelegatePagination() {
    searchedCountries =
        Paged(load: (i) => ApiService.loadCountries(i, true, query));

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
    return content(query);
  }

  content(query) {
    searchedCountries.reload();
    return StreamBuilder(
      stream: searchedCountries.notifier.stream,
      builder: (context, snapshot) {
        return Column(
          children: [
            (searchedCountries.loadingInitial)
                ? _buildProgressIndicator()
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
        child: CircularProgressIndicator(),
      ),
    );
  }
}

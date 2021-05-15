import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pagination_interface_demo/demo/bloc.dart';

class SearchDelegatePagination extends SearchDelegate {
  BlocPagination bloc = BlocPagination();
  final ScrollController _scrollController = ScrollController();

  SearchDelegatePagination() {
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >
          _scrollController.position.maxScrollExtent * .9)
        bloc.state.pagedCountries.next();
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
    return content();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query != bloc.state.searchText) {
      bloc.search(query);
    }
    return content();
  }

  content() {
    return BlocBuilder<BlocPagination, BlocPaginationState>(
        bloc: bloc,
        builder: (context, state) {
          return Column(
            children: [
              (state.pagedCountries.loadingInitial)
                  ? _buildProgressIndicator()
                  : Expanded(
                      child: ListView(
                        // use ListView.builder in production app
                        controller: _scrollController,
                        children: [
                          ...state.pagedCountries.items
                              .map((country) =>
                                  ListTile(title: Text(country.name)))
                              .toList(),
                          if (state.pagedCountries.loadingMore)
                            _buildProgressIndicator(),
                        ],
                      ),
                    ),
            ],
          );
        });
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

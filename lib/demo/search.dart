import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pagination_interface_demo/demo/api.service.dart';
import 'package:pagination_interface_demo/paged.dart';

class SearchState {
  final Paged<Country>? pagedCountries;
  final String searchText;
  SearchState({required this.pagedCountries, this.searchText = ""});
  SearchState copyWith({Paged<Country>? pagedCountries, String? searchText}) {
    return SearchState(
      pagedCountries: pagedCountries ?? this.pagedCountries,
      searchText: searchText ?? this.searchText,
    );
  }
}

class SearchBloc extends Cubit<SearchState> {
  SearchBloc() : super(SearchState()) {
    state.pagedCountries?.load =
        (i) => ApiService.searchCountries(state.searchText, i);
  }
}

class CustomSearchDelegate extends SearchDelegate {
  Paged<Country> pagedCountries = Paged((i) => ApiService.loadCountries(i));

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
    if (query != bloc.state.query) {
      bloc.search(query);
    }
    return content();
  }

  content() {
    return pagedCountries.items.map(
      (e) => ListTile(
        title: Text(e.name),
        subtitle: Text(e.code),
      ),
    );
  }
}

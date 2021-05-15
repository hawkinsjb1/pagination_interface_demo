import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pagination_interface_demo/demo/api.service.dart';
import 'package:pagination_interface_demo/paged.dart';

class BlocPaginationState {
  final Paged pagedCountries;
  final bool ascending;
  final String searchText;
  BlocPaginationState(
      {required this.pagedCountries,
      required this.ascending,
      this.searchText = ""});
  BlocPaginationState copyWith(
      {Paged? pagedCountries, bool? ascending, String? searchText}) {
    return BlocPaginationState(
      pagedCountries: pagedCountries ?? this.pagedCountries,
      ascending: ascending ?? this.ascending,
      searchText: searchText ?? this.searchText,
    );
  }
}

class BlocPagination extends Cubit<BlocPaginationState> {
  BlocPagination()
      : super(BlocPaginationState(
            pagedCountries: Paged<Country>(), ascending: true)) {
    // define load function
    state.pagedCountries.load =
        (i) => ApiService.loadCountries(i, state.ascending, state.searchText);

    // handle state changes
    state.pagedCountries.notifier.stream
        .listen((x) => emit(state.copyWith(pagedCountries: x)));

    // immediately load first page
    state.pagedCountries.next();
  }

  // 'reload()' will empty items prior to load because they are outdated once sort has changed
  setSortDirection(bool x) =>
      {emit(state.copyWith(ascending: x)), state.pagedCountries.reload()};

  // add debouncing in production app
  search(text) =>
      {emit(state.copyWith(searchText: text)), state.pagedCountries.reload()};
}

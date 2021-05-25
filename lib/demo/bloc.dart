import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pagination_interface_demo/demo/api.service.dart';
import 'package:pagination_interface_demo/paged.dart';

class BlocPaginationState {
  final Paged pagedCountries;
  final bool ascending;
  BlocPaginationState({required this.pagedCountries, required this.ascending});
  BlocPaginationState copyWith({Paged? pagedCountries, bool? ascending}) {
    return BlocPaginationState(
      pagedCountries: pagedCountries ?? this.pagedCountries,
      ascending: ascending ?? this.ascending,
    );
  }
}

class BlocPagination extends Cubit<BlocPaginationState> {
  BlocPagination()
      : super(BlocPaginationState(
            pagedCountries: Paged<Country>(), ascending: true)) {
    // define load function
    state.pagedCountries.load =
        (i) => ApiService.loadCountries(i, state.ascending, "");

    // handle state changes
    state.pagedCountries.notifier.stream
        .listen((x) => emit(state.copyWith(pagedCountries: x)));

    // immediately load first page
    state.pagedCountries.next();
  }

  setSortDirection(bool x) =>
      {emit(state.copyWith(ascending: x)), state.pagedCountries.reload()};
}

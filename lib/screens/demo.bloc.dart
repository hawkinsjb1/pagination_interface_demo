import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pagination_interface_demo/services/api.service.dart';
import 'package:pagination_interface_demo/paged.dart';

const kPageSize = 30;

class PaginationDemoBlocState {
  final Paged pagedCountries;
  final bool ascending;
  PaginationDemoBlocState(
      {required this.pagedCountries, required this.ascending});
  PaginationDemoBlocState copyWith({Paged? pagedCountries, bool? ascending}) {
    return PaginationDemoBlocState(
      pagedCountries: pagedCountries ?? this.pagedCountries,
      ascending: ascending ?? this.ascending,
    );
  }
}

class PaginationDemoBloc extends Cubit<PaginationDemoBlocState> {
  PaginationDemoBloc()
      : super(PaginationDemoBlocState(
          pagedCountries: Paged<Country>(expectedPageSize: kPageSize),
          ascending: true,
        )) {
    // define load function
    state.pagedCountries.load = (i) async =>
        await ApiService.loadCountries(i, kPageSize, state.ascending, "");

    // handle state changes
    state.pagedCountries.notifier.stream
        .listen((x) => emit(state.copyWith(pagedCountries: x)));

    // immediately load first page
    state.pagedCountries.next();
  }

  setSortDirection(bool x) =>
      {emit(state.copyWith(ascending: x)), state.pagedCountries.reload()};
}

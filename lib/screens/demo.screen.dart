import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pagination_interface_demo/components/spinner.dart';
import 'package:pagination_interface_demo/screens/demo.bloc.dart';
import 'package:pagination_interface_demo/screens/search.delegate.dart';

class PaginationDemoScreen extends StatefulWidget {
  @override
  _PaginationDemoScreenState createState() => _PaginationDemoScreenState();
}

class _PaginationDemoScreenState extends State<PaginationDemoScreen> {
  final PaginationDemoBloc bloc = PaginationDemoBloc();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    // scroll view detection
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >
          _scrollController.position.maxScrollExtent * .9)
        bloc.state.pagedCountries.next();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PaginationDemoBloc, PaginationDemoBlocState>(
      bloc: bloc,
      builder: (context, state) {
        return Scaffold(
          appBar: _buildAppBar(),
          body: RefreshIndicator(
            onRefresh: () => state.pagedCountries.refresh(),
            child: state.pagedCountries.failed
                ? _errorGraphic()
                : Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: RadioListTile(
                              value: true,
                              groupValue: bloc.state.ascending,
                              onChanged: bloc.state.pagedCountries.loading
                                  ? null
                                  : (v) => bloc.setSortDirection(v as bool),
                              title: Text('ascending'),
                            ),
                          ),
                          Expanded(
                            child: RadioListTile(
                              value: false,
                              groupValue: bloc.state.ascending,
                              onChanged: bloc.state.pagedCountries.loading
                                  ? null
                                  : (v) => bloc.setSortDirection(v as bool),
                              title: Text('descending'),
                            ),
                          ),
                        ],
                      ),
                      (state.pagedCountries.loadingInitial)
                          ? Container(
                              width: double.infinity,
                              child: Column(
                                children: [
                                  Spinner(),
                                  Text('Loading Countries...')
                                ],
                              ),
                            )
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
                                    Spinner(),
                                ],
                              ),
                            ),
                    ],
                  ),
          ),
        );
      },
    );
  }

  _buildAppBar() {
    return AppBar(
      title: Text('Countries'),
      actions: [
        IconButton(
          icon: Icon(Icons.search),
          onPressed: () => showSearch(
            context: context,
            delegate: SearchDelegatePagination(),
          ),
        ),
      ],
    );
  }

  _errorGraphic() {
    return SizedBox(
      width: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            ':(',
            style: TextStyle(fontSize: 48),
          ),
          TextButton(
            onPressed: () => bloc.state.pagedCountries.reload(),
            child: Text('RELOAD'),
          ),
        ],
      ),
    );
  }
}

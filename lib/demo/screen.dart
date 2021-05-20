import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pagination_interface_demo/demo/bloc.dart';
import 'package:pagination_interface_demo/demo/search.dart';

// add completer to pagination model
class ScreenPagination extends StatefulWidget {
  @override
  _ScreenPaginationState createState() => _ScreenPaginationState();
}

class _ScreenPaginationState extends State<ScreenPagination> {
  final BlocPagination bloc = BlocPagination();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >
          _scrollController.position.maxScrollExtent * .9)
        bloc.state.pagedCountries.next();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BlocPagination, BlocPaginationState>(
      bloc: bloc,
      builder: (context, state) {
        return Scaffold(
          appBar: _buildAppBar(),
          body: RefreshIndicator(
            onRefresh: () {
              // 'refresh()' will keep loaded items in view until fetch is finished
              state.pagedCountries.refresh();
              return state.pagedCountries.refreshCompleter.future;
            },
            child: Column(
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
                            _buildProgressIndicator(),
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
                              _buildProgressIndicator(),
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
}

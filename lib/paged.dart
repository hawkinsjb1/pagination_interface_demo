import 'dart:async';

class Paged<T> {
  // primarily needed for calling setState/emit upon state changes
  final StreamController<Paged<T>> notifier =
      StreamController<Paged<T>>.broadcast();

  // the dynamic function to pass page # to
  Function(int)? load;

  Paged({this.load});

  List<T> items = [];
  int page = 0;

  bool _hasMore = true;
  bool _paging = false;
  bool _failed = false;

  // various states built from internal values
  bool get loading => _paging;
  bool get loadingInitial => _paging && page == 1 && items.isEmpty;
  bool get refreshing => _paging && page == 1 && items.isNotEmpty;
  bool get loadingMore => _paging && page > 1;
  bool get loadedAll => !_hasMore;
  bool get noData => !_hasMore && items.isEmpty;
  bool get failed => _failed;

  // load next page (defaults to 1st)
  void next() async {
    clearFailed();

    if (load == null || !_hasMore || _paging) return;

    try {
      page += 1;
      _paging = true;
      notifier.add(this);

      var nextItems = await load!(page);
      _hasMore = !(nextItems == null || nextItems.isEmpty);
      items.addAll(nextItems);

      _paging = false;
    } catch (_) {
      _paging = false;
      _failed = true;
    }

    notifier.add(this);
  }

  // remove items in list => load data (will likely show spinner in UI)
  void reload() => {reset(), next()};

  // load data => set items in list (will avoid showing spinner in UI)
  Future<void> refresh() async {
    clearFailed();

    if (load == null) return;

    try {
      page = 1;
      _paging = true;
      notifier.add(this);

      var nextItems = await load!(page);
      _hasMore = !(nextItems == null || nextItems.isEmpty);
      items = nextItems;

      _paging = false;
    } catch (_) {
      _paging = false;
      _failed = true;
    }

    notifier.add(this);
  }

  void clearFailed() {
    if (_failed) {
      page = 0;
      _failed = false;
      notifier.add(this);
    }
  }

  void reset() => {items.clear(), page = 0, _paging = false, _hasMore = true};

  void dipose() => notifier.close();
}

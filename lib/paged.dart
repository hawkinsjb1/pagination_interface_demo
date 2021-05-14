import 'dart:async';

class Paged<T> {
  // primarily needed for calling setState/emit upon state changes
  final StreamController<Paged<T>> notifier = StreamController<Paged<T>>();

  // the dynamic function to pass page # to
  Function(int) load;

  Paged(this.load);

  List<T> items = [];

  // useful for refresh indicators
  Completer refreshCompleter = Completer();

  // internal values
  bool hasMore = true;
  bool paging = false;
  int page = 0;

  // various states built from internal values
  bool get loading => paging;
  bool get loadingInitial => paging && items.isEmpty;
  bool get loadingMore => paging && items.isNotEmpty;
  bool get loadedAll => !hasMore;
  bool get noData => !hasMore && items.isEmpty;

  // load next page (defaults to 1st)
  void next() async {
    if (!hasMore || paging) return;
    page += 1;

    paging = true;
    notifier.add(this);

    var nextItems = await this.load(this.page);
    hasMore = !(nextItems == null || nextItems.isEmpty);
    items.addAll(nextItems);

    paging = false;
    notifier.add(this);
  }

  // remove items in list => load data (will likely show spinner in UI)
  void reload() => {this.clear(), this.next()};

  // load data => set items in list (will avoid showing spinner in UI)
  void refresh() async {
    page = 1;

    var nextItems = await this.load(this.page);
    hasMore = !(nextItems == null || nextItems.isEmpty);
    items = nextItems;

    paging = false;
    refreshCompleter.complete();
    refreshCompleter = Completer();

    notifier.add(this);
  }

  void clear() => {items.clear(), page = 0, paging = false, hasMore = true};
}

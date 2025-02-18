import 'package:cached_annotation/cached_annotation.dart';

import '../../utils/test_utils.dart';

part 'cached_test_asynchronous.cached.dart';

const int ttlDurationSeconds = 1;

@withCache
abstract class AsynchronousCached implements _$AsynchronousCached {
  int _counter = 0;

  factory AsynchronousCached(
    TestDataProvider dataProvider,
  ) = _AsynchronousCached;

  @Cached(syncWrite: true)
  Future<int> syncCachedValue({@ignoreCache bool refresh = false}) {
    return dataProvider.fetchRandomValue();
  }

  @Cached(ttl: ttlDurationSeconds, syncWrite: true)
  Future<int> syncCachedValueWithTTl() async {
    _counter++;
    await Future.delayed(const Duration(milliseconds: 100));
    return dataProvider.fetchRandomValue();
  }

  @Cached(syncWrite: false)
  Future<int> asyncCachedValue({@ignoreCache bool refresh = false}) {
    return dataProvider.fetchRandomValue();
  }

  @Cached(ttl: ttlDurationSeconds, syncWrite: false)
  Future<int> asyncCachedValueWithTTl() async {
    _counter++;
    await Future.delayed(const Duration(milliseconds: 100));
    return dataProvider.fetchRandomValue();
  }

  @ClearCached("asyncCachedValue")
  void clearAsyncCachedValue();

  @ClearCached("asyncCachedValueWithTTl")
  void clearAsyncTTLCachedValue();

  @ClearCached("syncCachedValue")
  void clearCachedValue();

  @ClearCached("syncCachedValueWithTTl")
  void clearCachedValueWithTTl();

  @clearAllCached
  void clearAll();

  void resetCounter() => _counter = 0;

  int counter() => _counter;
}

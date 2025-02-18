import 'package:test/test.dart';
import '../utils/test_utils.dart';
import 'asynchronous/cached_test_asynchronous.dart';

int _slightlyLessThanTTL() => ttlDurationSeconds * 1000 - 10;

void main() {
  group('AsynchronousCache with syncWrite: TRUE', () {
    late TestDataProvider _dataProvider;

    setUp(() {
      _dataProvider = TestDataProvider();
    });

    test('cached value should be the same on the second method call', () async {
      final cachedClass = AsynchronousCached(_dataProvider);

      final results = await Future.wait(
          [cachedClass.syncCachedValue(), cachedClass.syncCachedValue()]);

      expect(results[0], equals(results[1]));
    });

    test('clear cache method should clear cache', () async {
      final cachedClass = AsynchronousCached(_dataProvider);
      final cachedValue = await cachedClass.syncCachedValue();
      cachedClass.clearCachedValue();
      final secondCachedValue = await cachedClass.syncCachedValue();

      expect(cachedValue != secondCachedValue, true);
    });

    test(
        'setting ignoreCache to true should ignore cached value and return new one',
        () async {
      final cachedClass = AsynchronousCached(_dataProvider);
      final cachedValue = await cachedClass.syncCachedValue();
      final secondCachedValue =
          await cachedClass.syncCachedValue(refresh: true);

      expect(cachedValue != secondCachedValue, true);
    });

    test(
        'cached method with set TTL, should return old value when there is no timeout',
        () async {
      final cachedClass = AsynchronousCached(_dataProvider);

      final cachedValueFuture = cachedClass.syncCachedValueWithTTl();
      await Future.delayed(const Duration(milliseconds: 10));
      final secondCachedValueFuture = cachedClass.syncCachedValueWithTTl();

      await Future.wait([cachedValueFuture, secondCachedValueFuture]);
      await Future.delayed(Duration(milliseconds: _slightlyLessThanTTL()));
      await cachedClass.syncCachedValueWithTTl();

      expect(cachedClass.counter(), 1);
    });

    test('cached method with set TTL, should return new value when TTL timeout',
        () async {
      final cachedClass = AsynchronousCached(_dataProvider);

      final cachedValueFuture = cachedClass.syncCachedValueWithTTl();
      await Future.delayed(const Duration(milliseconds: 10));
      final secondCachedValueFuture = cachedClass.syncCachedValueWithTTl();

      await Future.wait([cachedValueFuture, secondCachedValueFuture]);
      await Future.delayed(const Duration(seconds: ttlDurationSeconds));
      await cachedClass.syncCachedValueWithTTl();

      expect(cachedClass.counter(), 2);
    });
  });
  group('AsynchronousCache with syncWrite: FALSE', () {
    late TestDataProvider _dataProvider;

    setUp(() {
      _dataProvider = TestDataProvider();
    });

    test(
        'two calls of the same async functions, should return different values',
        () async {
      final cachedClass = AsynchronousCached(_dataProvider);
      final results = await Future.wait(
          [cachedClass.asyncCachedValue(), cachedClass.asyncCachedValue()]);

      expect(results[0], isNot(equals(results[1])));
    });

    test(
        'cached method with set TTL, should return old value when there is no timeout',
        () async {
      final cachedClass = AsynchronousCached(_dataProvider);

      final cachedValueFuture = cachedClass.asyncCachedValueWithTTl();
      await Future.delayed(const Duration(milliseconds: 10));
      final secondCachedValueFuture = cachedClass.asyncCachedValueWithTTl();

      await Future.wait([cachedValueFuture, secondCachedValueFuture]);
      await Future.delayed(Duration(milliseconds: _slightlyLessThanTTL()));

      expect(cachedClass.counter(), 2);
    });

    test('cached method with set TTL, should return new value when TTL timeout',
        () async {
      final cachedClass = AsynchronousCached(_dataProvider);

      final cachedValueFuture = cachedClass.asyncCachedValueWithTTl();
      await Future.delayed(const Duration(milliseconds: 10));
      final secondCachedValueFuture = cachedClass.asyncCachedValueWithTTl();

      await Future.wait([cachedValueFuture, secondCachedValueFuture]);
      await Future.delayed(const Duration(seconds: ttlDurationSeconds));
      await cachedClass.asyncCachedValueWithTTl();

      expect(cachedClass.counter(), 3);
    });
  });
}

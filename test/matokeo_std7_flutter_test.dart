import 'package:flutter_test/flutter_test.dart';
import 'package:matokeo_std7_flutter/cache/results_cache.dart';
import 'package:matokeo_core/matokeo_core.dart' show CachedResultData;

void main() {
  test('adds one to input values', () async {
    final instance = ResultsCache.instance;

    var data = CachedResultData(
        id: 1,
        name: 'THE NAME',
        year: 1555,
        url: 'hhh/jjjj.hu',
        xml: 'qwertyu');

    instance.doInsert(cacheType: CacheType.Psle, cachedResultData: data);
    CachedResultData found =
        await instance.doGet(cacheType: CacheType.Psle, url: 'THE NAME');
    print(found);
    expect(found, data);
    //expect(() => instance., throwsNoSuchMethodError);
  });
}

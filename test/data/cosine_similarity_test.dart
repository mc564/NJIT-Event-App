import 'package:test_api/test_api.dart';
import '../../lib/providers/cosine_similarity_provider.dart';

void main() {
  /*
  test(description, () {
    //setup
    //run 
    //verify
  });
  */

  test('correct character cosine similarity', () {
    CosineSimilarityProvider calculator = CosineSimilarityProvider();
    var result = calculator.cosineSimilarityCharacters('aber', 'rabe');
    expect(result, 1.0);
    result = calculator.cosineSimilarityCharacters('shikha', 'medlyn');
    expect(result, 0.0);
    result = calculator.cosineSimilarityCharacters('matt', 'shikha');
    expect(result, 0.14433756729740646);
    result = calculator.cosineSimilarityCharacters('jessica coyotl', 'medlyn chen');
    expect(result, 0.404145188432738);
    result = calculator.cosineSimilarityCharacters('shikha shah', 'medlyn chen');
    expect(result, 0.24845199749997662);
  });

  test('correct word cosine similarity', () {
    CosineSimilarityProvider calculator = CosineSimilarityProvider();
    var result = calculator.cosineSimilarityWords('aber', 'rabe');
    expect(result, 0.0);
    result = calculator.cosineSimilarityWords('shikha', 'medlyn');
    expect(result, 0.0);
    result = calculator.cosineSimilarityWords('matt', 'matt amato');
    expect(result, 0.7071067811865475);
    result = calculator.cosineSimilarityWords('jessica leticia coyotl', 'jessica alba');
    expect(result, 0.40824829046386296);
    result = calculator.cosineSimilarityWords('shikha shah', 'medlyn chen');
    expect(result, 0.0);
  });

  test('correct judge of similarity according to input thresholds for characters and words', () {
    //either word similarity or char similarity must be above the threshold to return true
    CosineSimilarityProvider calculator = CosineSimilarityProvider(charSimilarityThreshold: 0.3, wordSimilarityThreshold: 0.5);
    assert(calculator.areSimilar('jessica coyotl', 'medlyn chen') == true);
    //^should be true because in test 'correct character cosine similarity', similarity is measured as  0.404...
    assert(calculator.areSimilar('matt', 'shikha') == false);
    assert(calculator.areSimilar('shikha shah', 'medlyn chen') == false);
    assert(calculator.areSimilar('donald trump', 'duck') == true);
  });

}
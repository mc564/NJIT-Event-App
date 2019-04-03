import '../../lib/providers/cosine_similarity_provider.dart';
import 'package:test_api/test_api.dart';

//Removed all tests related to null variables because that's a big error.

void main(){

  CosineSimilarityProvider sample = CosineSimilarityProvider();

  //Help, what's a math?

  test('Test: Vector Magnitudes', (){

    List<int> vector = new List(5);

    vector[0] = 1;
    vector[1] = 2;
    vector[2] = 3;
    vector[3] = 4;
    vector[4] = 5;

    double result = sample.vectorMagnitude(vector);

    expect(result, 7.416198487095663); //We should, uh, get some rounding on this
  });

  test('Test: Vector Magnitudes, 0', (){

    List<int> vector = new List(5);

    vector[0] = 0;
    vector[1] = 0;
    vector[2] = 0;
    vector[3] = 0;
    vector[4] = 0;

    double result = sample.vectorMagnitude(vector);

    expect(result, 0);
  });

  test('Test: Dot Product', () {

    List<int> vector1 = new List(5);
    List<int> vector2 = new List(5);

    vector1[0] = 10;
    vector1[1] = 9;
    vector1[2] = 8;
    vector1[3] = 7;
    vector1[4] = 6;

    vector2[0] = 5;
    vector2[1] = 4;
    vector2[2] = 3;
    vector2[3] = 2;
    vector2[4] = 1;

    double result = sample.dotProduct(vector1, vector2);

    expect(result, 130);
  });

  test('Test: Dot Product, 0', () {

    List<int> vector1 = new List(5);
    List<int> vector2 = new List(5);

    vector1[0] = 0;
    vector1[1] = 0;
    vector1[2] = 0;
    vector1[3] = 0;
    vector1[4] = 0;

    vector2[0] = 0;
    vector2[1] = 0;
    vector2[2] = 0;
    vector2[3] = 0;
    vector2[4] = 0;

    double result = sample.dotProduct(vector1, vector2);

    expect(result, 0);
  });

  //Onto the words

  test('Test: Word Similarity, Same Word', (){

    var word1 = 'bike';
    var word2 = 'bike';

    var result = sample.cosineSimilarityWords(word1, word2);

    expect(result, 1); //IDK what a cosine difference is but these numbers are based off the assumption it's a %

  });

  test('Test: Word Similarity, 1 Letter Diff.', (){

    var word1 = 'bike';
    var word2 = 'mike';

    var result = sample.cosineSimilarityWords(word1, word2);

    expect(result, 0.0);

  });

  test('Test: Word Similarity, 2 Letter Diff.', (){

    var word1 = 'bike';
    var word2 = 'make';

    var result = sample.cosineSimilarityWords(word1, word2);

    expect(result, 0.0);

  });

  test('Test: Word Similarity, 3 Letter Diff.', (){

    var word1 = 'bike';
    var word2 = 'mate';

    var result = sample.cosineSimilarityWords(word1, word2);

    expect(result, 0.0);

  });

  test('Test: Word Similarity, Different Word', (){

    var word1 = 'bike';
    var word2 = 'matt';

    var result = sample.cosineSimilarityWords(word1, word2);

    expect(result, 0);

  });
  
  test('Test: Word Similarity, 1st empty', (){

    var word1 = '';
    var word2 = 'matt';

    var result = sample.cosineSimilarityWords(word1, word2);

    expect(result, 0);

  });

  test('Test: Word Similarity, 2nd empty', (){

    var word1 = 'bike';
    var word2 = '';

    var result = sample.cosineSimilarityWords(word1, word2);

    expect(result, 0);

  });

  test('Test: Word Similarity, empty', (){

    var word1 = '';
    var word2 = '';

    var result = sample.cosineSimilarityWords(word1, word2);

    expect(result, 1); //I mean duh, they're both empty.

  });

  test('Test: Word Similarity, Longer Word', (){

    var word1 = 'bike';
    var word2 = 'bbiikkee';

    var result = sample.cosineSimilarityWords(word1, word2);

    expect(result, 0);

  });

  //And now letters

  test('Test: Letter Similarity, Same Word', (){

    var word1 = 'bike';
    var word2 = 'bike';

    var result = sample.cosineSimilarityCharacters(word1, word2);

    expect(result, 1);

  });

  test('Test: Letter Similarity, 1 Letter Diff', (){

    var word1 = 'bike';
    var word2 = 'mike';

    var result = sample.cosineSimilarityCharacters(word1, word2);

    expect(result, .75);

  });

  test('Test: Letter Similarity, 2 Letter Diff', (){

    var word1 = 'bike';
    var word2 = 'make';

    var result = sample.cosineSimilarityCharacters(word1, word2);

    expect(result, .5);

  });

  test('Test: Letter Similarity, 3 Letter Diff', (){

    var word1 = 'bike';
    var word2 = 'mate';

    var result = sample.cosineSimilarityCharacters(word1, word2);

    expect(result, .25);

  });

  test('Test: Letter Similarity, Different Word', (){

    var word1 = 'bike';
    var word2 = 'matt';

    var result = sample.cosineSimilarityCharacters(word1, word2);

    expect(result, 0);

  });

  test('Test: Letter Similarity, 1st empty', (){

    var word1 = '';
    var word2 = 'matt';

    var result = sample.cosineSimilarityCharacters(word1, word2);

    expect(result, isNaN);

  });

  test('Test: Letter Similarity, 2nd empty', (){

    var word1 = 'bike';
    var word2 = '';

    var result = sample.cosineSimilarityCharacters(word1, word2);

    expect(result, isNaN);

  });

  test('Test: Letter Similarity, both empty', (){

    var word1 = '';
    var word2 = '';

    var result = sample.cosineSimilarityCharacters(word1, word2);

    expect(result, isNaN);

  });

  //Direct comparison

  test('Test: Word Comparison, Same Word', (){

    var word1 = 'bike';
    var word2 = 'bike';

    var result = sample.areSimilar(word1, word2);

    expect(result, true);

  });

  test('Test: Word Comparison, 1 Letter Diff.', (){

    var word1 = 'bike';
    var word2 = 'mike';

    var result = sample.areSimilar(word1, word2);

    expect(result, false); //This is a wholly unexpected result

  });

  test('Test: Word Comparison, 2 Letter Diff', (){

    var word1 = 'bike';
    var word2 = 'make';

    var result = sample.areSimilar(word1, word2);

    expect(result, false);

  });

  test('Test: Word Comparison, 3 Letter Diff', (){

    var word1 = 'bike';
    var word2 = 'mate';

    var result = sample.areSimilar(word1, word2);

    expect(result, false);

  });

  test('Test: Word Comparison, Different Word', (){

    var word1 = 'bike';
    var word2 = 'matt';

    var result = sample.areSimilar(word1, word2);

    expect(result, false);

  });

  test('Test: Word Comparison, 1st empty', (){

      var word1 = '';
      var word2 = 'matt';

      var result = sample.areSimilar(word1, word2);

      expect(result, false);

  });

  test('Test: Word Comparison, 2nd empty', (){

    var word1 = 'bike';
    var word2 = '';

    var result = sample.areSimilar(word1, word2);

    expect(result, false);

  });

  test('Test: Word Comparison, Both Empty', (){

    var word1 = '';
    var word2 = '';

    var result = sample.areSimilar(word1, word2);

    expect(result, true);

  });

  test('Test: Word Comparison, Longer Word', (){

    var word1 = 'bike';
    var word2 = 'bbiikkee';

    var result = sample.areSimilar(word1, word2);

    expect(result, true);

  });
}
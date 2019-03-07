import 'dart:math';

class CosineSimilarity {
  double _charSimilarityThreshold;
  double _wordSimilarityThreshold;

  CosineSimilarity(
      {double charSimilarityThreshold = 0.8,
      double wordSimilarityThreshold = 0.2})
      : _charSimilarityThreshold = charSimilarityThreshold,
        _wordSimilarityThreshold = wordSimilarityThreshold;

  double _vectorMagnitude(List<int> vector) {
    int ans = 0;
    vector.forEach((int num) {
      ans += (num * num);
    });

    return sqrt(ans);
  }

  double _dotProduct(List<int> v1, List<int> v2) {
    double prod = 0;
    for (int i = 0; i < v1.length; i++) {
      prod += v1[i] * v2[i];
    }
    return prod;
  }

  //works better if some words are the same - so can work on different length titles
  double cosineSimilarityWords(String one, String two) {
    Map<String, List<int>> wordFreq = Map<String, List<int>>();
    for (String word in one.toLowerCase().split(' ')) {
      if (!wordFreq.containsKey(word)) wordFreq[word] = [0, 0];
      wordFreq[word][0] = wordFreq[word][0] + 1;
    }
    for (String word in two.toLowerCase().split(' ')) {
      if (!wordFreq.containsKey(word)) wordFreq[word] = [0, 0];
      wordFreq[word][1] = wordFreq[word][1] + 1;
    }

    List<int> v1 = [];
    List<int> v2 = [];

    wordFreq.forEach((String word, List<int> freqList) {
      v1.add(freqList[0]);
      v2.add(freqList[1]);
    });

    double magOne = _vectorMagnitude(v1);
    double magTwo = _vectorMagnitude(v2);
    double dotProd = _dotProduct(v1, v2);
    return dotProd / (magOne * magTwo);
  }

  //works better if there are minor spell check differences between the
  //first title and the second
  double cosineSimilarityCharacters(String one, String two) {
    Map<String, List<int>> charFreq = Map<String, List<int>>();
    for (int i = 0; i < one.length; i++) {
      String char = one[i];
      if (!charFreq.containsKey(char)) charFreq[char] = [0, 0];
      charFreq[char][0] = charFreq[char][0] + 1;
    }

    for (int i = 0; i < two.length; i++) {
      String char = two[i];
      if (!charFreq.containsKey(char)) charFreq[char] = [0, 0];
      charFreq[char][1] = charFreq[char][1] + 1;
    }

    List<int> v1 = [];
    List<int> v2 = [];

    charFreq.forEach((String char, List<int> freqList) {
      v1.add(freqList[0]);
      v2.add(freqList[1]);
    });

    double magOne = _vectorMagnitude(v1);
    double magTwo = _vectorMagnitude(v2);
    double dotProd = _dotProduct(v1, v2);
    return dotProd / (magOne * magTwo);
  }

  bool areSimilar(String one, String two) {
    double charSimilarity = cosineSimilarityCharacters(one, two);
    double wordSimilarity = cosineSimilarityWords(one, two);
    if (charSimilarity >= _charSimilarityThreshold ||
        wordSimilarity >= _wordSimilarityThreshold) {
      return true;
    } else
      return false;
  }
}

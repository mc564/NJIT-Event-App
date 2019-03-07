import 'dart:math';

enum Location {
  AF,
  CAMP,
  CC,
  CAB,
  CKB,
  COLT,
  CHEN,
  CULM,
  CYP,
  DHRH,
  EBER,
  ECE,
  EDC,
  FMH,
  FSB,
  FENS,
  GRB,
  GITC,
  KUPF,
  LAU,
  LSEC,
  ME,
  MIC,
  NFAC,
  OAK,
  PARK,
  RED,
  STPG,
  SPEC,
  TIER,
  WEC,
  WEST,
  YORK,
  OTHER
}

class LocationHelper {
  //left out other, because there isn't an abbreviation for that one
  static final Map<Location, String> abbreviations = {
    Location.AF: 'AF',
    Location.CAMP: 'CAMP',
    Location.CC: 'CC',
    Location.CAB: 'CAB',
    Location.CKB: 'CKB',
    Location.COLT: 'COLT',
    Location.CHEN: 'CHEN',
    Location.CULM: 'CULM',
    Location.CYP: 'CYP',
    Location.DHRH: 'DHRH',
    Location.EBER: 'EBER',
    Location.ECE: 'ECE',
    Location.EDC: 'EDC',
    Location.FMH: 'FMH',
    Location.FSB: 'FSB',
    Location.FENS: 'FENS',
    Location.GRB: 'GRB',
    Location.GITC: 'GITC',
    Location.KUPF: 'KUPF',
    Location.LAU: 'LAU',
    Location.LSEC: 'LSEC',
    Location.ME: 'ME',
    Location.MIC: 'MIC',
    Location.NFAC: 'NFAC',
    Location.OAK: 'OAK',
    Location.PARK: 'PARK',
    Location.RED: 'RED',
    Location.STPG: 'STPG',
    Location.SPEC: 'SPEC',
    Location.TIER: 'TIER',
    Location.WEC: 'WEC',
    Location.WEST: 'WEST',
    Location.YORK: 'YORK',
  };

  static final Map<Location, String> longNames = {
    Location.AF: 'Athletic Field',
    Location.CAMP: 'Campbell Hall',
    Location.CC: 'Campus Center',
    Location.CAB: 'Central Avenue Building',
    Location.CKB: 'Central King Building',
    Location.COLT: 'Colton Hall',
    Location.CHEN: 'Council for Higher Education in Newark Building',
    Location.CULM: 'Cullimore Hall',
    Location.CYP: 'Cypress Residence Hall',
    Location.DHRH: 'Dorman Honors Residence Hall',
    Location.EBER: 'Eberhardt Hall',
    Location.ECE: 'Electrical and Computer Engineering Center',
    Location.EDC: 'Enterprise Development Center',
    Location.FMH: 'Faculty Memorial Hall',
    Location.FSB: 'Facilities Services Building',
    Location.FENS: 'Fenster Hall',
    Location.GRB: 'Greek Way Building',
    Location.GITC: 'Guttenberg Information Technology Center',
    Location.KUPF: 'Kupfrian Hall',
    Location.LAU: 'Laurel Residence Hall',
    Location.LSEC: 'Life Sciences & Engineering Center',
    Location.ME: 'Mechanical Engineering Center',
    Location.MIC: 'Microelectronics Center',
    Location.NFAC: 'Naimoli Family Athletic Center',
    Location.OAK: 'Oak Residence Hall',
    Location.PARK: 'Parking Deck/Student Mall',
    Location.RED: 'Redwood Residence Hall',
    Location.STPG: 'Science & Technology Park Garage',
    Location.SPEC: 'Specht Building',
    Location.TIER: 'Tiernan Hall',
    Location.WEC: 'Wellness & Events Center',
    Location.WEST: 'Weston Hall',
    Location.YORK: 'York Center',
  };

  //we'll say that if all the words are matched with edit distance 2, then the location is a match
  static final Map<Location, String> minimumMatchNames = {
    Location.AF: 'Athletic Field',
    Location.CAMP: 'Campbell',
    Location.CC: 'Campus Center',
    Location.CAB: 'Central Avenue',
    Location.CKB: 'Central King',
    Location.COLT: 'Colton',
    Location.CHEN: 'Council Higher Newark',
    Location.CULM: 'Cullimore',
    Location.CYP: 'Cypress',
    Location.DHRH: 'Dorman',
    Location.EBER: 'Eberhardt',
    Location.ECE: 'Electrical Computer Engineering',
    Location.EDC: 'Enterprise Development Center',
    Location.FMH: 'Faculty Memorial',
    Location.FSB: 'Facilities Services',
    Location.FENS: 'Fenster',
    Location.GRB: 'Greek',
    Location.GITC: 'Guttenberg',
    Location.KUPF: 'Kupfrian',
    Location.LAU: 'Laurel',
    Location.LSEC: 'Life Sciences Engineering',
    Location.ME: 'Mechanical Engineering',
    Location.MIC: 'Microelectronics',
    Location.NFAC: 'Naimoli',
    Location.OAK: 'Oak',
    //hm..not sure how to manage this one - also had parking deck
    Location.PARK: 'Student Mall',
    Location.RED: 'Redwood',
    Location.STPG: 'Science Technology Park',
    Location.SPEC: 'Specht',
    Location.TIER: 'Tiernan',
    Location.WEC: 'Wellness Events',
    Location.WEST: 'Weston',
    Location.YORK: 'York',
  };

  static String getAbbreviation(Location location) {
    if (abbreviations.containsKey(location)) {
      return abbreviations[location];
    } else {
      return 'OTHER';
    }
  }

  static String getLongName(Location location) {
    if (longNames.containsKey(location))
      return longNames[location];
    else
      return 'Other';
  }

  static Location abbrevStringToLocationCode(String location) {
    for (Location loc in abbreviations.keys) {
      String abbrev = abbreviations[loc];
      if (abbrev == location) return loc;
    }
    return Location.OTHER;
  }

  //converts any string of any format to a location object
  static Location getLocationCode(String locationString) {
    if (locationString == null || locationString.length == 0) {
      return Location.OTHER;
    }
    List<String> words = locationString.split(RegExp(r"( )+"));
    //check for a match in abbreviations first
    for (Location loc in abbreviations.keys) {
      String abbrev = abbreviations[loc];
      if (words.contains(abbrev)) return loc;
    }

    for (int i = 0; i < words.length; i++) {
      words[i] = words[i].toLowerCase();
    }

    //no matches? check for fuzzy matches for the minimum names for all locations
    for (Location loc in minimumMatchNames.keys) {
      String minimumName = minimumMatchNames[loc];
      List<String> minWords = minimumName.toLowerCase().split(RegExp(r"( )+"));
      for (String word in words) {
        for (String minWord in minWords) {
          if (minWord[0] == word[0] &&
              (minWord.length - word.length).abs() <= 2) {
            if (minEditDistance(minWord, word) < 3) {
              minWords.remove(minWord);
              break;
            }
          }
        }
      }

      if (minWords.length == 0) return loc;
    }

    return Location.OTHER;
  }

  static int minEditDistance(String s1, String s2) {
    int n = s1.length;
    int m = s2.length;
    List<List<int>> dp =
        List.generate(m + 1, (_) => List<int>.filled(n + 1, 0));
    for (int i = 0; i <= m; i++) {
      for (int j = 0; j <= n; j++) {
        if (i == 0) {
          dp[i][j] = j;
        } else if (j == 0) {
          dp[i][j] = i;
        } else if (s2[i - 1] == s1[j - 1]) {
          dp[i][j] = dp[i - 1][j - 1];
        } else {
          dp[i][j] = 1 + min(min(dp[i][j - 1], dp[i - 1][j]), dp[i - 1][j - 1]);
        }
      }
    }
    return dp[m][n];
  }
}

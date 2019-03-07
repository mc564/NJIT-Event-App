enum Category {
  ArtsAndEntertainment,
  HealthAndWellness,
  Sports,
  MeetAndLearn,
  AlumniAndUniversity,
  Celebrations,
  Miscellaneous,
  Community,
  Conferences,
  MarketPlace
}

//use to get a string from a category
class CategoryHelper {
  static final Map<Category, String> categoryStringFrom = {
    Category.ArtsAndEntertainment: 'Arts & Entertainment',
    Category.HealthAndWellness: 'Health & Wellness',
    Category.Sports: 'Sports',
    Category.MeetAndLearn: 'Meet & Learn',
    Category.AlumniAndUniversity: 'Alumni & University',
    Category.Celebrations: 'Celebrations',
    Category.Miscellaneous: 'Miscellaneous',
    Category.Community: 'Community',
    Category.Conferences: 'Conferences',
    Category.MarketPlace: 'Market Place & Tabling',
  };

  static final Map<String, Category> categoryFrom = {
    'Arts & Entertainment': Category.ArtsAndEntertainment,
    'Health & Wellness': Category.HealthAndWellness,
    'Sports': Category.Sports,
    'Meet & Learn': Category.MeetAndLearn,
    'Alumni & University': Category.AlumniAndUniversity,
    'Celebrations': Category.Celebrations,
    'Miscellaneous': Category.Miscellaneous,
    'Community': Category.Community,
    'Conferences': Category.Conferences,
    'Market Place & Tabling': Category.MarketPlace,
  };

  static String getString(Category category) {
    return categoryStringFrom[category];
  }

  static Category getCategory(String category) {
    return categoryFrom[category];
  }
}

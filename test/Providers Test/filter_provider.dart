import '../../lib/providers/filter_provider.dart';
import '../../lib/models/category.dart';
import '../../lib/models/sort.dart';
import '../../lib/models/location.dart';
import 'package:test_api/test_api.dart';

void main() {

  List<Category> cat =  new List(5);
  List<String> org = new List(5);
  List<String> org2 = new List(5);
  List<String> org3 = new List(5);
  List<Location> loc = new List(5);
  Sort sort;

  cat[0] = Category.Sports;
  cat[1] = Category.MarketPlace;
  cat[2] = Category.Celebrations;
  cat[3] = Category.ArtsAndEntertainment;
  cat[4] = Category.HealthAndWellness;

  org[0] = 'NJIT WEC';
  org[1] = 'NJIT GDS';
  org[2] = 'NJIT Graduation';
  org[3] = 'Newark Public Museam';
  org[4] = 'NJIT GDS';

  org2[0] = '';
  org2[1] = '';
  org2[2] = '';
  org2[3] = '';
  org2[4] = '';

  loc[0] = Location.WEC;
  loc[1] = Location.CC;
  loc[2] = Location.AF;
  loc[3] = Location.CC;
  loc[4] = Location.WEC;

  FilterProvider filter = FilterProvider(selectedCategories: cat, selectedOrganizations: org, selectedLocations: loc, sort: sort);

  test('Test: Filter Params', (){
    var result = filter.filterParameters;

    //I have no idea how to properly traverse the returned map.
    expect(filter.filterParameters.toString(), '{FilterType.Category: [Category.Sports, Category.MarketPlace, Category.Celebrations, Category.ArtsAndEntertainment, Category.HealthAndWellness], FilterType.Location: [Location.WEC, Location.CC, Location.AF, Location.CC, Location.WEC], FilterType.Organization: [NJIT WEC, NJIT GDS, NJIT Graduation, Newark Public Museam, NJIT GDS]}');
  });

  test('Test: Sort Type', () {
    
    var result = filter.sortType;

    expect(result, null); //didn't know how to set Sort lol
  });

  test('Test: Selected Categories', () {

    var result = filter.selectedCategories;

    expect(result.toString(), '[Category.Sports, Category.MarketPlace, Category.Celebrations, Category.ArtsAndEntertainment, Category.HealthAndWellness]');
  });

  test('Test: Selected Locations', (){
    var result = filter.selectedLocations;

    expect(result.toString(), '[Location.WEC, Location.CC, Location.AF, Location.CC, Location.WEC]');
  });

  test('Test: Selected Organizations', (){
    var result = filter.selectedOrganizations;

    expect(result.toString(), '[NJIT WEC, NJIT GDS, NJIT Graduation, Newark Public Museam, NJIT GDS]');
  });

  //These apparently don't work the way I assumed they did.
  /*test('Test: Add Category', (){

    filter.addCategory(Category.AlumniAndUniversity);

    var result = filter.selectedCategories;

    expect(result, 'Sports, Marketplace, Celebrations, ArtsAndEntertainment, HealthAndWellness, AlumniAndUniversity');
  });

  test('Test: Remove Category',(){

    filter.removeCategory(Category.ArtsAndEntertainment);
    filter.removeCategory(Category.HealthAndWellness);
    filter.removeCategory(Category.Celebrations);
    filter.removeCategory(Category.MarketPlace);
    filter.removeCategory(Category.Sports);

    var result = filter.selectedCategories;

    expect(result, 'AlumniAndUniversity');
  });

  test('Test: Set All Categories',(){

    filter.setCategories(cat);

    var result = filter.selectedCategories;

    expect(result, 'AlumniAndUniversity, Sports, Marketplace, Celebrations, ArtsAndEntertainment, HealthAndWellness');
  });

  test('Test: Add Location', (){

    filter.addLocation(Location.CULM);

    var result = filter.selectedLocations;

    expect(result, 'WEC, CC, AF, CC, WEC, CULM');
  });

  test('Test: Remove Location',(){

    filter.removeLocation(Location.WEC);
    filter.removeLocation(Location.CC);
    filter.removeLocation(Location.AF);

    var result = filter.selectedLocations;

    expect(result, 'CULM');
  });*/

  test('Test: Set All Locations',(){

    filter.setLocations(loc);

    var result = filter.selectedLocations;

    expect(result.toString(), '[Location.WEC, Location.CC, Location.AF, Location.CC, Location.WEC]');
  });

  /*test('Test: Add Organization', (){

    filter.addOrganization('Rutgers');

    var result = filter.selectedOrganizations;

    expect(result, 'NJIT WEC, NJIT GDS, NJIT Graduation, Newark Public Museam, NJIT GDS, Rutgers');
  });

  test('Test: Remove Organization',(){

    filter.removeOrganization('NJIT WEC');
    filter.removeOrganization('NJIT GDS');
    filter.removeOrganization('NJIT Graduation');
    filter.removeOrganization('Newark Public Museam');

    var result = filter.selectedOrganizations;

    expect(result, 'Rutgers');
  });*/

  test('Test: Set All Organizations',(){

    filter.setOrganizations(org);

    var result = filter.selectedOrganizations;

    expect(result.toString(), '[NJIT WEC, NJIT GDS, NJIT Graduation, Newark Public Museam, NJIT GDS]');
  });

  test('Test: Add Organization, empty', (){

    filter.addOrganization('');

    var result = filter.selectedOrganizations;

    expect(result.toString(), '[NJIT WEC, NJIT GDS, NJIT Graduation, Newark Public Museam, NJIT GDS, ]');
  });

  test('Test: Remove Organization, empty',(){

    filter.removeOrganization('');

    var result = filter.selectedOrganizations;

    expect(result.toString(), '[NJIT WEC, NJIT GDS, NJIT Graduation, Newark Public Museam, NJIT GDS]');
  });

  test('Test: Set All Organizations',(){

    filter.setOrganizations(org2);

    var result = filter.selectedOrganizations;

    expect(result.toString(), '[, , , , ]');
  });

  test('Test: Add Organization, null', (){

    filter.addOrganization(null);

    var result = filter.selectedOrganizations;

    expect(result.toString(), '[, , , , , null]');
  });

  test('Test: Remove Organization, null',(){

    filter.removeOrganization(null);

    var result = filter.selectedOrganizations;

    expect(result.toString(), '[, , , , ]');
  });

  test('Test: Set All Organizations',(){

    filter.setOrganizations(org3);

    var result = filter.selectedOrganizations;

    expect(result.toString(), '[null, null, null, null, null]');
  });

  test('Test: Set Sort', (){

    Sort sort2;

    filter.setSort(sort2);

    var result = filter.sortType;

    expect(result, null);
  });

  test('Test: Empty Everything', (){

    filter.clearFilters();

    var result1 = filter.selectedCategories;
    var result2 = filter.selectedLocations;
    var result3 = filter.selectedOrganizations;

    expect(result1, []);
    expect(result2, []);
    expect(result3, []);
  });
}
import '../../lib/providers/add_event_provider.dart';
import 'package:test_api/test_api.dart';

void main(){

  AddEventProvider event = AddEventProvider();

  //Testing individual validators under different situations.

  test('test: set name, valid', () {
      event.setTitle('beef');
      var result = event.titleValidator(event.title);
      expect(result, null);
      event.clear();
  });

  test('test: set name, null', () {
      event.setTitle(null);
      var result = event.titleValidator(event.title);
      expect(result, 'Title is required.');
      event.clear();
  });

  test('test: set name, empty', () {
      event.setTitle('');
      var result = event.titleValidator(event.title);
      expect(result, 'Title is required.');
      event.clear();
  });

  test('test: set org, valid', () {
      event.setOrganization('Bacon');
      var result = event.orgValidator(event.organization);
      expect(result, null);
      event.clear();
  });

  test('test: set org, null', () {
      event.setOrganization(null);
      var result = event.orgValidator(event.organization);
      expect(result, 'Organization is required.');
      event.clear();
  });

  test('test: set org, empty', () {
      event.setOrganization('');
      var result = event.orgValidator(event.organization);
      expect(result, 'Organization is required.');
      event.clear();
  });

  test('test: set loc, valid', () {
      event.setLocation('Bacon');
      var result = event.locationValidator(event.location);
      expect(result, null);
      event.clear();
  });

  test('test: set loc, null', () {
      event.setLocation(null);
      var result = event.locationValidator(event.location);
      expect(result, 'Location is required.');
      event.clear();
  });

  test('test: set loc, empty', () {
      event.setLocation('');
      var result = event.locationValidator(event.location);
      expect(result, 'Location is required.');
      event.clear();
  });

    test('test: set desc, valid', () {
      event.setDescription('Bacon');
      var result = event.descriptionValidator(event.description);
      expect(result, null);
      event.clear();
  });

  test('test: set desc, null', () {
      event.setDescription(null);
      var result = event.descriptionValidator(event.description);
      expect(result, 'Description is required.');
      event.clear();
  });

  test('test: set desc, empty', () {
      event.setDescription('');
      var result = event.descriptionValidator(event.description);
      expect(result, 'Description is required.');
      event.clear();
  });

  test('test: set cat, valid', () {
    event.setCategory('Bacon');
    var result = event.categoryValidator(event.category);
    expect(result, null);
    event.clear();
  });

  test('test: set cat, null', () {
      event.setCategory(null);
      var result = event.categoryValidator(event.category);
      expect(result, 'Category is required.');
      event.clear();
  });

  test('test: set cat, empty', () {
      event.setCategory('');
      var result = event.categoryValidator(event.category);
      expect(result, 'Category is required.');
      event.clear();
  });

  //Testing datetime variables, mostly so I understand them.

  test('test: datetime', () {
    event.setStartTime(DateTime.parse('1969-07-20 20:18:04Z'));  //This is the moon landing.
    event.setEndTime(DateTime.parse('1969-07-21 20:18:04Z'));
    var result = event.startTime.toString();
    expect(result, '1969-07-20 20:18:04Z');
    result = event.endTime.toString();
    expect(result, '1969-07-21 20:18:04Z');
    event.clear();
  });


  //Testing all validators at once. Buckle up, buttercup.

  test('The Big One: All Valid', (){
    
    event.setCategory('category');
    event.setDescription('description');
    event.setLocation('location');
    event.setOrganization('org');
    event.setTitle('title');

    var result1 = event.categoryValidator(event.category);
    var result2 = event.descriptionValidator(event.description);
    var result3 = event.locationValidator(event.location);
    var result4 = event.orgValidator(event.organization);
    var result5 = event.titleValidator(event.title);

    expect(result1, null);
    expect(result2, null);
    expect(result3, null);
    expect(result4, null);
    expect(result5, null);

    event.clear();
  });

  test('The Big One: All Null', (){
    
    event.setCategory(null);
    event.setDescription(null);
    event.setLocation(null);
    event.setOrganization(null);
    event.setTitle(null);

    var result1 = event.categoryValidator(event.category);
    var result2 = event.descriptionValidator(event.description);
    var result3 = event.locationValidator(event.location);
    var result4 = event.orgValidator(event.organization);
    var result5 = event.titleValidator(event.title);

    expect(result1, 'Category is required.');
    expect(result2, 'Description is required.');
    expect(result3, 'Location is required.');
    expect(result4, 'Organization is required.');
    expect(result5, 'Title is required.');

    event.clear();
  });

  test('The Big One: All Empty', (){
    
    event.setCategory('');
    event.setDescription('');
    event.setLocation('');
    event.setOrganization('');
    event.setTitle('');

    var result1 = event.categoryValidator(event.category);
    var result2 = event.descriptionValidator(event.description);
    var result3 = event.locationValidator(event.location);
    var result4 = event.orgValidator(event.organization);
    var result5 = event.titleValidator(event.title);

    expect(result1, 'Category is required.');
    expect(result2, 'Description is required.');
    expect(result3, 'Location is required.');
    expect(result4, 'Organization is required.');
    expect(result5, 'Title is required.');

    event.clear();
  });

  test('The Big One: Just Cat, Rest Null', (){
    
    event.setCategory('category');
    event.setDescription(null);
    event.setLocation(null);
    event.setOrganization(null);
    event.setTitle(null);

    var result1 = event.categoryValidator(event.category);
    var result2 = event.descriptionValidator(event.description);
    var result3 = event.locationValidator(event.location);
    var result4 = event.orgValidator(event.organization);
    var result5 = event.titleValidator(event.title);

    expect(result1, null);
    expect(result2, 'Description is required.');
    expect(result3, 'Location is required.');
    expect(result4, 'Organization is required.');
    expect(result5, 'Title is required.');

    event.clear();
  });

  test('The Big One: Just Desc, Rest Null', (){
    
    event.setCategory(null);
    event.setDescription('desc');
    event.setLocation(null);
    event.setOrganization(null);
    event.setTitle(null);

    var result1 = event.categoryValidator(event.category);
    var result2 = event.descriptionValidator(event.description);
    var result3 = event.locationValidator(event.location);
    var result4 = event.orgValidator(event.organization);
    var result5 = event.titleValidator(event.title);

    expect(result1, 'Category is required.');
    expect(result2, null);
    expect(result3, 'Location is required.');
    expect(result4, 'Organization is required.');
    expect(result5, 'Title is required.');

    event.clear();
  });

  test('The Big One: Just Loc, Rest Null', (){
    
    event.setCategory(null);
    event.setDescription(null);
    event.setLocation('loc');
    event.setOrganization(null);
    event.setTitle(null);

    var result1 = event.categoryValidator(event.category);
    var result2 = event.descriptionValidator(event.description);
    var result3 = event.locationValidator(event.location);
    var result4 = event.orgValidator(event.organization);
    var result5 = event.titleValidator(event.title);

    expect(result1, 'Category is required.');
    expect(result2, 'Description is required.');
    expect(result3, null);
    expect(result4, 'Organization is required.');
    expect(result5, 'Title is required.');

    event.clear();
  });

  test('The Big One: Just Org, Rest Null', (){
    
    event.setCategory(null);
    event.setDescription(null);
    event.setLocation(null);
    event.setOrganization('org');
    event.setTitle(null);

    var result1 = event.categoryValidator(event.category);
    var result2 = event.descriptionValidator(event.description);
    var result3 = event.locationValidator(event.location);
    var result4 = event.orgValidator(event.organization);
    var result5 = event.titleValidator(event.title);

    expect(result1, 'Category is required.');
    expect(result2, 'Description is required.');
    expect(result3, 'Location is required.');
    expect(result4, null);
    expect(result5, 'Title is required.');

    event.clear();
  });

  test('The Big One: Just Title, Rest Null', (){
    
    event.setCategory(null);
    event.setDescription(null);
    event.setLocation(null);
    event.setOrganization(null);
    event.setTitle('title');

    var result1 = event.categoryValidator(event.category);
    var result2 = event.descriptionValidator(event.description);
    var result3 = event.locationValidator(event.location);
    var result4 = event.orgValidator(event.organization);
    var result5 = event.titleValidator(event.title);

    expect(result1, 'Category is required.');
    expect(result2, 'Description is required.');
    expect(result3, 'Location is required.');
    expect(result4, 'Organization is required.');
    expect(result5, null);

    event.clear();
  });

  test('The Big One: Just Cat, Rest Empty', (){
    
    event.setCategory('category');
    event.setDescription('');
    event.setLocation('');
    event.setOrganization('');
    event.setTitle('');

    var result1 = event.categoryValidator(event.category);
    var result2 = event.descriptionValidator(event.description);
    var result3 = event.locationValidator(event.location);
    var result4 = event.orgValidator(event.organization);
    var result5 = event.titleValidator(event.title);

    expect(result1, null);
    expect(result2, 'Description is required.');
    expect(result3, 'Location is required.');
    expect(result4, 'Organization is required.');
    expect(result5, 'Title is required.');

    event.clear();
  });

  test('The Big One: Just Desc, Rest Empty', (){
    
    event.setCategory('');
    event.setDescription('desc');
    event.setLocation('');
    event.setOrganization('');
    event.setTitle('');

    var result1 = event.categoryValidator(event.category);
    var result2 = event.descriptionValidator(event.description);
    var result3 = event.locationValidator(event.location);
    var result4 = event.orgValidator(event.organization);
    var result5 = event.titleValidator(event.title);

    expect(result1, 'Category is required.');
    expect(result2, null);
    expect(result3, 'Location is required.');
    expect(result4, 'Organization is required.');
    expect(result5, 'Title is required.');

    event.clear();
  });

  test('The Big One: Just Loc, Rest Empty', (){
    
    event.setCategory('');
    event.setDescription('');
    event.setLocation('loc');
    event.setOrganization('');
    event.setTitle('');

    var result1 = event.categoryValidator(event.category);
    var result2 = event.descriptionValidator(event.description);
    var result3 = event.locationValidator(event.location);
    var result4 = event.orgValidator(event.organization);
    var result5 = event.titleValidator(event.title);

    expect(result1, 'Category is required.');
    expect(result2, 'Description is required.');
    expect(result3, null);
    expect(result4, 'Organization is required.');
    expect(result5, 'Title is required.');

    event.clear();
  });

  test('The Big One: Just Org, Rest Empty', (){
    
    event.setCategory('');
    event.setDescription('');
    event.setLocation('');
    event.setOrganization('org');
    event.setTitle('');

    var result1 = event.categoryValidator(event.category);
    var result2 = event.descriptionValidator(event.description);
    var result3 = event.locationValidator(event.location);
    var result4 = event.orgValidator(event.organization);
    var result5 = event.titleValidator(event.title);

    expect(result1, 'Category is required.');
    expect(result2, 'Description is required.');
    expect(result3, 'Location is required.');
    expect(result4, null);
    expect(result5, 'Title is required.');

    event.clear();
  });

  test('The Big One: Just Title, Rest Empty', (){
    
    event.setCategory('');
    event.setDescription('');
    event.setLocation('');
    event.setOrganization('');
    event.setTitle('title');

    var result1 = event.categoryValidator(event.category);
    var result2 = event.descriptionValidator(event.description);
    var result3 = event.locationValidator(event.location);
    var result4 = event.orgValidator(event.organization);
    var result5 = event.titleValidator(event.title);

    expect(result1, 'Category is required.');
    expect(result2, 'Description is required.');
    expect(result3, 'Location is required.');
    expect(result4, 'Organization is required.');
    expect(result5, null);

    event.clear();
  });

  test('The Big One: Null Cat, Rest Valid', (){
    
    event.setCategory(null);
    event.setDescription('test');
    event.setLocation('test');
    event.setOrganization('test');
    event.setTitle('test');

    var result1 = event.categoryValidator(event.category);
    var result2 = event.descriptionValidator(event.description);
    var result3 = event.locationValidator(event.location);
    var result4 = event.orgValidator(event.organization);
    var result5 = event.titleValidator(event.title);

    expect(result1, 'Category is required.');
    expect(result2, null);
    expect(result3, null);
    expect(result4, null);
    expect(result5, null);

    event.clear();
  });

  test('The Big One: Null Desc, Rest Valid', (){
    
    event.setCategory('test');
    event.setDescription(null);
    event.setLocation('test');
    event.setOrganization('test');
    event.setTitle('test');

    var result1 = event.categoryValidator(event.category);
    var result2 = event.descriptionValidator(event.description);
    var result3 = event.locationValidator(event.location);
    var result4 = event.orgValidator(event.organization);
    var result5 = event.titleValidator(event.title);

    expect(result1, null);
    expect(result2, 'Description is required.');
    expect(result3, null);
    expect(result4, null);
    expect(result5, null);

    event.clear();
  });

  test('The Big One: Null Loc, Rest Valid', (){
    
    event.setCategory('test');
    event.setDescription('test');
    event.setLocation(null);
    event.setOrganization('test');
    event.setTitle('test');

    var result1 = event.categoryValidator(event.category);
    var result2 = event.descriptionValidator(event.description);
    var result3 = event.locationValidator(event.location);
    var result4 = event.orgValidator(event.organization);
    var result5 = event.titleValidator(event.title);

    expect(result1, null);
    expect(result2, null);
    expect(result3, 'Location is required.');
    expect(result4, null);
    expect(result5, null);

    event.clear();
  });

  test('The Big One: Null Org, Rest Valid', (){
    
    event.setCategory('test');
    event.setDescription('test');
    event.setLocation('test');
    event.setOrganization(null);
    event.setTitle('test');

    var result1 = event.categoryValidator(event.category);
    var result2 = event.descriptionValidator(event.description);
    var result3 = event.locationValidator(event.location);
    var result4 = event.orgValidator(event.organization);
    var result5 = event.titleValidator(event.title);

    expect(result1, null);
    expect(result2, null);
    expect(result3, null);
    expect(result4, 'Organization is required.');
    expect(result5, null);

    event.clear();
  });

  test('The Big One: Null Title, Rest Valid', (){
    
    event.setCategory('test');
    event.setDescription('test');
    event.setLocation('test');
    event.setOrganization('test');
    event.setTitle(null);

    var result1 = event.categoryValidator(event.category);
    var result2 = event.descriptionValidator(event.description);
    var result3 = event.locationValidator(event.location);
    var result4 = event.orgValidator(event.organization);
    var result5 = event.titleValidator(event.title);

    expect(result1, null);
    expect(result2, null);
    expect(result3, null);
    expect(result4, null);
    expect(result5, 'Title is required.');

    event.clear();
  });

  test('The Big One: Empty Cat, Rest Valid', (){
    
    event.setCategory('');
    event.setDescription('test');
    event.setLocation('test');
    event.setOrganization('test');
    event.setTitle('test');

    var result1 = event.categoryValidator(event.category);
    var result2 = event.descriptionValidator(event.description);
    var result3 = event.locationValidator(event.location);
    var result4 = event.orgValidator(event.organization);
    var result5 = event.titleValidator(event.title);

    expect(result1, 'Category is required.');
    expect(result2, null);
    expect(result3, null);
    expect(result4, null);
    expect(result5, null);

    event.clear();
  });

  test('The Big One: Empty Desc, Rest Valid', (){
    
    event.setCategory('test');
    event.setDescription('');
    event.setLocation('test');
    event.setOrganization('test');
    event.setTitle('test');

    var result1 = event.categoryValidator(event.category);
    var result2 = event.descriptionValidator(event.description);
    var result3 = event.locationValidator(event.location);
    var result4 = event.orgValidator(event.organization);
    var result5 = event.titleValidator(event.title);

    expect(result1, null);
    expect(result2, 'Description is required.');
    expect(result3, null);
    expect(result4, null);
    expect(result5, null);

    event.clear();
  });

  test('The Big One: Empty Loc, Rest Valid', (){
    
    event.setCategory('test');
    event.setDescription('test');
    event.setLocation('');
    event.setOrganization('test');
    event.setTitle('test');

    var result1 = event.categoryValidator(event.category);
    var result2 = event.descriptionValidator(event.description);
    var result3 = event.locationValidator(event.location);
    var result4 = event.orgValidator(event.organization);
    var result5 = event.titleValidator(event.title);

    expect(result1, null);
    expect(result2, null);
    expect(result3, 'Location is required.');
    expect(result4, null);
    expect(result5, null);

    event.clear();
  });

  test('The Big One: Empty Org, Rest Valid', (){
    
    event.setCategory('test');
    event.setDescription('test');
    event.setLocation('test');
    event.setOrganization('');
    event.setTitle('test');

    var result1 = event.categoryValidator(event.category);
    var result2 = event.descriptionValidator(event.description);
    var result3 = event.locationValidator(event.location);
    var result4 = event.orgValidator(event.organization);
    var result5 = event.titleValidator(event.title);

    expect(result1, null);
    expect(result2, null);
    expect(result3, null);
    expect(result4, 'Organization is required.');
    expect(result5, null);

    event.clear();
  });

  test('The Big One: Empty Title, Rest Valid', (){
    
    event.setCategory('test');
    event.setDescription('test');
    event.setLocation('test');
    event.setOrganization('test');
    event.setTitle('');

    var result1 = event.categoryValidator(event.category);
    var result2 = event.descriptionValidator(event.description);
    var result3 = event.locationValidator(event.location);
    var result4 = event.orgValidator(event.organization);
    var result5 = event.titleValidator(event.title);

    expect(result1, null);
    expect(result2, null);
    expect(result3, null);
    expect(result4, null);
    expect(result5, 'Title is required.');

    event.clear();
  });
}
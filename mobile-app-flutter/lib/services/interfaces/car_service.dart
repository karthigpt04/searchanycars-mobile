import '../../models/listing.dart';

abstract class CarService {
  Future<List<Listing>> getListings({Map<String, dynamic>? filters});
  Future<Listing?> getListingById(int id);
}

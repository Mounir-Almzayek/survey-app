import '../models/user.dart';

class ProfileOnlineRepository {
  /// Fetch profile from API
  static Future<User> getProfile() async {
    // This is a placeholder for real API call
    // final request = APIRequest(
    //   path: '/profile',
    //   method: HTTPMethod.get,
    // );
    // final response = await DioProvider.instance.request(request);
    // return User.fromJson(response['data']);

    throw UnimplementedError('Online profile fetch not implemented yet');
  }
}

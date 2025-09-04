class ServerException implements Exception{}
class CacheException implements Exception{}
class NetworkException implements Exception{
  final String message;
  NetworkException([this.message = 'No network connection detected.']);
}
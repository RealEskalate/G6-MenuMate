import '../network/api_endpoints.dart';

// Using a getter function instead of const to avoid constant evaluation error
String get baseUrl => ApiEndpoints.baseUrl;
const String accessToken =
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJlbWFpbCI6ImpvaG4uZG9lQGV4YW1wbGUuY29tIiwiZXhwIjoxNzU3MzI1MjA5LCJpc192ZXJpZmllZCI6ZmFsc2UsInJvbGUiOiJPV05FUiIsInN0YXR1cyI6IkFDVElWRSIsInN1YiI6IjY4Yjk1MDBjMWViZTUxNGI5OTQyNTIyNSJ9.F16oP278TQDIw9Ivn6pQWA0DCwjmSNjPAo527IVwhtg';

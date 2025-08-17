// Hardcoded local booking service
class LocalBookingService {
  static final LocalBookingService _instance = LocalBookingService._internal();
  factory LocalBookingService() => _instance;
  LocalBookingService._internal();

  final List<Map<String, String>> bookings = [];

  void bookService(String student, String serviceType, String details) {
    bookings.add({
      'student': student,
      'serviceType': serviceType,
      'details': details,
    });
  }
}

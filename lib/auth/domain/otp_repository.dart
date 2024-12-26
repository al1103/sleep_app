// ignore: one_member_abstracts
abstract class OtpRepository {
  Future<bool> verificationOtp(String otp);
}

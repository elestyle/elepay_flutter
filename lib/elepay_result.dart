part of elepay_flutter;

/// The result data of the elepay SDK processing.
abstract class ElepayResult {
  factory ElepayResult.succeeded(String paymentId) = ElepayResultSucceeded;
  factory ElepayResult.failed(
          String paymentId, String code, String reason, String message) =
      ElepayResultFailed;
  factory ElepayResult.cancelled(String paymentId) = ElepayResultCancelled;
}

/// Successful result data, with the payment id information.
class ElepayResultSucceeded implements ElepayResult {
  final String paymentId;
  const ElepayResultSucceeded(this.paymentId);
}

/// Cancelled result data, with the payment id information.
class ElepayResultCancelled implements ElepayResult {
  final String paymentId;
  const ElepayResultCancelled(this.paymentId);
}

/// Failure result data.
///
/// Associated data is:
///  * payment id
///  * the error code
///  * the reason of the failure
///  * the detail message of the error
class ElepayResultFailed implements ElepayResult {
  /// The id of the payment that failed processing.
  final String paymentId;

  /// The error code could be used to get support from elepay.
  final String code;

  /// The reason of the error.
  final String reason;

  /// The detail message of the error.
  final String message;

  const ElepayResultFailed(
      this.paymentId, this.code, this.reason, this.message);
}

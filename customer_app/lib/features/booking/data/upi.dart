// UPI deep links (PLAN §12.9): the customer pays the mechanic's UPI ID directly; the app
// never asks for or stores bank or card details.

/// A UPI ID (VPA): `name@bank`, e.g. `kiran.patel@okaxis`.
final upiIdPattern = RegExp(r'^[a-zA-Z0-9._-]{2,256}@[a-zA-Z][a-zA-Z0-9]{1,63}$');

bool isValidUpiId(String upiId) => upiIdPattern.hasMatch(upiId.trim());

/// The note shown in the customer's UPI app: `Booking ABCD1234`.
String bookingNote(String bookingId) {
  final short = bookingId.replaceAll(RegExp('[^A-Za-z0-9]'), '');
  return 'Booking ${short.substring(0, short.length < 8 ? short.length : 8).toUpperCase()}';
}

/// `upi://pay?pa=…&pn=…&am=…&cu=INR&tn=…` with the amount fixed (so the customer can't be
/// asked for "a bit extra" off-app; PLAN §12 payment scam). Null if the UPI ID is malformed
/// or the amount isn't positive: then the app shows the ID and cash instead of a broken link.
///
/// Built by hand rather than with `Uri.queryParameters`, which writes spaces as `+`: several
/// UPI apps then show the payee as "Kiran+Patel". Names and notes are percent-encoded; the
/// UPI ID is validated and left as is (some apps reject `%40`).
Uri? upiPayUri({
  required String upiId,
  required String payeeName,
  required int amount,
  required String bookingId,
}) {
  final pa = upiId.trim();
  if (!isValidUpiId(pa) || amount <= 0) return null;
  final query = [
    'pa=$pa',
    'pn=${Uri.encodeComponent(payeeName.trim())}',
    'am=$amount.00',
    'cu=INR',
    'tn=${Uri.encodeComponent(bookingNote(bookingId))}',
  ].join('&');
  return Uri.parse('upi://pay?$query');
}

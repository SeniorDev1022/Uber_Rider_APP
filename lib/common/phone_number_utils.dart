String formatAndSanitizePhoneNumber(String rawNumber) {
  // First, sanitize the input by removing all non-digit characters
  String sanitizedNumber = rawNumber.replaceAll(RegExp(r'\D'), '');

  // Assuming the sanitized number is for US/Canada and should be 10 digits long
  if (sanitizedNumber.length != 10) {
    return 'Invalid phone number length'; // Handle as appropriate
  }

  // Split the number into its components
  String countryCode = '+1';
  String areaCode = sanitizedNumber.substring(0, 3);
  String prefix = sanitizedNumber.substring(3, 6);
  String lineNum = sanitizedNumber.substring(6);

  // Return the formatted phone number
  return '$countryCode $areaCode-$prefix-$lineNum';
}
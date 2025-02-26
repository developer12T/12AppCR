class StringHelper {
  // Generates a string with suitable spaces for left and right alignment.
  static String generateStringWithSuitableSpace(
    String leftText,
    String rightText,
    int totalWidth,
  ) {
    // Calculate the remaining space for alignment
    int spaceCount = totalWidth - leftText.length - rightText.length;
    spaceCount =
        spaceCount > 0 ? spaceCount : 0; // Ensure spaceCount is non-negative

    // Create the string with suitable spaces in between
    return leftText + ' ' * spaceCount + rightText;
  }

  // Utility function to pad a column to the right
  static String padRightWithSpaces(String text, int width) {
    return text.padRight(width);
  }

  // Utility function to pad a column to the left
  static String padLeftWithSpaces(String text, int width) {
    return text.padLeft(width);
  }
}

class RESTUtils {
  static String encodeParams(Map<String, String> params) {
    var s = "";
    params.forEach((key, value) {
      if (value != "null") {
        var urlEncode = Uri.encodeFull(value);
        s += "&$key=$urlEncode";
      }
    });
    return s;
  }
}

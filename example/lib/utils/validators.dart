/// Validates Hostname
bool isValidHost(String str) {
  if (str == null || str.isEmpty) return false;
  final ipAddressExp = RegExp(r'^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])$');
  final hostnameExp = RegExp(r'^(([a-zA-Z0-9]|[a-zA-Z0-9][a-zA-Z0-9\-]*[a-zA-Z0-9])\.)*([A-Za-z0-9]|[A-Za-z0-9][A-Za-z0-9\-]*[A-Za-z0-9])$');
  return ipAddressExp.hasMatch(str) || hostnameExp.hasMatch(str);
}

/// Validates a TCP port
bool isValidPort(String str) {
  if (str == null || str.isEmpty) return false;
  final regex = RegExp(r'^([0-9]{1,4}|[1-5][0-9]{4}|6[0-4][0-9]{3}|65[0-4][0-9]{2}|655[0-2][0-9]|6553[0-5])$');
  return regex.hasMatch(str);
}
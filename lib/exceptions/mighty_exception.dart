class MightyException {
  final String msg;

  MightyException(this.msg);

  @override
  String toString() {
    return this.msg;
  }
}

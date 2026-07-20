class RepositoryException implements Exception {
  final String operation;
  final Object cause;

  const RepositoryException(this.operation, this.cause);

  @override
  String toString() => 'RepositoryException($operation): $cause';
}

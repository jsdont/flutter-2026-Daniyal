sealed class ApiException implements Exception {
  const ApiException();
}

class NoConnectionException extends ApiException {
  const NoConnectionException();
}

class ServerException extends ApiException {
  const ServerException(this.status);

  final int status;
}

class NotFoundException extends ApiException {
  const NotFoundException();
}

class UnauthorizedException extends ApiException {
  const UnauthorizedException();
}

class BadResponseException extends ApiException {
  const BadResponseException([this.detail]);

  final String? detail;
}

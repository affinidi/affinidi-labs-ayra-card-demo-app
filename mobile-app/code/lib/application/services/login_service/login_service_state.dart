import 'package:meeting_place_core/meeting_place_core.dart';

enum LoginFlowStep {
  idle,
  loggingIn,
  establishingConnection,
  awaitingCredential,
  completed,
  error,
}

class LoginServiceState {
  const LoginServiceState({
    this.isLoading = false,
    this.step = LoginFlowStep.idle,
    this.errorMessage,
    this.statusMessage,
    this.lastEmail,
    this.lastResponseBody,
    this.channel,
  });

  final bool isLoading;
  final LoginFlowStep step;
  final String? errorMessage;
  final String? statusMessage;
  final String? lastEmail;
  final String? lastResponseBody;
  final Channel? channel;

  static const _sentinel = Object();

  LoginServiceState copyWith({
    bool? isLoading,
    LoginFlowStep? step,
    Object? errorMessage = _sentinel,
    Object? statusMessage = _sentinel,
    Object? lastEmail = _sentinel,
    Object? lastResponseBody = _sentinel,
    Object? channel = _sentinel,
  }) {
    return LoginServiceState(
      isLoading: isLoading ?? this.isLoading,
      step: step ?? this.step,
      errorMessage: identical(errorMessage, _sentinel)
          ? this.errorMessage
          : errorMessage as String?,
      statusMessage: identical(statusMessage, _sentinel)
          ? this.statusMessage
          : statusMessage as String?,
      lastEmail: identical(lastEmail, _sentinel)
          ? this.lastEmail
          : lastEmail as String?,
      lastResponseBody: identical(lastResponseBody, _sentinel)
          ? this.lastResponseBody
          : lastResponseBody as String?,
      channel: identical(channel, _sentinel)
          ? this.channel
          : channel as Channel?,
    );
  }
}

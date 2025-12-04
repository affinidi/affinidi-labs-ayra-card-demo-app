import 'dart:async';
import 'package:affinidi_tdk_vdip/affinidi_tdk_vdip.dart';
import 'package:meeting_place_core/meeting_place_core.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../infrastructure/exceptions/app_exception.dart';
import '../../../infrastructure/exceptions/app_exception_type.dart';
import '../../../infrastructure/loggers/app_logger/app_logger.dart';
import '../../../infrastructure/providers/app_logger_provider.dart';
import '../../../infrastructure/providers/shared_preferences_provider.dart';
import '../../../infrastructure/utils/credential_helper.dart';
import '../ayra_service/ayra_service.dart';
import '../vdip_service/vdip_service.dart';
import 'issuer_did_cache.dart';
import 'login_service_state.dart';

part 'login_service.g.dart';

@Riverpod(keepAlive: true)
class LoginService extends _$LoginService {
  static const _logKey = 'LOGIN';

  late final AppLogger _logger = ref.read(appLoggerProvider);

  @override
  LoginServiceState build() => const LoginServiceState();

  Future<void> login({required String email, required String provider}) async {
    _logger.info('Starting login for $email', name: _logKey);
    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
      statusMessage: 'Initializing login process...',
      step: LoginFlowStep.loggingIn,
    );

    try {
      state = state.copyWith(
        step: LoginFlowStep.establishingConnection,
        statusMessage: 'Establishing secure connection...',
      );

      final prefs = await ref.read(sharedPreferencesProvider.future);
      await prefs.setString(SharedPreferencesKeys.provider.name, provider);
      await prefs.setString(SharedPreferencesKeys.email.name, email);

      state = state.copyWith(
        step: LoginFlowStep.awaitingCredential,
        statusMessage: 'Requesting credentials...',
      );

      final vdipService = ref.read(vdipServiceProvider);

      final credentialsRequest = RequestCredentialsOptions(
        proposalId: CredentialHelper.employment,
        credentialMeta: CredentialMeta(data: {'email': email}),
      );

      VdipResult? credentialResult;

      await vdipService.requestCredential(
        credentialsRequest: credentialsRequest,
        onProgress: (msg) async {
          _logger.info('Credential request progress: $msg', name: _logKey);
          state = state.copyWith(statusMessage: msg);
        },
        onComplete: (result) async {
          credentialResult = result;
          _logger.info(
            'Credential request completed with status: ${result.status}',
            name: _logKey,
          );
          if (result.isSuccess) {
            state = state.copyWith(
              statusMessage: 'Credentials received successfully!',
            );
          } else if (result.isFailure) {
            state = state.copyWith(
              statusMessage: 'Failed to receive credentials: ${result.message}',
            );
          } else if (result.isCancelled) {
            state = state.copyWith(
              statusMessage: 'Credential request was cancelled',
            );
          }
        },
      );

      // Check if the credential request was successful before completing login
      if (credentialResult?.isSuccess == true) {
        //saving issuerDID in cache
        await cacheIssuerDid(
          ref: ref,
          issuerDid: credentialResult!.credentialResult!.issuerDid,
        );

        //update name in ayra auth state
        await ref
            .read(ayraAuthProvider.notifier)
            .loadNameFromEmploymentCredential(
              credentialResult!.credentialString!,
            );

        state = state.copyWith(
          isLoading: false,
          errorMessage: null,
          statusMessage: 'Login completed successfully!',
          step: LoginFlowStep.completed,
        );
      } else {
        // Handle failure or cancellation
        final errorMessage = credentialResult?.isFailure == true
            ? 'Credential request failed: ${credentialResult!.message}'
            : credentialResult?.isCancelled == true
            ? 'Credential request was cancelled'
            : 'Unknown error occurred during credential request';

        state = state.copyWith(
          isLoading: false,
          errorMessage: errorMessage,
          statusMessage: null,
          step: LoginFlowStep.error,
        );

        throw AppException(errorMessage, code: AppExceptionType.other.name);
      }
    } catch (error, stackTrace) {
      _logger.error(
        'Login flow failed',
        error: error,
        stackTrace: stackTrace,
        name: _logKey,
      );
      final friendlyMessage = _mapErrorToMessage(error);
      state = state.copyWith(
        isLoading: false,
        errorMessage: friendlyMessage,
        statusMessage: null,
        step: LoginFlowStep.error,
      );
      rethrow;
    }
  }

  void reset() {
    state = const LoginServiceState();
  }

  String _mapErrorToMessage(Object error) {
    if (error is AppException) {
      return error.message;
    } else if (error is MeetingPlaceCoreSDKException) {
      final original = error.innerException;
      if (original is AppException) {
        return original.message;
      }

      return original.toString();
    }

    if (error is TimeoutException) {
      return 'The request timed out. Please try again.';
    }

    return error.toString();
  }
}

## Ayra Section Work Log

### Created
- `lib/application/services/did_manager_service/did_manager_service.dart`: Riverpod service that resolves a `DidManager` for a DID by reading secure storage, generating keys on demand, and exposing it through `didManagerServiceProvider` for reuse across flows.

### Updated
- `lib/application/services/scan_service/verifier_connection_service.dart`: Refactored confirm flow to pull claimed credentials from the vault instead of minting demo data, added helpers to serialize vault credentials, tightened logging around VDSP callbacks, and wired in `didManagerServiceProvider` plus existing identities service.
- `lib/presentation/screens/ayra/scan_flow/scan_confirm_screen.dart`: Screen now delegates all confirmation logic to the service, relying on the new flow and surfacing richer error logging while keeping the UI lightweight.
- `lib/presentation/screens/ayra/ayra_main_screen.dart`: Onboarding automatically advances to provider selection when the default vault profile becomes available, surfaces an inline retry message on initialization failure, and preserves the remembered provider path via shared state.
- `lib/application/services/vault_service/vault_service.dart`: Supports credential listing via `getCredentials`, enabling the verifier flow to reuse persisted credentials rather than creating temporary ones.
- `learning.md`: Captures this consolidated history for future maintenance.

### Services & Providers
- `didManagerServiceProvider` exposes DID manager retrieval independently from the vault service, keeping secure-storage lookups encapsulated.
- `verifierConnectionServiceProvider` orchestrates DIDComm channel resolution, DID manager retrieval, vault credential loading, and VDSP listener setup in one place, giving screens a single entrypoint.
- `vaultServiceProvider` continues to manage profile initialization and credential storage; its notifier is now the source of truth for credentials shared during verifier flows.

### Messages & Flows
- Scan confirmation flow resolves or establishes verifier channels, authenticates with VDSP, and shares the full set of vault credentials, falling back gracefully when parsing fails.
- VDSP messaging reuses `VpspTriggerRequestBody` to kick off verifier requests, with improved debug logging for feature queries, data requests, and result reports.
- Onboarding flow transitions automatically once vault setup succeeds and keeps the manual retry affordance when setup fails.

### Shared Preferences & Local State
- Provider resume logic still reads cached issuer DIDs from shared preferences via `issuerDidPreferenceKey`; combined with the auto-advance behavior this delivers a smoother onboarding resume path.
- Onboarding state (`ayraOnboardingProvider`) now updates immediately after profile readiness, removing the extra user action while keeping per-provider selections intact.

### Packages & Imports
- Core packages leveraged: `flutter_riverpod` (state management for services/screens), `mpx_sdk` (channel discovery, message delivery), `affinidi_tdk_didcomm_client` (VDSP holder client), `ssi` (wallet, DID manager utilities and credential parsing), `uuid` (trigger message IDs), and `affinidi_tdk_vault` plus `affinidi_tdk_vault_flutter_utils` (vault access, secure storage seed management).
- Screen and service files import shared infrastructure layers: `app_logger` for structured logging, `app_exception` for domain errors, `identities_service` for vCard data, `vault_service` for profiles and credentials, `secure_storage` for key retrieval, and shared messages like `VpspTriggerRequestBody`.

### Widgets, Models & State
- Widgets: `AyraMainScreen`, `_OnboardingScaffold`, `_SetupProfileCard`, `_ProviderSelectionCard`, `_LoginCard` manage onboarding UI states; `ScanConfirmScreen` handles scan-specific confirmation; `_InfoTile` displays connection metadata in confirmation flow.
- Models: `AyraOnboardingState` (with `AyraOnboardingStep` enum) stores onboarding progress; `LoginServiceState` indicates login step and error; `VpspTriggerRequestBody` shapes outgoing trigger messages; vault claimed credentials rely on `DigitalCredential` from the TDK.
- Providers/Notifiers: `ayraOnboardingProvider`, `loginServiceProvider`, `identitiesServiceProvider`, `sharedPreferencesProvider`, `mpxSdkProvider`, `verifierConnectionServiceProvider`, `didManagerServiceProvider`, `vaultServiceProvider`.

### Sequence of the Ayra Flow
1. **App launch / screen init**: `AyraMainScreen` initializes `_screens`, kicks off `_initializeProfile`, and watches `ayraOnboardingProvider`.
2. **Vault setup loop**: `vaultServiceProvider.notifier.getProfile()` ensures the Ayra vault and default profile exist. On success `_profileReady` flips true and onboarding step auto-advances to `selectProvider`. Failures surface `_setupError`, enabling retry.
3. **Provider selection**: `_ProviderSelectionCard` fetches the available providers list; tapping a provider attempts `_resumeIfChannelExists` using `sharedPreferencesProvider` to read cached issuer DIDs and `mpxSdkProvider` to resume channels. If no channel, onboarding progresses to login.
4. **Login flow**: `_LoginCard` collects or pre-fills email (via `identitiesServiceProvider` vCard) and invokes `loginServiceProvider` to run the existing login service sequence (not refactored here), which caches issuer DIDs on success.
5. **Scan confirm**: `ScanConfirmScreen` receives decoded scan results, reads `verifierConnectionServiceProvider`, and calls `confirmScan`.
6. **Channel resolution**: `VerifierConnectionService.confirmScan` resolves existing DIDComm channel (`mpx_sdk`) or accepts the OOB invitation, using `identitiesServiceProvider` to provide contact vCard metadata.
7. **DID manager retrieval**: `didManagerServiceProvider` returns a `DidManager` based on the channel’s holder DID using secure storage.
8. **Vault credential load**: Service calls `vaultServiceProvider.notifier.getCredentials()` and reads `vaultServiceProvider` state to obtain all claimed credentials.
9. **VDSP subscription**: Using `VdspHolderClient.init`, the service authenticates, listens for incoming feature/data requests, converts vault credentials to `ParsedVerifiableCredential`, and shares them when requested.
10. **Trigger message**: After listener startup, the service sends a `VpspTriggerRequestMessage` via `mpx_sdk.sendMessage` to prompt the verifier to request data.
11. **Navigation**: On success, `ScanConfirmScreen` navigates to `ScanSuccessRoute`; errors propagate via snackbars/logging.

### Notes & Follow-ups
- Ensure vault credentials remain synchronized for demo environments; the flow now depends entirely on stored credentials.
- Shared preferences usage (issuer DID caching) is unchanged but critical for quick provider resumes—consider purging or refreshing entries during logout flows.
- Future refinements could align login and scan flows to reuse the same DID manager service for other DIDComm interactions.

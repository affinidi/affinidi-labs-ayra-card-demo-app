# mobile_experience_app

This reference application demonstrates how to use the MPX Flutter modules and example integrations (state management, services, infrastructure) in a real Flutter project.

## Requirements

- Flutter 3.35.3
- Dart SDK ^3.9.2

## Getting started

Set up your local environment to run the vault application.

#### Install FVM

Install the FVM package for Flutter version management. Currently using Flutter `3.35.3` for this project.

```
brew tap leoafarias/fvm
brew install fvm
```

Refer to the [installation](https://fvm.app/documentation/getting-started/installation) page of FVM to set up for other platforms.

#### Set up Flutter Path

Add the `fvm` in the $PATH for Flutter.

> The command below assumes you are using ZSH.

```
echo '# Setup Flutter path' >> ~/.zshrc
echo 'export PATH="$HOME/fvm/default/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc
```

### JAVA version

This project uses Java 17 and `jenv` to select the correct version.

#### Install JENV

```
brew install jenv
echo '# Load jenv'  >> ~/.zshrc
echo 'eval "$(jenv init -)"'  >> ~/.zshrc
source ~/.zshrc
```

#### Install Java 17

```
brew install openjdk@17
jenv add /opt/homebrew/opt/openjdk@17/libexec/openjdk.jdk/Contents/Home/
```

## Generating models

To generate models, run the following command in your terminal:

```bash
make gen
```

## Environment variables

Most environment variables have sensible defaults defined in the application. You only need to provide values that are specific to your setup or when you want to override the defaults.

### Required environment variables

The following variables **must** be provided in your `configurations/.env` file:

```bash
# Required for MPX SDK core functionality
SERVICE_DID=""
DEFAULT_MEDIATOR_DID=""

# Required for Firebase integration
FIREBASE_IOS_APIKEY=""
FIREBASE_IOS_APP_ID=""
FIREBASE_MESSAGING_SENDER_ID=""
FIREBASE_PROJECT_ID=""
FIREBASE_STORAGE_BUCKET=""
FIREBASE_IOS_BUNDLE_ID=""
FIREBASE_ANDROID_APIKEY=""
FIREBASE_ANDROID_APP_ID=""
```

### Optional environment variables

The following variables have default values but can be customized:

```bash
# App configuration (defaults shown)
APP_VERSION_NAME=""                              # Default: ""
BIOMETRICS_ENABLED="true"                        # Default: true
DATABASE_LOGGING_ENABLED="false"                 # Default: false (debug mode only)
FOREGROUND_NOTIFICATIONS_ENABLED="false"         # Default: false
TAPS_TO_UNLOCK_DEBUG="7"                         # Default: 7

# Chat settings (defaults shown)
CHAT_ACTIVITY_EXPIRES_IN_SECONDS="3"             # Default: 3
CHAT_PRESENCE_SEND_INTERVAL_IN_SECONDS="60"      # Default: 60
CHAT_IMAGE_MAX_SIZE="800"                        # Default: 800
CHAT_IMAGE_QUALITY_PERCENT="80"                  # Default: 80

# Profile settings (defaults shown)
PROFILE_IMAGE_MAX_SIZE="100"                     # Default: 100
PROFILE_IMAGE_QUALITY_PERCENT="80"               # Default: 80

# Marketplace
MARKETPLACE_QR_PREFIX=""                         # Default: ""
```

> **Note:** You can find all available configuration options and their default values in `lib/infrastructure/configuration/environment.dart`.

## Identity Verification (IDV)

The IDV attachment plugin enables users to prove their identity by scanning an identity document and sending it to a chat as a Verifiable Presentation (VP).

To enable this feature:

1. Go to the [Affinidi Portal](https://docs.affinidi.com/frameworks/iota-framework/sample-application-redirect/#create-a-personal-access-token) to set up your project
   **Note:** There are two Affinidi Portals: `dev` and `prod`
2. Once you obtain the required values for your chosen environment, create a configuration file if you haven't already:
   - Use `configurations/.env` for production
   - Use `configurations/.env.dev` for development

Add the following required variables to your environment file:

```
AFFINIDI_TDK_ENVIRONMENT=""
VAULT_NAME=""
VERIFF_PROVIDER_ID=""
PORTAL_PROJECT_ID=""
PORTAL_TOKEN_ID=""
PORTAL_PRIVATE_KEY=""
PORTAL_TOKEN_PASSPHRASE=""
```

#### Description of IDV variables

- `AFFINIDI_TDK_ENVIRONMENT`: can only be `"dev"` or `"prod"` depending on the environment
- `VAULT_NAME`: the name of the Affinidi TDK Vault used to store your IDV Verifiable Credential
- `VERIFF_PROVIDER_ID`: provider ID for Veriff, used by the plugin under the hood
- `PORTAL_PROJECT_ID`: generated when creating a Personal Access Token (PAT) from the Affinidi Portal
- `PORTAL_TOKEN_ID`: generated when creating a PAT from the Affinidi Portal
- `PORTAL_PRIVATE_KEY`: generated when creating a PAT from the Affinidi Portal
- `PORTAL_TOKEN_PASSPHRASE`: the passphrase you assigned when creating the PAT

### iOS

Make sure to add the configuration file to your iOS project by adding `GoogleService-Info.plist` in the folder `ios/Runner`

### Android

Make sure to add the configuration file to your iOS project by adding `google-services.json` in the folder `android/app`

## VS Code Configuration

If you are using VS Code as your IDE, you can quickly set up your launch configuration for this project:

1. Copy the template file from `/templates/.example.launch.json`
2. Paste it into your project’s `.vscode` directory and rename it to `launch.json`

This pre-defined configuration is set up to point to the appropriate environment file for your project. You can further customize this file to add or modify device IDs, change environment files, or extend it to suit your development needs.

## Run App on Simulator

Refer to Flutter's [Getting Started](https://docs.flutter.dev/get-started/install) page to learn more about setting up your environment to run the Flutter application on simulators.

## Support & feedback

If you face any issues or have suggestions, please don't hesitate to contact us using [this link](https://share.hsforms.com/1i-4HKZRXSsmENzXtPdIG4g8oa2v).

### Reporting technical issues

If you have a technical issue with the project's codebase, you can also create an issue directly in GitHub.

1. Ensure the bug was not already reported by searching on GitHub under
   [Issues]().

2. If you're unable to find an open issue addressing the problem,
   [open a new one]().
   Be sure to include a **title and clear description**, as much relevant information as possible,
   and a **code sample** or an **executable test case** demonstrating the expected behaviour that is not occurring.

## Contributing

Want to contribute?

Head over to our [CONTRIBUTING]() guidelines.

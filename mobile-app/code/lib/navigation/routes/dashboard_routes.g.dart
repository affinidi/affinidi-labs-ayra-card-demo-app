// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dashboard_routes.dart';

// **************************************************************************
// GoRouterGenerator
// **************************************************************************

List<RouteBase> get $appRoutes => [$dashboardShellRouteData];

RouteBase get $dashboardShellRouteData => StatefulShellRouteData.$route(
  restorationScopeId: DashboardShellRouteData.$restorationScopeId,
  factory: $DashboardShellRouteDataExtension._fromState,
  branches: [
    StatefulShellBranchData.$branch(
      navigatorKey: DashboardBranchData.$navigatorKey,
      restorationScopeId: DashboardBranchData.$restorationScopeId,

      routes: [
        GoRouteData.$route(
          path: '/dashboard',
          name: 'dashboard',

          factory: _$DashboardRoute._fromState,
          routes: [
            GoRouteData.$route(
              path: 'idv',
              name: 'idvFlow',

              factory: _$IdvFlowRoute._fromState,
            ),
            GoRouteData.$route(
              path: 'business-card',
              name: 'businessCard',

              factory: _$BusinessCardRoute._fromState,
            ),
          ],
        ),
      ],
    ),
    StatefulShellBranchData.$branch(
      navigatorKey: CredentialsBranchData.$navigatorKey,
      restorationScopeId: CredentialsBranchData.$restorationScopeId,

      routes: [
        GoRouteData.$route(
          path: '/credentials',
          name: 'credentials',

          factory: _$CredentialsRoute._fromState,
          routes: [
            GoRouteData.$route(
              path: 'credential-view',
              name: 'credentialView',

              factory: _$CredentialViewRoute._fromState,
            ),
            GoRouteData.$route(
              path: 'credential-json',
              name: 'credentialJson',

              factory: _$CredentialJsonRoute._fromState,
            ),
          ],
        ),
      ],
    ),
    StatefulShellBranchData.$branch(
      navigatorKey: ProfileBranchData.$navigatorKey,
      restorationScopeId: ProfileBranchData.$restorationScopeId,

      routes: [
        GoRouteData.$route(
          path: '/profile',
          name: 'profile',

          factory: _$ProfileRoute._fromState,
        ),
      ],
    ),
    StatefulShellBranchData.$branch(
      navigatorKey: ScanShareBranchData.$navigatorKey,
      restorationScopeId: ScanShareBranchData.$restorationScopeId,

      routes: [
        GoRouteData.$route(
          path: '/scan-share',
          name: 'scanShare',

          factory: _$ScanShareRoute._fromState,
          routes: [
            GoRouteData.$route(
              path: 'scan-camera',
              name: 'scanCamera',

              factory: _$ScanCameraRoute._fromState,
            ),
          ],
        ),
      ],
    ),
  ],
);

extension $DashboardShellRouteDataExtension on DashboardShellRouteData {
  static DashboardShellRouteData _fromState(GoRouterState state) =>
      const DashboardShellRouteData();
}

mixin _$DashboardRoute on GoRouteData {
  static DashboardRoute _fromState(GoRouterState state) =>
      const DashboardRoute();

  @override
  String get location => GoRouteData.$location('/dashboard');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin _$IdvFlowRoute on GoRouteData {
  static IdvFlowRoute _fromState(GoRouterState state) => IdvFlowRoute(
    autoStart:
        _$convertMapValue(
          'auto-start',
          state.uri.queryParameters,
          _$boolConverter,
        ) ??
        false,
  );

  IdvFlowRoute get _self => this as IdvFlowRoute;

  @override
  String get location => GoRouteData.$location(
    '/dashboard/idv',
    queryParams: {
      if (_self.autoStart != false) 'auto-start': _self.autoStart.toString(),
    },
  );

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin _$BusinessCardRoute on GoRouteData {
  static BusinessCardRoute _fromState(GoRouterState state) =>
      const BusinessCardRoute();

  @override
  String get location => GoRouteData.$location('/dashboard/business-card');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin _$CredentialsRoute on GoRouteData {
  static CredentialsRoute _fromState(GoRouterState state) =>
      const CredentialsRoute();

  @override
  String get location => GoRouteData.$location('/credentials');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin _$CredentialViewRoute on GoRouteData {
  static CredentialViewRoute _fromState(GoRouterState state) =>
      CredentialViewRoute(
        $extra: state.extra as ParsedVerifiableCredential<dynamic>,
      );

  CredentialViewRoute get _self => this as CredentialViewRoute;

  @override
  String get location => GoRouteData.$location('/credentials/credential-view');

  @override
  void go(BuildContext context) => context.go(location, extra: _self.$extra);

  @override
  Future<T?> push<T>(BuildContext context) =>
      context.push<T>(location, extra: _self.$extra);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location, extra: _self.$extra);

  @override
  void replace(BuildContext context) =>
      context.replace(location, extra: _self.$extra);
}

mixin _$CredentialJsonRoute on GoRouteData {
  static CredentialJsonRoute _fromState(GoRouterState state) =>
      CredentialJsonRoute(
        $extra: state.extra as ParsedVerifiableCredential<dynamic>,
      );

  CredentialJsonRoute get _self => this as CredentialJsonRoute;

  @override
  String get location => GoRouteData.$location('/credentials/credential-json');

  @override
  void go(BuildContext context) => context.go(location, extra: _self.$extra);

  @override
  Future<T?> push<T>(BuildContext context) =>
      context.push<T>(location, extra: _self.$extra);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location, extra: _self.$extra);

  @override
  void replace(BuildContext context) =>
      context.replace(location, extra: _self.$extra);
}

mixin _$ProfileRoute on GoRouteData {
  static ProfileRoute _fromState(GoRouterState state) => const ProfileRoute();

  @override
  String get location => GoRouteData.$location('/profile');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin _$ScanShareRoute on GoRouteData {
  static ScanShareRoute _fromState(GoRouterState state) =>
      const ScanShareRoute();

  @override
  String get location => GoRouteData.$location('/scan-share');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin _$ScanCameraRoute on GoRouteData {
  static ScanCameraRoute _fromState(GoRouterState state) =>
      const ScanCameraRoute();

  @override
  String get location => GoRouteData.$location('/scan-share/scan-camera');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

T? _$convertMapValue<T>(
  String key,
  Map<String, String> map,
  T? Function(String) converter,
) {
  final value = map[key];
  return value == null ? null : converter(value);
}

bool _$boolConverter(String value) {
  switch (value) {
    case 'true':
      return true;
    case 'false':
      return false;
    default:
      throw UnsupportedError('Cannot convert "$value" into a bool.');
  }
}

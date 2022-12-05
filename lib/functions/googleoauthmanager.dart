import 'dart:developer';
import 'dart:io';
import 'package:arthurmorgan/global_data.dart';
import 'package:http/http.dart' as http;
import 'package:oauth2/oauth2.dart' as oauth2;
import 'package:url_launcher/url_launcher.dart';

class GoogleOAuthManager {
  String authorizationEndpoint = "https://accounts.google.com/o/oauth2/v2/auth";
  String tokenEndpoint = "https://oauth2.googleapis.com/token";
  String clientID = GlobalData.gClientId!;
  String clientSecret = GlobalData.gClientSecret!;

  HttpServer? redirectServer;
  oauth2.Client? client;

  Future<void> redirect(Uri authorizationUrl) async {
    var url = authorizationUrl.toString();
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      throw Exception('Could not launch $url');
    }
  }

  Future<Map<String, String>> listen() async {
    var request = await redirectServer!.first;
    var params = request.uri.queryParameters;
    request.response.statusCode = 200;
    request.response.headers.set('content-type', 'text/plain');
    request.response.writeln('Authenticated! You can close this tab.');
    await request.response.close();
    await redirectServer!.close();
    redirectServer = null;
    return params;
  }

  Future<oauth2.Client> login() async {
    await redirectServer?.close();
    // Bind to an ephemeral port on localhost
    redirectServer = await HttpServer.bind('localhost', 0);
    final redirectURL = 'http://localhost:${redirectServer!.port}/auth';
    var authenticatedHttpClient =
        await _getOAuth2Client(Uri.parse(redirectURL));
    return authenticatedHttpClient;
  }

  Future<oauth2.Client> _getOAuth2Client(Uri redirectUrl) async {
    var grant = oauth2.AuthorizationCodeGrant(
      clientID,
      Uri.parse(authorizationEndpoint),
      Uri.parse(tokenEndpoint),
      httpClient: _JsonAcceptingHttpClient(),
      secret: clientSecret,
    );
    var authorizationUrl = grant.getAuthorizationUrl(redirectUrl, scopes: [
      "https://www.googleapis.com/auth/drive",
    ]);

    await redirect(authorizationUrl);
    var responseQueryParameters = await listen();

    var client =
        await grant.handleAuthorizationResponse(responseQueryParameters);
    return client;
  }

  Future<oauth2.Client> createClientFromCreds(String oauthjson) async {
    var credentials = oauth2.Credentials.fromJson(oauthjson);
    oauth2.Client client =
        oauth2.Client(credentials, identifier: clientID, secret: clientSecret);
    log(client.credentials.toJson().toString(), name: "TEST");
    return client;
  }
}

class _JsonAcceptingHttpClient extends http.BaseClient {
  final _httpClient = http.Client();
  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    request.headers['Accept'] = 'application/json';
    return _httpClient.send(request);
  }
}

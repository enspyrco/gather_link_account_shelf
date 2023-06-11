import 'dart:convert';

import 'package:gather_link_account_shelf/config/secret.dart';
import 'package:http/http.dart' as http;
import 'package:shelf/shelf.dart' show Request, Response;

Future<Response> githubHandler(Request request) async {
  String? nonce, code;

  try {
    nonce = request.url.queryParameters['state']!;
    code = request.url.queryParameters['code']!;

    // Exchange the code & secret for a token
    var tokenResponse = await http.post(
        Uri(
            scheme: 'https',
            host: 'github.com',
            path: 'login/oauth/access_token'),
        headers: {
          'Accept': 'application/json'
        },
        body: {
          'client_id': '3b2457d371c7b9b4a1b8',
          'client_secret': clientSecret,
          'code': code
        });
    var decodedTokenResponse =
        jsonDecode(utf8.decode(tokenResponse.bodyBytes)) as Map;
    var accessToken = decodedTokenResponse['access_token'] as String;

    return Response.movedPermanently(
        'https://gather-identity-link.web.app/github?token=$accessToken');
  } catch (error, trace) {
    return Response.internalServerError(
        body: 'error:\n$error\n\ntrace:\n$trace');
  } finally {
    // Locate.client.close();
  }
}

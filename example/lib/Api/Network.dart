import 'dart:convert';

import 'package:http/http.dart' as http;

enum HTTPMethod { POST, GET }

class HTTPHeader {
  final String name;
  final String value;

  const HTTPHeader({required this.name, required this.value});

  static HTTPHeader accept(String value) => HTTPHeader(name: 'Accept', value: value);
  static HTTPHeader userAgent(String value) => HTTPHeader(name: 'User-Agent', value: value);
  static HTTPHeader authorization(String bearerToken) =>
      HTTPHeader(name: 'Authorization', value: 'Bearer $bearerToken');
  static HTTPHeader contentType(String value) => HTTPHeader(name: 'Content-Type', value: value);
  static HTTPHeader contentEncoding(String value) => HTTPHeader(name: 'Content-Encoding', value: value);
  static HTTPHeader acceptEncoding(String value) => HTTPHeader(name: 'Accept-Encoding', value: value);
}

abstract class ReqInterceptor {
  void adapt(http.Request request);
}

class HeaderInterceptor implements ReqInterceptor {
  List<HTTPHeader> headers = [
    HTTPHeader.accept('application/json'),
    HTTPHeader.contentType('application/json'),
  ];

  @override
  void adapt(http.Request request) {
    headers.forEach((header) {
      request.headers[header.name] = header.value;
    });
  }
}

class Network {
  final HeaderInterceptor headerInterceptor;

  Network({required this.headerInterceptor});

  Future<http.Response> _sendRequest(http.Request request) async {
    http.Client client = http.Client();
    try {
      return await client.send(request).then((result) => http.Response.fromStream(result));
    } finally {
      client.close();
    }
  }

  Future<Map<String, dynamic>> requestJSON(
    String url, {
    HTTPMethod method = HTTPMethod.POST,
    Map<String, dynamic>? params,
  }) async {
    var uri = Uri.parse(url);
    var request = http.Request(method.name, uri);

    if (params != null) {
      request.body = jsonEncode(params);
    }

    headerInterceptor.adapt(request);

    http.Response response = await _sendRequest(request);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception('Network request failed: ${response.statusCode} ${response.body}');
    }
  }
}

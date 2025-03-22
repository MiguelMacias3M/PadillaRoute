import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:jose/jose.dart';

const String serverUrl = "https://fcm.googleapis.com/v1/projects/padillarouteapp-b4ef8/messages:send";


// Función para enviar un mensaje de FCM
Future<void> sendFCMMessage(String title, String body, String topic, String accessToken) async {
  final url = Uri.parse(serverUrl);

  final response = await http.post(
    url,
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accessToken',
    },
    body: jsonEncode({
      "message": {
        "topic": topic,
        "notification": {
          "title": title,
          "body": body
        }
      }
    }),
  );

  if (response.statusCode == 200) {
    print('Notificación enviada con éxito');
  } else {
    print('Error al enviar la notificación: ${response.body}');
  }
}

// Función para enviar un mensaje de FCM a un usuario específico usando su FCM Token
Future<void> sendFCMMessageToUser(String title, String body, String fcmToken, String accessToken) async {
  final url = Uri.parse(serverUrl);

  final response = await http.post(
    url,
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accessToken',
    },
    body: jsonEncode({
      "message": {
        "token": fcmToken,  // Usamos el token del usuario aquí
        "notification": {
          "title": title,
          "body": body,
        }
      }
    }),
  );
print("URL de FCM: $url");
  if (response.statusCode == 200) {
    print('Notificación enviada con éxito');
  } else {
    print('Error al enviar la notificación: ${response.statusCode} - ${response.body}');
  }
}


// Función pública para obtener el accessToken
Future<String> getAccessToken() async {
  final jwt = await _generateJWT();
  return await _getAccessToken(jwt);
}

// Genera un JWT para autenticación con Firebase
Future<String> _generateJWT() async {
  final privateKeyPem = '''
-----BEGIN PRIVATE KEY-----
MIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQCdeMbkRwyHyCvL\n0zfTeJAzEkL+P46PFDfX011
ijtjb1zer5NCeOKa8+XGR39PU2OjvlpSNgoV1YmiT\nci8j2VHNA6tjvvOeF3FGplW+/bl4yN+T+uyCWNcqGuurLM
GjJQSBHV2YOBeKIINg\nP9PynAndbH2kj3cMkY5wXwyQbslMeqXNQbV3j3ZKjF8ol45DgfJx+MWssNV5qjtn\nbDX
N1i5m7wP+81rV285iTG0wg7GWdcRfFRgW6jUva67sZfKlZQSD6GxGdsJognc2\nCaxlR7tl7WKAaqJu7VpV36zU2i
slRp7/2c1eDhaH8izuCTtxtZSDvS3itjVO5R4n\nuti45/P9AgMBAAECggEABicR2W7qVkB5Gnt3l2074f6CDiOXB
p3+jpHTaoZX9DTB\nbUIzDEHD1gPNrv/L+fe6F/c/zr6EgLg7i3F9ZJQgTVrxEhYD8RMvS3TfEVl3R2rM\n6C4xRK
+f0d4N9U5BFlvNvTHwQNeUNhhVOb2NlHxC0/epJNhaXrMt4NP947xWnT2T\nXeaSU2QnCJ7aTeCQ+dxmB41YMw2RJ
6S9ryvcmu7YfmDmSbUsZPlswFpVV2DbETAv\nX/TWE8Rv7XdY+QUyq+It7QeL7foYbPVX/OSNNQE+OODJAyZUgCid
tHwBeW1ixAsA\npjzhiJhObTC9k3c0tKrKT2ZfyHC8wrhZLFFRWOrxSwKBgQDVHyKrh6SL5DV2Jpl0\n9rqy5lN65
OYYs5yMvqaW6YlmxymRrRVVcZBVthUschwJEBqBKRidOUwHcheBndDK\ntaxqhV3g4sUsFV4f5oMEbIh97z3Yge+T
1Ev5SRXvedUEHKIeM9wBMqQYUCM107qe\niXU34ccMNb4YRyyqvbFruPAmxwKBgQC9J2MpOOnbUgzV3JCAMwTsF7J
yeFhqhxy6\nroyfj+nzGMwpYcz4cPLhjaGehFJAj9nqNmG4Fc2TXSV/8eSsZB6NQ+1oh1rbRnC2\nJztO/5Vu1B+v
MRLBfBN1vv8kZKja7mfFReudFrq7lCRVu1W7o+9OQYbzbtqtmCcl\nbWXl+Dw7GwKBgHADPkijMTOpTQP9Q5h6+SN
/9Q5Zcio3dKdwqMQWmHXhZZLAQr82\nweKaocRLcTq+MQADpoE0FSawq3QfixaPp8AQuoexCGqkDGV91QylMpPmAz
5hBJdQ\n9GFgLVxBT1kq53YyUYZ7pE13CRqIXsRmgKpPSzu6n1/JQMu4iaCRgf8PAoGAV+5x\neH5OqHgyI1EPk6k
kBqTVfcVYRN1ei6INGTgLp8jFUA94+512K0ht84TLv9ufj/OL\n5cms8W6BukK27TT1xvHm8YrKv9i1GNiQB59k1k
qiGA0WDQAjA7+wWDi7Dlt5vglN\nCI/CauTpJzmZF0uUOarYk13bJovu1sVOc2O8jDUCgYEAhRxwOtXXnVWTXOc0Q
Es1\n7izMHBP/OXLfZ7JvxjjpQ5jNemUeEYbLFRRh1l/FlrvtCToZIZkyfhOSTAXm553V\nmVvyRDn9qkF2+PfFoL
WaSVhhZdraDIsbbCx9LxuA3/n3JNnIk1j2ADE6P0zTcD+D\n09Gn6KngzLp1oc4+HmembIE=
-----END PRIVATE KEY-----
''';

  final key = JsonWebKey.fromPem(privateKeyPem); // Eliminamos el parámetro 'algorithm'

  final jwt = JsonWebSignatureBuilder()
    ..jsonContent = {
      'iss': 'firebase-adminsdk-fbsvc@padillarouteapp-b4ef8.iam.gserviceaccount.com',
      'scope': 'https://www.googleapis.com/auth/firebase.messaging',
      'aud': 'https://oauth2.googleapis.com/token',
      'exp': DateTime.now().millisecondsSinceEpoch ~/ 1000 + 3600,
      'iat': DateTime.now().millisecondsSinceEpoch ~/ 1000
    }
    ..addRecipient(key, algorithm: 'RS256'); // Aquí se especifica el algoritmo

  return jwt.build().toCompactSerialization();
}

// Obtiene el token de acceso usando el JWT
Future<String> _getAccessToken(String jwt) async {
  final response = await http.post(
    Uri.parse('https://oauth2.googleapis.com/token'),
    headers: {'Content-Type': 'application/x-www-form-urlencoded'},
    body: {
      'grant_type': 'urn:ietf:params:oauth:grant-type:jwt-bearer',
      'assertion': jwt,
    },
  );

  if (response.statusCode == 200) {
    final jsonResponse = jsonDecode(response.body);
    return jsonResponse['access_token'];
  } else {
    throw Exception('Error obteniendo access token: ${response.body}');
  }
}

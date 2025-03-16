import 'dart:convert';
import 'package:http/http.dart' as http;

const String serverUrl = "https://fcm.googleapis.com/v1/projects/padillarouteapp-b4ef8/messages:send";
const String accessToken = "ya29.c.c0ASRK0Gadmxi-EEs174J298oj4FW18fq26ZW5qDM1vlj2Q_5fTgDcua-pZMZ65dC_O4ByO2bhGYaEVJaGqqb3rOoUD6Y27h6IU_hbaTDHyvbINB_rKVd6kiuHjDrPia5MMcG19fH_2Mjm6_rb0UPlTmJLmg2q99owKb6n659D_qHRuPFFh55MaP1h9voLdIeqNhDKa0L9K9YM9IuP7zXPYKkd1B0nMUaPyuu5MxutpZHFZNevVS59aCYphlW4lFN-ABU5aEuqGMtjWtY0XPLLL7eWSaNGGG39SoBcj0hW2f8BUYMxtJBnVqqB1VllzsXDOzbTWOesVOS4NBsKyPsp06v4kIgUFTC9FnuF6Q2w18zGDPT0zsOV40F5H385DJroOIRuweMj3a4IQMoMIwed1sYgnjIdra8kF6yJi0ZqylfgaI40fxbYgpUkirltoo3V-FV8byfeIdFm8rxFO_vYqJhlnJf28m1ppjhp1U8JvFit_l-rmUyWtnOsI3n40tf7JilgxSQfxr2ZBfSqzFhYclfok4RUo1X4kXxhoIuwe13yM4jzUjxx3FZQlQWsMqYV_aISJbcm6Ys6sfo0hBRW0QrZrck5-zetY1dSU7j_zobjWg8XeOR-RgWIvRaRMqimOknctI2JaRyrIchzidybgztW7Rih5o7UZvmh15Wk0eRfsusboZk_v8apdYe1V2Xhbz3crzqh5vM0bcRt6x9uoy-i0Jie3xmxOlY4QRjsa0Vxo7S31mt0_-uknr2YobB31nkqsIV4jBmaj5Fqu5uMr29UQ2QsSbtBlxktunoVJrWaRkxRu9fr_xF1Uw-hX4W7ozVO1m171WS4q-1Raz_BOuV4UaiMXn9e7dS9VWI6WoO9wVx6qjI6JmOX0mUMvcUJdigRZ-01ZVaeMqXbMY6dIuf57Zf9haId1wa4anlUyfxJgSat5pBl8Sg81ttXhz4nMjQFp2pbUR2pU6p8b86sIXrmSOx0nlcdcbg4XJQF4fwIqnWSmX9nOon"; // Reemplaza con tu token de acceso válido

Future<void> sendFCMMessage(String title, String body, String topic) async {
  final url = Uri.parse(serverUrl);

  final response = await http.post(
    url,
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accessToken',
    },
    body: jsonEncode({
      "message": {
        "topic": topic,  // Usar el tema que se pasa como argumento
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


import 'dart:convert';
import 'package:http/http.dart' as http;

const String serverUrl = "https://fcm.googleapis.com/v1/projects/padillarouteapp-b4ef8/messages:send";
const String accessToken = "ya29.c.c0ASRK0GYYU4Kih-HVLjQHBrefs9TGqUphG7HnOcebL49lrlsjTVCJQSGcZn6vaXMjXPWJhLVstS_3DhmwSGvQaRa4FDpJqkRTSH8vIIxltdp54YcUB7jls1zeLCT_EnZ0oFPUsiOZ64hcLqzmDiY9YGFqTxY0-pyi42s5wn0QvrDbOwdxC65mVmQWvVbY4_-9mANaL4bKHi_ZPhRDJ0V0eJxKf7N8nOEJSzpjasFzZHIFwb2b9FpHOU6udjIY7iQPJ8SckfR7AV-N8lpzvYrOFQzJ5BbGvYY_6TD2G2I9xsuPnjZ-iLcYU-rPAZjFik8JUOTic_L9XxzEAn6XYTDeAaq66IxCpWxRV1IGTTZymJxkABho471rlhcnH385A6bIuZRiWWk3uSRVX5qy27QRFqlgj7v3OoBsqemm4BpuQ9qRiivSYyq5W9rbWBs10Ior4J2__xVmOui__hWhurr6MImfQY0a74bdXxuF4Bt-pcac0cB9b0-zyztuYkmRX7eOR5Bm4luh636RkhmYZWjdmJY89v3Xm0nV2VZfb-l_BgJnh5aIpn4-9v-dIsi889dvQ157c18eyk73yzQ-mm3Rgt5k3zZh3q9jYwaFlldzI1Onq-tt7O5WQ4gogwzsY8Qmr6R1RFo93XZkYyey0J5yxZ4BRy93UtzFMnn1_YhIdm0Vxevat7S7Qpw-sRI7i3jI2dORQvwj_JbyciipFoSQ1MfseMd1Qs-cjn0OljIdcZ8uU2yUf9xX1BFBa-knxf2RnIRJqk23u69-umoy1j1jB3lqnF5aOwzuIotZnYb6gjswYhh5n6Z9-Wls9_Y4avh8uI7edl6jUqluxSQlvmJepM03g93dqSejmk_Irv5wrw0nYxkeqOY9l_-mmb8z_wd6eRuqdza4eut0pF1dg2g7h-p3MyzYutVhF73Ocirm2eWQx6eFYlunswUZx19of39xJ2Ibp8cO6-ZiFwvw2gfcB38JQ5znQvInqgWS47JmgaJIaMbflj46i2I"; // Reemplaza con tu token de acceso válido

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


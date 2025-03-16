import 'dart:convert';
import 'package:http/http.dart' as http;

const String serverUrl = "https://fcm.googleapis.com/v1/projects/padillarouteapp-b4ef8/messages:send";
const String accessToken = "ya29.c.c0ASRK0GYYq6XK_dXFjMbDaH5MUSJwf1Ibs9QUasOBIkq_eFxqAxl55hT9PmYPjYDcnk-yyWUCgHZ0-J4BV1-uqugbIV-qnOCjHwPZXV35nQU5OgmSSbLvr3rTHfagX_8u--0kR084PxVPBYOcSa8Lzv_1WMJxdqTxOAd6myNNdcsz8NB78TJjhzddJBNIfaImidc5aRCLg91kBFKxI4N2MFks9SXYwgpYulRwSXY9S6Eknnee93Kgwpt2f_XYj1mz9nQaHfgnHlnCSbjs-LLW3rvXAKQHFtmNB_Zve4e08M953PYYcSZuxZ_cBKOzNKYbFylZrs22ngZTjpTRzOGCgbTkjLai5u1eyCWr7g5SWlCgRh4S23kZ4kR2T385AQ4S6UuXzcWwgfx0nX17B4hR7m0SU_0_nmZa22U8qtq9FmnViS_e8lavkFjQMngfzs-6O3-8UJeV86uWVJcgknY_QqVB_mRqyV5tYoJ2Y5iVgbFOVn1fwFyltwkzllpFV2a8zlS0lhYtxkvdW41Fqu_9uwxkvIp5kdXyUjVmqh23UtQXtSVfi44eS1bdeWi6XFu57Ww_4x3dieVU7U_5wUQk6e_UdMSQuxc9olQ1YXqRsc8-7W8rFbR578d0maVaXFOIwJ-1Suq5OJd8d6ocUlag-niO3QIQOuktjIZrwQ1uacSJ6g-uYg-Vc85x27jsjmsqbjV-UcbVJtbZVqng3Vkma07nMsmfg3hlIvzgYfcX7RfOoFkwkmbdcRdbeghWufQO7_Qxn1d3jauZ3y5s-plVMtckIMm4rdJSU_Yun167yhJBmyFlBOe5vzcfeI-rgiFOhrYuvaduQUVSYt8FyImid8zSz84tjUpIf-UIwIoy724V00bIgjdsstFdjnju--JvaZF1yY4ZObfbls0r2Rvc8a7gUzk3yFnV2tdtcs9hFotdMlvQRaBBke2iczjwXVqMZ9oatMXzJf3ejyqu-U1nO_r2sjrVu123JoFamMoadw_pqWJ2f199J-n"; // Reemplaza con tu token de acceso válido

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


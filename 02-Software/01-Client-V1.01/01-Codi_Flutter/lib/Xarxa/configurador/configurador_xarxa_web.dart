import 'package:dio/browser.dart';
import 'package:dio/dio.dart';

void configurarAdaptadorDio(Dio dio) {
  // En l'entorn web injectem el adaptador de navegador que no fa servir Platform
  dio.httpClientAdapter = BrowserHttpClientAdapter();
}
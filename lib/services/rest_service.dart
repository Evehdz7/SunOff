import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:sunoff/models/cotizacion/cotizacion_model.dart';
import 'package:sunoff/models/cotizacion/film_category.dart';
import 'package:sunoff/models/cotizacion/image_film.dart';
import 'package:sunoff/models/cotizacion/pelis.dart';
import 'package:sunoff/models/cotizacion/type_building.dart';
import 'package:sunoff/services/setup_service.dart';
import 'package:sunoff/utils/app_settings.dart';
import 'package:sunoff/utils/preference_user.dart';
import 'package:http/http.dart' as http;

class RestService {
  String? apiUrl;
  String? token;
  String? tokenDefault;
  late PreferencesUser pref;

  RestService() {
    this.apiUrl = appService<AppSettings>().apiUrl;
    this.pref = new PreferencesUser();
    var bytesToken = utf8.encode('u420qwd');
    this.token = sha1.convert(bytesToken).toString();
    this.tokenDefault = sha1.convert(bytesToken).toString();
  }

  Future<List<Pelis>> getPelis({int? categoryId}) async {
    late Uri url;

    if (categoryId != null) {
      url = new Uri.http(
          this.apiUrl!, '/films', {'category': categoryId.toString()});
    } else {
      url = new Uri.http(this.apiUrl!, '/films');
    }

    final response = await http.get(url, headers: this.header());

    if (response.statusCode == 200) {
      var responseParse = jsonDecode(response.body);
      Iterable iterable = responseParse ?? [];

      return iterable.map((item) => Pelis.fromJson(item)).toList();
    }

    throw ('Error al consultar la información');
  }

  Future<List<ImageFilm>> getImagesFilm({int? filmId}) async {
    late Uri url;

    if (filmId != null) {
      url = new Uri.http(
          this.apiUrl!, '/films/get-image/', {'film': filmId.toString()});
    } else {
      url = new Uri.http(this.apiUrl!, '/films');
    }

    final response = await http.get(url, headers: this.header());

    if (response.statusCode == 200) {
      var responseParse = jsonDecode(response.body);
      Iterable iterable = responseParse ?? [];

      return iterable.map((item) => ImageFilm.fromJson(item)).toList();
    }

    throw ('Error al consultar la información');
  }

  Future<List<FilmCategory>> getFilmCategory() async {
    final url = new Uri.http(this.apiUrl!, '/filmCategory');

    final response = await http.get(url, headers: this.header());

    if (response.statusCode == 200) {
      var responseParse = jsonDecode(response.body);
      Iterable iterable = responseParse ?? [];

      return iterable.map((item) => FilmCategory.fromJson(item)).toList();
    }

    throw ('Error al consultar la información');
  }

  Future<CotizacionModel> pricing(CotizacionModel cotizacionModel) async {
    final url = new Uri.http(this.apiUrl!, '/pricing');

    final request = http.MultipartRequest('POST', url);
    request.headers[HttpHeaders.authorizationHeader] = 'Bearer ${pref.token}';
    request.fields.addAll({
      'building_type_id': cotizacionModel.buildingTypeId.toString(),
      'comentary': cotizacionModel.comentario,
      'client': jsonEncode(cotizacionModel.cliente.toJson()),
      'sections': jsonEncode(
          cotizacionModel.secciones.map((elem) => elem.toJson()).toList()),
    });

    cotizacionModel.secciones.forEach((element) {
      if (element.imagen!.path != '') {
        request.files.add(http.MultipartFile(
            element.uuid,
            element.imagen!.readAsBytes().asStream(),
            element.imagen!.lengthSync(),
            filename: element.imagen!.path.split('/').last));
      }
    });

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      String responsebody = await response.stream.bytesToString();

      CotizacionModel responseObject =
          CotizacionModel.fromJson(json.decode(responsebody));

      return responseObject;
    }

    throw ('Error al guardar la cotización');
  }

  Future<List<CotizacionModel>> getPricing() async {
    final url = new Uri.http(this.apiUrl!, '/pricing');

    final response = await http.get(url, headers: this.header());

    if (response.statusCode == 200) {
      var responseParse = jsonDecode(response.body);
      Iterable iterable = responseParse ?? [];

      return iterable.map((item) => CotizacionModel.fromJson(item)).toList();
    }

    throw ('Error al consultar la información');
  }

  Future<List<TypeBuilding>> getBuildingType() async {
    final url = new Uri.http(this.apiUrl!, '/buildingType');

    final response = await http.get(url, headers: this.header());

    if (response.statusCode == 200) {
      var responseParse = jsonDecode(response.body);
      Iterable iterable = responseParse ?? [];

      return iterable.map((item) => TypeBuilding.fromJson(item)).toList();
    }

    throw ('Error al consultar la información');
  }

  Map<String, String> header() {
    return {HttpHeaders.authorizationHeader: 'Bearer ${this.pref.token}'};
  }
}

import 'dart:convert';
import 'package:movie_app/movie_model.dart';
import 'package:movie_app/response_data_list.dart';
import 'package:movie_app/response_data_map.dart';
import 'package:movie_app/url.dart' as url;
import 'package:http/http.dart' as http;
import 'package:movie_app/userlogin.dart';


class MovieService {
  Future getMovie() async {
	   UserLogin userLogin = UserLogin();
    var user = await userLogin.getUserLogin();
    if (user.status == false) {
      ResponseDataList response = ResponseDataList(
          status: false, message: 'anda belum login / token invalid');
      return response;
    }
	   var uri = Uri.parse(url.BaseUrl + "/get_movies");
    Map<String, String> headers = {
      "Authorization": 'Bearer ${user.token}',
    };
    var getMovie = await http.get(uri, headers: headers);


    if (getMovie.statusCode == 200) {
      var data = json.decode(getMovie.body);
      if (data["status"] == true) {
        List movie = data["data"].map((r) => MovieModel.fromJson(r)).toList();
        ResponseDataList response = ResponseDataList(
            status: true, message: 'success load data', data: movie);
        return response;
      } else {
        ResponseDataList response =
            ResponseDataList(status: false, message: 'Failed load data');
        return response;
      }
    } else {
      ResponseDataList response = ResponseDataList(
          status: false,
          message: "gagal load movie dengan code error ${getMovie.statusCode}");
      return response;
    }
  }
  Future insertMovie(request, image, id) async {
   UserLogin userLogin = UserLogin();
  var user = await userLogin.getUserLogin();
    if (user.status == false) {
      ResponseDataList response = ResponseDataList(
          status: false, message: 'anda belum login / token invalid');
      return response;
    }
    Map<String, String> headers = {
      "Authorization": 'Bearer ${user.token}',
      "Content-type": "multipart/form-data",
    };
    var reponse;
    if (id == null) {
      reponse = http.MultipartRequest(
        'POST',
        Uri.parse("${url.BaseUrl}/add_movies"),
      );
    } else {
      reponse = http.MultipartRequest(
        'POST',
        Uri.parse("${url.BaseUrl}/get_movies/$id"),
      );
    }
    if (image != null) {
      reponse.files.add(http.MultipartFile(
          'posterpath', image.readAsBytes().asStream(), image.lengthSync(),
          filename: image.path.split('/').last));
    }
    reponse.headers.addAll(headers);
    reponse.fields['title'] = request["title"];
    reponse.fields['voteaverage'] = request["voteaverage"];
    reponse.fields['overview'] = request["overview"];
 var res = await reponse.send();
    var result = await http.Response.fromStream(res);


    if (res.statusCode == 200) {
      var data = json.decode(result.body);
      if (data["status"] == true) {
        ResponseDataMap response = ResponseDataMap(
            status: true, message: 'success insert / update data');
        return response;
      } else {
        ResponseDataMap response = ResponseDataMap(
            status: false, message: 'Failed insert / update data');
        return response;
      }
    } else {
      ResponseDataMap response = ResponseDataMap(
          status: false,
          message: "gagal load movie dengan code error ${res.statusCode}");
      return response;
    }
  }

  

  Future hapusMovie(context, id) async {
    var uri = Uri.parse(url.BaseUrl + "/hapus_movies/$id");
    UserLogin userLogin = UserLogin();
  var user = await userLogin.getUserLogin();
    if (user.status == false) {
      ResponseDataList response = ResponseDataList(
          status: false, message: 'anda belum login / token invalid');
      return response;
    }
    Map<String, String> headers = {
      "Authorization": 'Bearer ${user.token}',
    };
    var hapusMovie = await http.delete(uri, headers: headers);


    if (hapusMovie.statusCode == 200) {
      var result = json.decode(hapusMovie.body);
      if (result["status"] == true) {
        ResponseDataList response =
            ResponseDataList(status: true, message: 'success hapus data');
        return response;
      } else {
        ResponseDataList response =
            ResponseDataList(status: false, message: 'Failed hapus data');
        return response;
      }
    } else {
      ResponseDataList response = ResponseDataList(
          status: false,
          message:
              "gagal hapus movie dengan code error ${hapusMovie.statusCode}");
      return response;
    }
  }
}

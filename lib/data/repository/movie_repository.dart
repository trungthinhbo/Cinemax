import 'package:cinemax/data/datasource/movie_datasource.dart';
import 'package:cinemax/data/model/movie_casts.dart';
import 'package:cinemax/data/model/moviegallery.dart';
import 'package:cinemax/data/model/movie.dart';
import 'package:cinemax/util/api_exception.dart';
import 'package:dartz/dartz.dart';

abstract class MovieRepository {
  Future<Either<String, List<Movie>>> getAllMovies();
  Future<Either<String, List<Movie>>> getMovies();
  Future<Either<String, List<Movie>>> getSeries();
  Future<Either<String, List<Moviesgallery>>> getPhotos(String movieId);
  Future<Either<String, List<MovieCasts>>> getCastList(String movieId);
}

class MovieRemoteRpository extends MovieRepository {
  final MovieDatasource _datasource;

  MovieRemoteRpository(this._datasource);
  @override
  Future<Either<String, List<Movie>>> getAllMovies() async {
    try {
      var response = await _datasource.getAllMovies();
      return right(response);
    } on ApiException catch (ex) {
      return left(ex.message);
    }
  }

  @override
  Future<Either<String, List<Movie>>> getMovies() async {
    try {
      var response = await _datasource.getMovies();
      return right(response);
    } on ApiException catch (ex) {
      return left(ex.message);
    }
  }

  @override
  Future<Either<String, List<Movie>>> getSeries() async {
    try {
      var response = await _datasource.getSeries();
      return right(response);
    } on ApiException catch (ex) {
      return left(ex.message);
    }
  }

  @override
  Future<Either<String, List<Moviesgallery>>> getPhotos(String movieId) async {
    try {
      var response = await _datasource.getPhotos(movieId);
      return right(response);
    } on ApiException catch (ex) {
      return left(ex.message);
    }
  }

  @override
  Future<Either<String, List<MovieCasts>>> getCastList(String movieId) async {
    try {
      var response = await _datasource.getCasts(movieId);
      return right(response);
    } on ApiException catch (ex) {
      return left(ex.message);
    }
  }
}

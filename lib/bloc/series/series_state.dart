import 'package:cinemax/data/model/series_cast.dart';
import 'package:cinemax/data/model/series_seasons.dart';
import 'package:dartz/dartz.dart';

abstract class SeriesState {}

class SeriesInitState extends SeriesState {}

class SeriesLoadingState extends SeriesState {}

class SeriesResponseState extends SeriesState {
  Either<String, List<SeriesSeasons>> getSeasons;
  Either<String, List<SeriesCasts>> getCasts;

  SeriesResponseState(this.getSeasons, this.getCasts);
}

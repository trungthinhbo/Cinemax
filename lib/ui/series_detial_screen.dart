import 'dart:ui';

import 'package:cinemax/bloc/series/series_bloc.dart';
import 'package:cinemax/bloc/series/series_state.dart';
import 'package:cinemax/constants/color_constants.dart';
import 'package:cinemax/data/model/movie.dart';
import 'package:cinemax/data/model/series_seasons.dart';
import 'package:cinemax/util/query_handler.dart';
import 'package:cinemax/widgets/cached_image.dart';
import 'package:cinemax/widgets/cast_crew_widget.dart';
import 'package:cinemax/widgets/loading_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';

class SeriesDetailScreen extends StatelessWidget {
  const SeriesDetailScreen({super.key, required this.series});
  final Movie series;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: BlocBuilder<SeriesBloc, SeriesState>(
        builder: (context, state) {
          if (state is SeriesLoadingState) {
            return const AppLoadingIndicator();
          } else if (state is SeriesResponseState) {
            return CustomScrollView(
              slivers: [
                _MovieDetailHeader(
                  series: series,
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _StoryLine(
                          storyLine: series.storyline,
                        ),
                        const CastAndCrewWidget(),
                        state.getSeasons.fold(
                          (exceptionMessage) {
                            return Text("exceptionMessage");
                          },
                          (seasonList) {
                            return _SeasonChip(
                              getSeasonList: seasonList,
                            );
                          },
                        ),
                        const Padding(
                          padding: EdgeInsets.only(right: 20.0, top: 20.0),
                          child: Column(
                            children: [
                              Text(
                                "Gallery",
                                style: TextStyle(
                                  fontFamily: "MSB",
                                  fontSize: 16,
                                  color: TextColors.whiteText,
                                ),
                              ),
                              SizedBox(height: 10.0),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const _Gallery(),
              ],
            );
          }
          return Text("There seem to be errors Getting data");
        },
      ),
    );
  }
}

class _Gallery extends StatelessWidget {
  const _Gallery();

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      sliver: SliverGrid(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            return Container(
              height: 100,
              width: 100,
              decoration: const BoxDecoration(
                color: SecondaryColors.greenColor,
                borderRadius: BorderRadius.all(
                  Radius.circular(15),
                ),
              ),
            );
          },
          childCount: 30,
        ),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
        ),
      ),
    );
  }
}

class _SeasonChip extends StatefulWidget {
  const _SeasonChip({required this.getSeasonList});
  final List<SeriesSeasons> getSeasonList;

  @override
  State<_SeasonChip> createState() => __SeasonChipState();
}

class __SeasonChipState extends State<_SeasonChip> {
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    int seasonNumbers = widget.getSeasonList.length;
    double maxHeight = 44.0 * seasonNumbers;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 30),
        const Text(
          "Episods",
          style: TextStyle(
            fontFamily: "MSB",
            fontSize: 16,
            color: TextColors.whiteText,
          ),
        ),
        const SizedBox(height: 15),
        GestureDetector(
          onTap: () {
            showDialog(
              context: context,
              builder: (context) {
                return ClipRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                    child: AlertDialog(
                      backgroundColor: PrimaryColors.softColor,
                      content: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 20),
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const SizedBox(width: 10),
                              GestureDetector(
                                onTap: () {
                                  Navigator.pop(context);
                                },
                                child: Container(
                                  height: 32,
                                  width: 32,
                                  decoration: const BoxDecoration(
                                    color: Color(0xff252836),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Image.asset(
                                    'assets/images/icon_close.png',
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              SizedBox(
                                height: maxHeight,
                                child: ListView.builder(
                                  itemCount: seasonNumbers,
                                  itemBuilder: (context, index) {
                                    return Center(
                                      child: Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 10.0),
                                        child: GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              selectedIndex = index;
                                            });
                                            Navigator.pop(context);
                                          },
                                          child: Text(
                                            "Season ${widget.getSeasonList[index].season}",
                                            style: TextStyle(
                                              fontFamily: "MSB",
                                              fontSize: (selectedIndex == index)
                                                  ? 24
                                                  : 20,
                                              color: (selectedIndex == index)
                                                  ? TextColors.whiteText
                                                  : TextColors.greyText,
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          },
          child: Row(
            children: [
              Text(
                "Season ${selectedIndex + 1}",
                style: const TextStyle(
                  fontFamily: "MSB",
                  fontSize: 14,
                  color: TextColors.whiteText,
                ),
              ),
              const SizedBox(width: 5),
              Image.asset(
                'assets/images/icon_arrow_down.png',
                height: 24,
                width: 24,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StoryLine extends StatelessWidget {
  const _StoryLine({required this.storyLine});
  final String storyLine;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Story Line",
          style: TextStyle(
            fontFamily: "MSB",
            fontSize: (MediaQueryHandler.screenWidth(context) < 350) ? 14 : 16,
            color: TextColors.whiteText,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Flexible(
              child: Text(
                storyLine,
                style: TextStyle(
                  fontFamily: "MR",
                  fontSize:
                      (MediaQueryHandler.screenWidth(context) < 350) ? 12 : 14,
                  color: TextColors.whiteText,
                ),
              ),
            ),
            Text(
              "More",
              style: TextStyle(
                fontFamily: "MSB",
                fontSize:
                    (MediaQueryHandler.screenWidth(context) < 350) ? 12 : 14,
                color: PrimaryColors.blueAccentColor,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _MovieDetailHeader extends StatelessWidget {
  const _MovieDetailHeader({required this.series});
  final Movie series;

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Stack(
        children: [
          SizedBox(
            height: 552,
            width: MediaQuery.of(context).size.width,
            child: FittedBox(
              fit: BoxFit.fill,
              child: CachedImage(
                imageUrl: series.thumbnail,
                radius: 0,
              ),
            ),
          ),
          Container(
            height: 552,
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              border: Border.all(
                width: 0,
                color: PrimaryColors.darkColor,
              ),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  PrimaryColors.darkColor.withOpacity(0.6),
                  PrimaryColors.darkColor,
                ],
              ),
            ),
          ),
          _MovieHeaderContent(
            series: series,
          ),
        ],
      ),
    );
  }
}

class _MovieHeaderContent extends StatefulWidget {
  const _MovieHeaderContent({required this.series});
  final Movie series;

  @override
  State<_MovieHeaderContent> createState() => _MovieHeaderContentState();
}

class _MovieHeaderContentState extends State<_MovieHeaderContent>
    with TickerProviderStateMixin {
  late final AnimationController controller;
  bool isLiked = false;

  @override
  void initState() {
    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          const SizedBox(
            height: 25,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Image.asset('assets/images/icon_arrow_back.png'),
              ),
              SizedBox(
                width: 170,
                child: Text(
                  widget.series.name,
                  style: TextStyle(
                    fontFamily: "MSB",
                    fontSize: (MediaQueryHandler.screenWidth(context) < 350)
                        ? 14
                        : 16,
                    color: TextColors.whiteText,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    if (isLiked) {
                      controller.reverse();
                      isLiked = false;
                    } else if (!isLiked) {
                      controller.forward();
                      isLiked = true;
                    }
                  });
                },
                child: Container(
                  height:
                      (MediaQueryHandler.screenWidth(context) < 350) ? 28 : 32,
                  width:
                      (MediaQueryHandler.screenWidth(context) < 350) ? 28 : 32,
                  decoration: const ShapeDecoration(
                    shape: ContinuousRectangleBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(40),
                      ),
                    ),
                    color: PrimaryColors.softColor,
                  ),
                  child: Transform.scale(
                    scale: 1.3,
                    child: Lottie.asset(
                      'assets/Animation - 1710000521327.json',
                      controller: controller,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 50),
          ClipRRect(
            borderRadius: const BorderRadius.all(
              Radius.circular(12),
            ),
            child: SizedBox(
              height:
                  (MediaQueryHandler.screenWidth(context) < 350) ? 243 : 287,
              width: (MediaQueryHandler.screenWidth(context) < 350) ? 165 : 205,
              child: FittedBox(
                fit: BoxFit.cover,
                child: CachedImage(
                  imageUrl: widget.series.thumbnail,
                  radius: 12,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/icon_calendar.png',
                  color: TextColors.greyText,
                  height:
                      (MediaQueryHandler.screenWidth(context) < 350) ? 12 : 16,
                  width:
                      (MediaQueryHandler.screenWidth(context) < 350) ? 12 : 16,
                ),
                const SizedBox(width: 3.0),
                Text(
                  widget.series.year,
                  style: TextStyle(
                    fontFamily: "MM",
                    fontSize: (MediaQueryHandler.screenWidth(context) < 350)
                        ? 10
                        : 12,
                    color: TextColors.greyText,
                  ),
                ),
                const SizedBox(width: 3.0),
                const VerticalDivider(
                  thickness: 1.3,
                  color: TextColors.greyText,
                ),
                const SizedBox(width: 3.0),
                Image.asset(
                  'assets/images/icon_clock.png',
                  color: TextColors.greyText,
                  height:
                      (MediaQueryHandler.screenWidth(context) < 350) ? 12 : 16,
                  width:
                      (MediaQueryHandler.screenWidth(context) < 350) ? 12 : 16,
                ),
                const SizedBox(width: 3.0),
                Text(
                  widget.series.timeLength,
                  style: TextStyle(
                    fontFamily: "MM",
                    fontSize: (MediaQueryHandler.screenWidth(context) < 350)
                        ? 10
                        : 12,
                    color: TextColors.greyText,
                  ),
                ),
                const SizedBox(width: 3.0),
                const VerticalDivider(
                  thickness: 1.3,
                  color: TextColors.greyText,
                ),
                const SizedBox(width: 3.0),
                Image.asset(
                  'assets/images/icon_film.png',
                  color: TextColors.greyText,
                  height:
                      (MediaQueryHandler.screenWidth(context) < 350) ? 12 : 16,
                  width:
                      (MediaQueryHandler.screenWidth(context) < 350) ? 12 : 16,
                ),
                const SizedBox(width: 3.0),
                Text(
                  widget.series.genre,
                  style: TextStyle(
                    fontFamily: "MM",
                    fontSize: (MediaQueryHandler.screenWidth(context) < 350)
                        ? 10
                        : 12,
                    color: TextColors.greyText,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 15.0),
          Container(
            height: 24,
            width: 55,
            decoration: const BoxDecoration(
              color: Color(0xff252836),
              borderRadius: BorderRadius.all(
                Radius.circular(8),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/icon_star.png',
                  color: SecondaryColors.orangeColor,
                  height: 16,
                  width: 16,
                ),
                const SizedBox(width: 5),
                Text(
                  widget.series.rate,
                  style: const TextStyle(
                    fontFamily: "MM",
                    fontSize: 12,
                    color: SecondaryColors.orangeColor,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height:
                    (MediaQueryHandler.screenWidth(context) < 350) ? 32 : 48,
                width:
                    (MediaQueryHandler.screenWidth(context) < 350) ? 100 : 115,
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.all(
                    Radius.circular(32),
                  ),
                  color: PrimaryColors.blueAccentColor,
                ),
                child: Center(
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 20),
                        child: Image.asset(
                          'assets/images/icon_play.png',
                          height: (MediaQueryHandler.screenWidth(context) < 350)
                              ? 18
                              : 24,
                          width: (MediaQueryHandler.screenWidth(context) < 350)
                              ? 18
                              : 24,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        "Play",
                        style: TextStyle(
                          fontFamily: "MM",
                          fontSize:
                              (MediaQueryHandler.screenWidth(context) < 350)
                                  ? 12
                                  : 16,
                          color: TextColors.whiteText,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 15.0),
              Container(
                height:
                    (MediaQueryHandler.screenWidth(context) < 350) ? 32 : 48,
                width: (MediaQueryHandler.screenWidth(context) < 350) ? 32 : 48,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: PrimaryColors.softColor,
                ),
                child: Center(
                  child: Image.asset(
                    'assets/images/icon_download.png',
                    color: PrimaryColors.blueAccentColor,
                    height: (MediaQueryHandler.screenWidth(context) < 350)
                        ? 18
                        : 24,
                    width: (MediaQueryHandler.screenWidth(context) < 350)
                        ? 18
                        : 24,
                  ),
                ),
              ),
              const SizedBox(width: 15.0),
              GestureDetector(
                onTap: () {
                  shareDialog(context);
                },
                child: Container(
                  height:
                      (MediaQueryHandler.screenWidth(context) < 350) ? 32 : 48,
                  width:
                      (MediaQueryHandler.screenWidth(context) < 350) ? 32 : 48,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: PrimaryColors.softColor,
                  ),
                  child: Center(
                    child: Image.asset(
                      'assets/images/icon_share.png',
                      color: PrimaryColors.blueAccentColor,
                      height: (MediaQueryHandler.screenWidth(context) < 350)
                          ? 18
                          : 24,
                      width: (MediaQueryHandler.screenWidth(context) < 350)
                          ? 18
                          : 24,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

Future<void> shareDialog(BuildContext context) async {
  await showDialog(
    context: context,
    builder: (context) {
      return ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
          child: AlertDialog(
            backgroundColor: PrimaryColors.softColor,
            content: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: SizedBox(
                width: MediaQuery.of(context).size.width,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const SizedBox(width: 10),
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Container(
                        height: 32,
                        width: 32,
                        decoration: const BoxDecoration(
                          color: Color(0xff252836),
                          shape: BoxShape.circle,
                        ),
                        child: Image.asset(
                          'assets/images/icon_close.png',
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Center(
                      child: Text(
                        "Share to",
                        style: TextStyle(
                          fontFamily: "MSB",
                          fontSize: 18,
                          color: TextColors.whiteText,
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    const Divider(
                      thickness: 1.33,
                      color: PrimaryColors.darkColor,
                    ),
                    const SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/images/Apple.png',
                          height: 49,
                          width: 49,
                        ),
                        const SizedBox(width: 15),
                        Image.asset(
                          'assets/images/Facebook.png',
                          height: 49,
                          width: 49,
                        ),
                        const SizedBox(width: 15),
                        Image.asset(
                          'assets/images/Google.png',
                          height: 49,
                          width: 49,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    },
  );
}

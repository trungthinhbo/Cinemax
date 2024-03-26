import 'dart:ui';

import 'package:cinemax/DI/service_locator.dart';
import 'package:cinemax/bloc/series/series_bloc.dart';
import 'package:cinemax/bloc/series/series_event.dart';
import 'package:cinemax/bloc/series/series_state.dart';
import 'package:cinemax/bloc/wishlist/wishlist_bloc.dart';
import 'package:cinemax/bloc/wishlist/wishlist_event.dart';
import 'package:cinemax/constants/color_constants.dart';
import 'package:cinemax/data/model/movie.dart';
import 'package:cinemax/data/model/series_cast.dart';
import 'package:cinemax/data/model/series_seasons.dart';
import 'package:cinemax/ui/comments_screen.dart';
import 'package:cinemax/ui/gallery_full_screen.dart';
import 'package:cinemax/util/query_handler.dart';
import 'package:cinemax/widgets/cached_image.dart';
import 'package:cinemax/widgets/comment_section.dart';
import 'package:cinemax/widgets/episode_widget.dart';
import 'package:cinemax/widgets/exception_message.dart';
import 'package:cinemax/widgets/loading_indicator.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';

class SeriesDetailScreen extends StatelessWidget {
  const SeriesDetailScreen({super.key, required this.series});
  final Movie series;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SeriesBloc(locator.get(), locator.get())
        ..add(SeriesDataRequestEvent(series.id, series.name)),
      child: Scaffold(
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
                    onLike: state.isLiked,
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
                          state.getCasts.fold(
                            (exceptionMessage) {
                              return const ExceptionMessage();
                            },
                            (casts) {
                              return SeriesCastAndCrew(
                                casts: casts,
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  state.getSeasons.fold(
                    (exceptionMessage) {
                      return const SliverToBoxAdapter(
                        child: ExceptionMessage(),
                      );
                    },
                    (seasonList) {
                      return SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.only(
                              right: 20, left: 20, bottom: 15),
                          child: _SeasonChip(
                            seasons: seasonList,
                            seriesName: series.name,
                          ),
                        ),
                      );
                    },
                  ),
                  state.getEpisodes.fold(
                    (exceptionMessage) {
                      return const SliverToBoxAdapter(
                        child: ExceptionMessage(),
                      );
                    },
                    (episodeList) {
                      return SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            return Padding(
                              padding: const EdgeInsets.only(
                                  right: 20, left: 20, bottom: 15),
                              child: EpisodeWidget(
                                episode: episodeList[index],
                              ),
                            );
                          },
                          childCount: episodeList.length,
                        ),
                      );
                    },
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 20.0, top: 20.0),
                      child: Column(
                        children: [
                          Text(
                            AppLocalizations.of(context)!.gallery,
                            style: const TextStyle(
                              fontFamily: "MSB",
                              fontSize: 16,
                              color: TextColors.whiteText,
                            ),
                          ),
                          const SizedBox(height: 10.0),
                        ],
                      ),
                    ),
                  ),
                  const _Gallery(),
                  SliverToBoxAdapter(
                    child: GestureDetector(
                      onTap: () {
                        PersistentNavBarNavigator.pushNewScreen(
                          context,
                          screen: CommentsScreen(
                            movieName: series.name,
                            year: series.year,
                            imageURL: series.thumbnail,
                          ),
                          withNavBar: false,
                          pageTransitionAnimation:
                              PageTransitionAnimation.cupertino,
                        );
                      },
                      child: const Padding(
                        padding: EdgeInsets.only(top: 20),
                        child: CommentSection(),
                      ),
                    ),
                  ),
                ],
              );
            }
            return Center(
              child: Text(AppLocalizations.of(context)!.state),
            );
          },
        ),
      ),
    );
  }
}

Future<void> showFullScreenGallery(BuildContext context, String photo) async {
  return showDialog(
    context: context,
    builder: (context) {
      return ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: AlertDialog(
            surfaceTintColor: Colors.transparent,
            backgroundColor: Colors.transparent,
            content: GalleryFullScreen(
              imageURL: photo,
            ),
          ),
        ),
      );
    },
  );
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
  const _SeasonChip({required this.seasons, required this.seriesName});
  final List<SeriesSeasons> seasons;
  final String seriesName;

  @override
  State<_SeasonChip> createState() => __SeasonChipState();
}

class __SeasonChipState extends State<_SeasonChip> {
  List<String> items = [];
  String? selectedValue;

  @override
  void initState() {
    items = widget.seasons.map((e) => e.season).toList();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 30),
        Text(
          AppLocalizations.of(context)!.episodes,
          style: const TextStyle(
            fontFamily: "MSB",
            fontSize: 16,
            color: TextColors.whiteText,
          ),
        ),
        const SizedBox(height: 5),
        DropdownButtonHideUnderline(
          child: DropdownButton2<String>(
            isExpanded: true,
            items: items
                .map((String item) => DropdownMenuItem<String>(
                      value: item,
                      child: Text(
                        item,
                        style: const TextStyle(
                          fontSize: 14,
                          fontFamily: "MSB",
                          color: TextColors.whiteText,
                        ),
                      ),
                    ))
                .toList(),
            hint: const Text(
              '1',
              style: TextStyle(
                fontSize: 14,
                color: TextColors.whiteText,
                fontFamily: "MSB",
              ),
            ),
            value: selectedValue,
            onChanged: (String? value) {
              setState(() {
                selectedValue = value;
              });
              context.read<SeriesBloc>().add(
                    SeriesEpisodesFetchEvent(
                      widget.seasons[items.indexOf(selectedValue!)].id,
                      widget.seasons[items.indexOf(selectedValue!)].seriesId,
                      widget.seriesName,
                    ),
                  );
            },
            buttonStyleData: const ButtonStyleData(
              padding: EdgeInsets.symmetric(horizontal: 16),
              height: 40,
              width: 100,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(
                  Radius.circular(15),
                ),
                color: PrimaryColors.softColor,
              ),
              elevation: 2,
            ),
            iconStyleData: IconStyleData(
              icon: SvgPicture.asset(
                'assets/images/icon_arrow_down.svg',
                height: 24,
                width: 24,
              ),
            ),
            dropdownStyleData: DropdownStyleData(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: PrimaryColors.softColor,
              ),
            ),
            menuItemStyleData: const MenuItemStyleData(
              height: 40,
            ),
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
          AppLocalizations.of(context)!.storyLine,
          style: TextStyle(
            fontFamily: "MSB",
            fontSize: (MediaQueryHandler.screenWidth(context) < 350) ? 14 : 16,
            color: TextColors.whiteText,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          storyLine,
          style: TextStyle(
            fontFamily: "MR",
            fontSize: (MediaQueryHandler.screenWidth(context) < 350) ? 12 : 14,
            color: TextColors.whiteText,
          ),
        ),
      ],
    );
  }
}

class _MovieDetailHeader extends StatelessWidget {
  const _MovieDetailHeader({required this.series, required this.onLike});
  final Movie series;
  final bool onLike;

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
            isLiked: onLike,
          ),
        ],
      ),
    );
  }
}

class _MovieHeaderContent extends StatefulWidget {
  const _MovieHeaderContent({required this.series, required this.isLiked});
  final Movie series;
  final bool isLiked;

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
    isLiked = isLiked;
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
            height: 40,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: SvgPicture.asset(
                  'assets/images/icon_arrow_back.svg',
                ),
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
                  textAlign: TextAlign.center,
                ),
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    if (isLiked) {
                      context
                          .read<SeriesBloc>()
                          .add(WishlistDeleteItemEvent(widget.series.name));
                      context
                          .read<WishlistBloc>()
                          .add(WishlistFetchCartsEvent());
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          backgroundColor: Colors.transparent,
                          content: _SnackBarUnlikeMessage(
                            seriesName: widget.series.name,
                          ),
                          duration: const Duration(seconds: 5),
                        ),
                      );
                      controller.reverse();
                      isLiked = false;
                    } else if (!isLiked) {
                      context.read<SeriesBloc>().add(
                            WishlistAddToCartEvent(widget.series),
                          );
                      context
                          .read<WishlistBloc>()
                          .add(WishlistFetchCartsEvent());
                      controller.forward();
                      isLiked = true;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          backgroundColor: Colors.transparent,
                          content: _SnackBarLikedMessage(
                            seriesName: widget.series.name,
                          ),
                          duration: const Duration(seconds: 5),
                        ),
                      );
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
          const SizedBox(height: 35),
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
                SvgPicture.asset(
                  'assets/images/icon_calendar.svg',
                  height:
                      (MediaQueryHandler.screenWidth(context) < 350) ? 12 : 16,
                  width:
                      (MediaQueryHandler.screenWidth(context) < 350) ? 12 : 16,
                  colorFilter: const ColorFilter.mode(
                    TextColors.greyText,
                    BlendMode.srcIn,
                  ),
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
                SvgPicture.asset(
                  'assets/images/icon_clock.svg',
                  height:
                      (MediaQueryHandler.screenWidth(context) < 350) ? 12 : 16,
                  width:
                      (MediaQueryHandler.screenWidth(context) < 350) ? 12 : 16,
                  colorFilter: const ColorFilter.mode(
                    TextColors.greyText,
                    BlendMode.srcIn,
                  ),
                ),
                const SizedBox(width: 3.0),
                Text(
                  "${widget.series.timeLength} ${AppLocalizations.of(context)!.minutes}",
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
                SvgPicture.asset(
                  'assets/images/icon_film.svg',
                  height:
                      (MediaQueryHandler.screenWidth(context) < 350) ? 12 : 16,
                  width:
                      (MediaQueryHandler.screenWidth(context) < 350) ? 12 : 16,
                  colorFilter: const ColorFilter.mode(
                    TextColors.greyText,
                    BlendMode.srcIn,
                  ),
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
                SvgPicture.asset(
                  'assets/images/icon_star.svg',
                  height: 16,
                  width: 16,
                  colorFilter: const ColorFilter.mode(
                    SecondaryColors.orangeColor,
                    BlendMode.srcIn,
                  ),
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
                        padding: const EdgeInsets.only(left: 25, right: 10),
                        child: SvgPicture.asset(
                          'assets/images/icon_play.svg',
                          height: (MediaQueryHandler.screenWidth(context) < 350)
                              ? 18
                              : 20,
                          width: (MediaQueryHandler.screenWidth(context) < 350)
                              ? 18
                              : 20,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        AppLocalizations.of(context)!.play,
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
                  child: SvgPicture.asset(
                    'assets/images/icon_download.svg',
                    height: (MediaQueryHandler.screenWidth(context) < 350)
                        ? 18
                        : 24,
                    width: (MediaQueryHandler.screenWidth(context) < 350)
                        ? 18
                        : 24,
                    colorFilter: const ColorFilter.mode(
                      PrimaryColors.blueAccentColor,
                      BlendMode.srcIn,
                    ),
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
                    child: SvgPicture.asset(
                      'assets/images/icon_share.svg',
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
                        child: SvgPicture.asset(
                          'assets/images/icon_close.svg',
                          height: 16,
                          width: 16,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: Text(
                        AppLocalizations.of(context)!.share,
                        style: const TextStyle(
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
                        SvgPicture.asset(
                          "assets/images/Apple.svg",
                        ),
                        const SizedBox(width: 15),
                        SvgPicture.asset(
                          "assets/images/Facebook.svg",
                        ),
                        const SizedBox(width: 15),
                        SvgPicture.asset(
                          "assets/images/Google.svg",
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

class SeriesCastAndCrew extends StatelessWidget {
  const SeriesCastAndCrew({super.key, required this.casts});
  final List<SeriesCasts> casts;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 30),
        Text(
          AppLocalizations.of(context)!.casts,
          style: TextStyle(
            fontFamily: "MSB",
            fontSize: (MediaQueryHandler.screenWidth(context) < 350) ? 14 : 16,
            color: TextColors.whiteText,
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 50,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: casts.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(right: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.all(
                        Radius.circular(100),
                      ),
                      child: SizedBox(
                        height: 40,
                        width: 40,
                        child: FittedBox(
                          fit: BoxFit.cover,
                          child: CachedImage(
                            imageUrl: casts[index].thumbnail,
                            radius: 100,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          casts[index].name,
                          style: TextStyle(
                            fontFamily: "MSB",
                            fontSize:
                                (MediaQueryHandler.screenWidth(context) < 350)
                                    ? 12
                                    : 14,
                            color: TextColors.whiteText,
                          ),
                        ),
                        Text(
                          casts[index].role,
                          style: TextStyle(
                            fontFamily: "MM",
                            fontSize:
                                (MediaQueryHandler.screenWidth(context) < 350)
                                    ? 8
                                    : 10,
                            color: TextColors.greyText,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _SnackBarLikedMessage extends StatelessWidget {
  const _SnackBarLikedMessage({required this.seriesName});
  final String seriesName;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQueryHandler.screenWidth(context),
      height: 60,
      decoration: const BoxDecoration(
        color: SecondaryColors.greenColor,
        borderRadius: BorderRadius.all(
          Radius.circular(15),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.only(right: 15, left: 15),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              "$seriesName ${AppLocalizations.of(context)!.isAddedToWishlist}",
              style: const TextStyle(
                color: TextColors.whiteText,
                fontSize: 12,
                fontFamily: "MSB",
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SnackBarUnlikeMessage extends StatelessWidget {
  const _SnackBarUnlikeMessage({required this.seriesName});
  final String seriesName;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQueryHandler.screenWidth(context),
      height: 60,
      decoration: const BoxDecoration(
        color: SecondaryColors.redColor,
        borderRadius: BorderRadius.all(
          Radius.circular(15),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.only(right: 15, left: 15),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              "$seriesName ${AppLocalizations.of(context)!.removeFromWishlist}",
              style: const TextStyle(
                color: TextColors.whiteText,
                fontSize: 12,
                fontFamily: "MSB",
              ),
            ),
          ],
        ),
      ),
    );
  }
}

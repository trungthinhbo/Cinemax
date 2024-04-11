import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cinemax/DI/service_locator.dart';
import 'package:cinemax/bloc/comments/comment_bloc.dart';
import 'package:cinemax/bloc/comments/comment_event.dart';
import 'package:cinemax/bloc/movies/movies_bloc.dart';
import 'package:cinemax/bloc/movies/movies_event.dart';
import 'package:cinemax/bloc/movies/movies_state.dart';
import 'package:cinemax/bloc/video/video_bloc.dart';
import 'package:cinemax/bloc/video/video_event.dart';
import 'package:cinemax/bloc/wishlist/wishlist_bloc.dart';
import 'package:cinemax/bloc/wishlist/wishlist_event.dart';
import 'package:cinemax/constants/color_constants.dart';
import 'package:cinemax/constants/string_constants.dart';
import 'package:cinemax/data/model/comment.dart';
import 'package:cinemax/data/model/movie_casts.dart';
import 'package:cinemax/data/model/moviegallery.dart';
import 'package:cinemax/data/model/movie.dart';
import 'package:cinemax/ui/comments_screen.dart';
import 'package:cinemax/util/func_util.dart';
import 'package:cinemax/util/query_handler.dart';
import 'package:cinemax/widgets/cached_image.dart';
import 'package:cinemax/widgets/comment_section.dart';
import 'package:cinemax/widgets/downloader.dart';
import 'package:cinemax/widgets/exception_message.dart';
import 'package:cinemax/widgets/shimmer_skelton.dart';
import 'package:cinemax/widgets/snackbar_content.dart';
import 'package:cinemax/widgets/video_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import 'package:shimmer/shimmer.dart';

class MovieDetailScreen extends StatelessWidget {
  const MovieDetailScreen({super.key, required this.movie});
  final Movie movie;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          MovieBloc(locator.get(), locator.get(), locator.get())
            ..add(MoviesDataRequestEvent(movie.id, movie.name)),
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.background,
        body: BlocBuilder<MovieBloc, MoviesState>(
          builder: (context, state) {
            if (state is MoviesLoadingState) {
              return Shimmer.fromColors(
                baseColor: Colors.grey[400]!,
                highlightColor: Colors.grey[100]!,
                child: const MovieDetailLoading(),
              );
            } else if (state is MoviesresponseState) {
              return CustomScrollView(
                slivers: [
                  _MovieDetailHeader(
                    movie: movie,
                    isLiked: state.isLiked,
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _StoryLine(
                            storyLine: movie.storyline,
                          ),
                          state.castList.fold(
                            (exceptionMessage) {
                              return const ExceptionMessage();
                            },
                            (castList) {
                              return MovieCastAndCrew(
                                casts: castList,
                              );
                            },
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.only(right: 20.0, top: 20.0),
                            child: Column(
                              children: [
                                Text(
                                  AppLocalizations.of(context)!.gallery,
                                  style: TextStyle(
                                    fontFamily:
                                        StringConstants.setBoldPersianFont(),
                                    fontSize: 16,
                                    color:
                                        Theme.of(context).colorScheme.tertiary,
                                  ),
                                ),
                                const SizedBox(height: 10.0),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  state.getPhotos.fold(
                    (exceptionMessage) {
                      return const SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.only(left: 20),
                          child: ExceptionMessage(),
                        ),
                      );
                    },
                    (photoList) {
                      return _Gallery(
                        photoList: photoList,
                      );
                    },
                  ),
                  state.getComments.fold(
                    (exceptionMessage) {
                      // return const SliverToBoxAdapter(
                      //   child: Padding(
                      //     padding: EdgeInsets.only(left: 20),
                      //     child: ExceptionMessage(),
                      //   ),
                      // );
                      return SliverToBoxAdapter(
                        child: Text(exceptionMessage),
                      );
                    },
                    (commentList) {
                      List<Comment> verbose = commentList
                          .where((element) => element.spoiler == false)
                          .toList();
                      if (verbose.isNotEmpty) {
                        verbose.shuffle();
                        return SliverToBoxAdapter(
                          child: GestureDetector(
                            onTap: () {
                              PersistentNavBarNavigator.pushNewScreen(
                                context,
                                screen: BlocProvider(
                                  create: (context) =>
                                      CommentsBloc(locator.get())
                                        ..add(
                                          CommentFetchEvent(movie.id),
                                        ),
                                  child: CommentsScreen(
                                    movieName: movie.name,
                                    year: movie.year,
                                    imageURL: movie.thumbnail,
                                    movieID: movie.id,
                                  ),
                                ),
                                withNavBar: false,
                                pageTransitionAnimation:
                                    PageTransitionAnimation.cupertino,
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(top: 25),
                              child: CommentSection(
                                comment: verbose[0],
                              ),
                            ),
                          ),
                        );
                      } else {
                        return SliverToBoxAdapter(
                          child: GestureDetector(
                            onTap: () {
                              PersistentNavBarNavigator.pushNewScreen(
                                context,
                                screen: BlocProvider(
                                  create: (context) =>
                                      CommentsBloc(locator.get())
                                        ..add(
                                          CommentFetchEvent(movie.id),
                                        ),
                                  child: CommentsScreen(
                                    movieName: movie.name,
                                    year: movie.year,
                                    imageURL: movie.thumbnail,
                                    movieID: movie.id,
                                  ),
                                ),
                                withNavBar: false,
                                pageTransitionAnimation:
                                    PageTransitionAnimation.cupertino,
                              );
                            },
                            child: const EmptyCommentSection(),
                          ),
                        );
                      }
                    },
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(
                          left: 20.0, bottom: 15.0, top: 20.0),
                      child: Text(
                        AppLocalizations.of(context)!.relatedMovie,
                        style: TextStyle(
                          fontFamily: StringConstants.setBoldPersianFont(),
                          fontSize: 16,
                          color: Theme.of(context).colorScheme.tertiary,
                        ),
                      ),
                    ),
                  ),
                  state.getRelateds.fold(
                    (exceptionMessage) {
                      return const SliverToBoxAdapter();
                    },
                    (relatedList) {
                      return SliverPadding(
                        padding:
                            const EdgeInsets.only(left: 20.0, bottom: 20.0),
                        sliver: SliverGrid(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              return Padding(
                                padding: const EdgeInsets.only(right: 15.0),
                                child: GestureDetector(
                                  onTap: () {
                                    routeCondition(context, relatedList[index]);
                                  },
                                  child: ClipRRect(
                                    borderRadius: const BorderRadius.all(
                                      Radius.circular(10),
                                    ),
                                    child: SizedBox(
                                      width: 100,
                                      child: FittedBox(
                                        fit: BoxFit.cover,
                                        child: CachedNetworkImage(
                                          imageUrl:
                                              relatedList[index].thumbnail,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                            childCount: relatedList.length,
                          ),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            mainAxisExtent: 200,
                          ),
                        ),
                      );
                    },
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

class _Gallery extends StatelessWidget {
  const _Gallery({required this.photoList});
  final List<Moviesgallery> photoList;

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.only(left: 20.0, right: 20.0, bottom: 15.0),
      sliver: SliverGrid(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            return GestureDetector(
              onTap: () {
                showFullScreenGallery(context, photoList[index].thumbnail);
              },
              child: ClipRRect(
                borderRadius: const BorderRadius.all(
                  Radius.circular(15),
                ),
                child: SizedBox(
                  height: 100,
                  width: 100,
                  child: FittedBox(
                    fit: BoxFit.cover,
                    child: CachedImage(
                      imageUrl: photoList[index].thumbnail,
                      radius: 15,
                    ),
                  ),
                ),
              ),
            );
          },
          childCount: photoList.length,
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
            fontFamily: StringConstants.setBoldPersianFont(),
            fontSize: (MediaQueryHandler.screenWidth(context) < 350) ? 14 : 16,
            color: Theme.of(context).colorScheme.tertiary,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          storyLine,
          style: TextStyle(
            fontFamily: StringConstants.setSmallPersionFont(),
            fontSize: (MediaQueryHandler.screenWidth(context) < 350) ? 12 : 14,
            color: Theme.of(context).colorScheme.tertiary,
          ),
        ),
      ],
    );
  }
}

class _MovieDetailHeader extends StatelessWidget {
  const _MovieDetailHeader({required this.movie, required this.isLiked});
  final Movie movie;
  final bool isLiked;

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Stack(
        children: [
          SizedBox(
            height: 552,
            width: MediaQuery.of(context).size.width,
            child: FittedBox(
              fit: BoxFit.cover,
              child: CachedImage(
                imageUrl: movie.thumbnail,
                radius: 0,
              ),
            ),
          ),
          Container(
            height: 600,
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
                  PrimaryColors.darkColor.withOpacity(0.7),
                  PrimaryColors.darkColor,
                ],
              ),
            ),
          ),
          _MovieHeaderContent(
            movie: movie,
            isOnLikes: isLiked,
          ),
        ],
      ),
    );
  }
}

class _MovieHeaderContent extends StatefulWidget {
  const _MovieHeaderContent({required this.movie, required this.isOnLikes});
  final Movie movie;
  final bool isOnLikes;

  @override
  State<_MovieHeaderContent> createState() => _MovieHeaderContentState();
}

class _MovieHeaderContentState extends State<_MovieHeaderContent>
    with TickerProviderStateMixin {
  late final AnimationController controller;
  bool? isLiked;

  @override
  void initState() {
    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    isLiked = widget.isOnLikes;
    if (!isLiked!) {
      controller.value = 0.0;
    } else if (isLiked!) {
      controller.value = 1.0;
    }
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
                  widget.movie.name,
                  style: TextStyle(
                    fontFamily: StringConstants.setBoldPersianFont(),
                    fontSize: (MediaQueryHandler.screenWidth(context) < 350)
                        ? 14
                        : 16,
                    color: Theme.of(context).colorScheme.tertiary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    headerLogics();
                  });
                },
                child: Container(
                  height:
                      (MediaQueryHandler.screenWidth(context) < 350) ? 28 : 32,
                  width:
                      (MediaQueryHandler.screenWidth(context) < 350) ? 28 : 32,
                  decoration: ShapeDecoration(
                    shape: const ContinuousRectangleBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(40),
                      ),
                    ),
                    color: Theme.of(context).colorScheme.secondary,
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
                  imageUrl: widget.movie.thumbnail,
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
                  widget.movie.year,
                  style: TextStyle(
                    fontFamily: StringConstants.setMediumPersionFont(),
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
                  "${widget.movie.timeLength} ${AppLocalizations.of(context)!.minutes}",
                  style: TextStyle(
                    fontFamily: StringConstants.setMediumPersionFont(),
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
                  widget.movie.genre,
                  style: TextStyle(
                    fontFamily: StringConstants.setMediumPersionFont(),
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
          ClipRRect(
            borderRadius: const BorderRadius.all(
              Radius.circular(8),
            ),
            child: ColoredBox(
              color: Theme.of(context).colorScheme.primaryContainer,
              child: SizedBox(
                height: 24,
                width: 55,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SvgPicture.asset(
                      'assets/images/icon_star.svg',
                      height: 16,
                      width: 16,
                      colorFilter: ColorFilter.mode(
                        Theme.of(context).colorScheme.secondaryContainer,
                        BlendMode.srcIn,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      widget.movie.rate,
                      style: TextStyle(
                        fontFamily: StringConstants.setMediumPersionFont(),
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.secondaryContainer,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 20.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return ClipRRect(
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                          child: BlocProvider(
                            create: (context) => VideoBloc(locator.get())
                              ..add(FetchTrailerEvent(widget.movie.id)),
                            child: const MainVideoBranch(),
                          ),
                        ),
                      );
                    },
                  );
                },
                child: ClipRRect(
                  borderRadius: const BorderRadius.all(
                    Radius.circular(32),
                  ),
                  child: ColoredBox(
                    color: Theme.of(context).colorScheme.secondaryContainer,
                    child: SizedBox(
                      height: (MediaQueryHandler.screenWidth(context) < 350)
                          ? 32
                          : 48,
                      width: (MediaQueryHandler.screenWidth(context) < 350)
                          ? 100
                          : 115,
                      child: Center(
                        child: Row(
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.only(left: 25, right: 10),
                              child: SvgPicture.asset(
                                'assets/images/icon_play.svg',
                                height:
                                    (MediaQueryHandler.screenWidth(context) <
                                            350)
                                        ? 18
                                        : 20,
                                width: (MediaQueryHandler.screenWidth(context) <
                                        350)
                                    ? 18
                                    : 20,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              AppLocalizations.of(context)!.play,
                              style: TextStyle(
                                fontFamily:
                                    StringConstants.setMediumPersionFont(),
                                fontSize:
                                    (MediaQueryHandler.screenWidth(context) <
                                            350)
                                        ? 12
                                        : 16,
                                color: Theme.of(context).colorScheme.tertiary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 15.0),
              GestureDetector(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return ClipRRect(
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                          child: BlocProvider(
                            create: (context) => VideoBloc(locator.get())
                              ..add(FetchTrailerEvent(widget.movie.id)),
                            child: const AppDownloader(),
                          ),
                        ),
                      );
                    },
                  );
                },
                child: ClipRRect(
                  borderRadius: const BorderRadius.all(
                    Radius.circular(100),
                  ),
                  child: ColoredBox(
                    color: Theme.of(context).colorScheme.secondary,
                    child: SizedBox(
                      height: (MediaQueryHandler.screenWidth(context) < 350)
                          ? 32
                          : 48,
                      width: (MediaQueryHandler.screenWidth(context) < 350)
                          ? 32
                          : 48,
                      child: Center(
                        child: SvgPicture.asset(
                          'assets/images/icon_download.svg',
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
                ),
              ),
              const SizedBox(width: 15.0),
              GestureDetector(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: SnackbarContent(
                        message: AppLocalizations.of(context)!.futureShare,
                        color: Theme.of(context).colorScheme.surfaceVariant,
                      ),
                      elevation: 0,
                      closeIconColor: Colors.transparent,
                      backgroundColor: Colors.transparent,
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
                child: ClipRRect(
                  borderRadius: const BorderRadius.all(
                    Radius.circular(100),
                  ),
                  child: ColoredBox(
                    color: Theme.of(context).colorScheme.secondary,
                    child: SizedBox(
                      height: (MediaQueryHandler.screenWidth(context) < 350)
                          ? 32
                          : 48,
                      width: (MediaQueryHandler.screenWidth(context) < 350)
                          ? 32
                          : 48,
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
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  headerLogics() {
    if (isLiked!) {
      context.read<MovieBloc>().add(WishlistDeleteItemEvent(widget.movie.name));
      context.read<WishlistBloc>().add(WishlistFetchCartsEvent());
      controller.reverse();
      isLiked = false;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 15),
          backgroundColor: Colors.transparent,
          content: SnackbarContent(
            message:
                "${widget.movie.name} ${AppLocalizations.of(context)!.removeFromWishlist}",
            color: Theme.of(context).colorScheme.tertiaryContainer,
          ),
          duration: const Duration(seconds: 5),
        ),
      );
    } else if (!isLiked!) {
      context.read<MovieBloc>().add(
            WishlistAddToCartEvent(widget.movie),
          );
      context.read<WishlistBloc>().add(WishlistFetchCartsEvent());
      controller.forward();
      isLiked = true;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 15),
          backgroundColor: Colors.transparent,
          content: SnackbarContent(
            message:
                "${widget.movie.name} ${AppLocalizations.of(context)!.isAddedToWishlist}",
            color: SecondaryColors.greenColor,
          ),
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }
}

class MovieCastAndCrew extends StatelessWidget {
  const MovieCastAndCrew({super.key, required this.casts});
  final List<MovieCasts> casts;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 30),
        Text(
          AppLocalizations.of(context)!.casts,
          style: TextStyle(
            fontFamily: StringConstants.setBoldPersianFont(),
            fontSize: (MediaQueryHandler.screenWidth(context) < 350) ? 14 : 16,
            color: Theme.of(context).colorScheme.tertiary,
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
                            fontFamily: StringConstants.setBoldPersianFont(),
                            fontSize:
                                (MediaQueryHandler.screenWidth(context) < 350)
                                    ? 12
                                    : 14,
                            color: Theme.of(context).colorScheme.tertiary,
                          ),
                        ),
                        Text(
                          casts[index].role,
                          style: TextStyle(
                            fontFamily: StringConstants.setMediumPersionFont(),
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

class MovieDetailLoading extends StatelessWidget {
  const MovieDetailLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 15),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ShimmerSkelton(
                  height: 32,
                  width: 32,
                  radius: 100,
                ),
                ShimmerSkelton(
                  height: 20,
                  width: 100,
                  radius: 5,
                ),
                ShimmerSkelton(
                  height: 32,
                  width: 32,
                  radius: 100,
                ),
              ],
            ),
            const SizedBox(height: 40),
            const Center(
              child: ShimmerSkelton(
                height: 287,
                width: 205,
                radius: 15,
              ),
            ),
            const SizedBox(height: 20),
            const Center(
              child: ShimmerSkelton(
                height: 20,
                width: 230,
                radius: 5,
              ),
            ),
            const SizedBox(height: 10),
            const Center(
              child: ShimmerSkelton(
                height: 20,
                width: 60,
                radius: 5,
              ),
            ),
            const SizedBox(height: 20),
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ShimmerSkelton(
                  height: 48,
                  width: 100,
                  radius: 100,
                ),
                SizedBox(width: 15),
                ShimmerSkelton(
                  height: 48,
                  width: 48,
                  radius: 100,
                ),
                SizedBox(width: 15),
                ShimmerSkelton(
                  height: 48,
                  width: 48,
                  radius: 100,
                ),
              ],
            ),
            const SizedBox(height: 15),
            const ShimmerSkelton(
              height: 20,
              width: 100,
              radius: 5,
            ),
            const SizedBox(height: 15),
            ShimmerSkelton(
              height: 20,
              width: MediaQueryHandler.screenWidth(context),
              radius: 5,
            ),
            const SizedBox(height: 10),
            ShimmerSkelton(
              height: 20,
              width: MediaQueryHandler.screenWidth(context) - 70,
              radius: 5,
            ),
            const SizedBox(height: 10),
            ShimmerSkelton(
              height: 20,
              width: MediaQueryHandler.screenWidth(context) - 100,
              radius: 5,
            ),
          ],
        ),
      ),
    );
  }
}

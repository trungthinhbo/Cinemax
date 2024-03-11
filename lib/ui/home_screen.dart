import 'package:cinemax/bloc/home/home_state.dart';
import 'package:cinemax/bloc/home/homebloc.dart';
import 'package:cinemax/constants/color_constants.dart';
import 'package:cinemax/data/model/movie.dart';
import 'package:cinemax/ui/category_search_screen.dart';
import 'package:cinemax/ui/search_screen.dart';
import 'package:cinemax/util/auth_manager.dart';
import 'package:cinemax/util/query_handler.dart';
import 'package:cinemax/widgets/banner.dart';
import 'package:cinemax/widgets/loading_indicator.dart';
import 'package:cinemax/widgets/movie_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          if (state is HomeLoadingState) {
            return const AppLoadingIndicator();
          }
          if (state is HomeResponseState) {
            return CustomScrollView(
              slivers: [
                _HomeHeader(name: AuthManager.readId()),
                const SearchBox(),
                state.getBanners.fold(
                  (exceptionMessage) {
                    return SliverToBoxAdapter(
                      child: Text("exceptionMessage"),
                    );
                  },
                  (bannerList) {
                    return SliverToBoxAdapter(
                      child: BannerContainer(
                        bannerList: bannerList,
                      ),
                    );
                  },
                ),
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.only(top: 25, left: 20),
                    child: Text(
                      "Categories",
                      style: TextStyle(
                        fontFamily: "MM",
                        fontSize: 16,
                        color: TextColors.whiteText,
                      ),
                      textAlign: TextAlign.start,
                    ),
                  ),
                ),
                const CategoryList(),
                SliverToBoxAdapter(
                  child: Padding(
                    padding:
                        const EdgeInsets.only(top: 30, left: 20, right: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Most Popular Movies",
                          style: TextStyle(
                            fontFamily: "MM",
                            fontSize: 16,
                            color: TextColors.whiteText,
                          ),
                          textAlign: TextAlign.start,
                        ),
                        GestureDetector(
                          onTap: () {
                            PersistentNavBarNavigator.pushNewScreen(
                              context,
                              screen: const CategorySearchScreen(),
                              withNavBar:
                                  false, // OPTIONAL VALUE. True by default.
                              pageTransitionAnimation:
                                  PageTransitionAnimation.cupertino,
                            );
                          },
                          child: const Text(
                            "See All",
                            style: TextStyle(
                              fontFamily: "MM",
                              fontSize: 14,
                              color: PrimaryColors.blueAccentColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                state.getMovies.fold(
                  (exceptionMessage) {
                    return Text("exceptionMessage");
                  },
                  (movieList) {
                    return MostPopList(movieList: movieList);
                  },
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding:
                        const EdgeInsets.only(top: 30, left: 20, right: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Most Popular Series",
                          style: TextStyle(
                            fontFamily: "MM",
                            fontSize: 16,
                            color: TextColors.whiteText,
                          ),
                          textAlign: TextAlign.start,
                        ),
                        GestureDetector(
                          onTap: () {
                            PersistentNavBarNavigator.pushNewScreen(
                              context,
                              screen: const CategorySearchScreen(),
                              withNavBar:
                                  false, // OPTIONAL VALUE. True by default.
                              pageTransitionAnimation:
                                  PageTransitionAnimation.cupertino,
                            );
                          },
                          child: const Text(
                            "See All",
                            style: TextStyle(
                              fontFamily: "MM",
                              fontSize: 14,
                              color: PrimaryColors.blueAccentColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                state.getSeries.fold(
                  (exceptionMessage) {
                    return Text("exceptionMessage");
                  },
                  (seriesList) {
                    return SeriesList(movieList: seriesList);
                  },
                ),
              ],
            );
          }
          return Text("There seem to be errors Getting data");
        },
      ),
    );
  }
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader({required this.name});
  final String name;

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const CircleAvatar(
                  radius: 20,
                  backgroundImage: AssetImage("assets/images/icon_user.png"),
                  backgroundColor: SecondaryColors.redColor,
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Hello, $name",
                      style: TextStyle(
                        fontFamily: "MSB",
                        fontSize: (MediaQueryHandler.screenWidth(context) < 350)
                            ? 12
                            : 16,
                        color: TextColors.whiteText,
                      ),
                    ),
                    Text(
                      "Let's find a movie for you",
                      style: TextStyle(
                        fontFamily: "MM",
                        fontSize: (MediaQueryHandler.screenWidth(context) < 350)
                            ? 8
                            : 12,
                        color: TextColors.greyText,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Container(
              height: 32,
              width: 32,
              decoration: const ShapeDecoration(
                shape: ContinuousRectangleBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(40),
                  ),
                ),
                color: PrimaryColors.softColor,
              ),
              child: Center(
                child: SvgPicture.asset(
                  'assets/images/icon_heart.svg',
                  color: SecondaryColors.redColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SearchBox extends StatelessWidget {
  const SearchBox({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.only(left: 20, right: 20, bottom: 25),
        child: GestureDetector(
          onTap: () {
            PersistentNavBarNavigator.pushNewScreen(
              context,
              screen: const SearchScreen(),
              withNavBar: true, // OPTIONAL VALUE. True by default.
              pageTransitionAnimation: PageTransitionAnimation.cupertino,
            );
          },
          child: Container(
            height: 41,
            width: MediaQuery.of(context).size.width,
            decoration: const BoxDecoration(
              color: PrimaryColors.softColor,
              borderRadius: BorderRadius.all(
                Radius.circular(24),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      SvgPicture.asset(
                        'assets/images/icon_search.svg',
                        height: 16,
                        width: 16,
                        color: TextColors.greyText,
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      const Text(
                        "Search a title...",
                        style: TextStyle(
                          fontFamily: "MM",
                          fontSize: 14,
                          color: TextColors.greyText,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: VerticalDivider(
                          color: TextColors.greyText,
                          thickness: 1.3,
                        ),
                      ),
                      SvgPicture.asset(
                        'assets/images/icon_setters.svg',
                        height: 16,
                        width: 16,
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
  }
}

class CategoryList extends StatefulWidget {
  const CategoryList({super.key});

  @override
  State<CategoryList> createState() => _CategoryListState();
}

class _CategoryListState extends State<CategoryList> {
  int selectedIndex = 0;
  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.only(left: 20, top: 20),
      sliver: SliverToBoxAdapter(
        child: SizedBox(
          height: 33,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 5,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(right: 10),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedIndex = index;
                    });
                  },
                  child: Container(
                    height: 31,
                    decoration: ShapeDecoration(
                      color: (selectedIndex == index)
                          ? PrimaryColors.softColor
                          : Colors.transparent,
                      shape: const ContinuousRectangleBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(40),
                        ),
                      ),
                    ),
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 30),
                        child: Text(
                          "All",
                          style: TextStyle(
                            fontFamily: "MM",
                            fontSize: 12,
                            color: (selectedIndex == index)
                                ? PrimaryColors.blueAccentColor
                                : TextColors.whiteText,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class MostPopList extends StatelessWidget {
  const MostPopList({super.key, required this.movieList});
  final List<Movie> movieList;

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.only(top: 25, left: 20),
        child: SizedBox(
          height: 231,
          child: ListView.builder(
            itemCount: movieList.length,
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(right: 15),
                child: MovieWidget(
                  showRate: true,
                  movie: movieList[index],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class SeriesList extends StatelessWidget {
  const SeriesList({super.key, required this.movieList});
  final List<Movie> movieList;

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.only(top: 25, left: 20, bottom: 35),
        child: SizedBox(
          height: 231,
          child: ListView.builder(
            itemCount: movieList.length,
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(right: 15),
                child: MovieWidget(
                  showRate: true,
                  movie: movieList[index],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

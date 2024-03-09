import 'package:cinemax/constants/color_constants.dart';
import 'package:cinemax/widgets/back_label.dart';
import 'package:cinemax/widgets/related_search_widget.dart';
import 'package:flutter/material.dart';

class CategorySearchScreen extends StatelessWidget {
  const CategorySearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Column(
                children: [
                  const SizedBox(
                    height: 30,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () {},
                        child: const BackLabel(),
                      ),
                      const Text(
                        "Most Popular Movies",
                        style: TextStyle(
                          fontFamily: "MSB",
                          fontSize: 16,
                          color: TextColors.whiteText,
                        ),
                      ),
                      const SizedBox(
                        width: 32,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.only(top: 40),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    return const Padding(
                      padding: EdgeInsets.only(bottom: 20),
                      child: RelatedSeachWidget(),
                    );
                  },
                  childCount: 10,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

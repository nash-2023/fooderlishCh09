import 'package:fdrlsh09/network/recipe_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../colors.dart';

class RecipeDetails extends StatelessWidget {
  const RecipeDetails({Key? key, required this.recipe}) : super(key: key);
  final APIRecipe recipe;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Stack(
                  children: [
                    Align(
                      alignment: Alignment.topLeft,
                      // TODO 1
                      child: Image.network(
                        'assets/images/pizza_w700.png',
                        height: 200,
                        width: 200,
                      ),
                    ),
                    Align(
                      alignment: Alignment.topLeft,
                      child: Container(
                        decoration: const BoxDecoration(
                            shape: BoxShape.circle, color: shim),
                        child: const BackButton(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 16,
                ),
                Padding(
                  padding: EdgeInsets.only(left: 16.0),
                  child: Text(
                    // TODO 2
                    recipe.label,
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(
                  height: 16,
                ),
                Padding(
                    padding: EdgeInsets.only(left: 16.0),
                    child: Chip(
                      // TODO 3
                      label: Text(getCalories(recipe.calories)),
                    )),
                const SizedBox(
                  height: 16,
                ),
                Center(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: green,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.0)),
                    ),
                    onPressed: () {
                      // TODO 4
                      Navigator.pop(context);
                    },
                    icon: SvgPicture.asset(
                      'assets/images/icon_bookmark.svg',
                      color: Colors.white,
                    ),
                    label: const Text(
                      'Bookmark',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

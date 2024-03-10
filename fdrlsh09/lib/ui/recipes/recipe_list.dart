import 'dart:math';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/custom_dropdown.dart';
import '../colors.dart';
import 'dart:convert';
import '../../network/recipe_model.dart';
import 'package:flutter/services.dart';
import '../recipe_card.dart';
import 'recipe_details.dart';
import '../../network/recipe_service.dart';

class RecipeList extends StatefulWidget {
  const RecipeList({Key? key}) : super(key: key);

  @override
  State createState() => _RecipeListState();
}

class _RecipeListState extends State<RecipeList> {
  static const String prefSearchKey = 'previousSearches';
  late TextEditingController searchTextController;
  final ScrollController _scrollController = ScrollController();
  List<APIHits> currentSearchList = [];
  int currentCount = 0;
  int currentStartPosition = 0;
  int currentEndPosition = 20;
  int pageCount = 20;
  bool hasMore = false;
  bool loading = false;
  bool inErrorState = false;
  List<String> previousSearches = <String>[];

  @override
  void initState() {
    super.initState();
    getPreviousSearches();
    searchTextController = TextEditingController(text: '');
    _scrollController.addListener(() {
      final triggerFetchMoreSize =
          0.7 * _scrollController.position.maxScrollExtent;

      if (_scrollController.position.pixels > triggerFetchMoreSize) {
        if (hasMore &&
            currentEndPosition < currentCount &&
            !loading &&
            !inErrorState) {
          setState(() {
            loading = true;
            currentStartPosition = currentEndPosition;
            currentEndPosition =
                min(currentStartPosition + pageCount, currentCount);
          });
        }
      }
    });
  }

// 1
  Future<APIRecipeQuery> getRecipeData(String query, int from, int to) async {
// 2
    final recipeJson = await RecipeService().getRecipes(query, from, to);
// 3
    final recipeMap = json.decode(recipeJson);
// 4
    return APIRecipeQuery.fromJson(recipeMap);
  }

  @override
  void dispose() {
    searchTextController.dispose();
    super.dispose();
  }

  void savePreviousSearches() async {
// 1
    final prefs = await SharedPreferences.getInstance();
// 2
    prefs.setStringList(prefSearchKey, previousSearches);
  }

  void getPreviousSearches() async {
// 1
    final prefs = await SharedPreferences.getInstance();
// 2
    if (prefs.containsKey(prefSearchKey)) {
// 3
      final searches = prefs.getStringList(prefSearchKey);
// 4
      if (searches != null) {
        previousSearches = searches;
      } else {
        previousSearches = <String>[];
      }
    }
  }

//----------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            _buildSearchCard(),
            _buildRecipeLoader(context),
          ],
        ),
      ),
    );
  }

//----------------------------------------------------
  Widget _buildSearchCard() {
    return Card(
      elevation: 4,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8.0))),
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Row(
          children: [
            // Replace
            IconButton(
              icon: const Icon(Icons.search),
// 1
              onPressed: () {
// 2
                startSearch(searchTextController.text);
// 3
                final currentFocus = FocusScope.of(context);
                if (!currentFocus.hasPrimaryFocus) {
                  currentFocus.unfocus();
                }
              },
            ),
            const SizedBox(
              width: 6.0,
            ),
            Expanded(
              child: Row(
                children: <Widget>[
                  Expanded(
// 3
                    child: TextField(
                      decoration: const InputDecoration(
                          border: InputBorder.none, hintText: 'Search'),
                      autofocus: false,
// 4
                      textInputAction: TextInputAction.done,
// 5
                      onSubmitted: (value) {
                        startSearch(searchTextController.text);
                      },
                      // onChanged: (value) {
                      //   startSearch(searchTextController.text);
                      // },
                      controller: searchTextController,
                    ),
                  ),
// 6
                  PopupMenuButton<String>(
                    icon: const Icon(
                      Icons.arrow_drop_down,
                      color: lightGrey,
                    ),
// 7
                    onSelected: (String value) {
                      searchTextController.text = value;
                      startSearch(searchTextController.text);
                    },
                    itemBuilder: (BuildContext context) {
// 8
                      return previousSearches
                          .map<CustomDropdownMenuItem<String>>((String value) {
                        return CustomDropdownMenuItem<String>(
                          text: value,
                          value: value,
                          callback: () {
                            setState(() {
// 9
                              previousSearches.remove(value);
                              savePreviousSearches();
                              Navigator.pop(context);
                            });
                          },
                        );
                      }).toList();
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void startSearch(String value) {
// 1
    setState(() {
// 2
      currentSearchList.clear();
      currentCount = 0;
      currentEndPosition = pageCount;
      currentStartPosition = 0;
      hasMore = true;
      value = value.trim();
// 3
      if (!previousSearches.contains(value)) {
// 4
        previousSearches.add(value);
// 5
        savePreviousSearches();
      }
    });
  }

  // 1
  Widget _buildRecipeList(BuildContext recipeListContext, List<APIHits> hits) {
// 2
    final size = MediaQuery.of(context).size;
    const itemHeight = 310;
    final itemWidth = size.width / 2;
// 3
    return Flexible(
// 4
      child: GridView.builder(
// 5
        controller: _scrollController,
// 6
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: (itemWidth / itemHeight),
        ),
// 7
        itemCount: hits.length,
// 8
        itemBuilder: (BuildContext context, int index) {
          return _buildRecipeCard(recipeListContext, hits, index);
        },
      ),
    );
  }

  Widget _buildRecipeCard(
      BuildContext topLevelContext, List<APIHits> hits, int index) {
// 1
    final recipe = hits[index].recipe;
    return GestureDetector(
      onTap: () {
        Navigator.push(topLevelContext, MaterialPageRoute(
          builder: (context) {
            return RecipeDetails(recipe: recipe);
          },
        ));
      },
// 2
      child: recipeCard(recipe),
    );
  }

  Widget _buildRecipeLoader(BuildContext context) {
// 1
    if (searchTextController.text.length < 3) {
      return Container();
    }
// 2
    return FutureBuilder<APIRecipeQuery>(
// 3
      future: getRecipeData(searchTextController.text.trim(),
          currentStartPosition, currentEndPosition),
// 4
      builder: (context, snapshot) {
// 5
        if (snapshot.connectionState == ConnectionState.done) {
// 6
          if (snapshot.hasError) {
            return Center(
              child: Text(snapshot.error.toString(),
                  textAlign: TextAlign.center, textScaleFactor: 1.3),
            );
          }
// 7
          loading = false;
          final query = snapshot.data;
          print("query:= ${query?.query}");
          print("from:= ${query?.from}");
          print("to:= ${query?.to}");
          print("more:= ${query?.more}");
          print("count:= ${query?.count}");
          // print("hits:= ${query?.hits}");

          inErrorState = false;
          if (query != null) {
            currentCount = query.count;
            hasMore = query.more;
            currentSearchList.addAll(query.hits);
// 8
            if (query.to < currentEndPosition) {
              currentEndPosition = query.to;
            }
          }
// 9
          return _buildRecipeList(context, currentSearchList);
        }
// 10
        else {
// 11
          if (currentCount == 0) {
// Show a loading indicator while waiting for the recipes
            return const Center(child: CircularProgressIndicator());
          } else {
// 12
            return _buildRecipeList(context, currentSearchList);
          }
        }
      },
    );
  }
}

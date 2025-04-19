import 'package:flutter/material.dart';
import 'package:mobile_project/api/api_service.dart';
import 'news_detail_page.dart';

class ArticlesPage extends StatefulWidget {
  const ArticlesPage({super.key});

  @override
  _ArticlesPageState createState() => _ArticlesPageState();
}

class _ArticlesPageState extends State<ArticlesPage> {
  List articles = [];
  List featuredArticles = [];
  List filteredArticles = [];
  TextEditingController searchController = TextEditingController();

  // Pagination variables
  int currentPage = 1;
  int articlesPerPage = 5;

  @override
  void initState() {
    super.initState();
    fetchArticles();
  }

  Future<void> fetchArticles() async {
    try {
      final apiService = ApiService();
      final fetchedArticles = await apiService.fetchArticles();
      setState(() {
        articles = fetchedArticles;
        featuredArticles = articles.take(5).toList();
        filteredArticles = articles.skip(5).take(5).toList();
      });
    } catch (e) {
      print('Error fetching articles: $e');
    }
  }

  // Pagination functions
  void loadPreviousPage() {
    if (currentPage > 1) {
      setState(() {
        currentPage--;
        int startIndex = 5+ (currentPage - 1) * articlesPerPage;
        filteredArticles =
            articles.skip(startIndex).take(articlesPerPage).toList();
      });
    }
  }

  void loadNextPage() {
    if ((currentPage * articlesPerPage) < articles.length) {
      setState(() {
        currentPage++;
        int startIndex = 5+(currentPage - 1) * articlesPerPage;
        filteredArticles =
            articles.skip(startIndex).take(articlesPerPage).toList();
      });
    }
  }

  // Format the date for display
  String formatDate(String dateString) {
    try {
      DateTime date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateString; // Return the original date if it's invalid
    }
  }

  // Filter articles based on search query
  void filterArticles(String query) {
    setState(() {
      filteredArticles =
          articles
              .where(
                (article) =>
                    article['title']?.toLowerCase().contains(
                      query.toLowerCase(),
                    ) ??
                    false,
              )
              .take(articlesPerPage)
              .toList();
      currentPage = 1; // Reset to first page after search
    });
  }

  String selectedFilter = 'All';

void filterByCategory(String category) {
  setState(() {
    selectedFilter = category;
    if (category == 'All') {
      filteredArticles = articles.take(articlesPerPage).toList();
    } else if (category == 'Like') {
      filteredArticles = articles.where((article) => article['liked'] == true).take(articlesPerPage).toList();
    } else if (category == 'Watch Later') {
      filteredArticles = articles.where((article) => article['watchLater'] == true).take(articlesPerPage).toList();
    }
  });
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF2D2),
      appBar: AppBar(
        title: const Text(
          'Mental Health Articles',
          style: TextStyle(
            color: Color.fromARGB(255, 255, 255, 255),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 90, 78, 66),
      ),
      body:
          articles.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                child: Column(
                  children: [
                    // Search Bar
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: TextField(
                        controller: searchController,
                        decoration: InputDecoration(
                          hintText: 'Search articles...',
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: const Color.fromARGB(59, 0, 0, 0),
                        ),
                        onChanged: filterArticles,
                      ),
                    ),
                    // Featured Articles
                    SizedBox(
                      height: 200,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: featuredArticles.length,
                        itemBuilder: (context, index) {
                          final article = featuredArticles[index];
                          return Container(
                            margin: const EdgeInsets.symmetric(
                              horizontal:
                                  8, // Horizontal space between articles
                              vertical: 12, // Vertical space between articles
                            ),
                            child: Card(
                              elevation: 2,
                              color: const Color.fromARGB(255, 119, 104, 88),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (context) =>
                                              NewsDetailPage(article: article),
                                    ),
                                  );
                                },
                                child: Container(
                                  width: 330,
                                  margin: const EdgeInsets.symmetric(horizontal: 8),
                                  child: Stack(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child:
                                            article['urlToImage'] != null
                                                ? Image.network(
                                                  article['urlToImage'],
                                                  width: double.infinity,
                                                  fit: BoxFit.cover,
                                                )
                                                : Container(
                                                  height: 200,
                                                  color: Colors.grey[200],
                                                  child: const Icon(
                                                    Icons.article,
                                                    size: 50,
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                      ),
                                      Positioned.fill(
                                        child: Container(
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            gradient: LinearGradient(
                                              colors: [
                                                Colors.black.withOpacity(0.7),
                                                Colors.transparent,
                                              ],
                                              begin: Alignment.bottomCenter,
                                              end: Alignment.topCenter,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        bottom: 10,
                                        left: 10,
                                        right: 10,
                                        child: Text(
                                          article['title'] ?? 'No title',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                            color: Colors.white,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 25),
                    
                  // Filter Buttons
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        FilterButton(label: 'All', isSelected: selectedFilter == 'All', onTap: () => filterByCategory('All')),
                        const SizedBox(width: 8),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                    // Article List
                    ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: filteredArticles.length,
                      itemBuilder: (context, index) {
                        final article = filteredArticles[index];
                        return Container(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 16, // Horizontal space between articles
                            vertical: 2, // Vertical space between articles
                          ),
                          child: Card(
                            elevation: 2,
                            color: const Color.fromARGB(255, 90, 78, 66),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) =>
                                            NewsDetailPage(article: article),
                                  ),
                                );
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(
                                  12.0,
                                ), // Internal padding for content
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child:
                                          article['urlToImage'] != null
                                              ? Image.network(
                                                article['urlToImage'],
                                                width: 100,
                                                height: 100,
                                                fit: BoxFit.cover,
                                              )
                                              : Container(
                                                width: 100,
                                                height: 100,
                                                color: Colors.grey[200],
                                                child: const Icon(
                                                  Icons.article,
                                                  size: 40,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            article['title'] ?? 'No title',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                              color: Colors.white,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            '${article['author'] ?? 'Unknown Author'} • ${formatDate(article['publishedAt'] ?? '')}',
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: Colors.white70,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    // Pagination buttons
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (currentPage > 1)
                            ElevatedButton(
                              onPressed: loadPreviousPage,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color.fromARGB(
                                  255,
                                  90,
                                  78,
                                  66,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                              child: const Text(
                                'Previous',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          const SizedBox(width: 20),
                          Text(
                            'Page $currentPage',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(width: 20),
                          if ((currentPage * articlesPerPage) < articles.length)
                            ElevatedButton(
                              onPressed: loadNextPage,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color.fromARGB(
                                  255,
                                  90,
                                  78,
                                  66,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                              child: const Text(
                                'Next',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
    );
  }
}

class FilterButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const FilterButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected
            ? Colors.brown 
            : Colors.transparent,
        side: BorderSide(
          color: Colors.brown, 
          width: 2,
        ),
        elevation: 0, 
        shadowColor: Colors.transparent
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.brown, 
        ),
      ),
    );
  }
}


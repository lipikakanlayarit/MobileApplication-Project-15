import 'package:flutter/material.dart';

class NewsDetailPage extends StatelessWidget {
  final Map article;
  const NewsDetailPage({required this.article, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF2D2),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 90, 78, 66),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (article['urlToImage'] != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(article['urlToImage'])),
              const SizedBox(height: 24),
              Text(
                '${article['author'] ?? 'Unknown Author'}',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.grey
                ),
              ),
              const SizedBox(height: 6),
              Text(
                article['title'] ?? 'No title available',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              
              const SizedBox(height: 16),
              Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.thumb_up, color: Color.fromARGB(255, 90, 78, 66),),
                    label: const Text('Like'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.bookmark,color: Color.fromARGB(255, 90, 78, 66),),
                    label: const Text('Watch Later'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ],
              ),
              const Divider(
                color: Colors.black54,
                thickness: 1,
                height: 40,
              ),
              Text(
                article['content'] ?? 'No content available',
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
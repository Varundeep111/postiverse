import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Import the intl package for DateFormat

class FullScreenImage extends StatelessWidget {
  final String imageUrl;
  final String title;
  final DateTime createdAt;
  final String username;

  const FullScreenImage({
    Key? key,
    required this.imageUrl,
    required this.title,
    required this.createdAt,
    required this.username,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Format the date
    final formattedDate = DateFormat('MMMM d, yyyy – h:mm a').format(createdAt);

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // Back button
            Padding(
              padding: const EdgeInsets.only(top: 16.0, left: 16.0),
              child: Align(
                alignment: Alignment.topLeft,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white, size: 30),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ),
            Expanded(
              child: Center(
                child: InteractiveViewer(
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.contain,
                    width: double.infinity,
                  ),
                ),
              ),
            ),
            // Bottom container with title and info
            Container(
              color: Colors.black.withOpacity(0.8),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image Title
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  // Info Column
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Username
                      Row(
                        children: [
                          const Icon(Icons.person, color: Colors.grey, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            'Posted by $username',
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Posted Time
                      Row(
                        children: [
                          const Icon(Icons.access_time, color: Colors.grey, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            formattedDate,
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ],
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

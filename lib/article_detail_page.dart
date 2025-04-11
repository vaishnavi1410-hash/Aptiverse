import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

class ArticleDetailPage extends StatelessWidget {
  final String title;
  final String content;
  final String topic;
  final String? imageUrl;

  const ArticleDetailPage({
    Key? key,
    required this.title,
    required this.content,
    required this.topic,
    this.imageUrl,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool isLiked = false;
    bool isBookmarked = false;

    return Scaffold(
      appBar: AppBar(
        title: Text("Article"),
        backgroundColor: Colors.lightBlue,
        actions: [
          IconButton(
            icon: Icon(Icons.share),
            onPressed: () => Share.share("$title\n\n$content"),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (imageUrl != null && imageUrl!.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(imageUrl!),
              ),
            SizedBox(height: 20),
            Text(
              title,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Divider(height: 30, thickness: 2),
            Text(content, style: TextStyle(fontSize: 16, height: 1.6)),
            SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _InteractiveIcon(
                  icon: Icons.thumb_up_alt_outlined,
                  activeIcon: Icons.thumb_up_alt,
                  label: "Like",
                ),
                _InteractiveIcon(
                  icon: Icons.bookmark_border,
                  activeIcon: Icons.bookmark,
                  label: "Bookmark",
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _InteractiveIcon extends StatefulWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const _InteractiveIcon({
    Key? key,
    required this.icon,
    required this.activeIcon,
    required this.label,
  }) : super(key: key);

  @override
  State<_InteractiveIcon> createState() => _InteractiveIconState();
}

class _InteractiveIconState extends State<_InteractiveIcon> {
  bool isActive = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        IconButton(
          icon: Icon(isActive ? widget.activeIcon : widget.icon),
          color: isActive ? Colors.blue : Colors.grey,
          onPressed: () {
            setState(() {
              isActive = !isActive;
            });
          },
        ),
        Text(widget.label),
      ],
    );
  }
}

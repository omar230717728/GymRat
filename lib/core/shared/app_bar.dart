import 'package:flutter/material.dart';

AppBar getAppBar(BuildContext context) {
  return 
AppBar(
    backgroundColor: Colors.transparent, // Completely transparent
    elevation: 0, // Remove shadow
    scrolledUnderElevation: 0,
    actions: [
      Container(
        margin: EdgeInsets.only(right: 8.0),
        padding: EdgeInsets.all(3.0),
        child: IconButton(onPressed: () {}, icon: Icon(Icons.search)),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(17),
          color: Theme.of(context).colorScheme.surface.withOpacity(0.9),
        ),
      ),
      Container(
        margin: EdgeInsets.only(right: 8.0),
        padding: EdgeInsets.all(3.0),
        child: IconButton(onPressed: () {}, icon: Icon(Icons.settings)),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(17),
          color: Theme.of(context).colorScheme.surface.withOpacity(0.9),
        ),
      ),
    ], // Remove shadow when scrolling
    title: Text(
      "title",
      style: TextStyle(
        color: Theme.of(context).colorScheme.onBackground,
        fontWeight: FontWeight.bold,
        fontSize: 20,
      ),
    ),
    leading: Container(
      padding: EdgeInsets.all(5.0),
      margin: EdgeInsets.only(left: 8.0),
      child: GestureDetector(
        onTap: () {
          // Handle profile tap
        },
        child: CircleAvatar(
          radius: 21,
          backgroundColor: Theme.of(context).colorScheme.primary,
          child: CircleAvatar(
            radius: 17,
            backgroundImage: NetworkImage(
              'assets/body_part_images/Screenshot 2025-09-30 232210.jpg',
            ),
            child: Container(), // Fallback
          ),
        ),
      ),
    ),
  );
}

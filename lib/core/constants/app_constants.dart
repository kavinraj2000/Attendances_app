import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class APPCONSTANTS {
  APPCONSTANTS();
  final double appBarHeight = kToolbarHeight;
  final double logoHeight = 32.0;
  final double iconSize = 24.0;
  final double badgeSize = 8.0;
  final double leftPadding = 16.0;
  final double rightPadding = 15.0;
  final double titleSpacing = 8.0;
  final double elevation = 2.0;
  final double sidebarWidth = 70.0;
  final double categoryImageSize = 50.0;
  final double categoryIconSize = 24.0;
  final double subCategoryIconSize = 32.0;
  final double errorImageHeight = 400.0;
  final double imageLoaderSize = 20.0;
  final double emptyStateIconSize = 64.0;
  final double maxCrossAxisExtent = 220.0;
  final double childAspectRatio = 0.9;
  final double subCategoryAspectRatio = 0.8;
  final int gridCrossAxisCount = 2;
  

  final TextStyle headerblack = GoogleFonts.unna(
    fontSize: 12,
    color: Colors.black87,
    fontWeight: FontWeight.normal,
  );

  final TextStyle headerwhite = GoogleFonts.poppins(
    fontSize: 12,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );
  final TextStyle textblack = GoogleFonts.unna(
    fontSize: 10,
    fontWeight: FontWeight.bold,
    color: Colors.black87,
  );
  final TextStyle textwhite = GoogleFonts.unna(
    fontSize: 10,
    color: Colors.white,
  );
  final TextStyle offer = TextStyle(
    fontFamily: 'Figtree',
    fontSize: 10,
    color: Color.fromARGB(255, 96, 94, 94),
    decoration: TextDecoration.lineThrough,
    decorationThickness: 1,
    decorationColor: Color.fromARGB(255, 96, 94, 94),
  );
}

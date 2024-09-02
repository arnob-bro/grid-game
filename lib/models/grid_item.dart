class GridItem {
  final int points;
  bool isSelected;
  bool isHighlighted;

  GridItem({
    required this.points,
    this.isSelected = false,
    this.isHighlighted = false,
  });
}

class Evolution {
  final String name;
  final String imageUrl;
  final String shinyImageUrl;
  final String gifUrl;
  final String shinyGifUrl;
  final List<Evolution> nextEvolutions;
  final String? trigger;

  Evolution({
    required this.name,
    required this.imageUrl,
    required this.shinyImageUrl,
    required this.gifUrl,
    required this.shinyGifUrl,
    this.nextEvolutions = const [],
    this.trigger,
  });

  Evolution copyWith({
    List<Evolution>? nextEvolutions,
    String? trigger,
  }) {
    return Evolution(
      name: name,
      imageUrl: imageUrl,
      shinyImageUrl: shinyImageUrl,
      gifUrl: gifUrl,
      shinyGifUrl: shinyGifUrl,
      nextEvolutions: nextEvolutions ?? this.nextEvolutions,
      trigger: trigger ?? this.trigger,
    );
  }
}

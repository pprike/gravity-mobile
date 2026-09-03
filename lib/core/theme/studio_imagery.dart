/// Studio photography exported from the Gravity Figma file.
abstract final class StudioImagery {
  static const hero = "assets/images/studio_hero.jpg";
  static const strength = "assets/images/class_strength.jpg";
  static const cardio = "assets/images/class_cardio.jpg";
  static const coach = "assets/images/coach.jpg";
  static const memberAvatar = "assets/images/member_avatar.jpg";

  static String forClassName(String name) {
    final value = name.toLowerCase();
    const cardioKeys = [
      "row",
      "hiit",
      "metcon",
      "burn",
      "cardio",
      "cycle",
      "spin",
      "endurance",
      "run",
      "kettle",
    ];
    if (cardioKeys.any(value.contains)) return cardio;

    const floorKeys = [
      "power",
      "strength",
      "lift",
      "olympic",
      "weight",
      "condition",
    ];
    if (floorKeys.any(value.contains)) return hero;

    return strength;
  }
}

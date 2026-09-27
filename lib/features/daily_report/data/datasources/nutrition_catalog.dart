class MealCategoryOptions {
  final String categoryName;
  final List<String> options;

  const MealCategoryOptions({
    required this.categoryName,
    required this.options,
  });
}

class NutritionCatalog {
  static const List<MealCategoryOptions> breakfast = [
    MealCategoryOptions(
      categoryName: 'بروتين',
      options: [
        'بيض مسلوق / أومليت (100جم)',
        'جبنة قريش (130جم)',
        'فول (150جم) + نصف كمية النشويات فقط',
        'زبادي يوناني قليل الدسم (170جم) + نصف كمية النشويات فقط',
      ],
    ),
    MealCategoryOptions(
      categoryName: 'نشويات',
      options: [
        'خبز بلدي (80جم)',
        'توست بني (80جم)',
        'خبز شوفان (60جم)',
        'شوفان (60جم)',
        'بطاطس مسلوقة أو اير فراير (170جم)',
      ],
    ),
    MealCategoryOptions(
      categoryName: 'أجبان / ألبان',
      options: [
        'فيتا طبيعي (40جم)',
        'جبن كريمي طبيعي (40جم)',
        'شيدر لايت (40جم) أو شيدر عادي (20جم)',
        'لبن كامل الدسم (200مل)',
      ],
    ),
    MealCategoryOptions(
      categoryName: 'خضروات',
      options: ['طبق سلطة / خضار طازج (100جم)'],
    ),
  ];

  static const List<MealCategoryOptions> lunch = [
    MealCategoryOptions(
      categoryName: 'بروتين',
      options: [
        'صدر دجاج مشوي (180جم)',
        'لحمة مشوية (160جم)',
        'كفتة مشوية (160جم)',
        'شيش طاووق (180جم)',
        'كبدة بقري مشوية (160جم)',
        'كبدة دجاج (180جم)',
        'سمك بلطي مشوي (230جم)',
        'سمك بوري مشوي (230جم)',
        'تونة مصفاة من الزيت (160جم)',
        'جمبري مشوي / مسلوق (190جم)',
        'شاورما دجاج (180جم)',
        'شاورما لحم (160جم)',
      ],
    ),
    MealCategoryOptions(
      categoryName: 'نشويات',
      options: [
        'أرز بسمتي مطهي (250جم)',
        'أرز أبيض مطهي (250جم)',
        'محشي (250جم)',
        'مكرونة ريد صوص (230جم)',
        'مكرونة وايت صوص (230جم)',
        'مكرونة بشاميل (230جم)',
        'بطاطس بالقلاية الهوائية (300جم)',
        'بطاطس مسلوقة (300جم)',
      ],
    ),
    MealCategoryOptions(
      categoryName: 'خضروات',
      options: [
        'طبق سلطة (100جم)',
        'خضار مطبوخ',
        'طبق سلطة (100جم) + خضار مطبوخ',
      ],
    ),
  ];

  static const List<MealCategoryOptions> snack = [
    MealCategoryOptions(
      categoryName: 'سناك',
      options: [
        'فول سوداني (30جم)',
        'شوكولاتة داكنة (30جم)',
        'فشار منزلي (30جم)',
        'مكسرات مشكلة (30جم)',
        'ترمس مسلوق (60جم)',
      ],
    ),
  ];

  static const List<MealCategoryOptions> beforeTraining = [
    MealCategoryOptions(
      categoryName: 'وجبة قبل التمرين',
      options: [
        'موز ناضج (150جم)',
        'تمر (45جم)',
        'بطاطا حلوة مشوية (150جم)',
        'تفاح (200جم)',
        'فراولة (300جم)',
        'عصير برتقال فريش (250مل)',
        'عصير رمان (200مل)',
      ],
    ),
    MealCategoryOptions(
      categoryName: 'المشروب (اختياري)',
      options: ['كوب قهوة سادة / بسكر دايت'],
    ),
  ];

  static const List<MealCategoryOptions> afterTraining = [
    MealCategoryOptions(
      categoryName: 'بروتين بعد التمرين',
      options: [
        'صدر دجاج مشوي (180جم)',
        'لحمة مشوية (160جم)',
        'كفتة مشوية (160جم)',
        'شيش طاووق (180جم)',
        'كبدة بقري مشوية (160جم)',
        'كبدة دجاج (180جم)',
        'سمك بلطي مشوي (230جم)',
        'سمك بوري مشوي (230جم)',
        'تونة مصفاة من الزيت (160جم)',
        'جمبري مشوي / مسلوق (190جم)',
        'شاورما دجاج (180جم)',
        'شاورما لحم (160جم)',
      ],
    ),
    MealCategoryOptions(
      categoryName: 'نشويات بعد التمرين',
      options: [
        'أرز بسمتي مطهي (250جم)',
        'أرز أبيض مطهي (250جم)',
        'محشي (250جم)',
        'مكرونة ريد صوص (230جم)',
        'مكرونة وايت صوص (230جم)',
        'مكرونة بشاميل (230جم)',
        'بطاطس بالقلاية الهوائية (300جم)',
        'بطاطس مسلوقة (300جم)',
      ],
    ),
    MealCategoryOptions(
      categoryName: 'خضروات',
      options: [
        'طبق سلطة (100جم)',
        'خضار مطبوخ',
        'طبق سلطة (100جم) + خضار مطبوخ',
      ],
    ),
  ];

  static const List<MealCategoryOptions> dinner = [
    MealCategoryOptions(
      categoryName: 'بروتين / ألبان',
      options: [
        'زبادي يوناني قليل الدسم (170جم)',
        'جبنة قريش (170جم)',
        'حليب (300مل)',
        'زبادي قليل الدسم (300مل)',
        'لبن رايب (300مل)',
      ],
    ),
    MealCategoryOptions(
      categoryName: 'إضافات',
      options: ['طبق سلطة / خضار طازج (100جم)', 'زيت زيتون (20جم)'],
    ),
  ];
}

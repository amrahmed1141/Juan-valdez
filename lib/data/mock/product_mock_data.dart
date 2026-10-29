import '../../core/constants/app_assets.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../models/cart_item_model.dart';
import '../models/product_model.dart';
import '../models/store_model.dart';

abstract final class ProductMockData {
  static const List<String> categories = [
    AppStrings.categoryCoffee,
    AppStrings.categoryIced,
    AppStrings.categoryCroissant,
    AppStrings.categoryCookies,
    AppStrings.categoryFood,
    AppStrings.categoryDesserts,
  ];

  static const List<({String imagePath, String label})> exploreCategories = [
    (
      imagePath: AppAssets.exploreHotDrinks,
      label: AppStrings.exploreHotDrinks,
    ),
    (
      imagePath: AppAssets.exploreIcedDrinks,
      label: AppStrings.exploreIcedDrinks,
    ),
    (
      imagePath: AppAssets.exploreFrozenDrinks,
      label: AppStrings.exploreFrozenDrinks,
    ),
    (
      imagePath: AppAssets.exploreSignature,
      label: AppStrings.exploreSignature,
    ),
    (
      imagePath: AppAssets.butterCroissant,
      label: AppStrings.exploreCroissant,
    ),
    (
      imagePath: AppAssets.chocolateChipCookie,
      label: AppStrings.exploreCookies,
    ),
    (
      imagePath: AppAssets.exploreSpecialOffers,
      label: AppStrings.exploreSpecialOffers,
    ),
  ];

  static const List<({String emoji, String label})> menuCategories = [
    (emoji: '☕', label: 'COFFEE'),
    (emoji: '🧊', label: 'COLD'),
    (emoji: '🥐', label: 'CROISSANT'),
    (emoji: '🍪', label: 'COOKIES'),
  ];

  // ── Hot Coffee (menu M prices) ──────────────────────────────────────────

  static const ProductModel americano = ProductModel(
    id: 'americano',
    name: 'Americano',
    description: 'Classic espresso diluted with hot water. Clean and bold.',
    price: 115,
    imagePath: AppAssets.juanValdezCoffee,
    pastelColor: AppColors.pastelPeach,
    category: AppStrings.categoryCoffee,
    highlight: 'Hot · Classic · Bold',
  );

  static const ProductModel cappuccino = ProductModel(
    id: 'cappuccino',
    name: 'Cappuccino',
    description: 'Espresso with steamed milk and a thick foam cap.',
    price: 140,
    imagePath: AppAssets.juanValdezCoffee,
    pastelColor: AppColors.pastelCream,
    category: AppStrings.categoryCoffee,
    highlight: 'Hot · Foam · Classic',
  );

  static const ProductModel espresso = ProductModel(
    id: 'espresso',
    name: 'Espresso',
    description: 'A concentrated shot of 100% Colombian Arabica.',
    price: 70,
    imagePath: AppAssets.juanValdezCoffee,
    pastelColor: AppColors.pastelPeach,
    category: AppStrings.categoryCoffee,
    highlight: 'Hot · Shot · Intense',
  );

  static const ProductModel espressoMacchiato = ProductModel(
    id: 'espresso_macchiato',
    name: 'Espresso Macchiato',
    description: 'Espresso marked with a dollop of steamed milk foam.',
    price: 80,
    imagePath: AppAssets.juanValdezCoffee,
    pastelColor: AppColors.pastelCream,
    category: AppStrings.categoryCoffee,
    highlight: 'Hot · Macchiato · Soft',
  );

  static const ProductModel flatWhite = ProductModel(
    id: 'flat_white',
    name: 'Flat White',
    description: 'Velvety microfoam over a double espresso.',
    price: 150,
    imagePath: AppAssets.juanValdezCoffee,
    pastelColor: AppColors.pastelMint,
    category: AppStrings.categoryCoffee,
    highlight: 'Hot · Silky · Smooth',
  );

  static const ProductModel latte = ProductModel(
    id: 'latte',
    name: 'Latte',
    description: 'Espresso with steamed milk — creamy and balanced.',
    price: 140,
    imagePath: AppAssets.juanValdezCoffee,
    pastelColor: AppColors.pastelCream,
    category: AppStrings.categoryCoffee,
    highlight: 'Hot · Creamy · Classic',
  );

  static const ProductModel mocca = ProductModel(
    id: 'mocca',
    name: 'Mocca',
    description: 'Espresso, chocolate, and steamed milk.',
    price: 170,
    imagePath: AppAssets.signatureCream,
    pastelColor: AppColors.pastelPink,
    category: AppStrings.categoryCoffee,
    highlight: 'Hot · Chocolate · Rich',
  );

  static const ProductModel spanishLatte = ProductModel(
    id: 'spanish_latte',
    name: 'Spanish Latte',
    description: 'Espresso with sweetened condensed milk.',
    price: 160,
    imagePath: AppAssets.juanValdezCoffee,
    pastelColor: AppColors.pastelYellow,
    category: AppStrings.categoryCoffee,
    highlight: 'Hot · Sweet · Creamy',
  );

  static const ProductModel arequipeCappuccino = ProductModel(
    id: 'arequipe_cappuccino',
    name: 'Arequipe Cappuccino',
    description: 'Cappuccino swirled with Colombian arequipe caramel.',
    price: 160,
    imagePath: AppAssets.signatureCream,
    pastelColor: AppColors.pastelPeach,
    category: AppStrings.categoryCoffee,
    highlight: 'Hot · Arequipe · Sweet',
  );

  static const ProductModel irishCappuccino = ProductModel(
    id: 'irish_cappuccino',
    name: 'Irish Cappuccino',
    description: 'Cappuccino with Irish cream flavour.',
    price: 165,
    imagePath: AppAssets.juanValdezCoffee,
    pastelColor: AppColors.pastelLavender,
    category: AppStrings.categoryCoffee,
    highlight: 'Hot · Irish · Creamy',
  );

  static const ProductModel viennaCappuccino = ProductModel(
    id: 'vienna_cappuccino',
    name: 'Vienna Cappuccino',
    description: 'Rich cappuccino topped Vienna-style.',
    price: 180,
    imagePath: AppAssets.signatureCream,
    pastelColor: AppColors.pastelCream,
    category: AppStrings.categoryCoffee,
    highlight: 'Hot · Vienna · Indulgent',
  );

  static const ProductModel flavoredLatte = ProductModel(
    id: 'flavored_latte',
    name: 'Flavored Latte',
    description: 'Latte with vanilla or cinnamon syrup.',
    price: 165,
    imagePath: AppAssets.juanValdezCoffee,
    pastelColor: AppColors.pastelYellow,
    category: AppStrings.categoryCoffee,
    highlight: 'Hot · Vanilla · Cinnamon',
  );

  static const ProductModel chaiLatte = ProductModel(
    id: 'chai_latte',
    name: 'Chai Latte',
    description: 'Spiced chai with steamed milk.',
    price: 180,
    imagePath: AppAssets.signatureCream,
    pastelColor: AppColors.pastelPeach,
    category: AppStrings.categoryCoffee,
    highlight: 'Hot · Spiced · Cozy',
  );

  static const ProductModel hotChocolate = ProductModel(
    id: 'hot_chocolate',
    name: 'Hot Chocolate',
    description: 'Rich melted chocolate with steamed milk.',
    price: 190,
    imagePath: AppAssets.signatureCream,
    pastelColor: AppColors.pastelPink,
    category: AppStrings.categoryCoffee,
    highlight: 'Hot · Chocolate · Comfort',
  );

  static const ProductModel matchaLatte = ProductModel(
    id: 'matcha_latte',
    name: 'Matcha Latte',
    description: 'Ceremonial matcha whisked with steamed milk.',
    price: 140,
    imagePath: AppAssets.blueberryBlend,
    pastelColor: AppColors.pastelMint,
    category: AppStrings.categoryCoffee,
    highlight: 'Hot · Matcha · Earthy',
  );

  static const ProductModel whiteHotChocolate = ProductModel(
    id: 'white_hot_chocolate',
    name: 'White Hot Chocolate',
    description: 'Creamy white chocolate steamed with milk.',
    price: 200,
    imagePath: AppAssets.signatureCream,
    pastelColor: AppColors.pastelCream,
    category: AppStrings.categoryCoffee,
    highlight: 'Hot · White chocolate · Soft',
  );

  static const ProductModel whiteMocha = ProductModel(
    id: 'white_mocha',
    name: 'White Mocha',
    description: 'Espresso with white chocolate and steamed milk.',
    price: 190,
    imagePath: AppAssets.signatureCream,
    pastelColor: AppColors.pastelCream,
    category: AppStrings.categoryCoffee,
    highlight: 'Hot · White mocha · Sweet',
  );

  static const ProductModel filterCoffee = ProductModel(
    id: 'filter_coffee',
    name: 'Filter Coffee',
    description: 'Slow-brewed Colombian filter coffee.',
    price: 140,
    imagePath: AppAssets.juanValdezCoffee,
    pastelColor: AppColors.pastelPeach,
    category: AppStrings.categoryCoffee,
    highlight: 'Hot · Filter · Clean',
  );

  static const ProductModel cortado = ProductModel(
    id: 'cortado',
    name: 'Cortado',
    description: 'Equal parts espresso and steamed milk.',
    price: 120,
    imagePath: AppAssets.juanValdezCoffee,
    pastelColor: AppColors.pastelCream,
    category: AppStrings.categoryCoffee,
    highlight: 'Hot · Balanced · Short',
  );

  static const ProductModel juanValdezCoffee = ProductModel(
    id: 'jv_coffee',
    name: 'Juan Valdez Coffee',
    description:
        '100% Colombian Arabica in our signature cup. Bold, aromatic, and grown by coffee-farming families.',
    price: 85,
    imagePath: AppAssets.juanValdezCoffee,
    pastelColor: AppColors.pastelPeach,
    category: AppStrings.categoryCoffee,
    highlight: 'Bold · Colombian · Classic',
  );

  // ── Cold / Iced ─────────────────────────────────────────────────────────

  static const ProductModel icedLatteProduct = ProductModel(
    id: 'iced_latte',
    name: 'Iced Latte',
    description: 'Espresso over ice with cold milk.',
    price: 130,
    imagePath: AppAssets.icedLatte,
    pastelColor: AppColors.pastelBlue,
    category: AppStrings.categoryIced,
    highlight: 'Iced · Creamy · Classic',
  );

  static const ProductModel icedSpanishLatteProduct = ProductModel(
    id: 'iced_spanish_latte',
    name: 'Iced Spanish Latte',
    description: 'Sweet Spanish latte poured over ice.',
    price: 145,
    imagePath: AppAssets.icedSpanishLatte,
    pastelColor: AppColors.pastelCream,
    category: AppStrings.categoryIced,
    highlight: 'Iced · Sweet · Creamy',
  );

  static const ProductModel icedMocca = ProductModel(
    id: 'iced_mocca',
    name: 'Iced Mocca',
    description: 'Chocolate mocha shaken over ice.',
    price: 150,
    imagePath: AppAssets.signatureCream,
    pastelColor: AppColors.pastelPink,
    category: AppStrings.categoryIced,
    highlight: 'Iced · Chocolate · Rich',
  );

  static const ProductModel caramelNevado = ProductModel(
    id: 'caramel_nevado',
    name: 'Caramel Nevado',
    description: 'Blended caramel drink topped with whipped cream.',
    price: 175,
    imagePath: AppAssets.signatureCream,
    pastelColor: AppColors.pastelYellow,
    category: AppStrings.categoryIced,
    highlight: 'Blended · Caramel · Cream',
  );

  static const ProductModel matchaNevado = ProductModel(
    id: 'matcha_nevado',
    name: 'Matcha Nevado',
    description: 'Blended matcha topped with whipped cream.',
    price: 140,
    imagePath: AppAssets.blueberryBlend,
    pastelColor: AppColors.pastelMint,
    category: AppStrings.categoryIced,
    highlight: 'Blended · Matcha · Fresh',
  );

  static const ProductModel brownieNevado = ProductModel(
    id: 'brownie_nevado',
    name: 'Brownie Nevado',
    description: 'Chocolate brownie blended drink with whipped cream.',
    price: 195,
    imagePath: AppAssets.signatureCream,
    pastelColor: AppColors.pastelPink,
    category: AppStrings.categoryIced,
    highlight: 'Blended · Brownie · Indulgent',
  );

  static const ProductModel chocolateNevado = ProductModel(
    id: 'chocolate_nevado',
    name: 'Chocolate Nevado',
    description: 'Blended chocolate drink with drizzle and cream.',
    price: 175,
    imagePath: AppAssets.signatureCream,
    pastelColor: AppColors.pastelPink,
    category: AppStrings.categoryIced,
    highlight: 'Blended · Chocolate · Cream',
  );

  static const ProductModel coffeeNevado = ProductModel(
    id: 'coffee_nevado',
    name: 'Coffee Nevado',
    description: 'Blended coffee topped with high whipped cream.',
    price: 150,
    imagePath: AppAssets.juanValdezCoffee,
    pastelColor: AppColors.pastelPeach,
    category: AppStrings.categoryIced,
    highlight: 'Blended · Coffee · Cream',
  );

  static const ProductModel arequipeNevado = ProductModel(
    id: 'arequipe_nevado',
    name: 'Arequipe Nevado',
    description: 'Blended arequipe caramel drink with cream.',
    price: 170,
    imagePath: AppAssets.signatureCream,
    pastelColor: AppColors.pastelYellow,
    category: AppStrings.categoryIced,
    highlight: 'Blended · Arequipe · Sweet',
  );

  static const ProductModel icedWhiteMocca = ProductModel(
    id: 'iced_white_mocca',
    name: 'Iced White Mocca',
    description: 'White mocha over ice.',
    price: 150,
    imagePath: AppAssets.signatureCream,
    pastelColor: AppColors.pastelCream,
    category: AppStrings.categoryIced,
    highlight: 'Iced · White mocha · Soft',
  );

  static const ProductModel icedAmericano = ProductModel(
    id: 'iced_americano',
    name: 'Iced Americano',
    description: 'Espresso and water over ice.',
    price: 120,
    imagePath: AppAssets.juanValdezCoffee,
    pastelColor: AppColors.pastelBlue,
    category: AppStrings.categoryIced,
    highlight: 'Iced · Clean · Bold',
  );

  static const ProductModel saltedCaramelLatte = ProductModel(
    id: 'salted_caramel_latte',
    name: 'Salted Caramel Latte',
    description: 'Iced latte with salted caramel.',
    price: 150,
    imagePath: AppAssets.icedSpanishLatte,
    pastelColor: AppColors.pastelYellow,
    category: AppStrings.categoryIced,
    highlight: 'Iced · Salted caramel · Sweet',
  );

  static const ProductModel icedTea = ProductModel(
    id: 'iced_tea',
    name: 'Iced Tea',
    description: 'Refreshing iced tea.',
    price: 110,
    imagePath: AppAssets.blueberryBlend,
    pastelColor: AppColors.pastelMint,
    category: AppStrings.categoryIced,
    highlight: 'Iced · Tea · Light',
  );

  static const ProductModel strawberryFrappe = ProductModel(
    id: 'strawberry_frappe',
    name: 'Strawberry Frappé',
    description:
        'Blended strawberry cream with berry swirl and whipped cream. Sweet, cold, and refreshing.',
    price: 115,
    imagePath: AppAssets.strawberryFrappe,
    pastelColor: AppColors.pastelPink,
    category: AppStrings.categoryIced,
    highlight: 'Berry · Cold · Sweet',
  );

  static const ProductModel blueberryBlend = ProductModel(
    id: 'blueberry_blend',
    name: 'Blueberry Blend',
    description:
        'Vibrant blueberry frozen blend topped with crushed ice and whole blueberries.',
    price: 115,
    imagePath: AppAssets.blueberryBlend,
    pastelColor: AppColors.pastelLavender,
    category: AppStrings.categoryIced,
    highlight: 'Berry · Frozen · Fresh',
  );

  static const ProductModel signatureCream = ProductModel(
    id: 'signature_cream',
    name: 'Signature Cream',
    description:
        'A silky blended cream drink topped with whipped cream — the café Nevado-style favourite.',
    price: 110,
    imagePath: AppAssets.signatureCream,
    pastelColor: AppColors.pastelMint,
    category: AppStrings.categoryIced,
    highlight: 'Creamy · Soft · Signature',
  );

  static const ProductModel orangeJuice = ProductModel(
    id: 'orange_juice',
    name: 'Orange Juice',
    description: 'Fresh-pressed orange juice.',
    price: 70,
    imagePath: AppAssets.blueberryBlend,
    pastelColor: AppColors.pastelYellow,
    category: AppStrings.categoryIced,
    highlight: 'Fresh · Juice · Citrus',
  );

  static const ProductModel mangoJuice = ProductModel(
    id: 'mango_juice',
    name: 'Mango Juice',
    description: 'Fresh mango juice.',
    price: 75,
    imagePath: AppAssets.blueberryBlend,
    pastelColor: AppColors.pastelYellow,
    category: AppStrings.categoryIced,
    highlight: 'Fresh · Juice · Tropical',
  );

  static const ProductModel strawberryJuice = ProductModel(
    id: 'strawberry_juice',
    name: 'Strawberry Juice',
    description: 'Fresh strawberry juice.',
    price: 65,
    imagePath: AppAssets.strawberryFrappe,
    pastelColor: AppColors.pastelPink,
    category: AppStrings.categoryIced,
    highlight: 'Fresh · Juice · Berry',
  );

  // ── Croissant ───────────────────────────────────────────────────────────

  static const ProductModel butterCroissant = ProductModel(
    id: 'butter_croissant',
    name: 'Butter Croissant',
    description: 'Classic flaky butter croissant, golden and layered.',
    price: 100,
    imagePath: AppAssets.butterCroissant,
    pastelColor: AppColors.pastelCream,
    category: AppStrings.categoryCroissant,
    highlight: 'Buttery · Flaky · Classic',
  );

  static const ProductModel mixedCheeseCroissant = ProductModel(
    id: 'mixed_cheese_croissant',
    name: 'Mixed Cheese Croissant',
    description: 'Warm croissant filled with mixed cheese.',
    price: 150,
    imagePath: AppAssets.butterCroissant,
    pastelColor: AppColors.pastelYellow,
    category: AppStrings.categoryCroissant,
    highlight: 'Cheese · Savoury · Warm',
  );

  static const ProductModel zaatarCroissant = ProductModel(
    id: 'zaatar_croissant',
    name: 'Zaatar Croissant',
    description: 'Flaky croissant with aromatic zaatar.',
    price: 110,
    imagePath: AppAssets.butterCroissant,
    pastelColor: AppColors.pastelMint,
    category: AppStrings.categoryCroissant,
    highlight: 'Zaatar · Herby · Savoury',
  );

  static const ProductModel turkeyCheeseCroissant = ProductModel(
    id: 'turkey_cheese_croissant',
    name: 'Turkey and Cheese Croissant',
    description: 'Croissant stuffed with turkey and cheese.',
    price: 155,
    imagePath: AppAssets.butterCroissant,
    pastelColor: AppColors.pastelPeach,
    category: AppStrings.categoryCroissant,
    highlight: 'Turkey · Cheese · Filling',
  );

  static const ProductModel almondCroissant = ProductModel(
    id: 'almond_croissant',
    name: 'Almond Croissant',
    description: 'Sweet almond-filled croissant.',
    price: 160,
    imagePath: AppAssets.raspberryCroissant,
    pastelColor: AppColors.pastelCream,
    category: AppStrings.categoryCroissant,
    highlight: 'Almond · Sweet · Flaky',
  );

  static const ProductModel chocolateCroissant = ProductModel(
    id: 'chocolate_croissant',
    name: 'Chocolate Croissant',
    description: 'Golden croissant drizzled with dark chocolate.',
    price: 140,
    imagePath: AppAssets.chocolateCroissant,
    pastelColor: AppColors.pastelPink,
    category: AppStrings.categoryCroissant,
    highlight: 'Chocolate · Flaky · Sweet',
  );

  static const ProductModel raspberryCroissant = ProductModel(
    id: 'raspberry_croissant',
    name: 'Raspberry Croissant',
    description: 'Croissant with icing drizzle and fresh raspberries.',
    price: 155,
    imagePath: AppAssets.raspberryCroissant,
    pastelColor: AppColors.pastelPink,
    category: AppStrings.categoryCroissant,
    highlight: 'Raspberry · Icing · Fresh',
  );

  // ── Cookies ─────────────────────────────────────────────────────────────

  static const ProductModel chocolateChipCookie = ProductModel(
    id: 'chocolate_chip_cookie',
    name: 'Chocolate Chip Cookie',
    description: 'Soft-baked cookie loaded with chocolate chips.',
    price: 130,
    imagePath: AppAssets.chocolateChipCookie,
    pastelColor: AppColors.pastelPeach,
    category: AppStrings.categoryCookies,
    highlight: 'Chocolate · Soft · Classic',
  );

  static const ProductModel nutellaCookie = ProductModel(
    id: 'nutella_cookie',
    name: 'Nutella or Kinder Cookie',
    description: 'Gourmet cookie with Nutella or Kinder chocolate.',
    price: 120,
    imagePath: AppAssets.nutellaCookie,
    pastelColor: AppColors.pastelYellow,
    category: AppStrings.categoryCookies,
    highlight: 'Nutella · Kinder · Rich',
  );

  static const ProductModel pistachioCookie = ProductModel(
    id: 'pistachio_cookie',
    name: 'Pistachio Cookie',
    description: 'Decadent cookie with pistachio flavour.',
    price: 130,
    imagePath: AppAssets.pistachioCookie,
    pastelColor: AppColors.pastelMint,
    category: AppStrings.categoryCookies,
    highlight: 'Pistachio · Soft · Nutty',
  );

  // ── Food (salads & sandwiches) ──────────────────────────────────────────

  static const ProductModel chickenCaesar = ProductModel(
    id: 'chicken_caesar',
    name: 'Chicken Caesar',
    description: 'Romaine, croutons, parmesan, and grilled chicken.',
    price: 255,
    imagePath: AppAssets.menuChipBreakfast,
    pastelColor: AppColors.pastelMint,
    category: AppStrings.categoryFood,
    highlight: 'Salad · Chicken · Fresh',
  );

  static const ProductModel quinoaTabbouleh = ProductModel(
    id: 'quinoa_tabbouleh',
    name: 'Quinoa Tabbouleh',
    description: 'Light quinoa tabbouleh salad.',
    price: 260,
    imagePath: AppAssets.menuChipBreakfast,
    pastelColor: AppColors.pastelMint,
    category: AppStrings.categoryFood,
    highlight: 'Salad · Quinoa · Fresh',
  );

  static const ProductModel tunaPasta = ProductModel(
    id: 'tuna_pasta',
    name: 'Tuna Pasta',
    description: 'Pasta salad with tuna.',
    price: 265,
    imagePath: AppAssets.menuChipBreakfast,
    pastelColor: AppColors.pastelBlue,
    category: AppStrings.categoryFood,
    highlight: 'Salad · Tuna · Hearty',
  );

  static const ProductModel chickenPestoSalad = ProductModel(
    id: 'chicken_pesto_salad',
    name: 'Chicken Pesto Salad',
    description: 'Chicken salad with pesto dressing.',
    price: 240,
    imagePath: AppAssets.menuChipBreakfast,
    pastelColor: AppColors.pastelMint,
    category: AppStrings.categoryFood,
    highlight: 'Salad · Pesto · Chicken',
  );

  static const ProductModel beansSalad = ProductModel(
    id: 'beans_salad',
    name: 'Beans Salad',
    description: 'Hearty mixed beans salad.',
    price: 265,
    imagePath: AppAssets.menuChipBreakfast,
    pastelColor: AppColors.pastelYellow,
    category: AppStrings.categoryFood,
    highlight: 'Salad · Beans · Filling',
  );

  static const ProductModel turkeyCheeseSandwich = ProductModel(
    id: 'turkey_cheese_sandwich',
    name: 'Turkey and Cheese Sandwich',
    description: 'Turkey and cheese on seeded bread.',
    price: 230,
    imagePath: AppAssets.menuChipBreakfast,
    pastelColor: AppColors.pastelCream,
    category: AppStrings.categoryFood,
    highlight: 'Sandwich · Turkey · Cheese',
  );

  static const ProductModel grilledHalloumi = ProductModel(
    id: 'grilled_halloumi',
    name: 'Grilled Halloumi Sandwich',
    description: 'Grilled halloumi sandwich.',
    price: 220,
    imagePath: AppAssets.menuChipBreakfast,
    pastelColor: AppColors.pastelYellow,
    category: AppStrings.categoryFood,
    highlight: 'Sandwich · Halloumi · Grilled',
  );

  static const ProductModel roastedBeef = ProductModel(
    id: 'roasted_beef',
    name: 'Roasted Beef Sandwich',
    description: 'Roasted beef sandwich.',
    price: 240,
    imagePath: AppAssets.menuChipBreakfast,
    pastelColor: AppColors.pastelPeach,
    category: AppStrings.categoryFood,
    highlight: 'Sandwich · Beef · Hearty',
  );

  static const ProductModel tunaSandwich = ProductModel(
    id: 'tuna_sandwich',
    name: 'Tuna Sandwich',
    description: 'Classic tuna sandwich.',
    price: 230,
    imagePath: AppAssets.menuChipBreakfast,
    pastelColor: AppColors.pastelBlue,
    category: AppStrings.categoryFood,
    highlight: 'Sandwich · Tuna · Classic',
  );

  static const ProductModel spicyChicken = ProductModel(
    id: 'spicy_chicken',
    name: 'Spicy Chicken Sandwich',
    description: 'Spicy chicken sandwich.',
    price: 235,
    imagePath: AppAssets.menuChipBreakfast,
    pastelColor: AppColors.pastelPink,
    category: AppStrings.categoryFood,
    highlight: 'Sandwich · Spicy · Chicken',
  );

  static const ProductModel chickenBbq = ProductModel(
    id: 'chicken_bbq',
    name: 'Chicken BBQ Sandwich',
    description: 'BBQ chicken sandwich.',
    price: 230,
    imagePath: AppAssets.menuChipBreakfast,
    pastelColor: AppColors.pastelPeach,
    category: AppStrings.categoryFood,
    highlight: 'Sandwich · BBQ · Chicken',
  );

  static const ProductModel chickenCaesarSandwich = ProductModel(
    id: 'chicken_caesar_sandwich',
    name: 'Chicken Caesar Sandwich',
    description: 'Chicken Caesar on soft bread.',
    price: 220,
    imagePath: AppAssets.menuChipBreakfast,
    pastelColor: AppColors.pastelMint,
    category: AppStrings.categoryFood,
    highlight: 'Sandwich · Caesar · Chicken',
  );

  static const ProductModel chickenPestoSandwich = ProductModel(
    id: 'chicken_pesto_sandwich',
    name: 'Chicken Pesto Sandwich',
    description: 'Chicken pesto sandwich.',
    price: 245,
    imagePath: AppAssets.menuChipBreakfast,
    pastelColor: AppColors.pastelMint,
    category: AppStrings.categoryFood,
    highlight: 'Sandwich · Pesto · Chicken',
  );

  // ── Desserts ────────────────────────────────────────────────────────────

  static const ProductModel eclairHazelnut = ProductModel(
    id: 'eclair_hazelnut',
    name: 'Éclair Hazelnut',
    description: 'Hazelnut cream éclair.',
    price: 140,
    imagePath: AppAssets.nutellaCookie,
    pastelColor: AppColors.pastelPeach,
    category: AppStrings.categoryDesserts,
    highlight: 'Éclair · Hazelnut · Cream',
  );

  static const ProductModel eclairPistachio = ProductModel(
    id: 'eclair_pistachio',
    name: 'Éclair Pistachio',
    description: 'Pistachio cream éclair.',
    price: 155,
    imagePath: AppAssets.pistachioCookie,
    pastelColor: AppColors.pastelMint,
    category: AppStrings.categoryDesserts,
    highlight: 'Éclair · Pistachio · Cream',
  );

  static const ProductModel plainBrownie = ProductModel(
    id: 'plain_brownie',
    name: 'Plain Brownie',
    description: 'Classic fudgy brownie.',
    price: 140,
    imagePath: AppAssets.pistachioCookie,
    pastelColor: AppColors.pastelPink,
    category: AppStrings.categoryDesserts,
    highlight: 'Brownie · Chocolate · Fudgy',
  );

  static const ProductModel walnutBrownie = ProductModel(
    id: 'walnut_brownie',
    name: 'Walnut Brownie',
    description: 'Brownie studded with walnuts.',
    price: 140,
    imagePath: AppAssets.pistachioCookie,
    pastelColor: AppColors.pastelPeach,
    category: AppStrings.categoryDesserts,
    highlight: 'Brownie · Walnut · Rich',
  );

  static const ProductModel saltedCaramelBrownie = ProductModel(
    id: 'salted_caramel_brownie',
    name: 'Salted Caramel Brownie',
    description: 'Brownie with salted caramel.',
    price: 145,
    imagePath: AppAssets.nutellaCookie,
    pastelColor: AppColors.pastelYellow,
    category: AppStrings.categoryDesserts,
    highlight: 'Brownie · Caramel · Salted',
  );

  static const ProductModel blueberryMuffin = ProductModel(
    id: 'blueberry_muffin',
    name: 'Blueberry Muffin',
    description: 'Soft muffin packed with blueberries.',
    price: 110,
    imagePath: AppAssets.blueberryBlend,
    pastelColor: AppColors.pastelLavender,
    category: AppStrings.categoryDesserts,
    highlight: 'Muffin · Blueberry · Soft',
  );

  static const ProductModel doubleChocolateMuffin = ProductModel(
    id: 'double_chocolate_muffin',
    name: 'Double Chocolate Muffin',
    description: 'Chocolate muffin with chocolate chips.',
    price: 110,
    imagePath: AppAssets.pistachioCookie,
    pastelColor: AppColors.pastelPink,
    category: AppStrings.categoryDesserts,
    highlight: 'Muffin · Chocolate · Double',
  );

  static const ProductModel vanillaMuffin = ProductModel(
    id: 'vanilla_muffin',
    name: 'Vanilla Muffin',
    description: 'Classic vanilla muffin.',
    price: 100,
    imagePath: AppAssets.butterCroissant,
    pastelColor: AppColors.pastelCream,
    category: AppStrings.categoryDesserts,
    highlight: 'Muffin · Vanilla · Soft',
  );

  static const ProductModel carrotCake = ProductModel(
    id: 'carrot_cake',
    name: 'Carrot Cake',
    description: 'Moist carrot cake slice.',
    price: 175,
    imagePath: AppAssets.butterCroissant,
    pastelColor: AppColors.pastelPeach,
    category: AppStrings.categoryDesserts,
    highlight: 'Cake · Carrot · Spiced',
  );

  static const ProductModel chocolateCake = ProductModel(
    id: 'chocolate_cake',
    name: 'Chocolate Cake',
    description: 'Rich chocolate cake slice.',
    price: 215,
    imagePath: AppAssets.pistachioCookie,
    pastelColor: AppColors.pastelPink,
    category: AppStrings.categoryDesserts,
    highlight: 'Cake · Chocolate · Rich',
  );

  static const ProductModel tiramisuCake = ProductModel(
    id: 'tiramisu_cake',
    name: 'Tiramisu Cake',
    description: 'Coffee-soaked tiramisu cake.',
    price: 230,
    imagePath: AppAssets.signatureCream,
    pastelColor: AppColors.pastelCream,
    category: AppStrings.categoryDesserts,
    highlight: 'Cake · Tiramisu · Coffee',
  );

  static const ProductModel blueberryCheesecake = ProductModel(
    id: 'blueberry_cheesecake',
    name: 'Blueberry Cheesecake',
    description: 'Creamy cheesecake with blueberry topping.',
    price: 200,
    imagePath: AppAssets.blueberryBlend,
    pastelColor: AppColors.pastelLavender,
    category: AppStrings.categoryDesserts,
    highlight: 'Cheesecake · Blueberry · Creamy',
  );

  static const ProductModel nutellaCheesecake = ProductModel(
    id: 'nutella_cheesecake',
    name: 'Nutella Cheesecake',
    description: 'Cheesecake swirled with Nutella.',
    price: 210,
    imagePath: AppAssets.nutellaCookie,
    pastelColor: AppColors.pastelPeach,
    category: AppStrings.categoryDesserts,
    highlight: 'Cheesecake · Nutella · Rich',
  );

  static const ProductModel pistachioCheesecake = ProductModel(
    id: 'pistachio_cheesecake',
    name: 'Pistachio Cheesecake',
    description: 'Cheesecake with pistachio cream.',
    price: 250,
    imagePath: AppAssets.pistachioCookie,
    pastelColor: AppColors.pastelMint,
    category: AppStrings.categoryDesserts,
    highlight: 'Cheesecake · Pistachio · Creamy',
  );

  /// Kept for older widgets that still reference product catalogue fields.
  static const List<ProductModel> juan_valdez = [
    juanValdezCoffee,
    signatureCream,
    strawberryFrappe,
    blueberryBlend,
  ];

  static const ProductModel icedSpanishLatte = icedSpanishLatteProduct;
  static const ProductModel icedLatte = icedLatteProduct;
  static const ProductModel icedColdFoam = strawberryFrappe;
  static const ProductModel icedMatchaLatte = matchaNevado;
  static const ProductModel coldBrew = icedAmericano;
  static const ProductModel breakfastWrap = turkeyCheeseSandwich;

  static List<ProductModel> get allProducts => [
        // Coffee
        americano,
        cappuccino,
        espresso,
        espressoMacchiato,
        flatWhite,
        latte,
        mocca,
        spanishLatte,
        arequipeCappuccino,
        irishCappuccino,
        viennaCappuccino,
        flavoredLatte,
        chaiLatte,
        hotChocolate,
        matchaLatte,
        whiteHotChocolate,
        whiteMocha,
        filterCoffee,
        cortado,
        juanValdezCoffee,
        // Cold
        icedLatteProduct,
        icedSpanishLatteProduct,
        icedMocca,
        caramelNevado,
        matchaNevado,
        brownieNevado,
        chocolateNevado,
        coffeeNevado,
        arequipeNevado,
        icedWhiteMocca,
        icedAmericano,
        saltedCaramelLatte,
        icedTea,
        strawberryFrappe,
        blueberryBlend,
        signatureCream,
        orangeJuice,
        mangoJuice,
        strawberryJuice,
        // Croissant
        butterCroissant,
        mixedCheeseCroissant,
        zaatarCroissant,
        turkeyCheeseCroissant,
        almondCroissant,
        chocolateCroissant,
        raspberryCroissant,
        // Cookies
        chocolateChipCookie,
        nutellaCookie,
        pistachioCookie,
        // Food
        chickenCaesar,
        quinoaTabbouleh,
        tunaPasta,
        chickenPestoSalad,
        beansSalad,
        turkeyCheeseSandwich,
        grilledHalloumi,
        roastedBeef,
        tunaSandwich,
        spicyChicken,
        chickenBbq,
        chickenCaesarSandwich,
        chickenPestoSandwich,
        // Desserts
        eclairHazelnut,
        eclairPistachio,
        plainBrownie,
        walnutBrownie,
        saltedCaramelBrownie,
        blueberryMuffin,
        doubleChocolateMuffin,
        vanillaMuffin,
        carrotCake,
        chocolateCake,
        tiramisuCake,
        blueberryCheesecake,
        nutellaCheesecake,
        pistachioCheesecake,
      ];

  static List<ProductModel> get trending => [
        butterCroissant,
        chocolateChipCookie,
        chocolateCroissant,
        nutellaCookie,
        raspberryCroissant,
        pistachioCookie,
      ];

  static ProductModel get pickedForYou => chocolateCroissant;

  static ProductModel get signaturePastry => butterCroissant;

  static List<CartItemModel> get usualOrder => [
        const CartItemModel(product: butterCroissant, quantity: 1),
        const CartItemModel(product: chocolateChipCookie, quantity: 1),
      ];

  static double get usualOrderTotal =>
      usualOrder.fold(0.0, (sum, item) => sum + item.lineTotal);

  static List<ProductModel> byCategory(String category) {
    switch (category) {
      case AppStrings.categoryCoffee:
      case AppStrings.exploreHotDrinks:
        return allProducts
            .where((p) => p.category == AppStrings.categoryCoffee)
            .toList(growable: false);
      case AppStrings.categoryIced:
      case AppStrings.exploreIcedDrinks:
      case AppStrings.exploreFrozenDrinks:
        return allProducts
            .where((p) => p.category == AppStrings.categoryIced)
            .toList(growable: false);
      case AppStrings.categoryCroissant:
      case AppStrings.exploreCroissant:
        return allProducts
            .where((p) => p.category == AppStrings.categoryCroissant)
            .toList(growable: false);
      case AppStrings.categoryCookies:
      case AppStrings.exploreCookies:
        return allProducts
            .where((p) => p.category == AppStrings.categoryCookies)
            .toList(growable: false);
      case AppStrings.categoryFood:
      case AppStrings.categoryBreakfast:
      case AppStrings.exploreCombos:
        return allProducts
            .where((p) => p.category == AppStrings.categoryFood)
            .toList(growable: false);
      case AppStrings.categoryDesserts:
      case AppStrings.categorySignature:
      case AppStrings.exploreSignature:
      case AppStrings.exploreSpecialOffers:
        return allProducts
            .where((p) =>
                p.category == AppStrings.categoryDesserts ||
                p.category == AppStrings.categoryCookies)
            .toList(growable: false);
      default:
        return allProducts;
    }
  }

  static ProductModel byId(String id) {
    return allProducts.firstWhere(
      (d) => d.id == id,
      orElse: () => juanValdezCoffee,
    );
  }

  static List<ProductModel> pairsWellWith(ProductModel product) {
    final isCoffeeDrink = product.category == AppStrings.categoryCoffee ||
        product.category == AppStrings.categoryIced;
    final isBakery = product.category == AppStrings.categoryCookies ||
        product.category == AppStrings.categoryCroissant;

    // Coffee / cold drinks → cookies & croissants.
    if (isCoffeeDrink) {
      const bakeryIds = [
        'chocolate_chip_cookie',
        'butter_croissant',
        'pistachio_cookie',
        'chocolate_croissant',
        'nutella_cookie',
        'raspberry_croissant',
      ];
      return bakeryIds
          .map(byId)
          .where((d) => d.id != product.id)
          .take(3)
          .toList(growable: false);
    }

    // Cookies / croissants → coffee.
    if (isBakery) {
      const coffeeIds = [
        'americano',
        'latte',
        'cappuccino',
        'jv_coffee',
        'iced_latte',
      ];
      return coffeeIds
          .map(byId)
          .where((d) => d.id != product.id)
          .take(3)
          .toList(growable: false);
    }

    return allProducts
        .where((d) => d.id != product.id && d.category != product.category)
        .take(3)
        .toList(growable: false);
  }

  static StoreModel storeById(String id) {
    return stores.firstWhere(
      (s) => s.id == id,
      orElse: () => defaultStore,
    );
  }

  static const StoreModel defaultStore = StoreModel(
    id: 'zamalek',
    name: 'Juan Valdez Zamalek',
    distanceKm: 0.6,
    status: 'Open',
    readyInMinutes: 6,
    latitude: 30.0626,
    longitude: 31.2197,
    isOpen: true,
    hours: '07:00 AM – 12:00 AM',
    supportsDineIn: true,
    address: 'Zamalek, Cairo',
  );

  static const List<StoreModel> stores = [
    defaultStore,
    StoreModel(
      id: 'new_cairo',
      name: 'Juan Valdez New Cairo',
      distanceKm: 2.4,
      status: 'Open',
      readyInMinutes: 8,
      latitude: 30.0074,
      longitude: 31.4913,
      isOpen: true,
      hours: '07:00 AM – 12:00 AM',
      supportsDineIn: true,
      address: 'New Cairo',
    ),
    StoreModel(
      id: 'maadi',
      name: 'Juan Valdez Maadi',
      distanceKm: 3.1,
      status: 'Open',
      readyInMinutes: 10,
      latitude: 29.9602,
      longitude: 31.2569,
      isOpen: true,
      hours: '07:00 AM – 11:00 PM',
      supportsDineIn: true,
      address: 'Maadi, Cairo',
    ),
    StoreModel(
      id: 'alex',
      name: 'Juan Valdez Alexandria',
      distanceKm: 180,
      status: 'Closed',
      readyInMinutes: 15,
      latitude: 31.2001,
      longitude: 29.9187,
      isOpen: false,
      hours: '08:00 AM – 11:00 PM',
      supportsDineIn: true,
      address: 'Alexandria',
    ),
  ];
}

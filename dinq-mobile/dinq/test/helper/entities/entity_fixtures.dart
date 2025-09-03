import 'package:dinq/features/dinq/restaurant_management/domain/entities/category.dart';
import 'package:dinq/features/dinq/restaurant_management/domain/entities/item.dart';
import 'package:dinq/features/dinq/restaurant_management/domain/entities/menu.dart';
import 'package:dinq/features/dinq/restaurant_management/domain/entities/restaurant.dart';
import 'package:dinq/features/dinq/restaurant_management/domain/entities/review.dart';
import 'package:dinq/features/dinq/restaurant_management/domain/entities/tab.dart';

class RestaurantFixtures {
  static const tId = 'restaurant_1';
  static const tName = 'Mama\'s Kitchen';
  static const tDescription = 'Authentic Ethiopian cuisine';
  static const tAddress = '123 Addis Ababa St';
  static const tPhone = '+251911123456';
  static const tEmail = 'mamas@example.com';
  static const tImage = 'mamas_kitchen.jpg';
  static const tIsActive = true;

  static const tRestaurant = Restaurant(
    id: tId,
    name: tName,
    description: tDescription,
    address: tAddress,
    phone: tPhone,
    email: tEmail,
    image: tImage,
    isActive: tIsActive,
  );

  static const tInactiveRestaurant = Restaurant(
    id: 'restaurant_2',
    name: 'Closed Restaurant',
    description: 'Temporarily closed',
    address: '456 Bole Rd',
    phone: '+251922654321',
    email: 'closed@example.com',
    image: 'closed.jpg',
    isActive: false,
  );

  static final tRestaurantList = [tRestaurant, tInactiveRestaurant];

  static final tLargeRestaurantList = List.generate(
    100,
    (index) => Restaurant(
      id: 'restaurant_$index',
      name: 'Restaurant $index',
      description: 'Description $index',
      address: 'Address $index',
      phone: '+251911${100000 + index}',
      email: 'restaurant$index@example.com',
      image: 'restaurant_$index.jpg',
      isActive: true,
    ),
  );
}

/// Test fixtures for Menu entities
class MenuFixtures {
  static const tId = 'menu_1';
  static const tRestaurantId = 'restaurant_1';
  static const tIsPublished = true;
  static const tViewCount = 500;

  static final tMenu = Menu(
    id: tId,
    restaurantId: tRestaurantId,
    isPublished: tIsPublished,
    tabs: TabFixtures.tTabList,
    viewCount: tViewCount,
  );

  static final tEmptyMenu = const Menu(
    id: 'menu_2',
    restaurantId: tRestaurantId,
    isPublished: true,
    tabs: [],
    viewCount: 0,
  );

  static final tUnpublishedMenu = Menu(
    id: 'menu_3',
    restaurantId: tRestaurantId,
    isPublished: false,
    tabs: TabFixtures.tTabList,
    viewCount: tViewCount,
  );

  static final tPopularMenu = Menu(
    id: 'menu_4',
    restaurantId: tRestaurantId,
    isPublished: true,
    tabs: TabFixtures.tTabList,
    viewCount: 999999,
  );

  static final tComplexMenu = Menu(
    id: 'menu_5',
    restaurantId: tRestaurantId,
    isPublished: true,
    tabs: List.generate(
      5,
      (tabIndex) => Tab(
        id: 'tab_$tabIndex',
        menuId: 'menu_5',
        name: 'Tab $tabIndex',
        nameAm: 'ታብ $tabIndex',
        categories: List.generate(
          3,
          (categoryIndex) => Category(
            id: 'category_${tabIndex}_$categoryIndex',
            tabId: 'tab_$tabIndex',
            name: 'Category $categoryIndex',
            nameAm: 'ክፍል $categoryIndex',
            items: List.generate(
              2,
              (itemIndex) => Item(
                id: 'item_${tabIndex}_${categoryIndex}_$itemIndex',
                name: 'Item $itemIndex',
                nameAm: 'ንጥል $itemIndex',
                slug: 'item-$itemIndex',
                categoryId: 'category_${tabIndex}_$categoryIndex',
                price: 100 + itemIndex * 50,
                currency: 'ETB',
                viewCount: 10,
                averageRating: 4.0,
                reviewIds: const [],
              ),
            ),
          ),
        ),
        isDeleted: false,
      ),
    ),
    viewCount: 1000,
  );
}

/// Test fixtures for Tab entities
class TabFixtures {
  static const tId = 'tab_1';
  static const tMenuId = 'menu_1';
  static const tName = 'Main Course';
  static const tNameAm = 'ለውጥ';
  static const tIsDeleted = false;

  static final tTab = Tab(
    id: tId,
    menuId: tMenuId,
    name: tName,
    nameAm: tNameAm,
    categories: CategoryFixtures.tCategoryList,
    isDeleted: tIsDeleted,
  );

  static final tDeletedTab = const Tab(
    id: 'tab_2',
    menuId: tMenuId,
    name: 'Deleted Tab',
    nameAm: 'የተሰረዘ ታብ',
    categories: [],
    isDeleted: true,
  );

  static final tEmptyTab = const Tab(
    id: 'tab_3',
    menuId: tMenuId,
    name: 'Empty Tab',
    nameAm: 'ባዶ ታብ',
    categories: [],
    isDeleted: false,
  );

  static final tTabList = [tTab, tDeletedTab];
}

/// Test fixtures for Category entities
class CategoryFixtures {
  static const tId = 'category_1';
  static const tTabId = 'tab_1';
  static const tName = 'Meat Dishes';
  static const tNameAm = 'የስጋ ምግቦች';

  static final tCategory = Category(
    id: tId,
    tabId: tTabId,
    name: tName,
    nameAm: tNameAm,
    items: ItemFixtures.tItemList,
  );

  static final tEmptyCategory = const Category(
    id: 'category_2',
    tabId: tTabId,
    name: 'Empty Category',
    nameAm: 'ባዶ ክፍል',
    items: [],
  );

  static final tVegetarianCategory = Category(
    id: 'category_3',
    tabId: tTabId,
    name: 'Vegetarian Dishes',
    nameAm: 'አትክልት ምግቦች',
    items: [ItemFixtures.tVegetarianItem],
  );
  static final tEmptyCategoryList = [] as List<Category>;
  static final tCategoryList = [tCategory, tVegetarianCategory];
}

/// Test fixtures for Item entities
class ItemFixtures {
  static const tId = 'item_1';
  static const tName = 'Doro Wat';
  static const tNameAm = 'ዶሮ ዋት';
  static const tSlug = 'doro-wat';
  static const tCategoryId = 'category_1';
  static const tDescription = 'Spicy chicken stew';
  static const tDescriptionAm = 'ተጨናነቀ የዶሮ ምግብ';
  static const tImage = ['doro_wat.jpg'];
  static const tPrice = 250;
  static const tCurrency = 'ETB';
  static const tAllergies = ['spicy'];
  static const tUserImages = [];
  static const tCalories = 450;
  static const tIngredients = ['chicken', 'berbere', 'onions'];
  static const tIngredientsAm = ['ዶሮ', 'በርበረ', 'ሽንኩርት'];
  static const tPreparationTime = 45;
  static const tHowToEat = 'Eat with injera';
  static const tHowToEatAm = 'ከእንጀራ ጋር ብላ';
  static const tViewCount = 150;
  static const tAverageRating = 4.5;
  static const tReviewIds = ['review_1', 'review_2'];

  static final tItem = const Item(
    id: tId,
    name: tName,
    nameAm: tNameAm,
    slug: tSlug,
    categoryId: tCategoryId,
    description: tDescription,
    descriptionAm: tDescriptionAm,
    image: tImage,
    price: tPrice,
    currency: tCurrency,
    allergies: tAllergies,
    userImages: tUserImages,
    calories: tCalories,
    ingredients: tIngredients,
    ingredientsAm: tIngredientsAm,
    preparationTime: tPreparationTime,
    howToEat: tHowToEat,
    howToEatAm: tHowToEatAm,
    viewCount: tViewCount,
    averageRating: tAverageRating,
    reviewIds: tReviewIds,
  );

  static final tTibsItem = const Item(
    id: 'item_2',
    name: 'Tibs',
    nameAm: 'ቲብስ',
    slug: 'tibs',
    categoryId: tCategoryId,
    description: 'Sautéed meat with vegetables',
    descriptionAm: 'ከእንስሳት ስጋ ጋር የተለበሰበት እንስሳት ስጋ',
    image: ['tibs.jpg'],
    price: 200,
    currency: 'ETB',
    allergies: [],
    userImages: [],
    calories: 380,
    ingredients: ['beef', 'onions', 'peppers'],
    ingredientsAm: ['ስጋ', 'ሽንኩርት', 'ቃሪ ቦታ'],
    preparationTime: 30,
    howToEat: 'Eat with injera',
    howToEatAm: 'ከእንጀራ ጋር ብላ',
    viewCount: 120,
    averageRating: 4.2,
    reviewIds: ['review_3'],
  );

  static final tVegetarianItem = const Item(
    id: 'item_3',
    name: 'Misir Wat',
    nameAm: 'ምስር ዋት',
    slug: 'misir-wat',
    categoryId: 'category_3',
    description: 'Spicy red lentil stew',
    descriptionAm: 'ተጨናነቀ ቀይ ምስር ምግብ',
    image: ['misir_wat.jpg'],
    price: 150,
    currency: 'ETB',
    allergies: ['spicy'],
    userImages: [],
    calories: 320,
    ingredients: ['red lentils', 'berbere', 'onions'],
    ingredientsAm: ['ቀይ ምስር', 'በርበረ', 'ሽንኩርት'],
    preparationTime: 40,
    howToEat: 'Eat with injera',
    howToEatAm: 'ከእንጀራ ጋር ብላ',
    viewCount: 100,
    averageRating: 4.3,
    reviewIds: ['review_4', 'review_5'],
  );

  static final tItemList = [tItem, tTibsItem];
}

// fixtures for review

class ReviewFixtures {
  static const tId = '123';
  static const tUserId = 'user_1';
  static const tUserName = 'John Doe';
  static const tUserAvatar = 'avatar.jpg';
  static const tRating = 4.5;
  static const tComment = 'Great food!';
  static const tImages = ['review_img1.jpg', 'review_img2.jpg'];
  static const tLike = 10;
  static const tDisLike = 2;
  static final DateTime tCreatedAt = DateTime.parse('2024-06-01T12:00:00Z');

  static const tItemId = 'item_1';
  static final tReview = Review(
    id: tId,
    itemId: tItemId,
    userId: tUserId,
    userName: tUserName,
    userAvatar: tUserAvatar,
    rating: tRating,
    comment: tComment,
    images: tImages,
    like: tLike,
    disLike: tDisLike,
    createdAt: tCreatedAt,
  );
  static final tReviews = List.generate(
    5,
    (index) => Review(
      id: '$tId$index',
      itemId: '$tItemId$index',
      userId: tUserId,
      userName: tUserName,
      userAvatar: tUserAvatar,
      rating: tRating,
      comment: tComment,
      images: tImages,
      like: index + 10,
      disLike: index,
      createdAt: tCreatedAt, 
    ),
  );
}

import 'dart:convert';

/// Demo API responses for restaurant management
/// This file provides mock data that matches our models for development/testing
class DemoApiResponses {
  // Demo restaurant data
  static const String restaurantsResponse = '''
[
  {
    "id": "rest_001",
    "name": "Mama's Kitchen",
    "description": "Authentic Ethiopian cuisine with modern twist",
    "address": "123 Addis Ababa Street, Bole",
    "phone": "+251911123456",
    "email": "contact@mamas-kitchen.et",
    "image": "https://example.com/restaurant1.jpg",
    "isActive": true
  },
  {
    "id": "rest_002",
    "name": "Habesha Delight",
    "description": "Traditional Ethiopian dishes served with love",
    "address": "456 Kazanchis Avenue, Piazza",
    "phone": "+251922654321",
    "email": "info@habesha-delight.et",
    "image": "https://example.com/restaurant2.jpg",
    "isActive": true
  },
  {
    "id": "rest_003",
    "name": "DineQ Express",
    "description": "Quick and delicious meals for busy professionals",
    "address": "789 Bole Medhanealem, CMC",
    "phone": "+251933789012",
    "email": "orders@dineq-express.et",
    "image": "https://example.com/restaurant3.jpg",
    "isActive": false
  }
]
''';

  // Demo menu data
  static const String menuResponse = '''
{
  "id": "menu_001",
  "restaurantId": "rest_001",
  "isPublished": true,
  "tabs": [
    {
      "id": "tab_001",
      "menuId": "menu_001",
      "name": "Main Courses",
      "nameAm": "ዋና ምግቦች",
      "categories": [
        {
          "id": "cat_001",
          "tabId": "tab_001",
          "name": "Traditional Dishes",
          "nameAm": "ለምድ ምግቦች",
          "items": [
            {
              "id": "item_001",
              "name": "Doro Wat",
              "nameAm": "ዶሮ ዋት",
              "slug": "doro-wat",
              "categoryId": "cat_001",
              "description": "Spicy chicken stew with berbere sauce",
              "descriptionAm": "በበርበረ ሶስ የተሰራ ያልተለመደ የዶሮ ምግብ",
              "image": ["https://example.com/doro-wat.jpg"],
              "price": 250,
              "currency": "ETB",
              "allergies": ["spicy"],
              "userImages": [],
              "calories": 450,
              "ingredients": ["chicken", "onion", "garlic", "berbere", "butter"],
              "ingredientsAm": ["ዶሮ", "ሽንኩርት", "ነጭ ሽንኩርት", "በርበረ", "ቅቤ"],
              "preparationTime": 45,
              "howToEat": "Eat with injera",
              "howToEatAm": "ከእንጀራ ጋር ብላ",
              "viewCount": 1250,
              "averageRating": 4.5,
              "reviewIds": ["rev_001", "rev_002"]
            },
            {
              "id": "item_002",
              "name": "Tibs",
              "nameAm": "ቲብስ",
              "slug": "tibs",
              "categoryId": "cat_001",
              "description": "Sautéed beef with vegetables",
              "descriptionAm": "ከእህል ጋር የተለለለ ሥጋ",
              "image": ["https://example.com/tibs.jpg"],
              "price": 200,
              "currency": "ETB",
              "allergies": [],
              "userImages": [],
              "calories": 380,
              "ingredients": ["beef", "onion", "green pepper", "tomato"],
              "ingredientsAm": ["ሥጋ", "ሽንኩርት", "ቅንጣት በርበረ", "ቲማቲም"],
              "preparationTime": 25,
              "howToEat": "Enjoy with injera",
              "howToEatAm": "ከእንጀራ ጋር አለግለግ",
              "viewCount": 890,
              "averageRating": 4.2,
              "reviewIds": ["rev_003"]
            }
          ]
        },
        {
          "id": "cat_002",
          "tabId": "tab_001",
          "name": "Vegetarian Options",
          "nameAm": "አትክልት ምግቦች",
          "items": [
            {
              "id": "item_003",
              "name": "Misir Wat",
              "nameAm": "ምስር ዋት",
              "slug": "misir-wat",
              "categoryId": "cat_002",
              "description": "Spicy red lentil stew",
              "descriptionAm": "በበርበረ ሶስ የተሰራ ምስር ምግብ",
              "image": ["https://example.com/misir-wat.jpg"],
              "price": 120,
              "currency": "ETB",
              "allergies": ["spicy"],
              "userImages": [],
              "calories": 280,
              "ingredients": ["red lentils", "onion", "garlic", "berbere", "tomato"],
              "ingredientsAm": ["ቀይ ምስር", "ሽንኩርት", "ነጭ ሽንኩርት", "በርበረ", "ቲማቲም"],
              "preparationTime": 30,
              "howToEat": "Serve with injera",
              "howToEatAm": "ከእንጀራ ጋር አቅርብ",
              "viewCount": 650,
              "averageRating": 4.3,
              "reviewIds": ["rev_004"]
            }
          ]
        }
      ],
      "isDeleted": false
    },
    {
      "id": "tab_002",
      "menuId": "menu_001",
      "name": "Beverages",
      "nameAm": "መጠጦች",
      "categories": [
        {
          "id": "cat_003",
          "tabId": "tab_002",
          "name": "Hot Drinks",
          "nameAm": "ለውጥ መጠጦች",
          "items": [
            {
              "id": "item_004",
              "name": "Ethiopian Coffee",
              "nameAm": "የኢትዮጵያ ቡና",
              "slug": "ethiopian-coffee",
              "categoryId": "cat_003",
              "description": "Freshly roasted Ethiopian coffee",
              "descriptionAm": "ቀሪ የተለለለ የኢትዮጵያ ቡና",
              "image": ["https://example.com/coffee.jpg"],
              "price": 50,
              "currency": "ETB",
              "allergies": [],
              "userImages": [],
              "calories": 5,
              "ingredients": ["coffee beans", "water"],
              "ingredientsAm": ["ቡና ቅንጣቶች", "ውሃ"],
              "preparationTime": 10,
              "howToEat": "Sip slowly and enjoy",
              "howToEatAm": "በያዘ ብላ እና አለግለግ",
              "viewCount": 420,
              "averageRating": 4.8,
              "reviewIds": ["rev_005"]
            }
          ]
        }
      ],
      "isDeleted": false
    }
  ],
  "viewCount": 2500
}
''';

  // Demo categories data
  static const String categoriesResponse = '''
[
  {
    "id": "cat_001",
    "tabId": "tab_001",
    "name": "Traditional Dishes",
    "nameAm": "ለምድ ምግቦች",
    "items": [
      {
        "id": "item_001",
        "name": "Doro Wat",
        "nameAm": "ዶሮ ዋት",
        "slug": "doro-wat",
        "categoryId": "cat_001",
        "description": "Spicy chicken stew with berbere sauce",
        "descriptionAm": "በበርበረ ሶስ የተሰራ ያልተለመደ የዶሮ ምግብ",
        "image": ["https://example.com/doro-wat.jpg"],
        "price": 250,
        "currency": "ETB",
        "allergies": ["spicy"],
        "userImages": [],
        "calories": 450,
        "ingredients": ["chicken", "onion", "garlic", "berbere", "butter"],
        "ingredientsAm": ["ዶሮ", "ሽንኩርት", "ነጭ ሽንኩርት", "በርበረ", "ቅቤ"],
        "preparationTime": 45,
        "howToEat": "Eat with injera",
        "howToEatAm": "ከእንጀራ ጋር ብላ",
        "viewCount": 1250,
        "averageRating": 4.5,
        "reviewIds": ["rev_001", "rev_002"]
      }
    ]
  }
]
''';

  // Demo reviews data
  static const String reviewsResponse = '''
[
  {
    "id": "rev_001",
    "itemId": "item_1",
    "userId": "user_001",
    "userName": "Abebe Kebede",
    "userAvatar": "https://example.com/avatar1.jpg",
    "rating": 5.0,
    "comment": "Absolutely delicious! The Doro Wat was perfectly spiced and the injera was fresh.",
    "images": ["https://example.com/review1.jpg"],
    "like": 12,
    "disLike": 0,
    "createdAt": "2024-01-15T14:30:00Z"
  },
  {
    "id": "rev_002",
    "itemId": "item_2",s
    "userId": "user_002",
    "userName": "Tigist Haile",
    "userAvatar": "https://example.com/avatar2.jpg",
    "rating": 4.0,
    "comment": "Great food and service. Would recommend to friends.",
    "images": [],
    "like": 8,
    "disLike": 1,
    "createdAt": "2024-01-10T12:15:00Z"
  }
]
''';

  // Demo user images data
  static const String userImagesResponse = '''
[
  "https://example.com/user-image1.jpg",
  "https://example.com/user-image2.jpg",
  "https://example.com/user-image3.jpg"
]
''';

  // Demo update responses
  static const String updateRestaurantResponse = '''
{
  "id": "rest_001",
  "name": "Mama's Kitchen Updated",
  "description": "Authentic Ethiopian cuisine with modern twist - Updated",
  "address": "123 Addis Ababa Street, Bole",
  "phone": "+251911123456",
  "email": "contact@mamas-kitchen.et",
  "image": "https://example.com/restaurant1.jpg",
  "isActive": true
}
''';

  static const String updateItemResponse = '''
{
  "id": "item_001",
  "name": "Doro Wat Updated",
  "nameAm": "ዶሮ ዋት የተሻሻለ",
  "slug": "doro-wat",
  "categoryId": "cat_001",
  "description": "Spicy chicken stew with berbere sauce - Updated recipe",
  "descriptionAm": "በበርበረ ሶስ የተሰራ ያልተለመደ የዶሮ ምግብ - የተሻሻለ የምግብ ምዝገባ",
  "image": ["https://example.com/doro-wat-updated.jpg"],
  "price": 270,
  "currency": "ETB",
  "allergies": ["spicy"],
  "userImages": [],
  "calories": 450,
  "ingredients": ["chicken", "onion", "garlic", "berbere", "butter", "special spice"],
  "ingredientsAm": ["ዶሮ", "ሽንኩርት", "ነጭ ሽንኩርት", "በርበረ", "ቅቤ", "ልዩ ቅመም"],
  "preparationTime": 45,
  "howToEat": "Eat with injera",
  "howToEatAm": "ከእንጀራ ጋር ብላ",
  "viewCount": 1250,
  "averageRating": 4.5,
  "reviewIds": ["rev_001", "rev_002"]
}
''';

  /// Get demo response based on endpoint
  static String getDemoResponse(String endpoint) {
    if (endpoint.contains('/restaurants') && !endpoint.contains('/menu')) {
      if (endpoint.contains('PUT') || endpoint.contains('PATCH')) {
        return updateRestaurantResponse;
      }
      return restaurantsResponse;
    } else if (endpoint.contains('/menu')) {
      return menuResponse;
    } else if (endpoint.contains('/categories')) {
      return categoriesResponse;
    } else if (endpoint.contains('/reviews')) {
      return reviewsResponse;
    } else if (endpoint.contains('/images')) {
      return userImagesResponse;
    } else if (endpoint.contains('PUT') && endpoint.contains('/items/')) {
      return updateItemResponse;
    }

    // Default response for unknown endpoints
    return '{"message": "Demo endpoint not found"}';
  }

  /// Parse JSON response to Map
  static Map<String, dynamic> parseResponse(String response) {
    return json.decode(response) as Map<String, dynamic>;
  }

  /// Parse JSON array response to List
  static List<dynamic> parseResponseList(String response) {
    return json.decode(response) as List<dynamic>;
  }
}

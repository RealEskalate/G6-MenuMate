/*
  DineQ realistic full seed (mongosh)
  Usage:
    mongosh "mongodb://localhost:27017/dineq_db" --file seeds/realistic_full_seed.mongosh.js

  Notes:
  - This script wipes and reseeds the primary collections used by the backend.
  - Values are intentionally realistic (restaurants, menus, dishes, reviews, reactions, analytics events).
  - Image URLs are high-quality public URLs (Unsplash/Pexels style links).
*/

(function seedDineQ() {
  const DB_NAME = db.getName();
  print(`\n▶ Seeding database: ${DB_NAME}`);

  const COLLECTIONS = {
    users: "users",
    restaurants: "restaurants",
    menus: "menus",
    items: "items",
    reviews: "review",
    reactions: "reaction",
    qr: "qr",
    views: "views",
  };

  const now = new Date();
  const hoursAgo = (h) => new Date(now.getTime() - h * 60 * 60 * 1000);
  const daysAgo = (d) => new Date(now.getTime() - d * 24 * 60 * 60 * 1000);

  // bcrypt hash for a common demo password ("password123")
  const DEMO_PASSWORD_HASH =
    "$2a$10$Nipb55h8rHxZnJuBxcWWeemPnIwRtiZhyDsZkrh4wBNZYqQ9wAfMW";

  const svgToDataUri = (svg) =>
    `data:image/svg+xml;utf8,${encodeURIComponent(svg)}`;

  const queryPhoto = (w, h, query, seed) =>
    `https://source.unsplash.com/${w}x${h}/?${encodeURIComponent(query)}&sig=${seed}`;

  const coverPhoto = (seed, query) =>
    queryPhoto(
      1800,
      1000,
      `${query}, modern elegant restaurant interior, dining, addis ababa`,
      seed,
    );

  // More accurate food images (Ethiopian plating, professional style)
  const dishPhoto = (seed, query) =>
    queryPhoto(
      1400,
      1000,
      `${query}, ethiopian cuisine, injera, professional food photography`,
      seed,
    );

  const makeAvatar = (firstName, lastName, seed) => {
    const palettes = [
      ["#355E3B", "#C9A227"],
      ["#7A3E1D", "#C58A4A"],
      ["#5B3A29", "#D9A441"],
      ["#254E70", "#7FA1C3"],
      ["#6D597A", "#B56576"],
      ["#2F5233", "#D6AD60"],
      ["#4A2C2A", "#B5651D"],
      ["#7F5539", "#D4A373"],
    ];
    const [bg, accent] = palettes[seed % palettes.length];
    const initials =
      `${(firstName || "?").trim().slice(0, 1)}${(lastName || "").trim().slice(0, 1)}`
        .toUpperCase()
        .replace(/[^A-Z]/g, "");
    const safeInitials = initials.length ? initials : "DQ";
    return svgToDataUri(`
      <svg xmlns="http://www.w3.org/2000/svg" width="400" height="400" viewBox="0 0 400 400">
        <defs>
          <linearGradient id="a" x1="0" y1="0" x2="1" y2="1">
            <stop offset="0%" stop-color="${bg}" />
            <stop offset="100%" stop-color="${accent}" />
          </linearGradient>
        </defs>
        <rect width="400" height="400" rx="84" fill="url(#a)"/>
        <circle cx="200" cy="160" r="72" fill="rgba(255,255,255,0.18)"/>
        <path d="M120 330c20-52 62-84 80-84s60 32 80 84" fill="rgba(255,255,255,0.16)"/>
        <text x="200" y="230" text-anchor="middle" font-family="Arial, Helvetica, sans-serif" font-size="110" font-weight="700" fill="#ffffff">
          ${safeInitials}
        </text>
      </svg>
    `);
  };

  const photo = {
    coverFallbacks: [
      coverPhoto(1, "ethiopian restaurant dining"),
      coverPhoto(2, "addis ababa coffee house"),
      coverPhoto(3, "ethiopian grill tibs"),
      coverPhoto(4, "modern addis restaurant"),
    ],
  };

  const ethiopianTraditionalItems = [
    {
      name: "Doro Wot",
      am: "ዶሮ ወጥ",
      price: 420,
      tags: ["Traditional", "Lunch", "Signature"],
      kcal: 680,
      prot: 42,
      carbs: 34,
      fat: 38,
      prep: 38,
      allergies: ["Egg", "Butter"],
    },
    {
      name: "Shiro Wot",
      am: "ሽሮ ወጥ",
      price: 280,
      tags: ["Traditional", "Vegan", "Popular"],
      kcal: 440,
      prot: 19,
      carbs: 62,
      fat: 12,
      prep: 18,
      allergies: ["Legumes"],
    },
    {
      name: "Misir Wot",
      am: "ምስር ወጥ",
      price: 260,
      tags: ["Traditional", "Vegan", "Fasting"],
      kcal: 390,
      prot: 17,
      carbs: 55,
      fat: 11,
      prep: 16,
      allergies: ["Legumes"],
    },
    {
      name: "Kik Alicha",
      am: "ክክ አሊጫ",
      price: 250,
      tags: ["Traditional", "Vegan", "Mild"],
      kcal: 360,
      prot: 16,
      carbs: 52,
      fat: 9,
      prep: 16,
      allergies: ["Legumes"],
    },
    {
      name: "Atkilt Wot",
      am: "አትክልት ወጥ",
      price: 230,
      tags: ["Traditional", "Vegan", "Side"],
      kcal: 260,
      prot: 6,
      carbs: 34,
      fat: 9,
      prep: 14,
      allergies: [],
    },
    {
      name: "Gomen",
      am: "ጎመን",
      price: 220,
      tags: ["Traditional", "Vegan", "Side"],
      kcal: 210,
      prot: 5,
      carbs: 18,
      fat: 12,
      prep: 12,
      allergies: [],
    },
    {
      name: "Beyaynetu",
      am: "በያይነቱ",
      price: 340,
      tags: ["Traditional", "Vegan", "Sampler"],
      kcal: 560,
      prot: 18,
      carbs: 76,
      fat: 17,
      prep: 24,
      allergies: ["Legumes"],
    },
    {
      name: "Tegabino Shiro",
      am: "ተጋቢኖ ሽሮ",
      price: 310,
      tags: ["Traditional", "Comfort", "Hot Plate"],
      kcal: 500,
      prot: 22,
      carbs: 48,
      fat: 21,
      prep: 20,
      allergies: ["Legumes", "Butter"],
    },
    {
      name: "Azifa",
      am: "አዚፋ",
      price: 190,
      tags: ["Traditional", "Vegan", "Cold Dish"],
      kcal: 240,
      prot: 11,
      carbs: 32,
      fat: 8,
      prep: 9,
      allergies: ["Legumes"],
    },
    {
      name: "Gomen be Siga",
      am: "ጎመን በስጋ",
      price: 390,
      tags: ["Traditional", "Lunch"],
      kcal: 610,
      prot: 34,
      carbs: 19,
      fat: 43,
      prep: 28,
      allergies: ["Butter"],
    },
    {
      name: "Key Wot",
      am: "ቀይ ወጥ",
      price: 400,
      tags: ["Traditional", "Spicy", "Dinner"],
      kcal: 630,
      prot: 37,
      carbs: 18,
      fat: 44,
      prep: 30,
      allergies: ["Butter"],
    },
    {
      name: "Mahberawi Platter",
      am: "ማህበራዊ ፕላተር",
      price: 980,
      tags: ["Traditional", "Sharing", "Signature"],
      kcal: 1480,
      prot: 68,
      carbs: 104,
      fat: 74,
      prep: 32,
      allergies: ["Butter", "Egg", "Legumes"],
    },
  ];

  const grillAndMeatItems = [
    {
      name: "Special Tibs",
      am: "ስፔሻል ጥብስ",
      price: 460,
      tags: ["Grill", "Dinner", "Popular"],
      kcal: 650,
      prot: 48,
      carbs: 13,
      fat: 41,
      prep: 18,
      allergies: [],
    },
    {
      name: "Shekla Tibs",
      am: "ሸክላ ጥብስ",
      price: 490,
      tags: ["Grill", "Hot Plate", "Signature"],
      kcal: 690,
      prot: 49,
      carbs: 15,
      fat: 45,
      prep: 20,
      allergies: [],
    },
    {
      name: "Awaze Tibs",
      am: "አዋዜ ጥብስ",
      price: 470,
      tags: ["Grill", "Spicy"],
      kcal: 670,
      prot: 46,
      carbs: 14,
      fat: 43,
      prep: 18,
      allergies: [],
    },
    {
      name: "Dereq Tibs",
      am: "ደረቅ ጥብስ",
      price: 455,
      tags: ["Grill", "Dry Fry"],
      kcal: 620,
      prot: 47,
      carbs: 10,
      fat: 40,
      prep: 16,
      allergies: [],
    },
    {
      name: "Chicken Tibs",
      am: "የዶሮ ጥብስ",
      price: 390,
      tags: ["Grill", "Dinner"],
      kcal: 540,
      prot: 41,
      carbs: 11,
      fat: 32,
      prep: 16,
      allergies: [],
    },
    {
      name: "Fish Tibs",
      am: "የዓሣ ጥብስ",
      price: 430,
      tags: ["Seafood", "Dinner"],
      kcal: 480,
      prot: 37,
      carbs: 9,
      fat: 29,
      prep: 17,
      allergies: ["Fish"],
    },
    {
      name: "Dulet",
      am: "ዱለት",
      price: 350,
      tags: ["Traditional", "Spicy", "Dinner"],
      kcal: 520,
      prot: 30,
      carbs: 10,
      fat: 38,
      prep: 15,
      allergies: ["Butter"],
    },
    {
      name: "Kitfo",
      am: "ክትፎ",
      price: 520,
      tags: ["Traditional", "Signature", "Dinner"],
      kcal: 710,
      prot: 39,
      carbs: 8,
      fat: 56,
      prep: 12,
      allergies: ["Butter"],
    },
    {
      name: "Lebleb Kitfo",
      am: "ለብለብ ክትፎ",
      price: 540,
      tags: ["Traditional", "Warm", "Signature"],
      kcal: 730,
      prot: 40,
      carbs: 8,
      fat: 58,
      prep: 13,
      allergies: ["Butter"],
    },
    {
      name: "Gored Gored",
      am: "ጎረድ ጎረድ",
      price: 510,
      tags: ["Traditional", "Raw Meat"],
      kcal: 660,
      prot: 44,
      carbs: 4,
      fat: 52,
      prep: 10,
      allergies: ["Butter"],
    },
    {
      name: "Tere Siga",
      am: "ጥሬ ስጋ",
      price: 530,
      tags: ["Traditional", "Raw Meat"],
      kcal: 640,
      prot: 46,
      carbs: 3,
      fat: 49,
      prep: 8,
      allergies: [],
    },
    {
      name: "Minchet Abish",
      am: "ምንቸት አብሽ",
      price: 380,
      tags: ["Traditional", "Dinner"],
      kcal: 590,
      prot: 33,
      carbs: 17,
      fat: 40,
      prep: 26,
      allergies: ["Butter"],
    },
  ];

  const breakfastAndCafeItems = [
    {
      name: "Firfir",
      am: "ፍርፍር",
      price: 240,
      tags: ["Breakfast", "Traditional", "Popular"],
      kcal: 500,
      prot: 15,
      carbs: 69,
      fat: 16,
      prep: 11,
      allergies: ["Gluten"],
    },
    {
      name: "Chechebsa",
      am: "ጨጨብሳ",
      price: 260,
      tags: ["Breakfast", "Traditional"],
      kcal: 540,
      prot: 14,
      carbs: 74,
      fat: 19,
      prep: 12,
      allergies: ["Gluten", "Butter"],
    },
    {
      name: "Fatira with Honey",
      am: "ፈጢራ ከማር ጋር",
      price: 230,
      tags: ["Breakfast", "Sweet"],
      kcal: 470,
      prot: 10,
      carbs: 63,
      fat: 18,
      prep: 10,
      allergies: ["Gluten"],
    },
    {
      name: "Fatira with Egg",
      am: "ፈጢራ ከእንቁላል ጋር",
      price: 250,
      tags: ["Breakfast", "Savory"],
      kcal: 510,
      prot: 18,
      carbs: 58,
      fat: 21,
      prep: 10,
      allergies: ["Gluten", "Egg"],
    },
    {
      name: "Genfo",
      am: "ገንፎ",
      price: 210,
      tags: ["Breakfast", "Traditional"],
      kcal: 390,
      prot: 10,
      carbs: 61,
      fat: 10,
      prep: 9,
      allergies: ["Butter"],
    },
    {
      name: "Foul",
      am: "ፉል",
      price: 220,
      tags: ["Breakfast", "Vegan", "Popular"],
      kcal: 360,
      prot: 16,
      carbs: 48,
      fat: 10,
      prep: 9,
      allergies: ["Legumes"],
    },
    {
      name: "Egg Sandwich",
      am: "እንቁላል ሳንድዊች",
      price: 190,
      tags: ["Breakfast", "Quick Bite"],
      kcal: 340,
      prot: 14,
      carbs: 31,
      fat: 17,
      prep: 6,
      allergies: ["Gluten", "Egg"],
    },
    {
      name: "Cheese Sandwich",
      am: "አይብ ሳንድዊች",
      price: 200,
      tags: ["Breakfast", "Quick Bite"],
      kcal: 360,
      prot: 13,
      carbs: 30,
      fat: 20,
      prep: 6,
      allergies: ["Gluten", "Dairy"],
    },
    {
      name: "Club Sandwich",
      am: "ክለብ ሳንድዊች",
      price: 360,
      tags: ["Cafe", "Lunch"],
      kcal: 570,
      prot: 28,
      carbs: 49,
      fat: 30,
      prep: 10,
      allergies: ["Gluten", "Egg"],
    },
    {
      name: "Avocado Toast",
      am: "አቮካዶ ቶስት",
      price: 310,
      tags: ["Cafe", "Healthy", "Breakfast"],
      kcal: 370,
      prot: 11,
      carbs: 38,
      fat: 18,
      prep: 8,
      allergies: ["Gluten"],
    },
    {
      name: "Blueberry Pancakes",
      am: "ብሉቤሪ ፓንኬክ",
      price: 340,
      tags: ["Cafe", "Sweet", "Breakfast"],
      kcal: 520,
      prot: 12,
      carbs: 74,
      fat: 18,
      prep: 10,
      allergies: ["Gluten", "Egg", "Dairy"],
    },
    {
      name: "Shakshuka",
      am: "ሻክሹካ",
      price: 350,
      tags: ["Brunch", "Popular"],
      kcal: 440,
      prot: 21,
      carbs: 24,
      fat: 27,
      prep: 12,
      allergies: ["Egg"],
    },
  ];

  const drinksAndDessertsItems = [
    {
      name: "Ethiopian Coffee Pot",
      am: "ቡና",
      price: 120,
      tags: ["Coffee", "Traditional", "Drinks"],
      kcal: 8,
      prot: 0,
      carbs: 1,
      fat: 0,
      prep: 8,
      allergies: [],
    },
    {
      name: "Macchiato",
      am: "ማኪያቶ",
      price: 140,
      tags: ["Coffee", "Drinks", "Cafe"],
      kcal: 70,
      prot: 4,
      carbs: 6,
      fat: 3,
      prep: 4,
      allergies: ["Dairy"],
    },
    {
      name: "Spiced Tea",
      am: "ሻይ",
      price: 90,
      tags: ["Tea", "Drinks"],
      kcal: 12,
      prot: 0,
      carbs: 3,
      fat: 0,
      prep: 4,
      allergies: [],
    },
    {
      name: "Spris",
      am: "ስፕሪስ",
      price: 180,
      tags: ["Juice", "Drinks", "Popular"],
      kcal: 220,
      prot: 3,
      carbs: 42,
      fat: 5,
      prep: 6,
      allergies: ["Dairy"],
    },
    {
      name: "Mango Juice",
      am: "ማንጎ ጁስ",
      price: 170,
      tags: ["Juice", "Drinks"],
      kcal: 160,
      prot: 2,
      carbs: 37,
      fat: 1,
      prep: 5,
      allergies: [],
    },
    {
      name: "Avocado Juice",
      am: "አቮካዶ ጁስ",
      price: 190,
      tags: ["Juice", "Drinks"],
      kcal: 240,
      prot: 4,
      carbs: 26,
      fat: 14,
      prep: 6,
      allergies: ["Dairy"],
    },
    {
      name: "Cheesecake Slice",
      am: "ቺዝኬክ",
      price: 250,
      tags: ["Dessert", "Cafe"],
      kcal: 420,
      prot: 6,
      carbs: 34,
      fat: 29,
      prep: 5,
      allergies: ["Dairy", "Egg", "Gluten"],
    },
    {
      name: "Chocolate Cake Slice",
      am: "ቸኮሌት ኬክ",
      price: 240,
      tags: ["Dessert", "Cafe"],
      kcal: 430,
      prot: 5,
      carbs: 45,
      fat: 25,
      prep: 5,
      allergies: ["Gluten", "Egg", "Dairy"],
    },
    {
      name: "Baklava",
      am: "ባክላቫ",
      price: 210,
      tags: ["Dessert", "Sweet"],
      kcal: 320,
      prot: 4,
      carbs: 37,
      fat: 18,
      prep: 5,
      allergies: ["Nuts", "Gluten"],
    },
    {
      name: "Croissant",
      am: "ክሮሳን",
      price: 160,
      tags: ["Pastry", "Breakfast"],
      kcal: 270,
      prot: 5,
      carbs: 25,
      fat: 16,
      prep: 4,
      allergies: ["Gluten", "Dairy"],
    },
    {
      name: "Cinnamon Roll",
      am: "ሲናሞን ሮል",
      price: 190,
      tags: ["Pastry", "Dessert"],
      kcal: 350,
      prot: 6,
      carbs: 46,
      fat: 16,
      prep: 5,
      allergies: ["Gluten", "Dairy", "Egg"],
    },
    {
      name: "Fresh Fruit Plate",
      am: "የፍራፍሬ ሳህን",
      price: 230,
      tags: ["Healthy", "Dessert"],
      kcal: 160,
      prot: 3,
      carbs: 35,
      fat: 1,
      prep: 6,
      allergies: [],
    },
  ];

  const fastingAndVeganItems = [
    {
      name: "Fasting Beyaynetu",
      am: "የጾም በያይነቱ",
      price: 320,
      tags: ["Vegan", "Fasting", "Traditional"],
      kcal: 520,
      prot: 17,
      carbs: 74,
      fat: 14,
      prep: 22,
      allergies: ["Legumes"],
    },
    {
      name: "Shiro Firfir",
      am: "ሽሮ ፍርፍር",
      price: 260,
      tags: ["Vegan", "Breakfast", "Fasting"],
      kcal: 470,
      prot: 18,
      carbs: 63,
      fat: 14,
      prep: 12,
      allergies: ["Legumes", "Gluten"],
    },
    {
      name: "Timatim Fitfit",
      am: "ቲማቲም ፍትፍት",
      price: 220,
      tags: ["Vegan", "Breakfast", "Light"],
      kcal: 280,
      prot: 6,
      carbs: 36,
      fat: 11,
      prep: 10,
      allergies: ["Gluten"],
    },
    {
      name: "Fasting Combo",
      am: "የጾም ኮምቦ",
      price: 380,
      tags: ["Vegan", "Sampler"],
      kcal: 610,
      prot: 20,
      carbs: 86,
      fat: 18,
      prep: 25,
      allergies: ["Legumes"],
    },
    {
      name: "Bozena Shiro",
      am: "ቦዘና ሽሮ",
      price: 390,
      tags: ["Traditional", "Popular"],
      kcal: 610,
      prot: 31,
      carbs: 41,
      fat: 34,
      prep: 20,
      allergies: ["Legumes", "Butter"],
    },
    {
      name: "Kik Firfir",
      am: "ክክ ፍርፍር",
      price: 250,
      tags: ["Vegan", "Breakfast"],
      kcal: 430,
      prot: 15,
      carbs: 61,
      fat: 12,
      prep: 11,
      allergies: ["Legumes", "Gluten"],
    },
    {
      name: "Gomen Firfir",
      am: "ጎመን ፍርፍር",
      price: 240,
      tags: ["Vegan", "Breakfast"],
      kcal: 390,
      prot: 12,
      carbs: 57,
      fat: 11,
      prep: 11,
      allergies: ["Gluten"],
    },
    {
      name: "Lentil Sambusa",
      am: "ምስር ሳምቡሳ",
      price: 150,
      tags: ["Snack", "Vegan"],
      kcal: 230,
      prot: 8,
      carbs: 27,
      fat: 10,
      prep: 6,
      allergies: ["Gluten", "Legumes"],
    },
    {
      name: "Vegetable Pasta",
      am: "አትክልት ፓስታ",
      price: 290,
      tags: ["Vegan", "Lunch", "Casual"],
      kcal: 480,
      prot: 12,
      carbs: 72,
      fat: 14,
      prep: 12,
      allergies: ["Gluten"],
    },
    {
      name: "Vegetable Rice",
      am: "አትክልት ሩዝ",
      price: 280,
      tags: ["Vegan", "Lunch"],
      kcal: 430,
      prot: 9,
      carbs: 74,
      fat: 10,
      prep: 12,
      allergies: [],
    },
    {
      name: "Hummus Plate",
      am: "ሁሙስ ሳህን",
      price: 240,
      tags: ["Vegan", "Starter"],
      kcal: 310,
      prot: 11,
      carbs: 28,
      fat: 16,
      prep: 7,
      allergies: ["Sesame", "Legumes"],
    },
    {
      name: "Falafel Wrap",
      am: "ፋላፍል ራፕ",
      price: 260,
      tags: ["Vegan", "Wrap", "Lunch"],
      kcal: 410,
      prot: 13,
      carbs: 48,
      fat: 17,
      prep: 9,
      allergies: ["Gluten", "Legumes"],
    },
  ];

  const itemSets = [
    ethiopianTraditionalItems,
    grillAndMeatItems,
    breakfastAndCafeItems,
    drinksAndDessertsItems,
    fastingAndVeganItems,
  ];

  const users = [];
  const testUsers = [
    {
      username: "sys_admin_test",
      first: "System",
      last: "Admin",
      email: "superadmin@dineqseed.com",
      phone: "+251911200500",
      role: "SUPER_ADMIN",
    },
    {
      username: "owner_test",
      first: "Mesfin",
      last: "Bekele",
      email: "owner@dineqseed.com",
      phone: "+251911200501",
      role: "OWNER",
    },
    {
      username: "manager_test",
      first: "Samuel",
      last: "Mekonnen",
      email: "manager@dineqseed.com",
      phone: "+251911200503",
      role: "MANAGER",
    },
    {
      username: "waiter_test",
      first: "Jake",
      last: "Waiter",
      email: "waiter@dineqseed.com",
      phone: "+251911200506",
      role: "WAITER",
    },
  ];

  testUsers.forEach((u, i) => {
    users.push({
      _id: ObjectId(),
      email: u.email,
      phoneNumber: u.phone,
      username: u.username,
      passwordHash: DEMO_PASSWORD_HASH,
      authProvider: "EMAIL",
      isVerified: true,
      fullName: `${u.first} ${u.last}`,
      firstName: u.first,
      lastName: u.last,
      profileImage: makeAvatar(u.first, u.last, i),
      role: u.role,
      status: "ACTIVE",
      preferences: {
        language: i % 2 === 0 ? "en-US" : "am-ET",
        theme: i % 2 === 0 ? "light" : "dark",
        notifications: true,
        favorites: [],
      },
      lastLoginAt: hoursAgo(2 + i),
      createdAt: daysAgo(100 - i * 3),
      updatedAt: daysAgo(1),
      isDeleted: false,
      fcmToken: `fcm_owner_${i + 1}`,
    });
  });

  const customerNames = [
    ["Abel", "Negash"],
    ["Mimi", "Belay"],
    ["Ruth", "Haile"],
    ["Jonas", "Alemu"],
    ["Nati", "Hailu"],
    ["Eyerus", "Worku"],
    ["Bini", "Gebru"],
    ["Eden", "Fisseha"],
    ["Mika", "Getnet"],
    ["Lina", "Assefa"],
    ["Noah", "Solomon"],
    ["Meron", "Ayalew"],
  ];

  customerNames.forEach((n, i) => {
    users.push({
      _id: ObjectId(),
      email: `${n[0].toLowerCase()}.${n[1].toLowerCase()}@mailseed.com`,
      phoneNumber: `+25192233${(100 + i).toString().padStart(3, "0")}`,
      username: `${n[0].toLowerCase()}_${n[1].toLowerCase()}`,
      passwordHash: DEMO_PASSWORD_HASH,
      authProvider: i % 5 === 0 ? "GOOGLE" : "EMAIL",
      isVerified: true,
      fullName: `${n[0]} ${n[1]}`,
      firstName: n[0],
      lastName: n[1],
      profileImage: makeAvatar(n[0], n[1], i + 10),
      role: "CUSTOMER",
      status: "ACTIVE",
      preferences: {
        language: i % 3 === 0 ? "am-ET" : "en-US",
        theme: i % 2 === 0 ? "light" : "dark",
        notifications: i % 4 !== 0,
        favorites: [],
      },
      lastLoginAt: hoursAgo((i % 24) + 1),
      createdAt: daysAgo(70 - i),
      updatedAt: daysAgo(i % 5),
      isDeleted: false,
      fcmToken: `fcm_customer_${i + 1}`,
    });
  });

  users.push({
    _id: ObjectId(),
    email: "admin@dineqseed.com",
    phoneNumber: "+251944000001",
    username: "platform_admin",
    passwordHash: DEMO_PASSWORD_HASH,
    authProvider: "EMAIL",
    isVerified: true,
    fullName: "Platform Admin",
    firstName: "Platform",
    lastName: "Admin",
    profileImage: makeAvatar("Platform", "Admin", 999),
    role: "ADMIN",
    status: "ACTIVE",
    preferences: {
      language: "en-US",
      theme: "dark",
      notifications: true,
      favorites: [],
    },
    lastLoginAt: hoursAgo(1),
    createdAt: daysAgo(220),
    updatedAt: daysAgo(0),
    isDeleted: false,
    fcmToken: "fcm_admin_1",
  });

  // Reuse existing user IDs by email (idempotent runs, stable manager/customer references)
  const existingUsers = db
    .getCollection(COLLECTIONS.users)
    .find(
      { email: { $in: users.map((u) => u.email) } },
      { projection: { _id: 1, email: 1 } },
    )
    .toArray();
  const existingUserByEmail = Object.fromEntries(
    existingUsers.map((u) => [u.email, u]),
  );
  users.forEach((u) => {
    const existing = existingUserByEmail[u.email];
    if (existing && existing._id) {
      u._id = existing._id;
    }
  });

  const managerPool = users.filter(
    (u) => u.role === "OWNER" || u.role === "MANAGER",
  );
  const customerPool = users.filter((u) => u.role === "CUSTOMER");

  const restaurantBlueprints = [
    {
      slug: "abay-mesob-bole",
      name: "Abay Mesob Bole",
      phone: "+251116650101",
      tags: ["Ethiopian", "Traditional", "Family", "Signature"],
      about:
        "A lively Bole favorite known for doro wot, mahberawi platters, and nightly Ethiopian coffee ceremony with neighborhood warmth.",
      taxId: "ET-TIN-ABAY-101",
      coords: [38.7892, 8.9916],
      colors: ["#7A3E1D", "#C58A4A"],
      currency: "ETB",
      language: "am-ET",
      vat: 15,
      setIndex: 0,
      coverIndex: 0,
    },
    {
      slug: "tibs-terrace-cmc",
      name: "Tibs Terrace CMC",
      phone: "+251116650202",
      tags: ["Grill", "Tibs", "Dinner", "Group Dining"],
      about:
        "Hot clay-plate tibs, kitfo specials, and late-evening service near CMC with energetic Addis grill-house atmosphere.",
      taxId: "ET-TIN-TIBS-202",
      coords: [38.8169, 9.0301],
      colors: ["#4A2C2A", "#B5651D"],
      currency: "ETB",
      language: "am-ET",
      vat: 15,
      setIndex: 1,
      coverIndex: 2,
    },
    {
      slug: "buna-bite-kazanchis",
      name: "Buna & Bite Kazanchis",
      phone: "+251116650303",
      tags: ["Cafe", "Breakfast", "Coffee", "Brunch"],
      about:
        "Morning-to-evening cafe in Kazanchis serving firfir, chechebsa, macchiato, spris, and fresh pastries for city commuters.",
      taxId: "ET-TIN-BUNA-303",
      coords: [38.7618, 9.0154],
      colors: ["#5B3A29", "#D9A441"],
      currency: "ETB",
      language: "en-US",
      vat: 15,
      setIndex: 2,
      coverIndex: 1,
    },
    {
      slug: "teff-garden-piastsa",
      name: "Teff Garden Piassa",
      phone: "+251116650404",
      tags: ["Vegan", "Fasting", "Traditional", "Healthy"],
      about:
        "Piassa spot focused on fasting beyaynetu, shiro varieties, and plant-forward Ethiopian classics with modern plating.",
      taxId: "ET-TIN-TEFF-404",
      coords: [38.7463, 9.0398],
      colors: ["#355E3B", "#C9A227"],
      currency: "ETB",
      language: "am-ET",
      vat: 15,
      setIndex: 4,
      coverIndex: 6,
    },
    {
      slug: "shewa-family-kirkos",
      name: "Shewa Family Kitchen Kirkos",
      phone: "+251116650505",
      tags: ["Family", "Traditional", "Lunch", "Value"],
      about:
        "Comfort-food kitchen in Kirkos offering generous portions of key wot, gomen be siga, and rotating daily specials.",
      taxId: "ET-TIN-SHEWA-505",
      coords: [38.7569, 8.9987],
      colors: ["#6B4226", "#E6C07B"],
      currency: "ETB",
      language: "am-ET",
      vat: 15,
      setIndex: 0,
      coverIndex: 4,
    },
    {
      slug: "atlas-fusion-bisrate",
      name: "Atlas Fusion Bisrate",
      phone: "+251116650606",
      tags: ["Fusion", "Modern", "Dinner", "Date Night"],
      about:
        "Contemporary Addis fusion dining in Bisrate Gebriel pairing Ethiopian flavors with modern presentation and curated beverages.",
      taxId: "ET-TIN-ATLAS-606",
      coords: [38.7698, 8.9719],
      colors: ["#254E70", "#7FA1C3"],
      currency: "ETB",
      language: "en-US",
      vat: 15,
      setIndex: 1,
      coverIndex: 8,
    },
    {
      slug: "gerji-brunch-club",
      name: "Gerji Brunch Club",
      phone: "+251116650707",
      tags: ["Brunch", "Cafe", "Dessert", "Juice"],
      about:
        "Weekend favorite in Gerji for breakfast platters, pancakes, avocado toast, juices, and specialty coffee drinks.",
      taxId: "ET-TIN-GERJI-707",
      coords: [38.8153, 8.9992],
      colors: ["#6D597A", "#B56576"],
      currency: "ETB",
      language: "en-US",
      vat: 15,
      setIndex: 2,
      coverIndex: 7,
    },
    {
      slug: "arat-kilo-veg-house",
      name: "Arat Kilo Veg House",
      phone: "+251116650808",
      tags: ["Vegan", "Fasting", "Students", "Budget Friendly"],
      about:
        "Popular around Arat Kilo for affordable fasting combos, lentil dishes, and quick healthy lunches.",
      taxId: "ET-TIN-ARAT-808",
      coords: [38.7611, 9.0476],
      colors: ["#2F5233", "#D6AD60"],
      currency: "ETB",
      language: "am-ET",
      vat: 15,
      setIndex: 4,
      coverIndex: 5,
    },
    {
      slug: "mexico-square-grill",
      name: "Mexico Square Grill",
      phone: "+251116650909",
      tags: ["Grill", "Tibs", "Late Night", "Casual"],
      about:
        "Bustling grill house near Mexico Square known for shekla tibs, fish tibs, and late-night Addis crowd energy.",
      taxId: "ET-TIN-MEX-909",
      coords: [38.7437, 8.9945],
      colors: ["#7F5539", "#D4A373"],
      currency: "ETB",
      language: "am-ET",
      vat: 15,
      setIndex: 1,
      coverIndex: 3,
    },
    {
      slug: "hayahulet-buna-ceremony",
      name: "Hayahulet Buna Ceremony",
      phone: "+251116651001",
      tags: ["Coffee", "Cafe", "Breakfast", "Traditional"],
      about:
        "Cozy Hayahulet coffee spot highlighting Ethiopian buna, macchiato, and light breakfast plates for early mornings and meetings.",
      taxId: "ET-TIN-HAYA-001",
      coords: [38.8012, 9.0223],
      colors: ["#5B3A29", "#D9A441"],
      currency: "ETB",
      language: "en-US",
      vat: 15,
      setIndex: 2,
      coverIndex: 2,
    },
    {
      slug: "megenagna-teff-bistro",
      name: "Megenagna Teff Bistro",
      phone: "+251116651002",
      tags: ["Ethiopian", "Traditional", "Lunch", "Modern"],
      about:
        "Modern teff-forward bistro around Megenagna serving classic wot with clean plating and consistent portions.",
      taxId: "ET-TIN-MEG-002",
      coords: [38.8098, 9.0206],
      colors: ["#355E3B", "#C9A227"],
      currency: "ETB",
      language: "am-ET",
      vat: 15,
      setIndex: 0,
      coverIndex: 0,
    },
    {
      slug: "shola-fast-and-fasting",
      name: "Shola Fast & Fasting",
      phone: "+251116651003",
      tags: ["Vegan", "Fasting", "Healthy", "Budget Friendly"],
      about:
        "Shola neighborhood place focused on fasting plates, shiro variants, lentil dishes, and light veggie meals.",
      taxId: "ET-TIN-SHOLA-003",
      coords: [38.835, 9.0342],
      colors: ["#2F5233", "#D6AD60"],
      currency: "ETB",
      language: "am-ET",
      vat: 15,
      setIndex: 4,
      coverIndex: 6,
    },
    {
      slug: "saris-spice-house",
      name: "Saris Spice House",
      phone: "+251116651004",
      tags: ["Ethiopian", "Traditional", "Spicy", "Dinner"],
      about:
        "Saris-based dinner house known for berbere-forward flavors and hearty evening plates for groups.",
      taxId: "ET-TIN-SARIS-004",
      coords: [38.7168, 8.9584],
      colors: ["#7A3E1D", "#C58A4A"],
      currency: "ETB",
      language: "am-ET",
      vat: 15,
      setIndex: 1,
      coverIndex: 8,
    },
    {
      slug: "kera-market-kitchen",
      name: "Kera Market Kitchen",
      phone: "+251116651005",
      tags: ["Lunch", "Value", "Traditional", "Family"],
      about:
        "Quick and reliable lunch stop near Kera with rotating daily specials and consistent injera quality.",
      taxId: "ET-TIN-KERA-005",
      coords: [38.7296, 8.9698],
      colors: ["#6B4226", "#E6C07B"],
      currency: "ETB",
      language: "am-ET",
      vat: 15,
      setIndex: 0,
      coverIndex: 4,
    },
    {
      slug: "torhailoch-breakfast-corner",
      name: "Torhailoch Breakfast Corner",
      phone: "+251116651006",
      tags: ["Breakfast", "Cafe", "Quick Bite", "Coffee"],
      about:
        "Torhailoch morning favorite for firfir, fatira, sandwiches, and fast macchiato for commuters.",
      taxId: "ET-TIN-TOR-006",
      coords: [38.7326, 9.0127],
      colors: ["#254E70", "#7FA1C3"],
      currency: "ETB",
      language: "en-US",
      vat: 15,
      setIndex: 2,
      coverIndex: 7,
    },
    {
      slug: "meskel-square-rooftop",
      name: "Meskel Square Rooftop",
      phone: "+251116651007",
      tags: ["Dinner", "Date Night", "Modern", "City View"],
      about:
        "Rooftop dining near Meskel Square with modern Ethiopian plates, drinks, and evening ambiance.",
      taxId: "ET-TIN-MSQ-007",
      coords: [38.757, 9.0103],
      colors: ["#6D597A", "#B56576"],
      currency: "ETB",
      language: "en-US",
      vat: 15,
      setIndex: 3,
      coverIndex: 9,
    },
    {
      slug: "stadium-grill-and-tibs",
      name: "Stadium Grill & Tibs",
      phone: "+251116651008",
      tags: ["Grill", "Tibs", "Group Dining", "Casual"],
      about:
        "Sports-night friendly grill near Stadium serving shekla tibs, dulet, and shared platters.",
      taxId: "ET-TIN-STD-008",
      coords: [38.7465, 9.0072],
      colors: ["#4A2C2A", "#B5651D"],
      currency: "ETB",
      language: "am-ET",
      vat: 15,
      setIndex: 1,
      coverIndex: 3,
    },
    {
      slug: "shiro-meda-heritage-mesob",
      name: "Shiro Meda Heritage Mesob",
      phone: "+251116651009",
      tags: ["Traditional", "Cultural", "Family", "Coffee"],
      about:
        "Heritage-style Ethiopian dining around Shiro Meda with classic wot, beyaynetu, and coffee ceremony service.",
      taxId: "ET-TIN-SMEDA-009",
      coords: [38.7874, 9.0632],
      colors: ["#7A3E1D", "#C58A4A"],
      currency: "ETB",
      language: "am-ET",
      vat: 15,
      setIndex: 0,
      coverIndex: 0,
    },
    {
      slug: "bethel-family-mesob",
      name: "Bethel Family Mesob",
      phone: "+251116651010",
      tags: ["Family", "Traditional", "Lunch", "Value"],
      about:
        "Bethel neighborhood kitchen serving dependable lunch plates, gomen, key wot, and daily specials.",
      taxId: "ET-TIN-BETHEL-010",
      coords: [38.7105, 9.0164],
      colors: ["#6B4226", "#E6C07B"],
      currency: "ETB",
      language: "am-ET",
      vat: 15,
      setIndex: 0,
      coverIndex: 4,
    },
    {
      slug: "jemo-garden-vegan",
      name: "Jemo Garden Vegan",
      phone: "+251116651011",
      tags: ["Vegan", "Fasting", "Healthy", "Modern"],
      about:
        "Jemo-focused plant-forward Ethiopian plates with fasting combos and lighter spice options.",
      taxId: "ET-TIN-JEMO-011",
      coords: [38.6894, 8.9531],
      colors: ["#2F5233", "#D6AD60"],
      currency: "ETB",
      language: "am-ET",
      vat: 15,
      setIndex: 4,
      coverIndex: 6,
    },
    {
      slug: "gurd-shola-brunch",
      name: "Gurd Shola Brunch",
      phone: "+251116651012",
      tags: ["Brunch", "Cafe", "Juice", "Dessert"],
      about:
        "Bright brunch place around Gurd Shola with pancakes, avocado toast, juices, pastries, and coffee.",
      taxId: "ET-TIN-GS-012",
      coords: [38.8295, 9.0221],
      colors: ["#254E70", "#7FA1C3"],
      currency: "ETB",
      language: "en-US",
      vat: 15,
      setIndex: 3,
      coverIndex: 7,
    },
    {
      slug: "four-kilo-campus-cafe",
      name: "4 Kilo Campus Cafe",
      phone: "+251116651013",
      tags: ["Cafe", "Students", "Breakfast", "Budget Friendly"],
      about:
        "Campus-friendly cafe in 4 Kilo serving affordable breakfast plates, sandwiches, and fast coffee.",
      taxId: "ET-TIN-4K-013",
      coords: [38.7647, 9.0494],
      colors: ["#5B3A29", "#D9A441"],
      currency: "ETB",
      language: "en-US",
      vat: 15,
      setIndex: 2,
      coverIndex: 1,
    },
    {
      slug: "six-kilo-student-kitchen",
      name: "6 Kilo Student Kitchen",
      phone: "+251116651014",
      tags: ["Lunch", "Students", "Value", "Traditional"],
      about:
        "A simple, filling lunch kitchen around 6 Kilo with rotating daily plates and fast service.",
      taxId: "ET-TIN-6K-014",
      coords: [38.7582, 9.0563],
      colors: ["#355E3B", "#C9A227"],
      currency: "ETB",
      language: "am-ET",
      vat: 15,
      setIndex: 0,
      coverIndex: 5,
    },
    {
      slug: "bole-road-injera-house",
      name: "Bole Road Injera House",
      phone: "+251116651015",
      tags: ["Traditional", "Lunch", "Family", "Popular"],
      about:
        "Bole Road injera-focused kitchen known for consistent injera and rich stew options at lunch and dinner.",
      taxId: "ET-TIN-BOLE-015",
      coords: [38.7941, 8.9929],
      colors: ["#7A3E1D", "#C58A4A"],
      currency: "ETB",
      language: "am-ET",
      vat: 15,
      setIndex: 0,
      coverIndex: 0,
    },
    {
      slug: "kazanchis-juice-bar",
      name: "Kazanchis Juice Bar",
      phone: "+251116651016",
      tags: ["Juice", "Drinks", "Cafe", "Dessert"],
      about:
        "Fresh juice and dessert bar in Kazanchis offering spris, avocado juice, cakes, and fruit plates.",
      taxId: "ET-TIN-KJ-016",
      coords: [38.7652, 9.0138],
      colors: ["#6D597A", "#B56576"],
      currency: "ETB",
      language: "en-US",
      vat: 15,
      setIndex: 3,
      coverIndex: 9,
    },
    {
      slug: "piassa-heritage-kitchen",
      name: "Piassa Heritage Kitchen",
      phone: "+251116651017",
      tags: ["Traditional", "Cultural", "Lunch", "Family"],
      about:
        "Piassa heritage-style Ethiopian kitchen with classic dishes, friendly service, and warm ambiance.",
      taxId: "ET-TIN-PIA-017",
      coords: [38.7479, 9.0376],
      colors: ["#6B4226", "#E6C07B"],
      currency: "ETB",
      language: "am-ET",
      vat: 15,
      setIndex: 0,
      coverIndex: 4,
    },
    {
      slug: "bole-night-grill",
      name: "Bole Night Grill",
      phone: "+251116651018",
      tags: ["Grill", "Late Night", "Tibs", "Casual"],
      about:
        "Late-night grill in Bole serving tibs variations, kitfo, and shared platters for the evening crowd.",
      taxId: "ET-TIN-BNG-018",
      coords: [38.7974, 8.9884],
      colors: ["#4A2C2A", "#B5651D"],
      currency: "ETB",
      language: "am-ET",
      vat: 15,
      setIndex: 1,
      coverIndex: 3,
    },
    {
      slug: "gerji-bakery-and-buna",
      name: "Gerji Bakery & Buna",
      phone: "+251116651019",
      tags: ["Bakery", "Cafe", "Coffee", "Pastry"],
      about:
        "Gerji bakery cafe featuring croissants, cinnamon rolls, cakes, and Ethiopian coffee favorites.",
      taxId: "ET-TIN-GBB-019",
      coords: [38.8172, 8.9961],
      colors: ["#5B3A29", "#D9A441"],
      currency: "ETB",
      language: "en-US",
      vat: 15,
      setIndex: 3,
      coverIndex: 10,
    },
    {
      slug: "lebu-family-kitchen",
      name: "Lebu Family Kitchen",
      phone: "+251116651020",
      tags: ["Family", "Traditional", "Lunch", "Value"],
      about:
        "Lebu neighborhood family restaurant serving hearty lunch plates and dependable traditional classics.",
      taxId: "ET-TIN-LEBU-020",
      coords: [38.7441, 8.9395],
      colors: ["#355E3B", "#C9A227"],
      currency: "ETB",
      language: "am-ET",
      vat: 15,
      setIndex: 0,
      coverIndex: 5,
    },
  ];

  // Add 40 more realistic Addis restaurants (auto-generated but deterministic)
  const extraRestaurantNames = [
    "Bole Skyline Kitchen",
    "Yod Abyssinia Cultural Dining",
    "Lucy Lounge & Grill",
    "Addis Flame House",
    "Blue Nile Terrace",
    "Sheger Heritage",
    "Entoto View Restaurant",
    "Lalibela Dining Hall",
    "Alem Mesob",
    "Kaffa Buna House",
    "Merkato Spice Hub",
    "Addis Rooftop Garden",
    "Habesha Corner",
    "Red Sea Grill Addis",
    "Sidamo Coffee & Kitchen",
    "Walia Steak & Tibs",
    "Injera & Clay Pot",
    "Mesob Culture House",
    "Addis Brasserie",
    "Ethio Roots Kitchen",
    "Highland Vegan Addis",
    "Bole Morning Cafe",
    "Piassa Sunset Grill",
    "Buna Barista Lab",
    "Golden Teff House",
    "Addis Street Food",
    "Heritage Clay Kitchen",
    "Urban Tibs House",
    "Addis Spice Route",
    "Capital Lounge",
    "Shewa Garden",
    "Kilimanjaro Addis",
    "Green Vegan Hub",
    "Traditional Taste Addis",
    "Modern Injera Lab",
    "Addis Grill Station",
    "Ethio Feast Hall",
    "Bole Central Kitchen",
    "Coffee Ceremony House",
    "Addis Fusion Table",
  ];

  const seededUnit = (n) => {
    const x = Math.sin(n * 9999.123) * 10000;
    return x - Math.floor(x);
  };
  const seededAddisCoords = (seed) => {
    const lon = 38.70 + seededUnit(seed) * 0.18;
    const lat = 8.93 + seededUnit(seed + 1) * 0.18;
    return [Number(lon.toFixed(6)), Number(lat.toFixed(6))];
  };

  extraRestaurantNames.forEach((name, idx) => {
    const slug = name.toLowerCase().replace(/[^a-z0-9]+/g, "-");
    restaurantBlueprints.push({
      slug,
      name,
      phone: `+25111667${(300 + idx).toString().padStart(3, "0")}`,
      tags: ["Ethiopian", "Modern", "Popular"],
      about: `${name} is a well-known Addis Ababa restaurant offering Ethiopian cuisine with a modern dining experience and consistent service.`,
      taxId: `ET-TIN-EXTRA-${(300 + idx).toString()}`,
      coords: seededAddisCoords(50000 + idx),
      colors: ["#7A3E1D", "#C58A4A"],
      currency: "ETB",
      language: "am-ET",
      vat: 15,
      setIndex: idx % itemSets.length,
      coverIndex: idx,
    });
  });

  const restaurants = restaurantBlueprints.map((r, i) => {
    const manager = managerPool[i % managerPool.length];
    return {
      _id: ObjectId(),
      slug: r.slug,
      previousSlugs: i % 2 === 0 ? [] : [`${r.slug}-legacy`],
      name: r.name,
      managerId: manager._id,
      phone: r.phone,
      location: { type: "Point", coordinates: r.coords },
      about: r.about,
      logoImage: queryPhoto(
        600,
        600,
        `${r.name}, restaurant exterior, addis ababa`,
        9000 + i,
      ),
      verificationStatus: i === 3 ? "pending" : "verified",
      verificationDocs: `https://images.unsplash.com/photo-1450101499163-c8848c66ca85?auto=format&fit=crop&w=1200&q=80&doc=${i + 1}`,
      schedule: [
        {
          day: "monday",
          is_open: true,
          start_time: "07:30",
          end_time: "22:00",
        },
        {
          day: "tuesday",
          is_open: true,
          start_time: "07:30",
          end_time: "22:00",
        },
        {
          day: "wednesday",
          is_open: true,
          start_time: "07:30",
          end_time: "22:00",
        },
        {
          day: "thursday",
          is_open: true,
          start_time: "07:30",
          end_time: "22:30",
        },
        {
          day: "friday",
          is_open: true,
          start_time: "07:30",
          end_time: "23:30",
        },
        {
          day: "saturday",
          is_open: true,
          start_time: "08:00",
          end_time: "23:30",
        },
        {
          day: "sunday",
          is_open: true,
          start_time: "08:00",
          end_time: "21:30",
        },
      ],
      specialDays: [
        {
          date: "2026-09-11",
          is_open: true,
          start_time: "09:00",
          end_time: "23:30",
        },
        {
          date: "2027-01-07",
          is_open: true,
          start_time: "09:00",
          end_time: "22:30",
        },
      ],
      defaultCurrency: r.currency,
      defaultLanguage: r.language,
      defaultVat: r.vat,
      taxId: r.taxId,
      tags: r.tags,
      primaryColor: r.colors[0],
      accentColor: r.colors[1],
      coverImage: queryPhoto(
        1800,
        1000,
        `${r.name}, modern elegant restaurant interior, dining, addis ababa`,
        12000 + i,
      ),
      averageRating: 0,
      viewCount: 0,
      createdAt: daysAgo(90 - i * 8),
      updatedAt: daysAgo(1),
      isDeleted: false,
      __setIndex: r.setIndex,
    };
  });

  // Reuse existing restaurant IDs by slug (prevents duplicate slugs breaking slug -> menu lookup)
  const existingRestaurants = db
    .getCollection(COLLECTIONS.restaurants)
    .find(
      { slug: { $in: restaurants.map((r) => r.slug) } },
      { projection: { _id: 1, slug: 1 } },
    )
    .toArray();
  const existingRestaurantBySlug = Object.fromEntries(
    existingRestaurants.map((r) => [r.slug, r]),
  );
  restaurants.forEach((r) => {
    const existing = existingRestaurantBySlug[r.slug];
    if (existing && existing._id) {
      r._id = existing._id;
    }
  });

  const menus = [];
  const items = [];
  let dishPhotoCursor = 0;

  restaurants.forEach((rest, rIndex) => {
    const set = itemSets[rest.__setIndex];

    [
      { suffix: "main-menu", title: "Main Menu", published: true },
      {
        suffix: "breakfast-and-brunch",
        title: "Breakfast & Brunch",
        published: true,
      },
      { suffix: "chef-specials", title: "Chef Specials", published: true },
      {
        suffix: "drinks-and-desserts",
        title: "Drinks & Desserts",
        published: true,
      },
    ].forEach((menuMeta, mIndex) => {
      const menuId = ObjectId();
      const createdAt = daysAgo(60 - rIndex * 5 - mIndex * 2);
      const selectedItems = Array.from({ length: 6 }).map((_, i) => {
        const idx = (mIndex * 4 + i + rIndex) % set.length;
        return set[idx];
      });

      const embeddedItems = selectedItems.map((base, i) => {
        const itemId = ObjectId();
        const slug = `${base.name.toLowerCase().replace(/[^a-z0-9]+/g, "-")}-${(rIndex + 1).toString()}${(mIndex + 1).toString()}${(i + 1).toString()}`;
        const imageUrl = dishPhoto(4000 + dishPhotoCursor, base.name);
        dishPhotoCursor += 1;

        const doc = {
          _id: itemId,
          name: base.name,
          nameAm: base.am,
          slug,
          menuSlug: `${rest.slug}-${menuMeta.suffix}`,
          description: `${base.name} prepared Addis-style with fresh local ingredients, balanced spice, and house finishing for a rich and familiar flavor profile.`,
          descriptionAm: `${base.am} በአዲስ አበባ ምግብ ባህል መንገድ በአዲስ እቃዎች ተዘጋጅቶ የሚቀርብ ምግብ።`,
          image: [imageUrl],
          price: base.price + (mIndex === 1 ? 35 : 0),
          currency: "ETB",
          allergies: base.allergies.length
            ? base.allergies
            : [
                "Contains none commonly recognized. Please inform staff of any allergies.",
              ],
          allergiesAm: base.allergies.length
            ? "Please ask staff for allergen details."
            : "በተለምዶ የሚታወቁ አለርጂ አይደሉም።",
          userImages: [],
          calories: base.kcal,
          protein: base.prot,
          carbs: base.carbs,
          fat: base.fat,
          nutritionalInfo: {
            calories: base.kcal,
            protein: base.prot,
            carbs: base.carbs,
            fat: base.fat,
          },
          tabTags: base.tags,
          tabTagsAm: base.tags.map((t) => `AM-${t}`),
          ingredients: [
            "Berbere / mitmita house blend",
            "Fresh local produce",
            "Niter kibbeh or plant-based alternatives",
          ],
          ingredientsAm: [
            "የቤት በርበሬ / ሚጥሚጣ",
            "አዲስ የአካባቢ እቃዎች",
            "ንጥር ቅቤ ወይም የጾም አማራጮች",
          ],
          preparationTime: base.prep,
          howToEat:
            "Best enjoyed warm. Pair with the recommended side and beverage for full flavor experience.",
          howToEatAm: "ሞቅ ሞቅ ሆኖ ሲቀርብ ይሻላል።",
          createdAt,
          updatedAt: daysAgo(1),
          isDeleted: false,
          viewCount: Math.floor(Math.random() * 240) + 40,
          averageRating: 0,
          reviewIds: [],
        };

        items.push(doc);
        return doc;
      });

      menus.push({
        _id: menuId,
        name: `${rest.name} ${menuMeta.title}`,
        restaurantId: rest._id.valueOf(),
        RestaurantSlug: rest.slug,
        slug: `${rest.slug}-${menuMeta.suffix}`,
        version: mIndex + 1,
        isPublished: menuMeta.published,
        publishedAt: createdAt,
        items: embeddedItems,
        createdAt,
        updatedAt: daysAgo(1),
        createdBy: rest.managerId.valueOf(),
        updatedBy: rest.managerId.valueOf(),
        isDeleted: false,
        viewCount: Math.floor(Math.random() * 800) + 150,
      });
    });
  });

  // Reuse existing menu IDs by slug (idempotent updates, avoids duplicate menus per restaurant)
  const existingMenus = db
    .getCollection(COLLECTIONS.menus)
    .find(
      { slug: { $in: menus.map((m) => m.slug) } },
      { projection: { _id: 1, slug: 1 } },
    )
    .toArray();
  const existingMenuBySlug = Object.fromEntries(
    existingMenus.map((m) => [m.slug, m]),
  );
  menus.forEach((m) => {
    const existing = existingMenuBySlug[m.slug];
    if (existing && existing._id) {
      m._id = existing._id;
    }
  });

  const reviews = [];
  const reactions = [];

  // Generate realistic review distribution over the first N items (enough for dashboards)
  const reviewItemCap = Math.min(240, items.length);
  items.slice(0, reviewItemCap).forEach((it, idx) => {
    const reviewCount = 2 + (idx % 5); // 2..6
    const relevantRestaurant = restaurants.find((r) =>
      menus.some(
        (m) =>
          m.restaurantId === r._id.valueOf() &&
          m.items.some((mi) => mi._id.valueOf() === it._id.valueOf()),
      ),
    );

    for (let i = 0; i < reviewCount; i++) {
      const customer = customerPool[(idx + i) % customerPool.length];
      const rating = [4, 5, 3.5, 4.5, 5, 4, 4.5, 3, 5][(idx + i) % 9];
      const rid = ObjectId();
      const createdAt = daysAgo((idx % 20) + i + 1);

      const review = {
        _id: rid,
        itemId: it._id.valueOf(),
        userId: customer._id.valueOf(),
        restaurantId: relevantRestaurant
          ? relevantRestaurant._id.valueOf()
          : restaurants[0]._id.valueOf(),
        imageUrls: i % 3 !== 0 ? [dishPhoto(7000 + idx * 10 + i, it.name)] : [],
        username: customer.username,
        userProfileImage: customer.profileImage,
        description:
          rating >= 4.5
            ? "Absolutely amazing! The flavors were perfectly balanced and the service was top-notch. Highly recommend the signature dishes."
            : rating >= 4
              ? "Really great meal. The atmosphere was cozy and the staff were very attentive. Great place for a family dinner."
              : "Decent food but a bit overpriced for the portion size. The waiting time was also slightly longer than expected.",
        rating,
        createdAt,
        updatedAt: createdAt,
        isApproved: true,
        isDeleted: false,
        flagCount: 0,
        likeCount: 0,
        dislikeCount: 0,
        reactionIds: [],
      };
      reviews.push(review);
    }
  });

  // Reactions on most reviews
  reviews.forEach((rv, i) => {
    const reactors = [
      customerPool[(i + 2) % customerPool.length],
      customerPool[(i + 6) % customerPool.length],
    ];

    reactors.forEach((u, k) => {
      const isLike = (i + k) % 5 !== 0;
      const reactionId = ObjectId();
      reactions.push({
        _id: reactionId,
        reviewId: rv._id.valueOf(),
        itemId: rv.itemId,
        userId: u._id.valueOf(),
        type: isLike ? "LIKE" : "DISLIKE",
        createdAt: rv.createdAt,
        updatedAt: rv.updatedAt,
        isDeleted: false,
      });
      rv.reactionIds.push(reactionId.valueOf());
      if (isLike) rv.likeCount += 1;
      else rv.dislikeCount += 1;
    });
  });

  // Push review ids + average rating to items
  const itemReviewMap = {};
  reviews.forEach((rv) => {
    if (!itemReviewMap[rv.itemId]) itemReviewMap[rv.itemId] = [];
    itemReviewMap[rv.itemId].push(rv);
  });

  items.forEach((it) => {
    const list = itemReviewMap[it._id.valueOf()] || [];
    it.reviewIds = list.map((r) => r._id.valueOf());
    it.averageRating = list.length
      ? Number(
          (list.reduce((s, r) => s + r.rating, 0) / list.length).toFixed(2),
        )
      : 0;
  });

  // Sync embedded menu items with item collection ratings/reviews
  const itemIndex = Object.fromEntries(
    items.map((it) => [it._id.valueOf(), it]),
  );
  menus.forEach((m) => {
    m.items = m.items.map((it) => ({
      ...it,
      reviewIds: itemIndex[it._id.valueOf()].reviewIds,
      averageRating: itemIndex[it._id.valueOf()].averageRating,
    }));
    const rated = m.items.filter((it) => it.averageRating > 0);
    m.averageRating = rated.length
      ? Number(
          (
            rated.reduce((s, it) => s + it.averageRating, 0) / rated.length
          ).toFixed(2),
        )
      : 0;
  });

  // restaurant average/view count
  restaurants.forEach((r) => {
    const relMenus = menus.filter((m) => m.restaurantId === r._id.valueOf());
    const ratedMenus = relMenus.filter((m) => (m.averageRating || 0) > 0);
    r.averageRating = ratedMenus.length
      ? Number(
          (
            ratedMenus.reduce((s, m) => s + m.averageRating, 0) /
            ratedMenus.length
          ).toFixed(2),
        )
      : 0;
    r.viewCount =
      relMenus.reduce((s, m) => s + m.viewCount, 0) +
      Math.floor(Math.random() * 400);
  });

  // QR codes
  const qrs = restaurants.map((r) => {
    const mainMenu = menus.find((m) => m.restaurantId === r._id.valueOf());
    const publicMenu = `https://dineq.app/user/restaurant-display/${r.slug}`;
    const imageUrl = `https://api.qrserver.com/v1/create-qr-code/?size=600x600&data=${encodeURIComponent(publicMenu)}`;
    return {
      _id: ObjectId(),
      imageUrl,
      publicMenuUrl: publicMenu,
      downloadUrl: imageUrl,
      menuId: mainMenu ? mainMenu._id.valueOf() : "",
      restaurantId: r._id.valueOf(),
      isActive: true,
      createdAt: daysAgo(20),
      expiresAt: daysAgo(-365),
      isDeleted: false,
      deletedAt: null,
    };
  });

  // View events (restaurants + menus + items), last 30 days with strong recent traffic
  const views = [];
  for (let d = 0; d < 30; d++) {
    restaurants.forEach((r, ri) => {
      const dailyBurst = d < 7 ? 22 : d < 14 ? 14 : 8;
      for (let j = 0; j < dailyBurst; j++) {
        const hour = 8 + (j % 14);
        const stamp = new Date(daysAgo(d).setHours(hour, (j * 7) % 60, 0, 0));

        views.push({
          _id: ObjectId(),
          entityType: "restaurant",
          entityId: r._id.valueOf(),
          userId: customerPool[(ri + j) % customerPool.length]._id.valueOf(),
          timestamp: stamp,
          ip: `196.188.${(ri + 10) % 255}.${(j + 20) % 255}`,
          userAgent:
            "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 Chrome/123.0.0.0 Safari/537.36",
        });
      }
    });
  }

  menus.forEach((m, i) => {
    for (let j = 0; j < 40; j++) {
      views.push({
        _id: ObjectId(),
        entityType: "menu",
        entityId: m._id.valueOf(),
        userId: customerPool[(i + j) % customerPool.length]._id.valueOf(),
        timestamp: hoursAgo((j % 72) + i),
        ip: `102.89.${(i + 12) % 255}.${(j + 40) % 255}`,
        userAgent:
          "Mozilla/5.0 (iPhone; CPU iPhone OS 17_3 like Mac OS X) AppleWebKit/605.1.15 Mobile/15E148",
      });
    }
  });

  items.slice(0, 30).forEach((it, i) => {
    for (let j = 0; j < 18; j++) {
      views.push({
        _id: ObjectId(),
        entityType: "item",
        entityId: it._id.valueOf(),
        userId: customerPool[(i + j + 1) % customerPool.length]._id.valueOf(),
        timestamp: hoursAgo((j % 48) + i),
        ip: `154.72.${(i + 30) % 255}.${(j + 77) % 255}`,
        userAgent:
          "Mozilla/5.0 (Linux; Android 14; Pixel 8) AppleWebKit/537.36 Chrome/123.0.0.0 Mobile Safari/537.36",
      });
    }
  });

  // Remove helper-only field from restaurants
  restaurants.forEach((r) => delete r.__setIndex);

  const asStringID = (value) => {
    if (value === null || value === undefined) return "";
    if (typeof value === "string") {
      const m = value.match(/^[0-9a-fA-F]{24}$/);
      if (m) return value;
      const m2 = value.match(/ObjectId\((?:"|')?([0-9a-fA-F]{24})(?:"|')?\)/);
      return m2 ? m2[1] : value;
    }
    if (typeof value === "object") {
      if (typeof value.str === "string" && /^[0-9a-fA-F]{24}$/.test(value.str))
        return value.str;
      if (typeof value.toHexString === "function") return value.toHexString();
      if (typeof value.valueOf === "function") {
        const v = value.valueOf();
        if (typeof v === "string") {
          const m3 = v.match(/^[0-9a-fA-F]{24}$/);
          if (m3) return v;
          const m4 = v.match(/ObjectId\((?:"|')?([0-9a-fA-F]{24})(?:"|')?\)/);
          if (m4) return m4[1];
        }
      }
    }
    return String(value);
  };

  // Normalize generated docs to backend mapper expectations (string ref IDs)
  const normalizedMenus = menus.map((m) => ({
    ...m,
    restaurantId: asStringID(m.restaurantId),
    createdBy: asStringID(m.createdBy),
    updatedBy: asStringID(m.updatedBy),
    items: (m.items || []).map((it) => ({
      ...it,
      reviewIds: Array.isArray(it.reviewIds)
        ? it.reviewIds.map((id) => asStringID(id))
        : [],
    })),
  }));

  const normalizedItems = items.map((it) => ({
    ...it,
    reviewIds: Array.isArray(it.reviewIds)
      ? it.reviewIds.map((id) => asStringID(id))
      : [],
  }));

  const normalizedReviews = reviews.map((r) => ({
    ...r,
    itemId: asStringID(r.itemId),
    userId: asStringID(r.userId),
    restaurantId: asStringID(r.restaurantId),
    reactionIds: Array.isArray(r.reactionIds)
      ? r.reactionIds.map((id) => asStringID(id))
      : [],
  }));

  const normalizedReactions = reactions.map((r) => ({
    ...r,
    reviewId: asStringID(r.reviewId),
    itemId: asStringID(r.itemId),
    userId: asStringID(r.userId),
  }));

  const normalizedQrs = qrs.map((q) => ({
    ...q,
    menuId: asStringID(q.menuId),
    restaurantId: asStringID(q.restaurantId),
  }));

  const normalizedViews = views.map((v) => ({
    ...v,
    entityId: asStringID(v.entityId),
    userId: asStringID(v.userId),
  }));

  // Repair legacy seed records that accidentally stored ObjectId refs in string fields.
  // This keeps old data while making menu lookup work for owner/dashboard flows.
  db.getCollection(COLLECTIONS.menus)
    .find({ restaurantId: { $type: "objectId" } })
    .forEach((doc) => {
      db.getCollection(COLLECTIONS.menus).updateOne(
        { _id: doc._id },
        {
          $set: {
            restaurantId: asStringID(doc.restaurantId),
            createdBy: asStringID(doc.createdBy),
            updatedBy: asStringID(doc.updatedBy),
          },
        },
      );
    });

  // append-only/upsert insert (preserve existing data)
  const upsertByField = (collectionName, docs, keyField) => {
    if (!docs || docs.length === 0) return;
    const ops = docs.map((doc) => ({
      updateOne: {
        filter: { [keyField]: doc[keyField] },
        update: {
          $set: Object.fromEntries(
            Object.entries(doc).filter(([k]) => k !== "_id"),
          ),
          $setOnInsert: { _id: doc._id },
        },
        upsert: true,
      },
    }));
    db.getCollection(collectionName).bulkWrite(ops, { ordered: false });
  };

  upsertByField(COLLECTIONS.users, users, "email");
  upsertByField(COLLECTIONS.restaurants, restaurants, "slug");

  // Resolve persisted restaurant IDs by slug so menu.restaurantId always matches DB reality
  const restaurantIdBySlug = {};
  restaurants.forEach((r) => {
    const persisted = db
      .getCollection(COLLECTIONS.restaurants)
      .findOne({ slug: r.slug }, { projection: { _id: 1 } });
    restaurantIdBySlug[r.slug] = persisted
      ? asStringID(persisted._id)
      : asStringID(r._id);
  });

  // Repair historical mismatches from previous seed runs.
  Object.entries(restaurantIdBySlug).forEach(([slug, rid]) => {
    db.getCollection(COLLECTIONS.menus).updateMany(
      { RestaurantSlug: slug },
      { $set: { restaurantId: rid } },
    );
  });

  const normalizedMenusWithCanonicalRestaurant = normalizedMenus.map((m) => ({
    ...m,
    restaurantId:
      restaurantIdBySlug[m.RestaurantSlug] || asStringID(m.restaurantId),
  }));

  upsertByField(
    COLLECTIONS.menus,
    normalizedMenusWithCanonicalRestaurant,
    "slug",
  );
  db.getCollection(COLLECTIONS.items).insertMany(normalizedItems);
  db.getCollection(COLLECTIONS.reviews).insertMany(normalizedReviews);
  db.getCollection(COLLECTIONS.reactions).insertMany(normalizedReactions);
  db.getCollection(COLLECTIONS.qr).insertMany(normalizedQrs);
  db.getCollection(COLLECTIONS.views).insertMany(normalizedViews);

  print(
    "\n✅ Seed completed successfully (append-only, existing data preserved)",
  );
  printjson({
    users: users.length,
    restaurants: restaurants.length,
    menus: menus.length,
    items: items.length,
    reviews: reviews.length,
    reactions: reactions.length,
    qr: qrs.length,
    views: views.length,
  });

  print("\nDemo sign-in users:");
  print("  Owner:   mesfin@dineqseed.com");
  print("  Manager: samuel@dineqseed.com");
  print("  Customer: abel.negash@mailseed.com");
  print(
    "  Password hash is seeded (demo hash), use your normal auth flow / reset to test plain passwords.",
  );
})();

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
    notifications: "notifications",
    refreshTokens: "refresh_tokens",
    otp: "otp",
    ocrJobs: "ocr_jobs",
    views: "views",
    passwordResetTokens: "password_reset_tokens",
    passwordResetSessions: "password_reset_session_collections",
  };

  const now = new Date();
  const hoursAgo = (h) => new Date(now.getTime() - h * 60 * 60 * 1000);
  const daysAgo = (d) => new Date(now.getTime() - d * 24 * 60 * 60 * 1000);

  // bcrypt hash for a common demo password (for seeded users)
  const DEMO_PASSWORD_HASH =
    "$2a$10$7EqJtq98hPqEX7fNZaFWoOQJ8L5yN7EzxKQEiC5EvhczHxVh9Yx8e";

  const photo = {
    logos: [
      "https://images.unsplash.com/photo-1556740749-887f6717d7e4?auto=format&fit=crop&w=512&q=80",
      "https://images.unsplash.com/photo-1521791136064-7986c2920216?auto=format&fit=crop&w=512&q=80",
      "https://images.unsplash.com/photo-1556761175-b413da4baf72?auto=format&fit=crop&w=512&q=80",
      "https://images.unsplash.com/photo-1600880292203-757bb62b4baf?auto=format&fit=crop&w=512&q=80",
    ],
    covers: [
      "https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?auto=format&fit=crop&w=1600&q=80",
      "https://images.unsplash.com/photo-1555396273-367ea4eb4db5?auto=format&fit=crop&w=1600&q=80",
      "https://images.unsplash.com/photo-1414235077428-338989a2e8c0?auto=format&fit=crop&w=1600&q=80",
      "https://images.unsplash.com/photo-1559339352-11d035aa65de?auto=format&fit=crop&w=1600&q=80",
      "https://images.unsplash.com/photo-1541544741938-0af808871cc0?auto=format&fit=crop&w=1600&q=80",
      "https://images.unsplash.com/photo-1590846406792-0adc7f938f1d?auto=format&fit=crop&w=1600&q=80",
    ],
    dishes: [
      "https://images.unsplash.com/photo-1544025162-d76694265947?auto=format&fit=crop&w=1200&q=80",
      "https://images.unsplash.com/photo-1604908176997-431dc7f6d9b5?auto=format&fit=crop&w=1200&q=80",
      "https://images.unsplash.com/photo-1512621776951-a57141f2eefd?auto=format&fit=crop&w=1200&q=80",
      "https://images.unsplash.com/photo-1546069901-ba9599a7e63c?auto=format&fit=crop&w=1200&q=80",
      "https://images.unsplash.com/photo-1603133872878-684f208fb84b?auto=format&fit=crop&w=1200&q=80",
      "https://images.unsplash.com/photo-1529042410759-befb1204b468?auto=format&fit=crop&w=1200&q=80",
      "https://images.unsplash.com/photo-1482049016688-2d3e1b311543?auto=format&fit=crop&w=1200&q=80",
      "https://images.unsplash.com/photo-1467003909585-2f8a72700288?auto=format&fit=crop&w=1200&q=80",
      "https://images.unsplash.com/photo-1512058564366-18510be2db19?auto=format&fit=crop&w=1200&q=80",
      "https://images.unsplash.com/photo-1514516816566-de580c621376?auto=format&fit=crop&w=1200&q=80",
      "https://images.unsplash.com/photo-1473093295043-cdd812d0e601?auto=format&fit=crop&w=1200&q=80",
      "https://images.unsplash.com/photo-1504674900247-0877df9cc836?auto=format&fit=crop&w=1200&q=80",
      "https://images.unsplash.com/photo-1562967916-eb82221dfb92?auto=format&fit=crop&w=1200&q=80",
      "https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?auto=format&fit=crop&w=1200&q=80",
      "https://images.unsplash.com/photo-1521389508051-d7ffb5dc8f70?auto=format&fit=crop&w=1200&q=80",
      "https://images.unsplash.com/photo-1515003197210-e0cd71810b5f?auto=format&fit=crop&w=1200&q=80",
      "https://images.unsplash.com/photo-1539136788836-5699e78bfc75?auto=format&fit=crop&w=1200&q=80",
      "https://images.unsplash.com/photo-1515003197210-e0cd71810b5f?auto=format&fit=crop&w=1200&q=80",
      "https://images.unsplash.com/photo-1550547660-d9450f859349?auto=format&fit=crop&w=1200&q=80",
      "https://images.unsplash.com/photo-1568901346375-23c9450c58cd?auto=format&fit=crop&w=1200&q=80",
    ],
  };

  const ethiopianItems = [
    {
      name: "Doro Wot",
      am: "ዶሮ ወጥ",
      price: 360,
      tags: ["Lunch", "Traditional"],
      kcal: 620,
      prot: 41,
      carbs: 36,
      fat: 34,
      prep: 35,
      allergies: ["Egg", "Butter"],
    },
    {
      name: "Shiro Wot",
      am: "ሽሮ ወጥ",
      price: 250,
      tags: ["Vegan", "Traditional"],
      kcal: 450,
      prot: 20,
      carbs: 65,
      fat: 12,
      prep: 20,
      allergies: ["Legumes"],
    },
    {
      name: "Tibs",
      am: "ጥብስ",
      price: 410,
      tags: ["Dinner", "Spicy"],
      kcal: 580,
      prot: 50,
      carbs: 14,
      fat: 35,
      prep: 18,
      allergies: [],
    },
    {
      name: "Kitfo",
      am: "ክትፎ",
      price: 470,
      tags: ["Dinner", "Traditional"],
      kcal: 690,
      prot: 38,
      carbs: 9,
      fat: 54,
      prep: 15,
      allergies: ["Butter"],
    },
    {
      name: "Firfir",
      am: "ፍርፍር",
      price: 230,
      tags: ["Breakfast", "Traditional"],
      kcal: 510,
      prot: 16,
      carbs: 70,
      fat: 17,
      prep: 12,
      allergies: ["Gluten"],
    },
    {
      name: "Beyaynetu",
      am: "በያይነቱ",
      price: 300,
      tags: ["Vegan", "Lunch"],
      kcal: 540,
      prot: 18,
      carbs: 74,
      fat: 16,
      prep: 25,
      allergies: ["Legumes"],
    },
  ];

  const italianItems = [
    {
      name: "Margherita Pizza",
      am: "ማርጋሪታ ፒዛ",
      price: 520,
      tags: ["Pizza", "Lunch"],
      kcal: 720,
      prot: 28,
      carbs: 82,
      fat: 30,
      prep: 18,
      allergies: ["Dairy", "Gluten"],
    },
    {
      name: "Spaghetti Carbonara",
      am: "ካርቦናራ",
      price: 560,
      tags: ["Pasta", "Dinner"],
      kcal: 780,
      prot: 32,
      carbs: 76,
      fat: 38,
      prep: 20,
      allergies: ["Egg", "Dairy", "Gluten"],
    },
    {
      name: "Minestrone Soup",
      am: "ሚነስትሮኔ",
      price: 290,
      tags: ["Soup", "Vegan"],
      kcal: 280,
      prot: 9,
      carbs: 44,
      fat: 7,
      prep: 15,
      allergies: ["Celery"],
    },
    {
      name: "Chicken Alfredo",
      am: "ቺክን አልፍሬዶ",
      price: 610,
      tags: ["Pasta", "Dinner"],
      kcal: 860,
      prot: 39,
      carbs: 73,
      fat: 46,
      prep: 22,
      allergies: ["Dairy", "Gluten"],
    },
    {
      name: "Bruschetta",
      am: "ብሩስኬታ",
      price: 240,
      tags: ["Starter"],
      kcal: 310,
      prot: 8,
      carbs: 35,
      fat: 15,
      prep: 10,
      allergies: ["Gluten"],
    },
    {
      name: "Tiramisu",
      am: "ቲራሚሱ",
      price: 280,
      tags: ["Dessert"],
      kcal: 420,
      prot: 7,
      carbs: 40,
      fat: 25,
      prep: 8,
      allergies: ["Dairy", "Egg", "Gluten"],
    },
  ];

  const asianItems = [
    {
      name: "Chicken Teriyaki Bowl",
      am: "ቴሪያኪ ቦውል",
      price: 540,
      tags: ["Rice Bowl", "Lunch"],
      kcal: 650,
      prot: 36,
      carbs: 74,
      fat: 19,
      prep: 17,
      allergies: ["Soy", "Sesame"],
    },
    {
      name: "Beef Ramen",
      am: "ቢፍ ራመን",
      price: 590,
      tags: ["Noodles", "Dinner"],
      kcal: 700,
      prot: 34,
      carbs: 78,
      fat: 26,
      prep: 20,
      allergies: ["Gluten", "Soy"],
    },
    {
      name: "Sushi Combo",
      am: "ሱሺ ኮምቦ",
      price: 760,
      tags: ["Sushi", "Signature"],
      kcal: 590,
      prot: 30,
      carbs: 62,
      fat: 21,
      prep: 18,
      allergies: ["Fish", "Soy", "Sesame"],
    },
    {
      name: "Pad Thai",
      am: "ፓድ ታይ",
      price: 530,
      tags: ["Noodles", "Popular"],
      kcal: 680,
      prot: 22,
      carbs: 86,
      fat: 24,
      prep: 16,
      allergies: ["Peanut", "Shellfish"],
    },
    {
      name: "Spring Rolls",
      am: "ስፕሪንግ ሮልስ",
      price: 260,
      tags: ["Starter"],
      kcal: 330,
      prot: 9,
      carbs: 43,
      fat: 12,
      prep: 9,
      allergies: ["Gluten"],
    },
    {
      name: "Mango Sticky Rice",
      am: "ማንጎ ስቲኪ ራይስ",
      price: 290,
      tags: ["Dessert"],
      kcal: 360,
      prot: 5,
      carbs: 68,
      fat: 8,
      prep: 7,
      allergies: [],
    },
  ];

  const cafeItems = [
    {
      name: "Avocado Toast",
      am: "አቮካዶ ቶስት",
      price: 290,
      tags: ["Breakfast", "Healthy"],
      kcal: 370,
      prot: 11,
      carbs: 39,
      fat: 18,
      prep: 8,
      allergies: ["Gluten"],
    },
    {
      name: "Shakshuka",
      am: "ሻክሹካ",
      price: 320,
      tags: ["Breakfast", "Popular"],
      kcal: 430,
      prot: 21,
      carbs: 24,
      fat: 27,
      prep: 12,
      allergies: ["Egg"],
    },
    {
      name: "Club Sandwich",
      am: "ክለብ ሳንድዊች",
      price: 340,
      tags: ["Lunch"],
      kcal: 560,
      prot: 27,
      carbs: 48,
      fat: 29,
      prep: 11,
      allergies: ["Gluten", "Egg"],
    },
    {
      name: "Iced Latte",
      am: "አይስድ ላቴ",
      price: 180,
      tags: ["Drinks", "Coffee"],
      kcal: 160,
      prot: 7,
      carbs: 18,
      fat: 6,
      prep: 4,
      allergies: ["Dairy"],
    },
    {
      name: "Blueberry Pancakes",
      am: "ብሉቤሪ ፓንኬክ",
      price: 310,
      tags: ["Breakfast", "Sweet"],
      kcal: 520,
      prot: 12,
      carbs: 74,
      fat: 18,
      prep: 10,
      allergies: ["Gluten", "Egg", "Dairy"],
    },
    {
      name: "Cheesecake Slice",
      am: "ቺዝኬክ",
      price: 240,
      tags: ["Dessert"],
      kcal: 410,
      prot: 6,
      carbs: 34,
      fat: 28,
      prep: 5,
      allergies: ["Dairy", "Egg", "Gluten"],
    },
  ];

  const itemSets = [ethiopianItems, italianItems, asianItems, cafeItems];

  const users = [];
  const ownerUsers = [
    {
      username: "mesfin_addis",
      first: "Mesfin",
      last: "Bekele",
      email: "mesfin@dineqseed.com",
      phone: "+251911200301",
      role: "OWNER",
    },
    {
      username: "hana_harbor",
      first: "Hana",
      last: "Tesfaye",
      email: "hana@dineqseed.com",
      phone: "+251911200302",
      role: "OWNER",
    },
    {
      username: "samuel_spice",
      first: "Samuel",
      last: "Mekonnen",
      email: "samuel@dineqseed.com",
      phone: "+251911200303",
      role: "MANAGER",
    },
    {
      username: "liya_roast",
      first: "Liya",
      last: "Kassa",
      email: "liya@dineqseed.com",
      phone: "+251911200304",
      role: "MANAGER",
    },
  ];

  ownerUsers.forEach((u, i) => {
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
      profileImage: photo.logos[i % photo.logos.length],
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
      profileImage: photo.logos[(i + 1) % photo.logos.length],
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
    profileImage: photo.logos[0],
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
      slug: "abay-signature-addis",
      name: "Abay Signature Addis",
      phone: "+251115123456",
      tags: ["Ethiopian", "Traditional", "Family"],
      about:
        "A flagship Ethiopian dining experience with slow-cooked stews, injera from teff, and live traditional coffee ceremony every evening.",
      taxId: "ET-TIN-ABAY-001",
      coords: [38.7578, 8.9806],
      colors: ["#8B4513", "#D2691E"],
      currency: "ETB",
      language: "am-ET",
      vat: 15,
      setIndex: 0,
      coverIndex: 0,
    },
    {
      slug: "porto-italia-bole",
      name: "Porto Italia Bole",
      phone: "+251116345678",
      tags: ["Italian", "Pizza", "Date Night"],
      about:
        "Wood-fired pizza oven, handmade pasta, and classic Italian desserts in a warm casual-fine setting.",
      taxId: "ET-TIN-PORTO-002",
      coords: [38.7893, 9.0107],
      colors: ["#1F7A1F", "#C0392B"],
      currency: "ETB",
      language: "en-US",
      vat: 15,
      setIndex: 1,
      coverIndex: 1,
    },
    {
      slug: "sakura-asian-kitchen",
      name: "Sakura Asian Kitchen",
      phone: "+251117456789",
      tags: ["Asian", "Sushi", "Noodles"],
      about:
        "Modern pan-Asian kitchen serving ramen, sushi, rice bowls, and crafted tea pairings.",
      taxId: "ET-TIN-SAKURA-003",
      coords: [38.7421, 9.0214],
      colors: ["#111827", "#EF4444"],
      currency: "ETB",
      language: "en-US",
      vat: 15,
      setIndex: 2,
      coverIndex: 2,
    },
    {
      slug: "sunrise-brunch-house",
      name: "Sunrise Brunch House",
      phone: "+251118567890",
      tags: ["Cafe", "Brunch", "Coffee"],
      about:
        "All-day brunch, premium coffee roast, and artisan bakery with bright naturally lit interiors.",
      taxId: "ET-TIN-SUNRISE-004",
      coords: [38.7728, 8.9982],
      colors: ["#F59E0B", "#0EA5E9"],
      currency: "ETB",
      language: "en-US",
      vat: 15,
      setIndex: 3,
      coverIndex: 3,
    },
  ];

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
      logoImage: photo.logos[i % photo.logos.length],
      verificationStatus: i === 3 ? "pending" : "verified",
      verificationDocs: `https://images.unsplash.com/photo-1450101499163-c8848c66ca85?auto=format&fit=crop&w=1200&q=80&doc=${i + 1}`,
      schedule: [
        {
          day: "monday",
          is_open: true,
          start_time: "08:00",
          end_time: "22:00",
        },
        {
          day: "tuesday",
          is_open: true,
          start_time: "08:00",
          end_time: "22:00",
        },
        {
          day: "wednesday",
          is_open: true,
          start_time: "08:00",
          end_time: "22:00",
        },
        {
          day: "thursday",
          is_open: true,
          start_time: "08:00",
          end_time: "22:00",
        },
        {
          day: "friday",
          is_open: true,
          start_time: "08:00",
          end_time: "23:00",
        },
        {
          day: "saturday",
          is_open: true,
          start_time: "09:00",
          end_time: "23:00",
        },
        {
          day: "sunday",
          is_open: true,
          start_time: "09:00",
          end_time: "21:00",
        },
      ],
      specialDays: [
        {
          date: "2026-12-25",
          is_open: true,
          start_time: "10:00",
          end_time: "20:00",
        },
        {
          date: "2026-01-07",
          is_open: true,
          start_time: "10:00",
          end_time: "19:00",
        },
      ],
      defaultCurrency: r.currency,
      defaultLanguage: r.language,
      defaultVat: r.vat,
      taxId: r.taxId,
      tags: r.tags,
      primaryColor: r.colors[0],
      accentColor: r.colors[1],
      coverImage: photo.covers[r.coverIndex],
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
      { suffix: "chef-specials", title: "Chef Specials", published: true },
    ].forEach((menuMeta, mIndex) => {
      const menuId = ObjectId();
      const createdAt = daysAgo(60 - rIndex * 5 - mIndex * 2);
      const selectedItems = set
        .slice(mIndex * 3, mIndex * 3 + 3)
        .concat(set.slice(0, 1));

      const embeddedItems = selectedItems.map((base, i) => {
        const itemId = ObjectId();
        const slug = `${base.name.toLowerCase().replace(/[^a-z0-9]+/g, "-")}-${(rIndex + 1).toString()}${(mIndex + 1).toString()}${(i + 1).toString()}`;
        const imageUrl = photo.dishes[dishPhotoCursor % photo.dishes.length];
        dishPhotoCursor += 1;

        const doc = {
          _id: itemId,
          name: base.name,
          nameAm: base.am,
          slug,
          menuSlug: `${rest.slug}-${menuMeta.suffix}`,
          description: `${base.name} prepared with premium ingredients, balanced seasoning, and house-style finishing for consistent quality and flavor depth.`,
          descriptionAm: `${base.am} በቤቱ ዘዴ በጥራት እቃዎች ተዘጋጅቶ የሚቀርብ ምግብ።`,
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
          ingredients: ["House spice blend", "Fresh herbs", "Premium produce"],
          ingredientsAm: ["የቤት ቅመም", "አዲስ ቅጠል", "ጥራት ያለው እቃ"],
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

  // Generate realistic review distribution over first 32 items
  items.slice(0, 32).forEach((it, idx) => {
    const reviewCount = 2 + (idx % 3); // 2..4
    const relevantRestaurant = restaurants.find((r) =>
      menus.some(
        (m) =>
          m.restaurantId === r._id.valueOf() &&
          m.items.some((mi) => mi._id.valueOf() === it._id.valueOf()),
      ),
    );

    for (let i = 0; i < reviewCount; i++) {
      const customer = customerPool[(idx + i) % customerPool.length];
      const rating = [4, 5, 3.5, 4.5, 5, 4][(idx + i) % 6];
      const rid = ObjectId();
      const createdAt = daysAgo((idx % 20) + i + 1);

      const review = {
        _id: rid,
        itemId: it._id.valueOf(),
        userId: customer._id.valueOf(),
        restaurantId: relevantRestaurant
          ? relevantRestaurant._id.valueOf()
          : restaurants[0]._id.valueOf(),
        imageUrls:
          i % 2 === 0
            ? [photo.dishes[(idx + i + 5) % photo.dishes.length]]
            : [],
        username: customer.username,
        userProfileImage: customer.profileImage,
        description:
          rating >= 4.5
            ? "Outstanding balance, authentic taste, and generous portion. Service was quick and friendly."
            : rating >= 4
              ? "Very tasty and well presented. Slightly salty but still excellent overall experience."
              : "Good flavor profile and texture, though portion size could be improved.",
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

  // Notifications
  const notifications = [];
  users.forEach((u, i) => {
    notifications.push({
      _id: ObjectId(),
      userId: u._id.valueOf(),
      message:
        i % 3 === 0
          ? "Welcome to DineQ! Your profile is fully set up."
          : i % 3 === 1
            ? "A new review was posted on one of your menu items."
            : "Your weekly analytics snapshot is ready.",
      type: i % 3 === 0 ? "SYSTEM" : i % 3 === 1 ? "INFO" : "INFO_UPDATE",
      isRead: i % 4 === 0,
      createdAt: daysAgo((i % 10) + 1),
      updatedAt: daysAgo(i % 5),
    });
  });

  // Refresh token docs
  const refreshTokens = users.map((u, i) => ({
    tokenHash: `seed_refresh_hash_${u._id.valueOf()}_${i}`,
    userId: u._id.valueOf(),
    revoked: i % 9 === 0,
    expiresAt: daysAgo(-14),
    createdAt: daysAgo(1 + (i % 5)),
  }));

  // OTP docs (active + expired examples)
  const otpDocs = customerPool.slice(0, 6).map((u, i) => ({
    _id: ObjectId(),
    email: u.email,
    codeHash: `otp_hash_demo_${i + 1}`,
    expiresAt: i < 4 ? hoursAgo(-1) : hoursAgo(1),
    attempts: i % 3,
    createdAt: hoursAgo(2 + i),
  }));

  // Password reset tokens + sessions
  const passResetTokens = customerPool.slice(0, 4).map((u, i) => ({
    _id: ObjectId(),
    email: u.email,
    rateLimit: i + 1,
    tokenHash: `pwreset_hash_${i}_${u._id.valueOf()}`,
    expiresAt: i % 2 === 0 ? hoursAgo(-2) : hoursAgo(2),
    used: i % 2 === 0,
    createdAt: hoursAgo(3 + i),
  }));

  const passResetSessions = customerPool.slice(0, 3).map((u, i) => ({
    _id: ObjectId(),
    userId: u._id.valueOf(),
    token: `reset_session_token_${i + 1}_${u._id.valueOf()}`,
    expiresAt: i === 0 ? hoursAgo(1) : hoursAgo(-1),
  }));

  // OCR Jobs
  const ocrJobs = restaurants.map((r, i) => {
    const menu = menus.find((m) => m.restaurantId === r._id.valueOf());
    const owner = users.find((u) => u._id.valueOf() === r.managerId.valueOf());
    const status = i === 3 ? "failed" : i === 2 ? "processing" : "completed";
    const completedAt = status === "completed" ? daysAgo(2 + i) : null;

    return {
      _id: ObjectId(),
      restaurantId: r._id.valueOf(),
      imageUrl: photo.covers[(i + 2) % photo.covers.length],
      userId: owner ? owner._id.valueOf() : users[0]._id.valueOf(),
      status,
      resultText:
        status === "failed"
          ? "OCR extraction failed due to low image quality."
          : "Parsed menu successfully with multilingual enrichment.",
      structuredMenuId: menu ? menu._id.valueOf() : "",
      error: status === "failed" ? "Image blur exceeded threshold." : "",
      createdAt: daysAgo(8 + i),
      updatedAt: daysAgo(1 + i),
      estimatedCompletion: daysAgo(7 + i),
      completedAt,
      results:
        status === "failed"
          ? null
          : {
              extracted_text:
                "Sample OCR extraction text including menu sections and item names.",
              photo_matches: [
                photo.dishes[(i + 1) % photo.dishes.length],
                photo.dishes[(i + 5) % photo.dishes.length],
              ],
              confidence_score: status === "processing" ? 0.72 : 0.93,
              structured_menu_id: menu ? menu._id.valueOf() : "",
              menu: menu
                ? {
                    id: menu._id.valueOf(),
                    name: menu.name,
                    slug: menu.slug,
                    items: menu.items
                      .slice(0, 2)
                      .map((mi) => ({
                        id: mi._id.valueOf(),
                        name: mi.name,
                        price: mi.price,
                      })),
                  }
                : null,
              raw_ai_json: '{"status":"ok","source":"gemini"}',
            },
      rawAiJson:
        status === "failed"
          ? ""
          : '{"model":"gemini-2.0-flash","structured":true}',
      phase:
        status === "failed"
          ? "ai_structuring"
          : status === "processing"
            ? "ocr_extraction"
            : "completed",
      progress: status === "failed" ? 58 : status === "processing" ? 41 : 100,
      phaseHistory: [
        {
          name: "received",
          status: "done",
          startedAt: daysAgo(8 + i),
          endedAt: daysAgo(8 + i),
        },
        {
          name: "ocr_extraction",
          status: status === "processing" ? "running" : "done",
          startedAt: daysAgo(8 + i),
          endedAt: status === "processing" ? null : daysAgo(7 + i),
        },
        {
          name: "ai_structuring",
          status:
            status === "failed"
              ? "failed"
              : status === "processing"
                ? "pending"
                : "done",
          startedAt:
            status === "failed" || status === "completed"
              ? daysAgo(7 + i)
              : null,
          endedAt: status === "completed" ? daysAgo(6 + i) : null,
        },
      ],
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

  const normalizedNotifications = notifications.map((n) => ({
    ...n,
    userId: asStringID(n.userId),
  }));

  const normalizedRefreshTokens = refreshTokens.map((t) => ({
    ...t,
    userId: asStringID(t.userId),
    tokenHash: `seed_refresh_hash_${asStringID(t.userId)}`,
  }));

  const normalizedResetSessions = passResetSessions.map((s) => ({
    ...s,
    userId: asStringID(s.userId),
    token:
      s.token || `reset_session_token_${asStringID(s.userId)}_${Date.now()}`,
  }));

  const normalizedOcrJobs = ocrJobs.map((j) => ({
    ...j,
    restaurantId: asStringID(j.restaurantId),
    userId: asStringID(j.userId),
    structuredMenuId: asStringID(j.structuredMenuId),
    results: j.results
      ? {
          ...j.results,
          structured_menu_id: asStringID(j.results.structured_menu_id),
          menu: j.results.menu
            ? {
                ...j.results.menu,
                id: asStringID(j.results.menu.id),
                items: Array.isArray(j.results.menu.items)
                  ? j.results.menu.items.map((mi) => ({
                      ...mi,
                      id: asStringID(mi.id),
                    }))
                  : [],
              }
            : null,
        }
      : null,
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
  db.getCollection(COLLECTIONS.notifications).insertMany(
    normalizedNotifications,
  );
  db.getCollection(COLLECTIONS.refreshTokens).insertMany(
    normalizedRefreshTokens,
  );
  db.getCollection(COLLECTIONS.otp).insertMany(otpDocs);
  db.getCollection(COLLECTIONS.passwordResetTokens).insertMany(passResetTokens);
  db.getCollection(COLLECTIONS.passwordResetSessions).insertMany(
    normalizedResetSessions,
  );
  db.getCollection(COLLECTIONS.ocrJobs).insertMany(normalizedOcrJobs);
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
    notifications: notifications.length,
    refreshTokens: refreshTokens.length,
    otp: otpDocs.length,
    passwordResetTokens: passResetTokens.length,
    passwordResetSessions: passResetSessions.length,
    ocrJobs: ocrJobs.length,
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

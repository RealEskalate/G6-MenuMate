// data/menu.ts


export type MenuItem = {
  id: string;
  title: string;
  description: string;
  price: number;
  image: string;
  section: string;
  category?: string;
  language?: string;
  ingredients: string[];
  howToEat: string;
};



export const menuData: MenuItem[] = [
  {
    id: "1",
    title: "Doro Wat",
    description: "Spicy chicken stew with berbere sauce, served with injera.",
    price: 350,
    image: "/loginfood.png",
    section: "Main Dishes",
    category: "Breakfast",
    language: "Amharic",
    ingredients: ["Chicken", "Berbere", "Onions", "Garlic"],
    howToEat: "Eat with injera",
  },
  {
    id: "2",
    title: "Tibs",
    description: "Sour flatbread served with sautéed meat and vegetables.",
    price: 350,
    image: "/loginfood.png",
    section: "Main Dishes",
    category: "Breakfast",
    language: "Amharic",
    ingredients: ["Beef", "Onions", "Spices", "Vegetables"],
    howToEat: "Serve hot with injera or bread",
  },
  {
    id: "3",
    title: "Gomen",
    description: "Collard greens cooked with garlic, ginger, and spices.",
    price: 350,
    image: "/loginfood.png",
    section: "Main Dishes",
    category: "Breakfast",
    language: "Amharic",
    ingredients: ["Collard greens", "Garlic", "Ginger", "Oil"],
    howToEat: "Best with injera",
  },
  {
    id: "4",
    title: "Kitfo",
    description: "Minced beef tartare with spices and clarified butter.",
    price: 350,
    image: "/loginfood.png",
    section: "Main Dishes",
    category: "Lunch",
    language: "Amharic",
    ingredients: ["Beef", "Spices", "Niter Kibbeh"],
    howToEat: "Serve with injera or kocho",
  },
  {
    id: "5",
    title: "Shiro",
    description: "Ground chickpea stew with Ethiopian spices and herbs.",
    price: 350,
    image: "/loginfood.png",
    section: "Main Dishes",
    category: "Lunch",
    language: "Amharic",
    ingredients: ["Chickpeas", "Berbere", "Onions", "Garlic"],
    howToEat: "Serve with injera",
  },
  {
    id: "6",
    title: "Kolo",
    description: "Roasted barley and chickpeas with spices. Traditional Ethiopian snack.",
    price: 80,
    image: "/loginfood.png",
    section: "Appetizers",
    category: "",
    ingredients: ["Barley", "Chickpeas", "Salt", "Spices"],
    howToEat: "Eat as a snack",
  },
  {
    id: "7",
    title: "Dabo Kolo",
    description: "Small pieces of bread seasoned with spices. Perfect appetizer or snack.",
    price: 80,
    image: "/loginfood.png",
    section: "Appetizers",
    category: "",
    ingredients: ["Flour", "Butter", "Salt", "Spices"],
    howToEat: "Snack with tea or coffee",
  },
  {
    id: "8",
    title: "Ethiopian Coffee",
    description: "Traditional Ethiopian coffee served in a traditional ceremony. Rich and aromatic.",
    price: 30,
    image: "/loginfood.png",
    section: "Beverages",
    category: "",
    ingredients: ["Coffee beans", "Water"],
    howToEat: "Serve hot in small cups",
  },
  {
    id: "9",
    title: "Tej",
    description: "Traditional Ethiopian honey wine. Sweet and refreshing alcoholic beverage.",
    price: 120,
    image: "/loginfood.png",
    section: "Beverages",
    category: "",
    ingredients: ["Honey", "Water", "Tej yeast"],
    howToEat: "Serve chilled",
  },
];

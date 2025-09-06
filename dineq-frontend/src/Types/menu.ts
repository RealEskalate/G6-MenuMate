export interface NutritionalInfo {
  calories: number;
  protein: number;
  carbs: number;
  fat: number;
}

export interface MenuItem {
  id: string;
  name: string;
  name_am?: string;
  slug: string;
  description?: string;
  description_am?: string;
  price: number;
  currency: string;
  allergies?: string[] | string;
  allergies_am?: string;
  tab_tags: string[];
  tab_tags_am: string[];
  nutritional_info?: NutritionalInfo;
  preparation_time?: number;
  how_to_eat?: string;
  how_to_eat_am?: string;
  created_at: string;
  updated_at: string;
  is_deleted: boolean;
  view_count: number;
  average_rating: number;
  image_url: string;
}

export interface Menu {
  id: string;
  name: string;
  slug: string;
  restaurant_id: string;
  version: number;
  is_published: boolean;
  published_at: string;
  items: MenuItem[];
  created_at: string; //
  updated_at: string;
}

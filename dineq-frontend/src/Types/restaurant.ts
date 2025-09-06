export interface Restaurant {
  id: string;
  slug: string;
  name: string;
  manager_id: string;
  phone: string;
  about: string;
  logo_image: string;
  cover_image: string;
  verification_status: string;
  verification_docs: string;
  average_rating: number;
  view_count: number;
  created_at: string;
  updated_at: string;
}

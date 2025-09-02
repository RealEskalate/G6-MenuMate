export interface Contact {
  phone: string;
  email: string;
}




export interface Restaurant {
  id: string;
  name: string;
  about: string;
  contact: Contact;
  averageRating: number;
  logoImage: string;
}

export interface RestaurantListProps {
  restaurants: Restaurant[];
}
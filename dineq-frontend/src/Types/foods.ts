export interface FoodType {
    id:number,
    name: string,
    price: string,
    description: string,
    image:string
}

export interface FoodListProps {
  foods: FoodType[];
}
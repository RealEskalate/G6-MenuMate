import NavBar from "@/components/common/NavBar";
import Image from "next/image";
import SideBar from "@/components/restaurant/SideBar";
import Dashboard from "./(restaurant)/dashboard/menu/page";
import LandingPage from "./landing_page/page";
import Restaurants from "./user/restaurant-display/page";
import WhoAreYou from "@/components/common/WhoAreYou";
import EmailVerification from "@/components/common/EmailVerification";
import FoodCard from "./user/restaurant-display/food-display/page";
import SingleRestaurant from "./user/restaurant-display/[id]/page";


export default function Home() {
  return (
    <div>
      <LandingPage />
      {/* <Restaurants/> */}
      {/* <WhoAreYou/> */}
      {/* <EmailVerification/> */}
      {/* <FoodCard/> */}
      <NavBar/>
      {/* <SingleRestaurant/> */}
    </div>
  );
}

import LandingPage from "./landing_page/page";
import Restaurants from "./user/restaurant-display/page";
import WhoAreYou from "@/components/common/WhoAreYou";
import EmailVerification from "@/components/common/EmailVerification";
import FoodCard from "./user/restaurant-display/food-display/page";
import SingleRestaurant from "./user/restaurant-display/[id]/page";
import NavBar from "@/components/common/NavBar";



export default function Home() {
  return (
    <div>
      {/* <NavBar role={"user"}/> */}
      <LandingPage />
      {/* <Restaurants/> */}
      {/* <WhoAreYou/> */}
      {/* <EmailVerification/> */}
      {/* <FoodCard/> */}
      {/* <SingleRestaurant/> */}
    </div>
  );
}

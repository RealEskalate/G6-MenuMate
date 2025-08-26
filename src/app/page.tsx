import NavBar from "@/components/common/NavBar";
import Image from "next/image";
import Restaurants from "./user/restaurant/page";
import Footer from "@/components/common/Footer"
import ForgotPassword from "@/components/common/ForgotPassword";
import PageNotFound from "@/components/common/PageNotFound";
import Signin from "@/components/common/Signin";

export default function Home() {
  return (
   <div>
     <NavBar role = "OWNER"/>
     <p>Your one-stop solution for restaurant reservations</p>
     <Restaurants/>
     {/* <Signin/> */}
     {/* <ForgotPassword/> */}
     <Footer/>
   </div>
  );
}

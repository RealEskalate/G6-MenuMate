import NavBar from "@/components/common/NavBar";
import Image from "next/image";

export default function Home() {
  return (
   <div>
     <NavBar role = "OWNER"/>
     <p>Your one-stop solution for restaurant reservations</p>
   </div>
  );
}

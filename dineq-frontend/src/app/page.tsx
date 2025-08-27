import NavBar from "@/components/common/NavBar";
import Image from "next/image";
import SideBar from "@/components/restaurant/SideBar";
import Dashboard from "./(restaurant)/dashboard/menu/page";
import LandingPage from "./landing_page/page";

export default function Home() {
  return (
    <div>
      <LandingPage />
    </div>
  );
}

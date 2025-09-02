import React from "react";
import Header from "./components/Header";
import Hero from "./components/Hero";
import HowItWorks from "./components/HowItWorks";
import CustomizeMenu from "./components/CustomizeMenu";
import FoodLovers from "./components/FoodLovers";
import NoMoreGuessing from "./components/NoMoreGuessing";
import Features from "./components/Features";
import Pricing from "./components/Pricing";
import Footer from "@/components/common/Footer";

export default function LandingPage() {
  return (
    <div className="bg-white z-11">
      <div className="relative h-210 mb-84 bg-orange-100 m-5 rounded-2xl z-5">
        <Header />
        <Hero />
      </div>
      <main>
        <HowItWorks />
        <CustomizeMenu />
        <FoodLovers />
        <NoMoreGuessing />
        <Features />
        <Pricing />
      </main>
      <Footer />
    </div>
  );
}

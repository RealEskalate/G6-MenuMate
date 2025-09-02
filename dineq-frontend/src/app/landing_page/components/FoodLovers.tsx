"use client";
import Image from "next/image";
import Link from "next/link";
import { motion, useInView } from "framer-motion";
import { useRef } from "react";

export default function FoodLovers() {
  const ref = useRef(null);
  const inView = useInView(ref, { once: false, amount: 0.3 });

  return (
    <section className="bg-white py-16 md:py-24" ref={ref}>
      <div className="container mx-auto px-6 grid grid-cols-1 md:grid-cols-2 gap-12 items-center">
        {/* Image Section */}
        <motion.div
          className="relative w-full aspect-[4/3] flex items-center justify-center"
          animate={inView ? { x: 0, opacity: 1 } : { x: 50, opacity: 0 }}
          transition={{ duration: 0.8 }}
        >
          <Image
            src="/foodFestival.png"
            alt="Food Festival image"
            className="w-full h-full object-contain"
          />
        </motion.div>

        {/* Text Section */}
        <motion.div
          className="text-center md:text-right"
          animate={inView ? { x: 0, opacity: 1 } : { x: -50, opacity: 0 }}
          transition={{ duration: 0.8 }}
        >
          <h2 className="text-3xl sm:text-4xl font-extrabold text-gray-800">
            Bring More Food Lovers to Your Doorstep
          </h2>
          <p className="mt-4 text-gray-600">
            Whether you&apos;re running a restaurant, a food festival, or a
            special event, we help you attract the right crowd, boost
            visibility, and turn hungry visitors into loyal customers.
          </p>
          <Link
            href="#"
            className="mt-6 inline-block bg-orange-500 text-white px-6 py-3 rounded-md hover:bg-orange-600 transition-colors duration-200 shadow-md"
          >
            Join us
          </Link>
        </motion.div>
      </div>
    </section>
  );
}

import Image from "next/image";
import Link from "next/link";

export default function NoMoreGuessing() {
  return (
    <section className="bg-orange-100 h-[48rem] py-16 md:py-24">
      <div className="container mx-auto px-6 text-center">
        <h2 className="text-3xl font-bold text-gray-800">
          No More Guessing What's on the Menu
        </h2>
        <p className="mt-6 text-gray-600 max-w-3xl mx-auto">
          Just scan a menu with your phone and instantly see clear dishes with
          real photos, translations, prices, and reviews — all in one place for
          FREE.
        </p>
        <div className="mt-12 flex justify-center space-x-4">
          <Link
            href="#"
            className="bg-orange-500 text-white px-6 py-3 rounded-md hover:bg-orange-600"
          >
            Download on the App Store
          </Link>
          <Link
            href="#"
            className="bg-orange-500 text-white px-6 py-3 rounded-md hover:bg-orange-600"
          >
            Get it on Google Play
          </Link>
        </div>
        <div className="relative z-10 mt-8 flex justify-center items-end overflow-hidden">
          {/* Left phone */}
          <Image
            className="relative z-0 translate-x-11 scale-100"
            src="/nearByRestaurant.png"
            alt="Phone Left"
            width={220}
            height={440}
          />

          {/* Middle phone */}
          <Image
            className="relative z-10"
            src="/nearByRestaurant.png"
            alt="Phone Middle"
            width={250}
            height={500}
          />

          {/* Right phone */}
          <Image
            className="relative z-0 -translate-x-11 scale-100"
            src="/nearByRestaurant.png"
            alt="Phone Right"
            width={220}
            height={440}
          />
        </div>
      </div>
    </section>
  );
}

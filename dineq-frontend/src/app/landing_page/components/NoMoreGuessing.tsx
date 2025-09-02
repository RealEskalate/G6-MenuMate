import Image from "next/image";
import Link from "next/link";

export default function NoMoreGuessing() {
  return (
    <section className="bg-orange-100 pt-16 md:pt-24 flex flex-col justify-between">
      <div className="container mx-auto px-6 text-center">
        <h2 className="text-3xl font-bold text-gray-800">
          No More Guessing What&lsquo;s on the Menu
        </h2>
        <p className="mt-6 text-gray-600 max-w-3xl mx-auto">
          Just scan a menu with your phone and instantly see clear dishes with
          real photos, translations, prices, and reviews — all in one place for
          FREE.
        </p>
        <div className="mt-8 flex flex-col md:flex-row justify-center space-y-4 md:space-y-0 md:space-x-4">
          <Link
            href="#"
            className="bg-orange-500 text-white px-6 py-3 rounded-md hover:bg-orange-600 transition-colors duration-200"
          >
            Download on the App Store
          </Link>
          <Link
            href="#"
            className="bg-orange-500 text-white px-6 py-3 rounded-md hover:bg-orange-600 transition-colors duration-200"
          >
            Get it on Google Play
          </Link>
        </div>

        {/* Mobile-only view with a single phone */}
        <div className="relative z-10 mt-4 flex justify-center items-end md:hidden">
          <Image
            src="/nearByRestaurant.png"
            alt="Phone Middle"
            width={192}
            height={384}
            className="relative z-10 w-48 sm:w-60"
          />
        </div>
      </div>

      {/* Desktop-only view with three phones, aligned to bottom */}
      <div className="hidden md:flex justify-center items-end">
        <div className="relative w-[1200px] h-[500px] max-w-[95%]"> {/* Give a fixed height */}
          <Image
            src="/Threephones.png"
            alt="Phones"
            fill
            style={{ objectFit: "contain" }}
          />
        </div>
      </div>
    </section>
  );
}

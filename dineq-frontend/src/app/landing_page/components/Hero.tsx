import Link from "next/link";
import Image from "next/image";

export default function Hero() {
  return (
    <section className="text-center py-16 md:py-24 px-6 z-5">
      <h1 className="text-4xl md:text-6xl font-bold text-gray-800">
        Digitize Menus. <br />
        <span className="text-orange-500">Discover Real Food.</span>
      </h1>
      <p className="mt-4 text-gray-600 max-w-2xl mx-auto">
        Turn paper menus into digital menus and see real photos of every dish
        before you order.
      </p>
      <div className="mt-8 flex justify-center space-x-4">
        <Link
          href="/auth/user-signup"
          className="bg-orange-500 text-white px-6 py-3 rounded-md hover:bg-orange-600"
        >
          I&lsquo;m a Customer
        </Link>
        <Link
          href="#"
          className="bg-white border border-gray-300 text-gray-700 px-6 py-3 rounded-md hover:bg-gray-100"
        >
          I&lsquo;m a Restaurant
        </Link>
      </div>

      {/* Responsive image section */}
      <div className="mt-5 w-full px-4 sm:px-0">
        <div className="relative w-full aspect-[4/3] max-w-3xl mx-auto rounded-xl overflow-visible shadow-3xl">
          {/* Main background image */}
          <div className="relative w-[170%] h-[170%] -translate-x-1/2 left-1/2 -translate-y-1/2 top-1/2">
            <Image
              src="/heropic.png"
              alt="Image of QR code and food"
              fill
              style={{ objectFit: "cover" }}
            />
          </div>

          {/* Simplified image layout for mobile */}
          <div className="md:hidden absolute bottom-0 w-full px-4 z-20">
            <Image
              src="/heropic.png"
              alt="Phone with the app"
              width={250}
              height={250}
              className="mx-auto object-contain"
            />
          </div>
        </div>
      </div>
    </section>
  );
}

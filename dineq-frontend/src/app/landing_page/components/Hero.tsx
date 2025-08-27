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
        <a
          href="#"
          className="bg-orange-500 text-white px-6 py-3 rounded-md hover:bg-orange-600"
        >
          I'm a Customer
        </a>
        <a
          href="#"
          className="bg-white border border-gray-300 text-gray-700 px-6 py-3 rounded-md hover:bg-gray-100"
        >
          I'm a Restaurant
        </a>
      </div>
      <div
        className="absolute bottom-30 left-1/2 transform -translate-x-1/2 translate-y-1/2 
                  w-full max-w-3xl z-10"
      >
        <div className="relative overflow-hidden bg-gray-300 h-127 rounded-lg flex items-center justify-center shadow-lg">
          <Image
            className="object-cover"
            src="/qrCodeAndFood.png"
            alt="Image of Qrcode and Food"
            fill
          />
          <div className="absolute -bottom-40 z-5 ">
            <Image
              src="/hpEnvy.png"
              alt="Laptop with the Dinq application open"
              width={450}
              height={450}
            ></Image>
          </div>
          <div className="absolute -bottom-7 z-5">
            <Image
              src="/tecnoSpark4.png"
              alt="Tecno spark 4 phone with the app"
              width={200}
              height={200}
            ></Image>
          </div>
        </div>
      </div>
    </section>
  );
}

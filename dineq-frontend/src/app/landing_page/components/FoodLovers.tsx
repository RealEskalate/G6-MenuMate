import Image from "next/image";

export default function FoodLovers() {
  return (
    <section className="mx-44 py-16 md:py-24 bg-white">
      <div className="container mx-auto px-6 grid md:grid-cols-2 gap-12 items-center">
        <Image
          src="/foodFestival.png"
          alt="Food Festival image"
          width={800}
          height={800}
        ></Image>
        <div className="text-right">
          <h2 className="text-3xl font-bold text-gray-800">
            Bring More Food Lovers to Your Doorstep
          </h2>
          <p className="mt-4 text-gray-600">
            Whether you're running a restaurant, a food festival, or a special
            event, we help you attract the right crowd, boost visibility, and
            turn hungry visitors into loyal customers.
          </p>
          <a
            href="#"
            className="mt-6 inline-block bg-orange-500 text-white px-6 py-3 rounded-md hover:bg-orange-600"
          >
            Join us
          </a>
        </div>
      </div>
    </section>
  );
}

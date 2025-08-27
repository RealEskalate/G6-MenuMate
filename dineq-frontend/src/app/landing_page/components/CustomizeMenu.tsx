import Image from "next/image";
import Link from "next/link";
export default function CustomizeMenu() {
  return (
    <section className="m-14 mx-48 py-16 md:py-24">
      <div className="container mx-auto px-6 grid md:grid-cols-2 gap-12 items-center">
        <div>
          <h2 className="text-3xl font-bold text-gray-800">
            Customize Your Menu With Our AI
          </h2>
          <p className="mt-4 text-gray-600">
            Smart tools to manage your menu the way your customers see it. From
            dish names to photos—tailor every detail effortlessly.
          </p>
          <Link
            href="#"
            className="mt-6 inline-block bg-orange-500 text-white px-6 py-3 rounded-md hover:bg-orange-600"
          >
            Create menu now
          </Link>
        </div>
        <div className="h-80 rounded-lg flex items-center justify-center z-5">
          <span className="text-gray-500 -">
            <Image
              src="/orignalMenuVsDigitalMenu.png"
              alt="Old menu Vs Digital Menu"
              width={800}
              height={800}
              className="translate-x-20"
            ></Image>
          </span>
        </div>
      </div>
    </section>
  );
}

import Image from "next/image";
import Link from "next/link";

export default function Footer() {
  return (
    <footer className="bg-white pt-20 border-t border-orange-200 h-[14rem] py-12 px-6 md:px-12 lg:px-24">
      <div className="container mx-auto flex flex-col md:flex-row justify-between items-center">
        <div>
          <div className="flex pb-3 items-center space-x-2">
            <div className="w-8 h-8 bg-orange-500 rounded-md flex items-center justify-center text-white font-bold">
              <Image
                src="/menuMateIcon.png"
                alt="Menu mate Icon"
                width={200}
                height={200}
              ></Image>
            </div>
            <span className="text-xl font-bold text-gray-800">MenuMate</span>
          </div>
          <p className="mt-2 text-gray-600 max-w-xs">
            Digitizing Ethiopian dining experiences with AI-powered menu
            solutions.
          </p>
        </div>
        <div className="mt-8 md:mt-0 flex justify-evenly gap-48">
          <Link href="#" className="text-gray-600 hover:text-orange-500">
            Home
          </Link>
          <Link href="#" className="text-gray-600 hover:text-orange-500">
            Features
          </Link>
          <Link href="#" className="text-gray-600 hover:text-orange-500">
            Pricing
          </Link>
        </div>
      </div>
    </footer>
  );
}

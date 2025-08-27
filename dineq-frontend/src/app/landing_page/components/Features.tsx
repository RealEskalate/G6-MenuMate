import Image from "next/image";

export default function Features() {
  return (
    <section className="relative py-16 md:py-24 bg-white mx-28 z-20 h-[48]">
      <div className="container mx-auto px-6">
        {/* Section Header */}
        <div className="text-center mb-12">
          <h2 className="text-3xl md:text-4xl font-bold text-gray-800">
            Features that Empower Your Business
          </h2>
          <p className="text-gray-600 mt-2">
            All the tools you need to create an engaging digital experience for
            your customers.
          </p>
        </div>

        {/* 
          Main Grid Container
          - On large screens (lg), it uses a 10-column grid to achieve the asymmetrical layout.
          - Top cards span 5 columns each (50%).
          - Bottom-left card spans 6 columns (60%).
          - Bottom-right card spans 4 columns (40%).
          - On mobile, it defaults to a single column stack.
        */}
        <div className="grid grid-cols-1 lg:grid-cols-10 gap-8">
          {/* Card 1: Save Time & Resources */}
          <div className="lg:col-span-5 flex flex-col justify-between p-8 border border-orange-200 rounded-2xl shadow-lg">
            <div>
              <h3 className="text-2xl font-bold text-gray-800">
                Save Time &amp; Resources
              </h3>
              <p className="mt-2 text-gray-600">
                Update your menu in seconds - no more reprinting or wasting
                money. Keep everything fresh and up to date with just a click.
              </p>
            </div>
            <div className="mt-6 bg-white p-4 rounded-xl shadow-md flex items-center space-x-4 border border-gray-100">
              <Image
                src="/sambusa.png"
                alt="Sambusa dish"
                width={80}
                height={80}
                className="rounded-lg object-cover"
              />
              <div className="flex-grow">
                <p className="font-bold text-gray-800">Sambusa</p>
                <p className="text-sm text-gray-500">
                  Crispy pastry filled with spiced lentils and vegetables.
                </p>
              </div>
              <span className="font-bold text-orange-500">45 ETB</span>
            </div>
          </div>

          {/* Card 2: Language Support */}
          <div className="lg:col-span-5 flex flex-col justify-between p-8 border border-orange-200 rounded-2xl shadow-lg">
            <div>
              <h3 className="text-2xl font-bold text-gray-800">
                Language Support
              </h3>
              <p className="mt-2 text-gray-600">
                Break language barriers. Instantly show your menu in Amharic or
                English so every customer feels at home.
              </p>
            </div>
            <div className="mt-6 flex justify-center">
              <div className="flex items-center space-x-4 p-4 border border-gray-300 rounded-2xl shadow-sm">
                <Image
                  src="/Google Translate.png"
                  alt="Translate icon"
                  width={32}
                  height={32}
                />
                <span className="text-xl font-semibold text-gray-700">
                  Translate
                </span>
              </div>
            </div>
          </div>

          {/* Card 3: Smart Dashboard Management */}
          <div className="lg:col-span-6 flex flex-col p-8 border border-orange-200 rounded-2xl shadow-lg overflow-hidden">
            <div>
              <h3 className="text-2xl font-bold text-gray-800">
                Smart Dashboard Management
              </h3>
            </div>
            <div>
              <p className="mt-2 text-gray-600 pr-48">
                All your menus, reviews, and insights in one place. Manage with
                ease, whether you have one branch or many.
              </p>
            </div>
            <div className="mt-6 -mb-8 -mr-8">
              <Image
                src="/analyticsOnPc.png"
                alt="Analytics dashboard on a computer screen"
                width={800}
                height={450}
                className="w-full object-cover"
              />
            </div>
          </div>

          {/* Card 4: Promotions & Specials */}
          <div className="lg:col-span-4 flex flex-col justify-between p-8 border border-orange-200 rounded-2xl shadow-lg">
            <div>
              <h3 className="text-2xl font-bold text-gray-800">
                Promotions & Specials
              </h3>
              <p className="mt-2 text-gray-600">
                Highlight today&apos;s specials or limited-time offers. Make
                sure customers never miss out on what's new and exciting.
              </p>
            </div>
            <div className="mt-6 flex justify-center">
              <Image
                src="/fiftyPercentOff.png"
                alt="50% Off promotion graphic"
                width={250}
                height={100}
              />
            </div>
          </div>
        </div>
      </div>
    </section>
  );
}

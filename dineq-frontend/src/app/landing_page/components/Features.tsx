"use client";
import Image from "next/image";
import { motion } from "framer-motion";

export default function Features() {
  const cards = [
    {
      id: 1,
      title: "Save Time & Resources",
      description:
        "Update your menu in seconds - no more reprinting or wasting money. Keep everything fresh and up to date with just a click.",
      content: (
        <div className="mt-6 bg-white p-4 rounded-xl shadow-md flex items-center space-x-4 border border-gray-100">
          <img
            src="/sambusa.png"
            alt="Sambusa dish"
            className="rounded-lg object-cover w-16 h-16 sm:w-20 sm:h-20"
          />
          <div className="flex-grow">
            <p className="font-bold text-gray-800">Sambusa</p>
            <p className="text-sm text-gray-500">
              Crispy pastry filled with spiced lentils and vegetables.
            </p>
          </div>
          <span className="font-bold text-orange-500">45 ETB</span>
        </div>
      ),
      colSpan: "lg:col-span-5",
    },
    {
      id: 2,
      title: "Language Support",
      description:
        "Break language barriers. Instantly show your menu in Amharic or English so every customer feels at home.",
      content: (
        <div className="mt-6 flex justify-center">
          <div className="flex items-center space-x-4 p-4 border border-gray-300 rounded-2xl shadow-sm">
            <img
              src="/Google Translate.png"
              alt="Translate icon"
              className="w-8 h-8 sm:w-10 sm:h-10"
            />
            <span className="text-xl font-semibold text-gray-700">
              Translate
            </span>
          </div>
        </div>
      ),
      colSpan: "lg:col-span-5",
    },
    {
      id: 3,
      title: "Smart Dashboard Management",
      description:
        "All your menus, reviews, and insights in one place. Manage with ease, whether you have one branch or many.",
      content: (
        <div className="mt-2">
          <img
            src="/analyticsOnPc.png"
            alt="Analytics dashboard on a computer screen"
            className="w-full object-cover rounded-xl"
          />
        </div>
      ),
      colSpan: "lg:col-span-6",
    },
    {
      id: 4,
      title: "Promotions & Specials",
      description:
        "Highlight today&apos;s specials or limited-time offers. Make sure customers never miss out on what's new and exciting.",
      content: (
        <div className="mt-2 flex justify-center">
          <img
            src="/fiftyPercentOff.png"
            alt="50% Off promotion graphic"
            className="w-32 sm:w-48 lg:w-56"
          />
        </div>
      ),
      colSpan: "lg:col-span-4",
    },
  ];

  return (
    <section className="relative py-16 md:py-24 bg-white px-6">
      <div className="container mx-auto">
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

        {/* Cards */}
        {/* Mobile: Horizontal scroll */}
        <div className="sm:hidden overflow-x-auto flex gap-4 pb-6">
          {cards.map((card, index) => (
            <motion.div
              key={card.id}
              className={`min-w-[280px] flex-shrink-0 p-6 border border-orange-200 rounded-2xl shadow-lg`}
              initial={{ opacity: 0, y: 30 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ duration: 0.6, delay: index * 1 }}
            >
              <h3 className="text-xl font-bold text-gray-800">{card.title}</h3>
              <p className="mt-2 text-gray-600 text-sm">{card.description}</p>
              {card.content}
            </motion.div>
          ))}
        </div>

        {/* Desktop: Grid */}
        <div className="hidden lg:grid grid-cols-10 gap-8">
          {cards.map((card, index) => (
            <motion.div
              key={card.id}
              className={`${card.colSpan} flex flex-col p-8 border border-orange-200 rounded-2xl shadow-lg`}
              initial={{ opacity: 0, y: 30 }}
              whileInView={{ opacity: 1, y: 0 }}
              transition={{ duration: 0.6, delay: index * 1 }}
              viewport={{ once: false, amount: 0.3 }}
            >
              <h3 className="text-2xl font-bold text-gray-800">{card.title}</h3>
              <p className="mt-2 text-gray-600">{card.description}</p>
              {card.content}
            </motion.div>
          ))}
        </div>
      </div>
    </section>
  );
}

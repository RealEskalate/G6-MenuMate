"use client";
import Image from "next/image";
import { motion } from "framer-motion";

export default function HowItWorks() {
  const steps = [
    { step: "STEP 1", title: "Upload Menu Photo", description: "Take a photo of any paper menu with your phone camera.", icon: "/camera.png" },
    { step: "STEP 2", title: "OCR Extraction", description: "AI extracts menu items & prices in Amharic and English.", icon: "/ocr.png" },
    { step: "STEP 3", title: "Customization", description: "Organize your menu items with our AI assistant.", icon: "/gallary.png" },
    { step: "STEP 4", title: "Up & Ready", description: "Get shareable QR menus in which users can scan, share and browse.", icon: "/fourPoint.png" },
  ];

  return (
    <section className="bg-white py-16 md:py-24">
      <div className="container mx-auto px-6 text-center">
        <h2 className="text-3xl sm:text-4xl font-extrabold text-gray-800">How it Works</h2>
        <p className="text-gray-600 mt-2 text-base sm:text-lg">
          Simple steps to digitize your dining experience
        </p>

        <div className="mt-16 md:mt-20">
          {/* Mobile scroll */}
          <div className="sm:hidden overflow-x-auto scrollbar-hide snap-x snap-mandatory">
            <div className="flex space-x-4 px-6 pb-4">
              {steps.map((step, index) => (
                <motion.div
                  key={index}
                  className="relative w-60 flex-shrink-0 snap-center p-4 border border-orange-200 rounded-lg text-left shadow bg-white pt-10"
                  initial={{ opacity: 0, y: 30 }}
                  whileInView={{ opacity: 1, y: 0 }}
                  transition={{ duration: 0.6, delay: index * 0.2 }}
                  viewport={{ once: false, amount: 0.3 }}
                >
                  <div className="absolute top-2 right-4 w-12 h-12 bg-orange-500 rounded-full flex items-center justify-center shadow-md">
                    <Image src={step.icon} alt={step.title} width={30} height={30} />
                  </div>
                  <div className="pt-4">
                    <p className="text-gray-400 text-xs font-medium">{step.step}</p>
                    <h3 className="mt-2 font-bold text-lg text-gray-800">{step.title}</h3>
                    <p className="mt-3 text-gray-600 leading-relaxed text-sm">{step.description}</p>
                  </div>
                </motion.div>
              ))}
            </div>
          </div>

          {/* Desktop grid */}
          <div className="hidden sm:grid grid-cols-2 lg:grid-cols-4 gap-8 px-8">
            {steps.map((step, index) => (
              <motion.div
                key={index}
                className="relative p-6 border border-orange-200 rounded-lg text-left shadow bg-white pt-16"
                initial={{ opacity: 0, y: 30 }}
                whileInView={{ opacity: 1, y: 0 }}
                transition={{ duration: 0.6, delay: index * 0.2 }}
                viewport={{ once: true }}
              >
                <div className="absolute -top-10 right-6 w-16 h-16 bg-orange-500 rounded-full flex items-center justify-center shadow-md">
                  <Image src={step.icon} alt={step.title} width={50} height={50} />
                </div>
                <div className="pt-6">
                  <p className="text-gray-400 text-sm font-medium">{step.step}</p>
                  <h3 className="mt-2 font-bold text-xl text-gray-800">{step.title}</h3>
                  <p className="mt-3 text-gray-600 leading-relaxed text-sm">{step.description}</p>
                </div>
              </motion.div>
            ))}
          </div>
        </div>
      </div>
    </section>
  );
}

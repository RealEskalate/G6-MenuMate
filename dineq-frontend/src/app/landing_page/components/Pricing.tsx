"use client";
import Link from "next/link";

export default function Pricing() {
  const freeFeatures = [
    "Basic menu digitization",
    "5 menu uploads per month",
    "Basic QR code generation",
  ];
  const premiumFeatures = [
    "Unlimited menu uploads",
    "Advanced Analytics Dashboard",
    "Advanced QR code branding",
    "Promotions & Specials",
  ];

  return (
    <section className="py-16 md:py-24">
      <div className="container mx-auto px-6 text-center">
        <h2 className="text-3xl font-bold text-gray-800">
          Our Pricing For Restaurants
        </h2>

        {/* Mobile: Horizontal scroll */}
        <div className="mt-12 sm:hidden overflow-x-auto flex gap-4 pb-6 px-2">
          {/* Free Plan */}
          <div className="min-w-[260px] flex-shrink-0 border border-orange-200 rounded text-gray-600 p-6 text-left bg-white">
            <h3 className="text-2xl font-bold">FREE Plan</h3>
            <p className="text-gray-600">Perfect to get started.</p>
            <div className="mt-4 text-4xl text-black font-bold">
              ETB{" "}
              <span className="text-lg text-orange-400  font-normal">0/month</span>
            </div>
            <ul className="mt-6 space-y-2">
              {freeFeatures.map((feature, index) => (
                <li key={index} className="flex items-center">
                  <svg
                    className="w-5 h-5 text-orange-500 mr-2"
                    fill="none"
                    stroke="currentColor"
                    viewBox="0 0 24 24"
                    xmlns="http://www.w3.org/2000/svg"
                  >
                    <path
                      strokeLinecap="round"
                      strokeLinejoin="round"
                      strokeWidth="2"
                      d="M5 13l4 4L19 7"
                    ></path>
                  </svg>
                  {feature}
                </li>
              ))}
            </ul>
            <Link
              href="/auth/manager-signup"
              className="mt-8 block w-full bg-gray-200 text-gray-700 text-center py-3 rounded-md hover:bg-gray-300"
            >
              Get Started
            </Link>
          </div>

          {/* Premium Plan */}
          <div className="min-w-[260px] flex-shrink-0 bg-orange-500 text-white rounded-lg p-6 text-left">
            <h3 className="text-2xl font-bold">Premium Plan</h3>
            <p className="text-orange-100">Everything in Free, plus:</p>
            <div className="mt-4 text-4xl font-bold">
              ETB 300<span className="text-lg font-normal">/month</span>
            </div>
            <ul className="mt-6 space-y-2">
              {premiumFeatures.map((feature, index) => (
                <li key={index} className="flex items-center">
                  <svg
                    className="w-5 h-5 text-white mr-2"
                    fill="none"
                    stroke="currentColor"
                    viewBox="0 0 24 24"
                    xmlns="http://www.w3.org/2000/svg"
                  >
                    <path
                      strokeLinecap="round"
                      strokeLinejoin="round"
                      strokeWidth="2"
                      d="M5 13l4 4L19 7"
                    ></path>
                  </svg>
                  {feature}
                </li>
              ))}
            </ul>
            <Link
              href="/auth/manager-signup"
              className="mt-8 block w-full bg-white text-orange-500 text-center py-3 rounded-md hover:bg-orange-100"
            >
              Get Started
            </Link>
          </div>
        </div>

        {/* Desktop: Grid */}
        <div className="hidden sm:grid grid-cols-1 md:grid-cols-2 gap-8 mt-12 max-w-4xl mx-auto">
          {/* Free Plan */}
          <div className="border border-orange-200 rounded text-gray-600 p-8 text-left bg-white">
            <h3 className="text-2xl font-bold">FREE Plan</h3>
            <p className="text-gray-600">Perfect to get started.</p>
            <div className="mt-4 text-4xl text-black font-bold">
              ETB{" "}
              <span className="text-lg text-orange-400 font-normal">0/month</span>
            </div>
            <ul className="mt-6 space-y-2">
              {freeFeatures.map((feature, index) => (
                <li key={index} className="flex items-center">
                  <svg
                    className="w-5 h-5 text-orange-500 mr-2"
                    fill="none"
                    stroke="currentColor"
                    viewBox="0 0 24 24"
                    xmlns="http://www.w3.org/2000/svg"
                  >
                    <path
                      strokeLinecap="round"
                      strokeLinejoin="round"
                      strokeWidth="2"
                      d="M5 13l4 4L19 7"
                    ></path>
                  </svg>
                  {feature}
                </li>
              ))}
            </ul>
            <Link
              href="/auth/manager-signup"
              className="mt-8 block w-full bg-gray-200 text-gray-700 text-center py-3 rounded-md hover:bg-gray-300"
            >
              Get Started
            </Link>
          </div>

          {/* Premium Plan */}
          <div className="bg-orange-500 text-white rounded-lg p-8 text-left">
            <h3 className="text-2xl font-bold">Premium Plan</h3>
            <p className="text-orange-100">Everything in Free, plus:</p>
            <div className="mt-4 text-4xl font-bold">
              ETB 300<span className="text-lg font-normal">/month</span>
            </div>
            <ul className="mt-6 space-y-2">
              {premiumFeatures.map((feature, index) => (
                <li key={index} className="flex items-center">
                  <svg
                    className="w-5 h-5 text-white mr-2"
                    fill="none"
                    stroke="currentColor"
                    viewBox="0 0 24 24"
                    xmlns="http://www.w3.org/2000/svg"
                  >
                    <path
                      strokeLinecap="round"
                      strokeLinejoin="round"
                      strokeWidth="2"
                      d="M5 13l4 4L19 7"
                    ></path>
                  </svg>
                  {feature}
                </li>
              ))}
            </ul>
            <Link
              href="/auth/manager-signup"
              className="mt-8 block w-full bg-white text-orange-500 text-center py-3 rounded-md hover:bg-orange-100"
            >
              Get Started
            </Link>
          </div>
        </div>
      </div>
    </section>
  );
}

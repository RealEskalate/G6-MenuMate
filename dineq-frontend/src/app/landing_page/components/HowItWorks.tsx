import Image from "next/image";

export default function HowItWorks() {
  const steps = [
    {
      step: "STEP 1",
      title: "Upload Menu Photo",
      description: "Take a photo of any paper menu with your phone camera.",
      icon: (
        <Image src="/camera.png" alt="Camera" width={100} height={100}></Image>
      ),
    },
    {
      step: "STEP 2",
      title: "OCR Extraction",
      description: "AI extracts menu items & prices in Amharic and English.",
      icon: (
        <Image src="/ocr.png" alt="Camera" width={100} height={100}></Image>
      ),
    },
    {
      step: "STEP 3",
      title: "Customization",
      description: "Organize your menu items with our AI assistant.",
      icon: (
        <Image src="/gallary.png" alt="Camera" width={100} height={100}></Image>
      ),
    },
    {
      step: "STEP 4",
      title: "Up & Ready",
      description:
        "Get shareable QR menus in which users can scan, share and browse.",
      icon: (
        <Image
          src="/fourPoint.png"
          alt="Camera"
          width={100}
          height={100}
        ></Image>
      ),
    },
  ];

  return (
    <section className="mx-24 py-16 md:py-24 bg-white z-0">
      <div className="container mx-auto px-6 text-center">
        <h2 className="text-3xl font-bold text-gray-800">How it Works</h2>
        <p className="text-gray-600 mt-2">
          Simple steps to digitize your dining experience
        </p>
        <div className="mt-24 grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-x-8 gap-y-16">
          {steps.map((step, index) => (
            <div
              key={index}
              className="relative p-8 border border-orange-200 rounded-lg text-left shadow-sm"
            >
              {/* Image placeholder positioned top-right */}
              <div className="absolute -top-12 right-6 w-24 h-24 bg-orange-500 rounded-full flex items-center justify-center">
                {/* Replace this div with your <Image> component */}
                {step.icon}
              </div>

              <div className="pt-8">
                <p className="text-gray-400 text-sm font-medium">{step.step}</p>
                <h3 className="mt-2 font-bold text-2xl text-gray-800">
                  {step.title}
                </h3>
                <p className="mt-3 text-gray-600 leading-relaxed">
                  {step.description}
                </p>
              </div>
            </div>
          ))}
        </div>
      </div>
    </section>
  );
}

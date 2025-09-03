import React from 'react';
import Image from 'next/image';

const WhoAreYou = () => {
  return (
    <>
      <div className='flex flex-col md:flex-row-reverse min-h-screen'>
        {/* Image Section */}
        <div className='relative w-full md:w-1/3 h-48 md:h-auto'>
          <Image
            src="/Frame.png"
            alt='food image'
            fill
            className="object-cover"
          />
        </div>

        {/* Form Section */}
        <div className='w-full md:w-2/3 flex items-center justify-center p-4 md:p-0'>
          <div className="w-full max-w-md p-6 bg-white rounded-xl shadow-lg h-auto">
            <h1 className="text-2xl font-bold mb-6 text-left">Who Are You ?</h1>
            <p className="mb-6">Choose your role to get the most out of Dineq</p>

            {/* Restaurant Card */}
            <div className="w-full h-[100px] rounded-lg border border-[var(--color-primary)] flex items-center gap-4 my-5 p-3 cursor-pointer hover:shadow-md transition-shadow duration-200">
              <div className="relative w-[85px] h-[85px] rounded-full overflow-hidden flex-shrink-0">
                <Image
                  src="/menuMateIcon.png"
                  alt="Restaurant"
                  fill
                  className="object-cover"
                />
              </div>
              <div className="flex flex-col justify-center">
                <p className="text-lg font-semibold text-gray-800">Restaurant</p>
                <p className="text-sm text-gray-600">
                  Create and manage digital menus, generate QR codes, and track performance
                </p>
              </div>
            </div>

            {/* Customer Card */}
            <div className="w-full h-[100px] rounded-lg border border-[var(--color-primary)] flex items-center gap-4 my-5 p-3 cursor-pointer hover:shadow-md transition-shadow duration-200">
              <div className="relative w-[85px] h-[85px] rounded-full overflow-hidden flex-shrink-0">
                <Image
                  src="/menuMateIcon.png"
                  alt="Customer"
                  fill
                  className="object-cover"
                />
              </div>
              <div className="flex flex-col justify-center">
                <p className="text-lg font-semibold text-gray-800">Customer</p>
                <p className="text-sm text-gray-600">
                  Discover dishes, scan QR menus and share reviews
                </p>
              </div>
            </div>
          </div>
        </div>
      </div>
    </>
  );
};

export default WhoAreYou;
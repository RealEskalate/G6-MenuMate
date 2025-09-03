import React from 'react'
import Image from 'next/image'
import Link from 'next/link'

const WhoAreYou = () => {
  return (
    <>
    <div className='flex '>
          <div className='w-2/3'>
    
          <div className="flex items-center justify-center min-h-screen bg-gray-100 ">
          <div className="w-full max-w-md p-6 bg-white rounded-xl shadow-lg  h-auto">
                <h1 className="text-2xl font-bold mb-6 text-left">Who Are You ?</h1>
                <p>Choose your role to get the most out of Dineq</p>
                <Link href="/auth/manager-signup">
                <div className="w-full h-[100px] rounded-lg border border-[var(--color-primary)] flex items-center gap-4 my-5 p-3">
                {/* Image Circle */}
                <div className="relative w-[85px] h-[85px] rounded-full overflow-hidden flex-shrink-0">
                    <Image
                    src="/menuMateIcon.png"
                    alt="Restaurant"
                    fill
                    className="object-cover"
                    />
                </div>

                {/* Text Section */}
                <div className="flex flex-col justify-center">
                    <p className="text-lg font-semibold text-gray-800">Restaurant</p>
                    <p className="text-sm text-gray-600">
                    Create and manage digital menus, generate QR codes, and track performance
                    </p>
                </div>
            </div>
                </Link>

            <Link href="/auth/user-signup">
            <div className="w-full h-[100px] rounded-lg border border-[var(--color-primary)] flex items-center gap-4 my-5 p-3">
                {/* Image Circle */}
                <div className="relative w-[85px] h-[85px] rounded-full overflow-hidden flex-shrink-0">
                    <Image
                    src="/menuMateIcon.png"
                    alt="Restaurant"
                    fill
                    className="object-cover"
                    />
                </div>

                {/* Text Section */}
                <div className="flex flex-col justify-center">
                    <p className="text-lg font-semibold text-gray-800">Costumer</p>
                    <p className="text-sm text-gray-600">
                    Discover dishes, scan QR menus and share reviews
                    </p>
                </div>
            </div>
            </Link>   
                
      </div>
    </div>
    
    
          
    
          </div>
    
          <div className=' relative w-1/3 h-screen'>
            <Image 
            src="/Frame.png" 
            alt='food image'
            fill/>
          </div>
    
        </div>
    
    </>
  )
}

export default WhoAreYou

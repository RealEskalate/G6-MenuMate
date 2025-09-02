import React from 'react'
import Image from 'next/image'

const EmailVerification = () => {
  return (
    <>

    <div className='flex '>
              <div className='w-2/3'>
        
              <div className="flex items-center justify-center min-h-screen bg-gray-100 ">
              <div className="w-full max-w-md p-6 bg-white rounded-xl shadow-lg  h-auto">
                    <h1 className="text-2xl font-bold mb-6 text-left">Email Verification</h1>
                    <p>Please enter the 4-digit code sent to you at Youremail@gmail.com</p>

                    <p className='p-5'>Resend code</p>
                    <div className="w-full flex items-center justify-center gap-4 my-5">
                            {[0, 1, 2, 3].map((_, idx) => (
                                <input
                                key={idx}
                                type="text"
                                maxLength={1}
                                inputMode="numeric" 
                                pattern="\d*"        
                                className="w-[55px] h-[55px] rounded-full border text-center text-2xl focus:outline-none focus:ring-2 focus:ring-orange-500"
                                />
                            ))}
                            </div>


    
                            <button
                                type="submit"
                                className="w-full flex justify-center mx-auto  text-white py-2 my-3 rounded-lg "
                                style={{ backgroundColor: "var(--color-primary)" }}
                            >
                                Enter 
                            </button>
    
    
    
        
                    
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

export default EmailVerification

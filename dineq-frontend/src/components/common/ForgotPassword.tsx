import React from 'react'
import Image from 'next/image'
import { FaArrowLeft } from "react-icons/fa";

const ForgotPassword = () => {
  return (
    <>
    <div className='flex'>

        <div className='w-2/3'>
        <div className="flex items-center justify-center min-h-screen bg-gray-100">
      <div className="w-full max-w-md p-6 bg-white rounded-xl shadow-lg">
            <h1 className="text-2xl font-bold mb-6 text-center">Forgot Password ?</h1>
            <p className='text-gray-500'>Enter your email address and we will send you a lilnk to reset your password</p>

            <form action="" className="space-y-4">
              
              <div className="flex flex-col py-5">
                <label htmlFor="email" className="mb-1 text-sm font-medium">
                  Email Address
                </label>
                <input
                  type="email"
                  name="email"
                  id="email"
                  placeholder="Enter Your Email"
                  className="border rounded-lg px-3 py-2 focus:outline-none focus:ring-2 "
                   style={{ borderColor: "var(--color-primary)" }}
                />
              </div>

            
              

              {/* Login Button */}
              <button
                type="submit"
                className="w-1/2 flex justify-center mx-auto  text-white py-2 rounded-lg "
                style={{ backgroundColor: "var(--color-primary)" }}
              >
                Send Reset Link
              </button>

              {/* Footer */}
              <p className="text-sm text-center">
                
                <a 
                href="/register" 
                className="flex justify-center hover:underline" 
                style={{ color: "var(--color-primary)" }}
                >
                <div className="flex items-center gap-2">
                    <FaArrowLeft /> 
                    <span>Back to signin</span>
                </div>
                </a>

              </p>
            </form>
  </div>
</div>

        </div>

        <div className=' relative w-1/3 h-screen'>
            <Image 
            src="/images/Frame.png" 
            alt='food image'
            fill/>
        </div>



    </div>
    
    </>
  )
}

export default ForgotPassword

import React from 'react'
import Image from 'next/image'

const Signin = () => {
  return (
    <>

    <div className='flex '>
      <div className='w-2/3'>

      <div className="flex items-center justify-center min-h-screen bg-gray-100">
      <div className="w-full max-w-md p-6 bg-white rounded-xl shadow-lg">
            <h1 className="text-2xl font-bold mb-6 text-center">Welcome Back!</h1>

            <form action="" className="space-y-4">
              
              <div className="flex flex-col">
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

            
              <div className="flex flex-col">
                <label htmlFor="password" className="mb-1 text-sm font-medium">
                  Password
                </label>
                <input
                  type="password"
                  name="password"
                  id="password"
                  placeholder="**********"
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
                Login
              </button>

              {/* Footer */}
              <p className="text-sm text-center">
                Don't have an account?{" "}
                <a href="/register" className="hover:underline" style={{ color: "var(--color-primary)" }}>
                  Register
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

export default Signin

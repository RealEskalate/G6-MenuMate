import React from 'react'
import { FaCheck } from 'react-icons/fa'
const PageNotFound = () => {
  return (
    <>
    <div className=" min-h-screen flex flex-col items-center justify-center">
        <div className="flex items-center justify-center w-12 h-12 rounded-full bg-gray-500 ">
            <FaCheck className="text-white text-xl" />
        </div>
        <h1 className='text-3xl text-gray-500 font-extrabold m-3'>404</h1>
        <h2 className='text-2xl text-gray-500 font-bold'>Page Not Found</h2>
        <p className='text-gray-500'>The page you are looking for does not exist or has been moved</p>
        <button
                type="submit"
                className=" mt-4 px-6 py-2 rounded-lg text-white "
                style={{ backgroundColor: "var(--color-primary)" }}
              >
                Back to Home
        </button>
    </div>

    </>
  )
}

export default PageNotFound

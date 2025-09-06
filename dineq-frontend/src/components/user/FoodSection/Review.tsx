import React from 'react'

const Review = () => {
  return (
    <div className="space-y-4 border rounded-xl p-4 shadow-sm">
        <h2 className='text-2xl font-semibold mb-3'>Reviews</h2>
            <div className="space-y-2">
              <p className="font-semibold">Selamawit ⭐⭐⭐⭐</p>
              <p className="text-gray-600">
                The spice was just right! Reminded me of home.
              </p>
            </div>
            <div className="space-y-2">
              <p className="font-semibold">Mikias ⭐⭐⭐⭐⭐</p>
              <p className="text-gray-600">
                Best doro wat I’ve had in a long time!
              </p>
            </div>
          </div>
  )
}

export default Review
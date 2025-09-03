"use client";
import FoodHeader from '@/components/user/FoodSection/FoodHeader'
import FoodMiniNavBar from '@/components/user/FoodSection/FoodMiniNavBar'

import React from 'react'
const FoodCard = () => {
  return (
    <div className='w-full max-w-[80%] flex flex-col gap-4 '>
        <FoodHeader image= "/logo.png" title="Fried Chicken" price="$12.99" onFavorite={() => alert('Added to favorites!')} />
        <FoodMiniNavBar />
        
          
    </div>
  )
}

export default FoodCard
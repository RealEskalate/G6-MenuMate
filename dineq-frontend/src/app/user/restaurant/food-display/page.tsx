"use client";
import FoodHeader from '@/components/user/FoodSection/FoodHeader'
import FoodMiniNavBar from '@/components/user/FoodSection/FoodMiniNavBar'

import React from 'react'
const FoodCard = () => {
  return (
    <div>
        <FoodHeader image = "Logo.png" title='Fried Chicken' price='$12.99' onFavorite={() => alert('Added to favorites!')} />
        <FoodMiniNavBar />
        
          
    </div>
  )
}

export default FoodCard
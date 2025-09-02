"use client";
import FoodHeader from '@/components/user/FoodSection/FoodHeader'
import React from 'react'

const FoodCard = () => {
  return (
    <div>FoodCard
        <FoodHeader image ="/Logo.png" title='Fried Chicken' price='$12.99' onFavorite={() => alert('Added to favorites!')} />
          
    </div>
  )
}

export default FoodCard
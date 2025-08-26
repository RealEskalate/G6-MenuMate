import FoodHeader from '@/components/user/FoodSection/FoodHeader'
import React from 'react'
import logo from '../../../../public/logo.png'
const FoodCard = () => {
  return (
    <div>FoodCard
        <FoodHeader image = {logo} title='Fried Chicken' price='$12.99' onFavorite={() => alert('Added to favorites!')} />
          
    </div>
  )
}

export default FoodCard
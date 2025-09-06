"use client"
import React from 'react'
import Image from 'next/image'
import foods from '@/data/food'
import { FoodType } from '../../../Types/foods'



const FoodItem :React.FC<FoodType> =(props) => {
  return (
    <>

    <div className=' flex w-[535.2483px] h-[110.8581px] border border-[var(--color-primary)] rounded-lg '>

        <div className='h-[97.0008px] w-[152.4299px] relative rounded-lg m-[5px]'>
            <Image 
            src={props.image}
            alt="Background"
            layout="fill"          
            objectFit="cover"
            className='rounded-lg '
            />

           

        </div>

        <div className='w-[354.8999px] h-[87.7627px] pt-[10.7776px] pr-[12.7025px] pb-[23.6449px] pl-[11.9327px] flex flex-col gap-y-[9.34px]'>
            <div className='flex justify-between  h-[24px] pt-[10.74px]'>
                <p className='font-semibold text-[20px] leading-[23.3504px]'>{props.name}</p>
                <p className='font-semibold text-[20px] leading-[23.3504px]'>{props.price}</p>


            </div>
            <div className='h-[20px] w-[330.2648px]'>
                <p>{props.description}</p>
            </div>

        </div>

    </div>
    </>
  )
}



const Foods = () =>{

    const meal = foods.map((food) =>{
        return <FoodItem  
        key={food.id}
        {...food}/>
    })

    return(
        <>
        <div className='flex flex-wrap justify-center gap-6'>
             {meal}

        </div>
       
        </>
    )


}

export default Foods

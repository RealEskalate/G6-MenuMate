import Tags from '@/components/common/Tags';
import React from 'react'

const Description = () => {
    const ingredients = [
    "Chicken (doro)",
    "Berbere spice mix",
    "Onions",
    "Garlic",
    "Ginger",
    "Niter kibbeh (spiced butter)",
    "Tomato paste",
    "Boiled eggs",
    "Injera",
  ];
  return (
    <div className=' border  rounded-xl shadow-sm p-4 mb-3'>
        <div className='rounded-md flex flex-col'>
            <h2 className="text-2xl font-semibold mb-3">Discription</h2>
            <p>Traditional Ethiopian chicken stew simmered with berbere spices and served with injera.</p>

        </div>
        <div className='boreder border-[var(--color-primary)] rounded-md flex flex-col'>
            <h2 className='text-2xl font-semibold mb-3'>Ingredients</h2>
            <ul className="  space-x-1 flex  text-gray-700">
              {ingredients.map((item, index) => (
                <li key={index}> <Tags>{item}</Tags></li>
              ))}
            </ul>

        

        </div>
        <div > </div>

    </div>
  )
}

export default Description
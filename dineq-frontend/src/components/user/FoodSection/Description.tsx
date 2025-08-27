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
    <div>
        <div className='boreder border-[var(--color-primary)] rounded-md flex flex-col'>
            <h3 className='headline-medium'>Description</h3>
            <p>Traditional Ethiopian chicken stew simmered with berbere spices and served with injera.</p>

        </div>
        <div className='boreder border-[var(--color-primary)] rounded-md flex flex-col'>
            <h3 className='headline-medium'>Ingredients</h3>
            <ul className="list-disc list-inside space-y-1 text-gray-700">
        {ingredients.map((item, index) => (
          <li key={index}> <Tags>{index}</Tags></li>
        ))}
      </ul>
        

        </div>

    </div>
  )
}

export default Description
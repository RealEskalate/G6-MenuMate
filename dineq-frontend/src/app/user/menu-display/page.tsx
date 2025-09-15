"use client";

import React, { useEffect, useState } from "react";

type Food = {
  id: string;
  name: string;
  description?: string;
  price?: number;
  image_url?: string;
};

const Foods = () => {
  const [foods, setFoods] = useState<Food[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const fetchFoods = async () => {
      try {
        const res = await fetch(
          `${process.env.NEXT_PUBLIC_API_BASE_URL}/images/search?item=pizza` // 🔹 replace "pizza" with dynamic query later if needed
        );

        if (!res.ok) {
          throw new Error("Failed to fetch foods");
        }

        const data = await res.json();
        setFoods(data);
      } catch (error) {
        console.error("Error fetching foods:", error);
      } finally {
        setLoading(false);
      }
    };

    fetchFoods();
  }, []);

  if (loading) return <p>Loading...</p>;

  return (
    <div className="grid grid-cols-1 md:grid-cols-3 gap-6 p-4">
      {foods.length > 0 ? (
        foods.map((food) => (
          <div
            key={food.id}
            className="border rounded-xl shadow-md p-4 bg-white"
          >
            {food.image_url && (
              <img
                src={food.image_url}
                alt={food.name}
                className="w-full h-40 object-cover rounded-md mb-3"
              />
            )}
            <h2 className="text-lg font-semibold">{food.name}</h2>
            {food.description && (
              <p className="text-gray-600 text-sm">{food.description}</p>
            )}
            {food.price !== undefined && (
              <p className="mt-2 font-bold">${food.price}</p>
            )}
          </div>
        ))
      ) : (
        <p>No foods found.</p>
      )}
    </div>
  );
};

export default Foods;

"use client";
import React, { useEffect } from 'react';
import RestaurantCard from '@/app/user/RestaurantCard'
import { useDispatch, useSelector } from 'react-redux';
import { fetchRestaurants } from '@/store/restaurantsSlice';
import { RootState, AppDispatch } from '@/store/store';
import { Restaurant } from '../../Types/restaurants';

const Restaurants = () => {
  const dispatch = useDispatch<AppDispatch>();
  const { restaurants, loading, error } = useSelector((state: RootState) => state.restaurants);

  useEffect(() => {
    dispatch(fetchRestaurants({ page: 1, pageSize: 20 }));
  }, [dispatch]);

  if (loading) return <div className='flex justify-center p-8'>Loading restaurants...</div>;
  if (error) return <div className='flex justify-center p-8 text-red-600'>Failed to load restaurants: {error}</div>;
  if (!restaurants?.length) return <div className='text-center p-8'>No restaurants found.</div>;

  const cards = restaurants.map((apiRestaurant) => {
    const normalized: Restaurant = {
      id: String(apiRestaurant.id),
      name: apiRestaurant.name ?? 'Unnamed Restaurant',
      about: apiRestaurant.about ?? '',
      contact: {
        phone: apiRestaurant.phone ?? '',
        email: ''
      },
      averageRating: Number(apiRestaurant.average_rating ?? 0),
      logoImage: apiRestaurant.logo_image ?? '/Background.png',
      location: ''
    };
    return <RestaurantCard key={normalized.id} {...normalized} />;
  });

  return (
    <div className='flex flex-wrap justify-center gap-6'>
      {cards}
    </div>
  );
};

export default Restaurants;

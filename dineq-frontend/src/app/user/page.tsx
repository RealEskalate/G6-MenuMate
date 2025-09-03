"use client";
import React, { useEffect, useMemo, useState } from 'react';
import RestaurantCard from '@/app/user/RestaurantCard'
import { useDispatch, useSelector } from 'react-redux';
import { fetchRestaurants } from '@/store/restaurantsSlice';
import { RootState, AppDispatch } from '@/store/store';
import { Restaurant } from '../../Types/restaurants';

const Restaurants = () => {
  const dispatch = useDispatch<AppDispatch>();
  const { restaurants, loading, error } = useSelector((state: RootState) => state.restaurants);
  const [query, setQuery] = useState("");

  useEffect(() => {
    dispatch(fetchRestaurants({ page: 1, pageSize: 20 }));
  }, [dispatch]);

  const normalizedRestaurants = useMemo<Restaurant[]>(() => {
    return (restaurants || []).map((apiRestaurant) => ({
      id: String(apiRestaurant.id),
      name: apiRestaurant.name ?? 'Unnamed Restaurant',
      about: apiRestaurant.about ?? '',
      contact: {
        phone: (apiRestaurant as any).phone ?? '',
        email: ''
      },
      averageRating: Number((apiRestaurant as any).average_rating ?? 0),
      logoImage: (apiRestaurant as any).logo_image ?? '/Background.png',
      location: ''
    }));
  }, [restaurants]);

  const filteredRestaurants = useMemo(() => {
    if (!query.trim()) return normalizedRestaurants;
    const q = query.toLowerCase();
    return normalizedRestaurants.filter(r =>
      r.name.toLowerCase().includes(q) || r.about.toLowerCase().includes(q)
    );
  }, [normalizedRestaurants, query]);

  const nearbyRestaurants = useMemo(() => {
    return [...filteredRestaurants]
      .sort((a, b) => b.averageRating - a.averageRating)
      .slice(0, Math.min(6, filteredRestaurants.length));
  }, [filteredRestaurants]);

  const allButNearby = useMemo(() => {
    const nearbyIds = new Set(nearbyRestaurants.map(r => r.id));
    return filteredRestaurants.filter(r => !nearbyIds.has(r.id));
  }, [filteredRestaurants, nearbyRestaurants]);

  if (loading) return <div className='flex justify-center p-8'>Loading restaurants...</div>;
  if (error) return <div className='flex justify-center p-8 text-red-600'>Failed to load restaurants: {error}</div>;
  if (!normalizedRestaurants?.length) return <div className='text-center p-8'>No restaurants found.</div>;

  return (
    <div className='w-full max-w-7xl mx-auto px-4 sm:px-6 lg:px-8'>
      {/* Search Bar */}
      <div className='w-full mt-4 mb-6'>
        <input
          type='text'
          value={query}
          onChange={(e) => setQuery(e.target.value)}
          placeholder='Search restaurants by name or description...'
          className='w-full rounded-md border border-gray-300 px-4 py-2 focus:outline-none focus:ring-2 focus:ring-black focus:border-transparent'
        />
      </div>

      {/* Nearby Restaurants */}
      <section className='mb-10'>
        <h2 className='text-xl font-semibold mb-4'>Nearby restaurants</h2>
        {nearbyRestaurants.length === 0 ? (
          <div className='text-gray-500'>No nearby restaurants match your search.</div>
        ) : (
          <div className='flex flex-wrap justify-center gap-6'>
            {nearbyRestaurants.map((r) => (
              <RestaurantCard key={`nearby-${r.id}`} {...r} />
            ))}
          </div>
        )}
      </section>

      {/* All Restaurants */}
      <section className='mb-8'>
        <h2 className='text-xl font-semibold mb-4'>All restaurants</h2>
        {filteredRestaurants.length === 0 ? (
          <div className='text-gray-500'>No restaurants match your search.</div>
        ) : (
          <div className='flex flex-wrap justify-center gap-6'>
            {(allButNearby.length ? allButNearby : filteredRestaurants).map((r) => (
              <RestaurantCard key={r.id} {...r} />
            ))}
          </div>
        )}
      </section>
    </div>
  );
};

export default Restaurants;

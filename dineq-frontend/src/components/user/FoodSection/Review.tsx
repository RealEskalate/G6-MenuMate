// src/components/user/Review.tsx
"use client";

import React, { useEffect, useState } from 'react';
import { FaStar } from 'react-icons/fa';
import Image from 'next/image';
import { ArrowLeft, ArrowRight } from 'lucide-react';

interface Review {
  id: string;
  user: {
    name: string;
    profile_picture: string;
  };
  rating: number;
  title: string;
  comment: string;
  photos: string[];
  visit_date: string;
}

interface ReviewProps {
  restaurantId: string;
}

const ReviewCard = ({ review }: { review: Review }) => {
  const fullStars = Math.floor(review.rating);
  const totalStars = 5;

  return (
    <div className="bg-white p-6 rounded-2xl shadow-sm border border-gray-200">
      <div className="flex items-center mb-4">
        <div className="relative w-12 h-12 rounded-full overflow-hidden mr-4">
          <Image
            src={review.user?.profile_picture || 'https://ui-avatars.com/api/?name=' + encodeURIComponent(review.user?.name || 'User') + '&background=random&color=fff'}
            alt={review.user?.name || 'User'}
            fill
            className="object-cover"
          />
        </div>
        <div>
          <h3 className="font-bold text-lg text-gray-800">{review.user?.name || 'Anonymous User'}</h3>
          <span className="text-sm text-gray-500">{new Date(review.visit_date).toLocaleDateString()}</span>
        </div>
      </div>
      
      <div className="flex items-center mb-2">
        {Array.from({ length: totalStars }, (_, i) => (
          <FaStar key={i} className={`w-4 h-4 ${i < fullStars ? 'text-yellow-500' : 'text-gray-300'}`} />
        ))}
        <span className="ml-2 text-sm text-gray-600 font-medium">{review.rating.toFixed(1)}</span>
      </div>
      
      <p className="font-semibold text-gray-900 mb-2">{review.title}</p>
      <p className="text-gray-600 leading-relaxed">{review.comment}</p>
      
      {review.photos.length > 0 && (
        <div className="mt-4 flex flex-wrap gap-2">
          {review.photos.map((photo, index) => (
            <div key={index} className="relative w-24 h-24 rounded-lg overflow-hidden border border-gray-200">
              <Image 
                src={photo} 
                alt={`Review photo ${index + 1}`} 
                fill 
                className="object-cover" 
              />
            </div>
          ))}
        </div>
      )}
    </div>
  );
};

const ReviewSkeleton = () => (
  <div className="animate-pulse space-y-6">
    <div className="bg-white p-6 rounded-2xl shadow-sm border border-gray-200">
      <div className="flex items-center mb-4">
        <div className="w-12 h-12 rounded-full bg-gray-200 mr-4"></div>
        <div className="space-y-2">
          <div className="h-4 w-32 bg-gray-200 rounded"></div>
          <div className="h-3 w-24 bg-gray-200 rounded"></div>
        </div>
      </div>
      <div className="h-4 w-20 bg-gray-200 rounded mb-2"></div>
      <div className="h-5 w-full bg-gray-200 rounded"></div>
      <div className="h-4 w-5/6 bg-gray-200 rounded mt-2"></div>
    </div>
  </div>
);

const Review: React.FC<ReviewProps> = ({ restaurantId }) => {
  const [reviews, setReviews] = useState<Review[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [page, setPage] = useState(1);
  const [pageSize, setPageSize] = useState(5); // You can adjust this value
  const [totalPages, setTotalPages] = useState(1);
  const [sort, setSort] = useState<'newest' | 'oldest' | 'highest_rating'>('newest');
  const [ratingFilter, setRatingFilter] = useState<string>('all');

  useEffect(() => {
    async function fetchReviews() {
      try {
        setLoading(true);
        const response = await fetch(`https://g6-menumate-1.onrender.com/api/v1/restaurants/${restaurantId}/reviews?page=${page}&pageSize=${pageSize}&sort=${sort}&rating=${ratingFilter}`);
        if (!response.ok) {
          throw new Error('Failed to fetch reviews.');
        }
        const data = await response.json();
        setReviews(data.reviews || []);
        setTotalPages(data.totalPages || 1);
      } catch (err) {
        setError(err instanceof Error ? err.message : 'An unknown error occurred.');
      } finally {
        setLoading(false);
      }
    }
    
    if (restaurantId) {
      fetchReviews();
    }
  }, [restaurantId, page, pageSize, sort, ratingFilter]);

  const handleNextPage = () => setPage(prev => Math.min(prev + 1, totalPages));
  const handlePrevPage = () => setPage(prev => Math.max(prev - 1, 1));
  const handleSortChange = (newSort: 'newest' | 'oldest' | 'highest_rating') => {
    setSort(newSort);
    setPage(1); // Reset to first page on sort change
  };
  const handleRatingChange = (newRating: string) => {
    setRatingFilter(newRating);
    setPage(1); // Reset to first page on filter change
  };

  if (loading) {
    return (
      <div className="space-y-6 border rounded-xl p-6 shadow-sm">
        <h2 className='text-3xl font-bold text-gray-800 mb-6'>Customer Reviews</h2>
        <ReviewSkeleton />
      </div>
    );
  }

  if (error) {
    return (
      <div className="text-center p-6 text-red-500 border rounded-xl shadow-sm">
        <p>Error: {error}</p>
        <p>Could not load reviews. Please try again later.</p>
      </div>
    );
  }

  return (
    <div className="space-y-6 border rounded-xl p-6 shadow-sm bg-gray-50">
      <h2 className='text-3xl font-bold text-gray-800'>Customer Reviews</h2>

      {/* Controls: Sorting and Filtering */}
      <div className="flex flex-col sm:flex-row justify-between items-center space-y-4 sm:space-y-0 sm:space-x-4 p-4 rounded-lg bg-white shadow-sm">
        <div className="flex-1 w-full sm:w-auto">
          <label htmlFor="sort" className="text-gray-700 mr-2 font-medium">Sort By:</label>
          <select
            id="sort"
            value={sort}
            onChange={(e) => handleSortChange(e.target.value as any)}
            className="rounded-md border border-gray-300 py-1 px-2 focus:outline-none focus:ring-2 focus:ring-[var(--color-primary)]"
          >
            <option value="newest">Newest</option>
            <option value="oldest">Oldest</option>
            <option value="highest_rating">Highest Rating</option>
          </select>
        </div>
        <div className="flex-1 w-full sm:w-auto">
          <label htmlFor="rating-filter" className="text-gray-700 mr-2 font-medium">Rating:</label>
          <select
            id="rating-filter"
            value={ratingFilter}
            onChange={(e) => handleRatingChange(e.target.value)}
            className="rounded-md border border-gray-300 py-1 px-2 focus:outline-none focus:ring-2 focus:ring-[var(--color-primary)]"
          >
            <option value="all">All</option>
            <option value="5">5 Stars</option>
            <option value="4">4 Stars & Up</option>
            <option value="3">3 Stars & Up</option>
            <option value="2">2 Stars & Up</option>
            <option value="1">1 Star & Up</option>
          </select>
        </div>
      </div>

      {reviews.length > 0 ? (
        <div className="space-y-6">
          {reviews.map((review) => (
            <ReviewCard key={review.id} review={review} />
          ))}
        </div>
      ) : (
        <div className="text-center p-6 bg-white rounded-2xl shadow-sm border border-gray-200">
          <p className="text-gray-500 font-medium">No reviews found for this restaurant.</p>
        </div>
      )}

      {/* Pagination Controls */}
      {totalPages > 1 && (
        <div className="flex justify-center items-center gap-4 mt-6">
          <button
            onClick={handlePrevPage}
            disabled={page === 1}
            className="p-2 rounded-full text-gray-700 hover:bg-gray-200 transition-colors disabled:opacity-50 disabled:cursor-not-allowed"
          >
            <ArrowLeft className="w-5 h-5" />
          </button>
          <span className="text-gray-700 font-medium">
            Page {page} of {totalPages}
          </span>
          <button
            onClick={handleNextPage}
            disabled={page === totalPages}
            className="p-2 rounded-full text-gray-700 hover:bg-gray-200 transition-colors disabled:opacity-50 disabled:cursor-not-allowed"
          >
            <ArrowRight className="w-5 h-5" />
          </button>
        </div>
      )}
    </div>
  );
};

export default Review;
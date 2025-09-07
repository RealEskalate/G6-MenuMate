"use client"
import * as React from "react"
import { useState, FormEvent } from "react"
import { Star, Upload, X } from "lucide-react"
import { Input } from "@/components/ui/input"
import { Button } from "@/components/ui/button"
import { Textarea } from "@/components/ui/textarea"
import { toast } from 'react-toastify';
import 'react-toastify/dist/ReactToastify.css';

// You would pass this as a prop, for example:
// <ReviewForm restaurantId="some-restaurant-id-123" userId="user-id-456" />
interface ReviewFormProps {
  restaurantId: string;
  userId: string;
  // A callback to refresh the reviews list after a successful submission
  onReviewSubmitted?: () => void;
}

export default function ReviewForm({ restaurantId, userId, onReviewSubmitted }: ReviewFormProps) {
  const [rating, setRating] = useState(0);
  const [hover, setHover] = useState(0);
  const [comment, setComment] = useState("");
  const [title, setTitle] = useState("");
  const [file, setFile] = useState<File | null>(null);
  const [loading, setLoading] = useState(false);

  const handleFileChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    if (e.target.files) {
      setFile(e.target.files[0] || null);
    }
  };

  const handleSubmit = async (e: FormEvent) => {
    e.preventDefault();
    setLoading(true);

    if (rating === 0 || !comment.trim()) {
      toast.error("Please provide a rating and a comment.");
      setLoading(false);
      return;
    }

    // You would typically upload the photo to a service like Cloudinary first.
    // For this example, we'll assume the API can handle a direct file upload or a URL.
    // If you're using a file, you might need to use FormData.
    const reviewData = {
      restaurant_id: restaurantId,
      user_id: userId,
      rating: rating,
      title: title || "New Review", // Use a default title if none is provided
      comment: comment,
      visit_date: new Date().toISOString(),
      photos: file ? [file] : [], // This part depends on your API's file handling
      categories: {
        food_quality: rating, // Using the same rating for all categories for simplicity
        service: rating,
        ambiance: rating,
        value_for_money: rating,
      },
    };

    try {
      const formData = new FormData();
      formData.append("review", JSON.stringify(reviewData));
      if (file) {
        formData.append("photo", file);
      }
      
      const response = await fetch("https://g6-menumate-1.onrender.com/api/v1/reviews", {
        method: "POST",
        body: formData, // Use FormData for file uploads
      });

      if (!response.ok) {
        const errorData = await response.json();
        throw new Error(errorData.message || "Failed to submit review.");
      }

      toast.success("Review submitted successfully! 🎉");
      
      // Reset form fields
      setRating(0);
      setHover(0);
      setComment("");
      setTitle("");
      setFile(null);
      
      // Call parent callback to refresh reviews
      onReviewSubmitted?.();

    } catch (error) {
      toast.error(error.message || "An unknown error occurred.");
    } finally {
      setLoading(false);
    }
  };

  return (
    <form onSubmit={handleSubmit} className="p-6 border rounded-xl shadow-sm bg-white">
      <h2 className='text-3xl font-bold text-gray-800 mb-2'>Write a Review</h2>
      <p className="text-gray-600 mb-6">Share your experience with us!</p>

      {/* Rating */}
      <div className="mb-6">
        <label className="block text-md font-medium text-gray-900 mb-2">
          Your Overall Rating
        </label>
        <div className="flex gap-2">
          {[1, 2, 3, 4, 5].map((star) => (
            <button
              type="button"
              key={star}
              onClick={() => setRating(star)}
              onMouseEnter={() => setHover(star)}
              onMouseLeave={() => setHover(0)}
              className="focus:outline-none"
            >
              <Star
                className={`w-10 h-10 transition-all duration-200 ${
                  star <= (hover || rating)
                    ? "fill-[var(--color-primary)] text-[var(--color-primary)]"
                    : "text-gray-300"
                }`}
              />
            </button>
          ))}
        </div>
      </div>
      
      {/* Title */}
      <Input 
        label="Review Title" 
        placeholder="e.g., Delicious Food & Great Service" 
        value={title}
        onChange={(e) => setTitle(e.target.value)}
        className="mb-4" 
      />

      {/* Comment */}
      <div className="mb-6">
        <label className="block text-md font-medium text-gray-900 mb-2">
          Your Comment
        </label>
        <Textarea
          placeholder="What did you like or dislike? How was your experience?"
          rows={4}
          value={comment}
          onChange={(e) => setComment(e.target.value)}
          className="w-full rounded-md border border-input bg-transparent px-3 py-2 text-base shadow-sm focus:border-[var(--color-primary)] focus:ring-[var(--color-primary)]/40 focus:ring-1 outline-none"
        />
      </div>

      {/* File Upload */}
      <div className="mb-6">
        <label className="block text-md font-medium text-gray-900 mb-2">
          Add photos (optional)
        </label>
        <div 
          className="flex flex-col items-center justify-center border-2 border-dashed border-gray-300 rounded-lg p-6 cursor-pointer hover:border-[var(--color-primary)] transition"
          onClick={() => document.getElementById('upload-input')?.click()}
        >
          <input
            type="file"
            accept="image/*"
            onChange={handleFileChange}
            className="hidden"
            id="upload-input"
          />
          {file ? (
            <div className="flex items-center space-x-2">
              <span className="text-sm text-gray-600">{file.name}</span>
              <button 
                type="button" 
                onClick={(e) => { e.stopPropagation(); setFile(null); }}
                className="text-red-500 hover:text-red-700"
              >
                <X className="w-4 h-4" />
              </button>
            </div>
          ) : (
            <div className="flex flex-col items-center">
              <Upload className="w-8 h-8 text-gray-400 mb-2" />
              <span className="text-sm text-gray-600">Click to upload photos</span>
              <span className="text-xs text-gray-400">JPG, PNG up to 5MB each</span>
            </div>
          )}
        </div>
      </div>

      {/* Submit Button */}
      <Button 
        type="submit"
        size="lg" 
        className="w-full"
        disabled={loading}
      >
        {loading ? "Submitting..." : "Submit Review"}
      </Button>
    </form>
  );
}
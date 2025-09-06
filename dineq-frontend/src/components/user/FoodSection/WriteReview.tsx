"use client"
import * as React from "react"
import { useState } from "react"
import { Star, Upload } from "lucide-react"
import { Input } from "@/components/ui/input"
import { Button } from "@/components/ui/button"

export default function ReviewForm() {
  const [rating, setRating] = useState(0)
  const [hover, setHover] = useState(0)
  const [file, setFile] = useState<File | null>(null)

  return (
    <div className=" p-6 border rounded-xl shadow-sm">
      <h2 className='text-2xl font-semibold mb-3'>Write a Review</h2>
      <p className="text-gray-600 mb-6">Share your thoughts</p>

      {/* Name */}
      <Input label="Name" placeholder="Enter your name" required className="mb-4" />

      {/* Rating */}
      <div className="mb-4">
        <label className="block text-lg font-medium text-gray-900 mb-2">
          Rate your experience
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
                className={`w-8 h-8 ${
                  star <= (hover || rating)
                    ? "fill-[var(--color-primary)] text-[var(--color-primary)]"
                    : "text-gray-300"
                }`}
              />
            </button>
          ))}
        </div>
      </div>

      {/* Comment */}
      <div className="mb-4">
        <label className="block text-lg font-medium text-gray-900 mb-2">
          Comment
        </label>
        <textarea
          placeholder="Write your review..."
          rows={4}
          className="w-full rounded-md border border-input bg-transparent px-3 py-2 text-base shadow-xs focus-visible:border-[var(--color-primary)] focus-visible:ring-[var(--color-primary)]/40 focus-visible:ring-[1px] outline-none"
        />
      </div>

      {/* File Upload */}
      <div className="mb-6">
        <label className="block text-lg font-medium text-gray-900 mb-2">
          Add photos (optional)
        </label>
        <div className="flex flex-col items-center justify-center border-2 border-dashed border-gray-300 rounded-lg p-6 cursor-pointer hover:border-[var(--color-primary)] transition">
          <input
            type="file"
            accept="image/*"
            onChange={(e) => setFile(e.target.files?.[0] || null)}
            className="hidden"
            id="upload"
          />
          <label htmlFor="upload" className="flex flex-col items-center cursor-pointer">
            <Upload className="w-8 h-8 text-gray-400 mb-2" />
            <span className="text-sm text-gray-600">
              {file ? file.name : "Upload photos"}
            </span>
            <span className="text-xs text-gray-400">JPG, PNG up to 5MB each</span>
          </label>
        </div>
      </div>

      {/* Submit */}
      <Button variant="default" size="lg" className="w-full">
        Submit Review
      </Button>
    </div>
  )
}

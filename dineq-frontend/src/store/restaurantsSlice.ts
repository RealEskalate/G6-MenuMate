// src/store/restaurantsSlice.ts
import { createSlice, createAsyncThunk } from "@reduxjs/toolkit";

// API Response types based on the actual API structure
interface ApiRestaurant {
  id: string;
  slug: string;
  name: string;
  manager_id: string;
  phone: string;
  about: string;
  logo_image: string;
  tags: string[];
  verification_status: string;
  average_rating: number;
  view_count: number;
  branch_count: number;
}

// Define the type of the parameter for fetchRestaurants
interface FetchRestaurantsParams {
  page?: number;
  pageSize?: number;
}

// Async thunk to fetch restaurants from the API
export const fetchRestaurants = createAsyncThunk(
  "restaurants/fetch",
  async ({ page = 1, pageSize = 20 }: FetchRestaurantsParams) => {
    const res = await fetch(
      `https://g6-menumate-1.onrender.com/api/v1/restaurants?page=1&pageSize=20`,
      { cache: "no-store" }
    );
    if (!res.ok) throw new Error("Failed to fetch restaurants");
    const data = await res.json();
    return data.data; // array of restaurants
  }
);

interface RestaurantState {
  restaurants: ApiRestaurant[];
  loading: boolean;
  error: string | null;
}

const initialState: RestaurantState = {
  restaurants: [],
  loading: false,
  error: null,
};

// Create the slice
const restaurantsSlice = createSlice({
  name: "restaurants",
  initialState,
  reducers: {},
  extraReducers: (builder) => {
    builder
      .addCase(fetchRestaurants.pending, (state) => {
        state.loading = true;
        state.error = null;
      })
      .addCase(fetchRestaurants.fulfilled, (state, action) => {
        state.restaurants = action.payload;
        state.loading = false;
      })
      .addCase(fetchRestaurants.rejected, (state, action) => {
        state.loading = false;
        state.error = action.error.message || "Something went wrong";
      });
  },
});

export default restaurantsSlice.reducer;

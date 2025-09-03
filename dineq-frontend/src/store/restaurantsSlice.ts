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
  tags?: string[];
  verification_status?: string;
  average_rating: number;
  view_count?: number;
  branch_count?: number;
}

interface ApiResponseEnvelope {
  page: number;
  pageSize: number;
  restaurants: ApiRestaurant[];
  total: number;
  totalPages: number;
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
    const url = `https://g6-menumate-1.onrender.com/api/v1/restaurants?page=${encodeURIComponent(
      page
    )}&pageSize=${encodeURIComponent(pageSize)}`;

    const res = await fetch(url, { cache: "no-store" });
    if (!res.ok) throw new Error("Failed to fetch restaurants");

    const data: ApiResponseEnvelope = await res.json();
    return data.restaurants; // array of restaurants
  }
);

// Fetch single restaurant by ID
export const fetchRestaurantById = createAsyncThunk(
  "restaurants/fetchById",
  async (id: string) => {
    // Try direct endpoint first
    const direct = await fetch(
      `https://g6-menumate-1.onrender.com/api/v1/restaurants/${encodeURIComponent(id)}`,
      { cache: "no-store" }
    );
    if (direct.ok) {
      const data = await direct.json();
      const entity = (data && (data.restaurant || data.data || data)) as any;
      if (entity && entity.id) return entity as ApiRestaurant;
    }

    // Fallback to list and find
    const listRes = await fetch(
      `https://g6-menumate-1.onrender.com/api/v1/restaurants?page=1&pageSize=50`,
      { cache: "no-store" }
    );
    if (!listRes.ok) throw new Error("Failed to fetch restaurant");
    const listData = await listRes.json();
    const list = (listData && (listData.restaurants || listData.data || [])) as ApiRestaurant[];
    const found = list.find((r) => String(r.id) === id);
    if (!found) throw new Error("Restaurant not found");
    return found;
  }
);

interface RestaurantState {
  restaurants: ApiRestaurant[];
  loading: boolean;
  error: string | null;
  currentRestaurant: ApiRestaurant | null;
  currentLoading: boolean;
  currentError: string | null;
}

const initialState: RestaurantState = {
  restaurants: [],
  loading: false,
  error: null,
  currentRestaurant: null,
  currentLoading: false,
  currentError: null,
};

// Create the slice
const restaurantsSlice = createSlice({
  name: "restaurants",
  initialState,
  reducers: {},
  extraReducers: (builder) => {
    builder
      // list
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
      })
      // single by id
      .addCase(fetchRestaurantById.pending, (state) => {
        state.currentLoading = true;
        state.currentError = null;
        state.currentRestaurant = null;
      })
      .addCase(fetchRestaurantById.fulfilled, (state, action) => {
        state.currentRestaurant = action.payload;
        state.currentLoading = false;
      })
      .addCase(fetchRestaurantById.rejected, (state, action) => {
        state.currentLoading = false;
        state.currentError = action.error.message || "Something went wrong";
      });
  },
});

export default restaurantsSlice.reducer;

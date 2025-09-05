// src/store/restaurantsSlice.ts
import { createSlice, createAsyncThunk } from "@reduxjs/toolkit";

// API Response types based on the actual API structure
export interface ApiRestaurant {
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
  message?: string;
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
    const apiUrl = process.env.NEXT_PUBLIC_API_BASE_URL;
    const url = `${apiUrl}/restaurants?page=${encodeURIComponent(
      page
    )}&pageSize=${encodeURIComponent(pageSize)}`;

    const res = await fetch(url, { cache: "no-store" });
    const responseText = await res.text();
    let data: ApiResponseEnvelope;
    try {
        data = responseText ? JSON.parse(responseText) : { restaurants: [] };
    } catch (error) {
        console.error("Failed to parse JSON response:", responseText);
        throw new Error("Received an invalid response from the server.");
    }

    if (!res.ok) {
      throw new Error(data.message || `Request failed with status ${res.status}`);
    }

    return data.restaurants; // array of restaurants
  }
);

// Fetch single restaurant by ID
export const fetchRestaurantById = createAsyncThunk(
  "restaurants/fetchById",
  async (id: string) => {
    // Try direct endpoint first
    const direct = await fetch(
      `${process.env.NEXT_PUBLIC_API_BASE_URL}/restaurants/${encodeURIComponent(id)}`,
      { cache: "no-store" }
    );

    if (direct.ok) {
      const responseText = await direct.text();
      let data;
      try {
          data = responseText ? JSON.parse(responseText) : {};
      } catch (error) {
          console.error("Failed to parse JSON response:", responseText);
          throw new Error("Received an invalid response from the server.");
      }

      let entity: ApiRestaurant | undefined;
      if ("restaurant" in data && data.restaurant) {
        entity = data.restaurant;
      } else if ("data" in data && data.data) {
        entity = data.data;
      } else if ("id" in data) {
        entity = data as ApiRestaurant;
      }

      if (entity && entity.id) return entity;
    }

    // Fallback to list and find
    const listRes = await fetch(
      `${process.env.NEXT_PUBLIC_API_BASE_URL}/restaurants?page=1&pageSize=50`,
      { cache: "no-store" }
    );
    if (!listRes.ok) throw new Error("Failed to fetch restaurant");

    const responseText = await listRes.text();
    let listData;
    try {
        listData = responseText ? JSON.parse(responseText) : {};
    } catch (error) {
        console.error("Failed to parse JSON response:", responseText);
        throw new Error("Received an invalid response from the server.");
    }
    let list: ApiRestaurant[] = [];

    if (Array.isArray(listData)) {
      list = listData;
    } else if ("restaurants" in listData && listData.restaurants) {
      list = listData.restaurants;
    } else if ("data" in listData && listData.data) {
      list = listData.data;
    }

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

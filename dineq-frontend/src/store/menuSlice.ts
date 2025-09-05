

import { createSlice, createAsyncThunk, PayloadAction } from "@reduxjs/toolkit";

// Types
export interface MenuItem {
  id: string;
  name: string;
  description: string;
  price: number;
  image?: string;
  category?: string;
  is_available: boolean;
  created_at: string;
  updated_at: string;
}

export interface Menu {
  id: string;
  name: string;
  description?: string;
  restaurant_id: string;
  slug: string;
  is_active: boolean;
  created_at: string;
  updated_at: string;
  items?: MenuItem[];
}

export interface MenuResponse {
  message: string;
  data: {
    menu: Menu[];
  };
}

export interface MenuItemsResponse {
  message: string;
  data: {
    items: MenuItem[];
  };
}

// Async thunks
export const fetchMenusByRestaurantSlug = createAsyncThunk(
  "menu/fetchByRestaurantSlug",
  async ({ restaurantSlug, accessToken }: { restaurantSlug: string; accessToken: string }) => {
    const response = await fetch(
      `${process.env.NEXT_PUBLIC_API_BASE_URL}/menus/${restaurantSlug}`,
      { 
        cache: "no-store",
        headers: {
          'Authorization': `Bearer ${accessToken}`,
          'Content-Type': 'application/json'
        }
      }
    );
    
    const responseText = await response.text();
    let data;
    try {
        data = responseText ? JSON.parse(responseText) : {};
    } catch (error) {
        console.error("Failed to parse JSON response:", responseText);
        throw new Error("Received an invalid response from the server.");
    }

    if (!response.ok) {
      throw new Error(data.message || `Request failed with status ${response.status}`);
    }
    
    return data.data.menu;
  }
);

export const fetchMenuItemsByMenuSlug = createAsyncThunk(
  "menu/fetchItemsByMenuSlug",
  async ({ menuSlug, accessToken }: { menuSlug: string; accessToken: string }) => {
    const response = await fetch(
      `${process.env.NEXT_PUBLIC_API_BASE_URL}/menu-items/${menuSlug}`,
      { 
        cache: "no-store",
        headers: {
          'Authorization': `Bearer ${accessToken}`,
          'Content-Type': 'application/json'
        }
      }
    );
    
    const responseText = await response.text();
    let data;
    try {
        data = responseText ? JSON.parse(responseText) : {};
    } catch (error) {
        console.error("Failed to parse JSON response:", responseText);
        throw new Error("Received an invalid response from the server.");
    }

    if (!response.ok) {
      throw new Error(data.message || `Request failed with status ${response.status}`);
    }
    
    return data.data.items;
  }
);

export const fetchMenuById = createAsyncThunk(
  "menu/fetchById",
  async ({ menuId, accessToken }: { menuId: string; accessToken: string }) => {
    const response = await fetch(
      `${process.env.NEXT_PUBLIC_API_BASE_URL}/menus/${menuId}`,
      { 
        cache: "no-store",
        headers: {
          'Authorization': `Bearer ${accessToken}`,
          'Content-Type': 'application/json'
        }
      }
    );
    
    const responseText = await response.text();
    let data;
    try {
        data = responseText ? JSON.parse(responseText) : {};
    } catch (error) {
        console.error("Failed to parse JSON response:", responseText);
        throw new Error("Received an invalid response from the server.");
    }

    if (!response.ok) {
      throw new Error(data.message || `Request failed with status ${response.status}`);
    }
    
    return data.data.menu;
  }
);

interface MenuState {
  menus: Menu[];
  currentMenuItems: MenuItem[];
  loading: boolean;
  itemsLoading: boolean;
  error: string | null;
  itemsError: string | null;
}

const initialState: MenuState = {
  menus: [],
  currentMenuItems: [],
  loading: false,
  itemsLoading: false,
  error: null,
  itemsError: null,
};

const menuSlice = createSlice({
  name: "menu",
  initialState,
  reducers: {
    clearMenus: (state) => {
      state.menus = [];
      state.currentMenuItems = [];
      state.error = null;
      state.itemsError = null;
    },
    clearMenuItems: (state) => {
      state.currentMenuItems = [];
      state.itemsError = null;
    },
  },
  extraReducers: (builder) => {
    // Fetch menus by restaurant slug
    builder
      .addCase(fetchMenusByRestaurantSlug.pending, (state) => {
        state.loading = true;
        state.error = null;
      })
      .addCase(fetchMenusByRestaurantSlug.fulfilled, (state, action: PayloadAction<Menu[]>) => {
        state.loading = false;
        state.menus = action.payload;
        state.error = null;
      })
      .addCase(fetchMenusByRestaurantSlug.rejected, (state, action) => {
        state.loading = false;
        state.error = action.error.message || "Failed to fetch menus";
      });

    // Fetch menu items by menu slug
    builder
      .addCase(fetchMenuItemsByMenuSlug.pending, (state) => {
        state.itemsLoading = true;
        state.itemsError = null;
      })
      .addCase(fetchMenuItemsByMenuSlug.fulfilled, (state, action: PayloadAction<MenuItem[]>) => {
        state.itemsLoading = false;
        state.currentMenuItems = action.payload;
        state.itemsError = null;
      })
      .addCase(fetchMenuItemsByMenuSlug.rejected, (state, action) => {
        state.itemsLoading = false;
        state.itemsError = action.error.message || "Failed to fetch menu items";
      });

    // Fetch menu by ID
    builder
      .addCase(fetchMenuById.pending, (state) => {
        state.loading = true;
        state.error = null;
      })
      .addCase(fetchMenuById.fulfilled, (state, action: PayloadAction<Menu[]>) => {
        state.loading = false;
        state.menus = action.payload;
        state.error = null;
      })
      .addCase(fetchMenuById.rejected, (state, action) => {
        state.loading = false;
        state.error = action.error.message || "Failed to fetch menu";
      });
  },
});

export const { clearMenus, clearMenuItems } = menuSlice.actions;
export default menuSlice.reducer;

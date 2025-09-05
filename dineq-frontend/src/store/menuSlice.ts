// store/menuSlice.ts
import { createSlice, PayloadAction } from "@reduxjs/toolkit";
import { MenuItem } from "@/lib/api"; // the interface we defined earlier

interface MenuState {
  menuItems: MenuItem[];
}

const initialState: MenuState = {
  menuItems: [],
};

const menuSlice = createSlice({
  name: "menu",
  initialState,
  reducers: {
    setMenuItems: (state, action: PayloadAction<MenuItem[]>) => {
      state.menuItems = action.payload;
    },
    clearMenuItems: (state) => {
      state.menuItems = [];
    },
  },
});

export const { setMenuItems, clearMenuItems } = menuSlice.actions;
export default menuSlice.reducer;

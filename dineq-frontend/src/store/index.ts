// store/index.ts
import { configureStore } from "@reduxjs/toolkit";
import menuReducer from "./menuSlice";

export const store = configureStore({
  reducer: {
    menu: menuReducer,
  },
});

// Infer types
export type RootState = ReturnType<typeof store.getState>;
export type AppDispatch = typeof store.dispatch;

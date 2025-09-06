// src/store/store.ts
import { configureStore } from "@reduxjs/toolkit";
import restaurantsReducer from "@/store/restaurantsSlice";


export const store = configureStore({
  reducer: {
    restaurants: restaurantsReducer,
    
  },
});

// Infer the `RootState` and `AppDispatch` types for TypeScript
export type RootState = ReturnType<typeof store.getState>;
export type AppDispatch = typeof store.dispatch;

import { Dispatch } from "@reduxjs/toolkit";
import { setMenuItems } from "./menuSlice";
import { uploadMenuOCR, getOCRStatus } from "@/lib/api";
import { AppRouterInstance } from "next/dist/shared/lib/app-router-context.shared-runtime";

export const startOCRProcessing = (
  file: File,
  accessToken: string,
  router: AppRouterInstance
) => {
  return async (dispatch: Dispatch) => {
    try {
      // Step 1: Upload the file and get the job ID
      const result = await uploadMenuOCR(file, accessToken);
      const jobId = result.data.job_id;

      // Step 2: Poll for the OCR status
      const poll = async () => {
        const statusRes = await getOCRStatus(jobId, accessToken);
        const { status, results, progress } = statusRes.data;

        // You could dispatch progress updates here if needed
        // dispatch(setOCRProgress(progress));

        if (status === "completed") {
          if (results?.menu_items) {
            // Step 3: Dispatch the menu items to the Redux store
            dispatch(setMenuItems(results.menu_items));
          }
          // Step 4: Navigate *after* the dispatch is complete
          router.push("/restaurant/dashboard/menu/manual_menu");
        } else if (status === "failed") {
          console.error("❌ OCR job failed");
          // Handle failure (e.g., dispatch an error action)
        } else {
          // Poll again after a delay
          setTimeout(poll, 3000);
        }
      };

      await poll();
    } catch (err) {
      console.error("❌ Error during OCR process:", err);
      // Handle overall error
    }
  };
};

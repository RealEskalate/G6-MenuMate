// "use client";

// import React from "react";
// import OpeningHours from "./components/OpeningHours";

// const SettingProfile = () => {
//   return (
//     <div className="w-full h-full max-w-full max-h-full overflow-auto lg:w-auto lg:h-auto lg:overflow-visible">
//       <h1 className="font-semibold text-2xl">Restaurant Details</h1>
//       {/* Restaurant Details and Country Type */}
//       <div className="grid grid-cols-1 min-w-[200px] md:grid-cols-2 gap-x-8 gap-y-6 mt-5">
//         {/* Restaurant Name Field */}
//         <div>
//           <label
//             htmlFor="restaurant_name"
//             className="block font-semibold text-base text-gray-700 mb-2"
//           >
//             Restaurant name
//           </label>
//           <input
//             type="text"
//             id="restaurant_name"
//             className="block w-full border border-gray-300 rounded-lg p-2.5 focus:ring-blue-500 focus:border-blue-500"
//           />
//         </div>

//         {/* Country Field */}
//         <div>
//           <label
//             htmlFor="cuisine_type"
//             className="block font-semibold text-base text-gray-700 mb-2"
//           >
//             Cuisine Type
//           </label>
//           <input
//             type="text"
//             id="cuisine_type"
//             className="block w-full border border-gray-300 rounded-lg p-2.5 focus:ring-blue-500 focus:border-blue-500"
//           />
//         </div>
//       </div>

//       {/* Restaurant Photo upload */}
//       <div className="flex flex-col md:flex-row gap-10 mt-10 justify-between">
//         <div>
//           {/* Logo Upload area*/}
//           <label
//             htmlFor="logo"
//             className="block text-sm font-medium text-gray-700 mb-1"
//           >
//             Logo
//           </label>

//           <label
//             htmlFor="logo"
//             className="flex flex-col items-center justify-center w-full bg-white border border-gray-300 rounded-lg cursor-pointer hover:bg-gray-50 transition-colors md:w-[24rem] max-w-md h-40 "
//           >
//             <div className="flex flex-col items-center justify-center pt-5 pb-6">
//               {/* Icon */}
//               <svg
//                 className="w-8 h-8 mb-3 text-gray-400"
//                 aria-hidden="true"
//                 xmlns="http://www.w3.org/2000/svg"
//                 fill="none"
//                 viewBox="0 0 24 24"
//                 strokeWidth="1.5"
//                 stroke="currentColor"
//               >
//                 <path
//                   strokeLinecap="round"
//                   strokeLinejoin="round"
//                   d="M2.25 15.75l5.159-5.159a2.25 2.25 0 013.182 0l5.159 5.159m-1.5-1.5l1.409-1.409a2.25 2.25 0 013.182 0l2.909 2.909m-18 3.75h16.5a1.5 1.5 0 001.5-1.5V6a1.5 1.5 0 00-1.5-1.5H3.75A1.5 1.5 0 002.25 6v12a1.5 1.5 0 001.5 1.5zm10.5-11.25h.008v.008h-.008V8.25zm.375 0a.375.375 0 11-.75 0 .375.375 0 01.75 0z"
//                 />
//               </svg>

//               {/* Text */}
//               <p className="text-sm text-gray-600">Upload photo</p>
//             </div>

//             {/* Your original file input, now correctly linked and hidden */}
//             <input type="file" id="logo" className="hidden" accept="image/*" />
//           </label>
//         </div>
//         {/* logo upload area ends */}

//         {/* Banner upload area */}
//         <div>
//           <label
//             htmlFor="banner"
//             className="block text-sm font-medium text-gray-700 mb-1"
//           >
//             Cover/Banner
//           </label>

//           {/* This new label acts as the clickable, styled upload area */}
//           <label
//             htmlFor="banner"
//             className="flex flex-col items-center justify-center w-full bg-white border border-gray-300 rounded-lg cursor-pointer hover:bg-gray-50 transition-colors md:w-[24rem] max-w-md h-40 "
//           >
//             <div className="flex flex-col items-center justify-center pt-5 pb-6">
//               {/* Icon */}
//               <svg
//                 className="w-8 h-8 mb-3 text-gray-400"
//                 aria-hidden="true"
//                 xmlns="http://www.w3.org/2000/svg"
//                 fill="none"
//                 viewBox="0 0 24 24"
//                 strokeWidth="1.5"
//                 stroke="currentColor"
//               >
//                 <path
//                   strokeLinecap="round"
//                   strokeLinejoin="round"
//                   d="M2.25 15.75l5.159-5.159a2.25 2.25 0 013.182 0l5.159 5.159m-1.5-1.5l1.409-1.409a2.25 2.25 0 013.182 0l2.909 2.909m-18 3.75h16.5a1.5 1.5 0 001.5-1.5V6a1.5 1.5 0 00-1.5-1.5H3.75A1.5 1.5 0 002.25 6v12a1.5 1.5 0 001.5 1.5zm10.5-11.25h.008v.008h-.008V8.25zm.375 0a.375.375 0 11-.75 0 .375.375 0 01.75 0z"
//                 />
//               </svg>

//               {/* Text */}
//               <p className="text-sm text-gray-600">Upload photo</p>
//             </div>

//             {/* Your original file input, now correctly linked and hidden */}
//             <input
//               type="file"
//               id="banner"
//               className="hidden"
//               accept="image/*"
//             />
//           </label>
//         </div>
//       </div>
//       {/* Restaurant Photo upload end */}

//       {/*Description*/}
//       <div className="w-full md:w-[51rem] mt-3">
//         <label
//           htmlFor="description"
//           className="block text-sm font-medium text-gray-700 mb-1"
//         >
//           Description
//         </label>

//         <div className="relative">
//           <textarea
//             id="description"
//             rows={4}
//             className="block w-full px-4 py-3 pr-12 text-gray-900 border border-gray-300 rounded-lg shadow-sm focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent"
//             placeholder="Enter a description..."
//             defaultValue="Authentic Ethiopian flavours"
//           />
//         </div>
//       </div>

//       {/* START: Contact Details Section */}
//       <div className="mt-8">
//         <div className="grid grid-cols-1 md:grid-cols-2 gap-x-8 gap-y-6">
//           {/* Email Field */}
//           <div>
//             <label
//               htmlFor="email"
//               className="block text-sm font-medium text-gray-700"
//             >
//               email
//             </label>
//             <div className="mt-1 relative">
//               <input
//                 type="email"
//                 id="email"
//                 className="block w-full px-4 py-3 pr-10 text-gray-900 border border-gray-300 rounded-lg shadow-sm focus:outline-none focus:ring-2 focus:ring-blue-500"
//                 defaultValue="yohannesT@gmail.com"
//               />
//             </div>
//           </div>

//           {/* Phone Number Field */}
//           <div>
//             <label
//               htmlFor="phone-number"
//               className="block text-sm font-medium text-gray-700"
//             >
//               Phone number
//             </label>
//             <div className="mt-1 relative">
//               <input
//                 type="tel"
//                 id="phone-number"
//                 className="block w-full px-4 py-3 pr-10 text-gray-900 border border-gray-300 rounded-lg shadow-sm focus:outline-none focus:ring-2 focus:ring-blue-500"
//                 defaultValue="+251 9 000000"
//               />
//             </div>
//           </div>
//         </div>

//         {/* Location Field */}
//         <div className="mt-6">
//           <label
//             htmlFor="location"
//             className="block text-sm font-medium text-gray-700"
//           >
//             Location
//           </label>
//           <div className="mt-1 relative">
//             <input
//               type="text"
//               id="location"
//               className="block w-full px-4 py-3 pr-10 text-gray-900 border border-gray-300 rounded-lg shadow-sm focus:outline-none focus:ring-2 focus:ring-blue-500"
//               defaultValue="Bole, Addis Ababa"
//             />
//           </div>
//         </div>

//         {/* Map Image */}
//         <div className="mt-4">
//           <img
//             src="https://i.imgur.com/4l34n4A.png" // Placeholder map image
//             alt="Location map"
//             className="w-full h-48 object-cover rounded-lg border border-gray-300"
//           />
//         </div>
//       </div>
//       {/* END: Contact Details Section */}

//       {/* START: Opening Hours Section */}

//       <OpeningHours />

//       {/* END: Opening Hours Section */}
//     </div>
//   );
// };

// export default SettingProfile;

"use client";

import React, { useState, useEffect, useCallback, ChangeEvent } from "react";
import { useSession } from "next-auth/react"; // Import useSession

import {
  getMyRestaurantProfile,
  updateRestaurantProfile,
} from "../../../../../lib/restaurant_setting_api"; // path for update and get restaurant api requests along with the updating form data
import OpeningHours, {
  DaySchedule,
  SpecialDay,
} from "./components/OpeningHours";

// Define the shape of our data state based on the API response
type ProfileState = {
  name: string;
  cuisine_type: string;
  about: string;
  email: string;
  phone: string;
  location_string: string;
  logo_image: string | null;
  cover_image: string | null;
  schedule: DaySchedule[];
  special_days: SpecialDay[];
};

const EditIcon = () => (
  <svg
    xmlns="http://www.w3.org/2000/svg"
    fill="none"
    viewBox="0 0 24 24"
    strokeWidth="1.5"
    stroke="currentColor"
    className="w-5 h-5"
  >
    <path
      strokeLinecap="round"
      strokeLinejoin="round"
      d="M16.862 4.487l1.687-1.688a1.875 1.875 0 112.652 2.652L6.832 19.82a4.5 4.5 0 01-1.897 1.13l-2.685.8.8-2.685a4.5 4.5 0 011.13-1.897L16.863 4.487zm0 0L19.5 7.125"
    />
  </svg>
);

const SettingProfile = () => {
  const { data: session, status: sessionStatus } = useSession(); // Get the user's session
  const [data, setData] = useState<ProfileState | null>(null);
  const [isLoading, setIsLoading] = useState(true);
  const [slug, setSlug] = useState<string | null>(null); // We need to store the slug for updates
  const [activeField, setActiveField] = useState<string | null>(null);
  const [savingStatus, setSavingStatus] = useState<
    "idle" | "saving" | "saved" | "error"
  >("idle");

  useEffect(() => {
    // Only fetch data when the user session is loaded and authenticated
    if (sessionStatus === "authenticated" && session?.accessToken) {
      getMyRestaurantProfile(session.accessToken)
        .then((apiData) => {
          if (apiData.restaurants && apiData.restaurants.length > 0) {
            // Your API returns an array, so we take the first restaurant
            const restaurantData = apiData.restaurants[0];

            // Store the slug in state for future updates
            setSlug(restaurantData.slug);

            // Populate the data state
            setData({
              name: restaurantData.name || "",
              cuisine_type: restaurantData.cuisine_type || "",
              about: restaurantData.about || "",
              email: restaurantData.email || "",
              phone: restaurantData.phone || "",
              location_string:
                restaurantData.location?.coordinates?.join(", ") || "",
              logo_image: restaurantData.logo_image || null,
              cover_image: restaurantData.cover_image || null,
              schedule: restaurantData.schedule || [],
              special_days: restaurantData.special_days || [],
            });
          }
        })
        .catch((error) => setSavingStatus("error"))
        .finally(() => setIsLoading(false));
    } else if (sessionStatus === "unauthenticated") {
      // Handle case where user is not logged in
      setIsLoading(false);
    }
  }, [sessionStatus, session]);

  // === UPDATE HANDLER ===
  const handleAutosave = useCallback(
    async (updates: Record<string, any>) => {
      // We need the slug and token to make an update
      if (!slug || !session?.accessToken) return;

      setActiveField(null);
      setSavingStatus("saving");
      try {
        const updatedData = await updateRestaurantProfile(
          slug,
          session.accessToken,
          updates
        );
        // Sync local state with the confirmed data from the server
        setData((prevData) => ({ ...prevData!, ...updatedData }));
        setSavingStatus("saved");
      } catch (error) {
        setSavingStatus("error");
      } finally {
        setTimeout(() => setSavingStatus("idle"), 2000);
      }
    },
    [slug, session]
  );

  const handleInputChange = (
    e: ChangeEvent<HTMLInputElement | HTMLTextAreaElement>
  ) => {
    const { name, value } = e.target;
    setData((prev) => (prev ? { ...prev, [name]: value } : null));
  };

  const handleFileChange = (
    e: ChangeEvent<HTMLInputElement>,
    fieldName: "logo_image" | "cover_image"
  ) => {
    const file = e.target.files?.[0];
    if (file) {
      //update UI with a local preview
      const previewUrl = URL.createObjectURL(file);
      setData((prev) => (prev ? { ...prev, [fieldName]: previewUrl } : null));
      // Trigger the upload and save
      handleAutosave({ [fieldName]: file });
    }
  };

  const handleScheduleChange = (day: string, field: string, value: any) => {
    const newSchedule = data!.schedule.map((d) =>
      d.day === day ? { ...d, [field]: value } : d
    );
    setData((prev) => (prev ? { ...prev, schedule: newSchedule } : null));
    handleAutosave({ schedule: newSchedule });
  };

  const handleSpecialDayAdd = (newDay: SpecialDay) => {
    const newSpecialDays = [...data!.special_days, newDay];
    setData((prev) =>
      prev ? { ...prev, special_days: newSpecialDays } : null
    );
    handleAutosave({ special_days: newSpecialDays });
  };

  const handleSpecialDayDelete = (date: string) => {
    const newSpecialDays = data!.special_days.filter((d) => d.date !== date);
    setData((prev) =>
      prev ? { ...prev, special_days: newSpecialDays } : null
    );
    handleAutosave({ special_days: newSpecialDays });
  };

  if (isLoading || sessionStatus === "loading")
    return <div className="p-6">Loading profile...</div>;
  if (!data)
    return (
      <div className="p-6 text-red-500">
        Could not load restaurant profile. Please ensure you are logged in and
        have a restaurant assigned.
      </div>
    );

  return (
    <div>
      <div className="flex justify-between items-center mb-6">
        <h1 className="font-semibold text-2xl">Restaurant Details</h1>
        <div className="text-sm text-gray-500 h-5">
          {savingStatus === "saving" && "Saving..."}
          {savingStatus === "saved" && "✓ Changes saved"}
          {savingStatus === "error" && "✗ Error saving"}
        </div>
      </div>

      {/* Name & Cuisine */}
      <div className="grid grid-cols-1 md:grid-cols-2 gap-x-8 gap-y-6">
        <div>
          <label htmlFor="name" className="block font-semibold ...">
            Restaurant name
          </label>
          <div className="relative">
            <input
              name="name"
              id="name"
              value={data.name}
              onChange={handleInputChange}
              onFocus={() => setActiveField("name")}
              onBlur={() => handleAutosave({ name: data.name })}
              readOnly={activeField !== "name"}
              className="block w-full ... read-only:bg-gray-100 read-only:cursor-default"
            />
            <div className="absolute ...">
              <EditIcon />
            </div>
          </div>
        </div>
        <div>
          <label htmlFor="cuisine_type" className="block font-semibold ...">
            Cuisine Type
          </label>
          <div className="relative">
            <input
              name="cuisine_type"
              id="cuisine_type"
              value={data.cuisine_type}
              onChange={handleInputChange}
              onFocus={() => setActiveField("cuisine_type")}
              onBlur={() => handleAutosave({ cuisine_type: data.cuisine_type })}
              readOnly={activeField !== "cuisine_type"}
              className="block w-full ... read-only:bg-gray-100 read-only:cursor-default"
            />
            <div className="absolute ...">
              <EditIcon />
            </div>
          </div>
        </div>
      </div>

      {/* Photo Uploads */}
      <div className="flex flex-col md:flex-row gap-10 mt-10">
        <div>
          <label className="block ...">Logo</label>
          <label htmlFor="logo_image" className="flex ...">
            {data.logo_image ? (
              <img
                src={data.logo_image}
                alt="Logo Preview"
                className="h-full w-full object-cover rounded-lg"
              />
            ) : (
              <p>Upload photo</p>
            )}
          </label>
          <input
            type="file"
            id="logo_image"
            onChange={(e) => handleFileChange(e, "logo_image")}
            className="hidden"
            accept="image/*"
          />
        </div>
        <div>
          <label className="block ...">Cover/Banner</label>
          <label htmlFor="cover_image" className="flex ...">
            {data.cover_image ? (
              <img
                src={data.cover_image}
                alt="Cover Preview"
                className="h-full w-full object-cover rounded-lg"
              />
            ) : (
              <p>Upload photo</p>
            )}
          </label>
          <input
            type="file"
            id="cover_image"
            onChange={(e) => handleFileChange(e, "cover_image")}
            className="hidden"
            accept="image/*"
          />
        </div>
      </div>

      {/* Description & Contact Details... (apply the same pattern as above) */}
      <div className="w-full mt-10">
        <label htmlFor="about" className="...">
          Description
        </label>
        <div className="relative">
          <textarea
            name="about"
            id="about"
            rows={4}
            value={data.about}
            onChange={handleInputChange}
            onFocus={() => setActiveField("about")}
            onBlur={() => handleAutosave({ about: data.about })}
            readOnly={activeField !== "about"}
            className="block w-full ... read-only:bg-gray-100 read-only:cursor-default"
          />
          <div className="absolute ...">
            <EditIcon />
          </div>
        </div>
      </div>

      <OpeningHours
        schedule={data.schedule}
        specialDays={data.special_days}
        onScheduleChange={handleScheduleChange}
        onSpecialDayAdd={handleSpecialDayAdd}
        onSpecialDayDelete={handleSpecialDayDelete}
      />
    </div>
  );
};

export default SettingProfile;

// src/components/user/ProfilePage.tsx
"use client";

import React, { useState, useEffect } from "react";
import { Input } from "@/components/ui/input";
import { Button } from "@/components/ui/button";
import { useSession } from "next-auth/react";
import { useForm } from "react-hook-form";
import { changePassword, updateProfile, getUserProfile } from "@/lib/profile";
import Image from "next/image";
import { UserIcon, LockClosedIcon } from "@heroicons/react/24/outline";

// Import the new AvatarSelector component
import AvatarSelector from "@/components/user/ImageSelctor";

export const dynamic = "force-dynamic";

interface ProfileForm {
  first_name: string;
  last_name: string;
}

interface PasswordForm {
  currentPassword: string;
  newPassword: string;
}

interface UserProfile {
  id: string;
  username: string;
  email: string;
  first_name: string;
  last_name: string;
  profile_image?: string;
  updated_at: string;
}

// Define the Avatar type for the mock data
type Avatar = {
  id: number;
  url: string;
  gender: "male" | "female";
};

// Mock data for avatars (replace with a real API call)
const mockAvatars: Avatar[] = Array.from({ length: 50 }, (_, i) => ({
  id: i,
  url: `https://avatar.iran.liara.run/public/${i}`,
  gender: i % 2 === 0 ? "male" : "female",
}));

const ProfilePage = () => {
  const [editMode, setEditMode] = useState(false);
  const [loadingProfile, setLoadingProfile] = useState(false);
  const [loadingPassword, setLoadingPassword] = useState(false);
  const [profile, setProfile] = useState<UserProfile | null>(null);
  const [successMessage, setSuccessMessage] = useState("");

  const [showAvatarSelector, setShowAvatarSelector] = useState(false);
  const [isUpdatingAvatar, setIsUpdatingAvatar] = useState(false);

  const { data: session } = useSession();
  const token = session?.accessToken || "";

  const {
    register: registerProfile,
    handleSubmit: handleSubmitProfile,
    reset: resetProfile,
    setValue: setProfileValue,
  } = useForm<ProfileForm>();

  const {
    register: registerPassword,
    handleSubmit: handleSubmitPassword,
    reset: resetPassword,
    formState: { errors: passwordErrors },
  } = useForm<PasswordForm>();

  useEffect(() => {
    const fetchProfile = async () => {
      if (!token) return;
      try {
        const response = await getUserProfile(token);
        setProfile(response.data);
      } catch (error) {
        console.error("Failed to fetch profile:", error);
      }
    };
    fetchProfile();
  }, [token]);

  const onProfileSubmit = async (data: ProfileForm) => {
    try {
      setLoadingProfile(true);
      
      const response = await updateProfile(token, {
        first_name: data.first_name,
        last_name: data.last_name,
      });

      setSuccessMessage(response.message);

      const updated = await getUserProfile(token);
      setProfile(updated.data);
      resetProfile({
        first_name: updated.data.first_name,
        last_name: updated.data.last_name,
      });
      setEditMode(false);
    } catch (error) {
      setSuccessMessage((error as Error).message);
    } finally {
      setLoadingProfile(false);
    }
  };

  const onPasswordSubmit = async (data: PasswordForm) => {
    try {
      setLoadingPassword(true);
      const response = await changePassword(
        token,
        data.currentPassword,
        data.newPassword
      );
      setSuccessMessage(response.message);
      resetPassword();
    } catch (error) {
      setSuccessMessage((error as Error).message);
    } finally {
      setLoadingPassword(false);
    }
  };

  // New function to handle avatar selection and update
  const handleAvatarSelect = async (url: string) => {
    if (!token) {
      setSuccessMessage("Authentication token missing.");
      setShowAvatarSelector(false);
      return;
    }

    try {
      setIsUpdatingAvatar(true);
      setSuccessMessage("Updating avatar...");

      // Fetch the image from the URL as a Blob
      const imageResponse = await fetch(url);
      const imageBlob = await imageResponse.blob();

      // Create a File object from the Blob
      const file = new File([imageBlob], "avatar.png", {
        type: imageBlob.type,
      });

      // Call the updateProfile API function with the new File
      const apiResponse = await updateProfile(token, { avatar: file });

      setSuccessMessage(apiResponse.message);
      setProfile(apiResponse.data);
    } catch (error) {
      setSuccessMessage("Failed to update avatar. Please try again.");
      console.error("Error updating avatar:", error);
    } finally {
      setIsUpdatingAvatar(false);
      setShowAvatarSelector(false); // Close the dialog
    }
  };

  return (
    <div className="min-h-screen bg-gray-50">
      <div className="w-full h-32 bg-gradient-to-r from-orange-400 to-yellow-300 flex items-center justify-center rounded-b-xl">
        <h1 className="text-white text-3xl font-bold">Your Profile</h1>
      </div>

      <main className="mx-auto p-6 w-full max-w-3xl space-y-6">
        <div className="bg-white rounded-xl shadow-md p-6 space-y-6">
          <div className="flex flex-col items-center">
            <div className="relative group">
              {profile?.profile_image ? (
                <Image
                  src={profile.profile_image}
                  width={96}
                  height={96}
                  alt="User avatar"
                  className="w-24 h-24 rounded-full object-cover ring-4 ring-orange-300 hover:scale-105 transition-transform"
                />
              ) : (
                <div className="w-24 h-24 rounded-full bg-gray-200 flex items-center justify-center text-gray-500 text-xl ring-2 ring-gray-300">
                  👤
                </div>
              )}
              {editMode && (
                <Button
                  className="absolute bottom-0 right-0 p-2 rounded-full bg-orange-500 hover:bg-orange-600 transition-colors"
                  onClick={() => setShowAvatarSelector(true)}
                  aria-label="Change avatar"
                >
                  <UserIcon className="w-4 h-4 text-white" />
                </Button>
              )}
            </div>

            <h2 className="mt-4 text-lg font-semibold">
              {profile ? `${profile.first_name} ${profile.last_name}` : "Name"}
            </h2>
            <p className="text-sm text-gray-500">
              {profile ? `Email: ${profile.email}` : "Email not available"}
            </p>

            <Button
              className="mt-3 hover:bg-orange-600 transition-colors"
              onClick={() => setEditMode(!editMode)}
            >
              {editMode ? "Cancel" : "Edit Profile"}
            </Button>
          </div>

          <div className="mt-4 w-full bg-gray-200 rounded-full h-3">
            <div className="bg-orange-400 h-3 rounded-full w-[80%]"></div>
          </div>
          <p className="text-sm text-gray-500 text-center">
            Profile 80% complete
          </p>

          {successMessage && (
            <p className="text-green-600 text-sm font-medium text-center">
              {successMessage}
            </p>
          )}

          {editMode && (
            <div className="mt-6 space-y-8">
              <form
                onSubmit={handleSubmitProfile(onProfileSubmit)}
                className="space-y-4"
              >
                <h3 className="text-lg font-semibold flex items-center gap-2">
                  <UserIcon className="w-5 h-5 text-orange-500" />
                  Update Profile
                </h3>
                
                {/* File input is removed here as we are using the AvatarSelector */}

                <div>
                  <label className="block text-sm font-medium">
                    First Name
                  </label>
                  <Input
                    type="text"
                    defaultValue={profile?.first_name}
                    {...registerProfile("first_name")}
                    className="focus:ring-2 focus:ring-orange-400"
                  />
                </div>

                <div>
                  <label className="block text-sm font-medium">
                    Last Name
                  </label>
                  <Input
                    type="text"
                    defaultValue={profile?.last_name}
                    {...registerProfile("last_name")}
                    className="focus:ring-2 focus:ring-orange-400"
                  />
                </div>

                <Button type="submit" disabled={loadingProfile}>
                  {loadingProfile ? "Saving..." : "Save Profile"}
                </Button>
              </form>

              <hr className="my-6 border-gray-300" />

              <form
                onSubmit={handleSubmitPassword(onPasswordSubmit)}
                className="space-y-4"
              >
                <h3 className="text-lg font-semibold flex items-center gap-2">
                  <LockClosedIcon className="w-5 h-5 text-orange-500" />
                  Change Password
                </h3>

                <div>
                  <label className="block text-sm font-medium">
                    Current Password
                  </label>
                  <Input
                    type="password"
                    {...registerPassword("currentPassword", {
                      required: "Current password is required",
                    })}
                    className="focus:ring-2 focus:ring-orange-400"
                  />
                  {passwordErrors.currentPassword && (
                    <p className="text-sm text-red-500">
                      {passwordErrors.currentPassword.message}
                    </p>
                  )}
                </div>

                <div>
                  <label className="block text-sm font-medium">
                    New Password
                  </label>
                  <Input
                    type="password"
                    {...registerPassword("newPassword", {
                      required: "New password is required",
                      minLength: {
                        value: 6,
                        message: "Must be at least 6 characters",
                      },
                    })}
                    className="focus:ring-2 focus:ring-orange-400"
                  />
                  {passwordErrors.newPassword && (
                    <p className="text-sm text-red-500">
                      {passwordErrors.newPassword.message}
                    </p>
                  )}
                </div>

                <Button type="submit" disabled={loadingPassword}>
                  {loadingPassword ? "Changing..." : "Change Password"}
                </Button>
              </form>
            </div>
          )}
        </div>
      </main>
      
      {/* Conditionally render the AvatarSelector component */}
      {showAvatarSelector && (
        <AvatarSelector
          avatars={mockAvatars}
          open={showAvatarSelector}
          onOpenChange={setShowAvatarSelector}
          onSelect={handleAvatarSelect}
        />
      )}
    </div>
  );
};

export default ProfilePage;
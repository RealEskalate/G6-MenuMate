"use client"

import React, { useState } from "react"
import { Input } from "@/components/ui/input"
import { Button } from "@/components/ui/button"
import { useSession } from "next-auth/react"
import { useForm } from "react-hook-form"
import { changePassword, updateProfile } from "@/lib/profile"

export const dynamic = "force-dynamic"

interface ProfileForm {
  first_name: string
  last_name: string
  bio?: string
  avatar?: FileList
}

interface PasswordForm {
  currentPassword: string
  newPassword: string
}

const ProfilePage = () => {
  const [editMode, setEditMode] = useState(false)
  const [loadingProfile, setLoadingProfile] = useState(false)
  const [loadingPassword, setLoadingPassword] = useState(false)

  const { data: session, status } = useSession()

  const {
    register: registerProfile,
    handleSubmit: handleSubmitProfile,
    reset: resetProfile,
  } = useForm<ProfileForm>()

  const {
    register: registerPassword,
    handleSubmit: handleSubmitPassword,
    reset: resetPassword,
    formState: { errors: passwordErrors },
  } = useForm<PasswordForm>()

  // if (status === "loading") return <p>Loading...</p>
  // if (status === "unauthenticated") return <p>Please log in to view your profile.</p>

  const token = session?.accessToken || ""

  // ✅ Handle profile update
  const onProfileSubmit = async (data: ProfileForm) => {
    try {
      setLoadingProfile(true)

      const avatarFile = data.avatar?.[0] ?? null

      const response = await updateProfile(token, {
        first_name: data.first_name,
        last_name: data.last_name,
        bio: data.bio,
        avatar: avatarFile,
      })

      alert(response.message)
      resetProfile()
      setEditMode(false)
    } catch (error) {
      alert((error as Error).message)
    } finally {
      setLoadingProfile(false)
    }
  }

  // ✅ Handle password change
  const onPasswordSubmit = async (data: PasswordForm) => {
    try {
      setLoadingPassword(true)
      const response = await changePassword(token, data.currentPassword, data.newPassword)
      alert(response.message)
      resetPassword()
    } catch (error) {
      alert((error as Error).message)
    } finally {
      setLoadingPassword(false)
    }
  }

  return (
    <div className="max-w-3xl mx-auto p-6 space-y-6">
      <h1 className="text-2xl font-semibold">Profile</h1>

      {/* Profile Card */}
      <div className="border rounded-lg p-6 shadow-sm space-y-6">
        <div className="flex flex-col items-center">
          {session?.user?.image ? (

          ):(
          <div className="w-24 h-24 rounded-full bg-gray-200 flex items-center justify-center text-gray-500">
            User
          </div>
          )}
          <h2 className="mt-4 text-lg font-semibold">Abebe Kebede</h2>
          <p className="text-sm text-gray-500">Member since January 2024</p>

          {/* Toggle Edit Mode */}
          <Button className="mt-3" onClick={() => setEditMode(!editMode)}>
            {editMode ? "Cancel" : "Edit Profile"}
          </Button>
        </div>

        {/* ✅ Edit Mode */}
        {editMode && (
          <div className="mt-6 space-y-8">
            {/* Profile Update Form */}
            <form onSubmit={handleSubmitProfile(onProfileSubmit)} className="space-y-4">
              <h3 className="text-lg font-semibold">Update Profile</h3>

              <div>
                <label className="block text-sm font-medium">First Name</label>
                <Input type="text" {...registerProfile("first_name")} />
              </div>

              <div>
                <label className="block text-sm font-medium">Last Name</label>
                <Input type="text" {...registerProfile("last_name")} />
              </div>



              <div>
                <label className="block text-sm font-medium">Avatar</label>
                <Input type="file" accept="image/*" {...registerProfile("avatar")} />
              </div>

              <Button type="submit" disabled={loadingProfile}>
                {loadingProfile ? "Saving..." : "Save Profile"}
              </Button>
            </form>

            {/* Change Password Form */}
            <form onSubmit={handleSubmitPassword(onPasswordSubmit)} className="space-y-4">
              <h3 className="text-lg font-semibold">Change Password</h3>

              <div>
                <label className="block text-sm font-medium">Current Password</label>
                <Input
                  type="password"
                  {...registerPassword("currentPassword", { required: "Current password is required" })}
                />
                {passwordErrors.currentPassword && (
                  <p className="text-sm text-red-500">{passwordErrors.currentPassword.message}</p>
                )}
              </div>

              <div>
                <label className="block text-sm font-medium">New Password</label>
                <Input
                  type="password"
                  {...registerPassword("newPassword", {
                    required: "New password is required",
                    minLength: { value: 6, message: "Must be at least 6 characters" },
                  })}
                />
                {passwordErrors.newPassword && (
                  <p className="text-sm text-red-500">{passwordErrors.newPassword.message}</p>
                )}
              </div>

              <Button type="submit" disabled={loadingPassword}>
                {loadingPassword ? "Changing..." : "Change Password"}
              </Button>
            </form>
          </div>
        )}
      </div>
    </div>
  )
}

export default ProfilePage

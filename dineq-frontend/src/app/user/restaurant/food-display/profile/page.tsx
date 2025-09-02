"use client"
import React, { useState } from "react"
import { Input } from "@/components/ui/input"
import { Button } from "@/components/ui/button"
import { updateProfile, changePassword } from "@/lib/api/userApi"

const ProfilePage = () => {
  const [firstName, setFirstName] = useState("Abebe")
  const [lastName, setLastName] = useState("Kebede")
  const [avatar, setAvatar] = useState<File | null>(null)
  const [loading, setLoading] = useState(false)

  // ⚠️ Replace this with real token from auth/session
  const token = "your-jwt-token"

  const handleUpdateProfile = async () => {
    try {
      setLoading(true)
      const response = await updateProfile(token, {
        first_name: firstName,
        last_name: lastName,
        avatar,
      })
      alert(response.message)
    } catch (error: any) {
      alert(error.message)
    } finally {
      setLoading(false)
    }
  }

  const handleChangePassword = async () => {
    try {
      setLoading(true)
      const response = await changePassword(
        token,
        "currentPassword123",
        "newSecurePassword456"
      )
      alert(response.message)
    } catch (error: any) {
      alert(error.message)
    } finally {
      setLoading(false)
    }
  }

  return (
    <div className="max-w-2xl mx-auto space-y-6 p-6">
      <h1 className="text-2xl font-semibold">Profile</h1>

      {/* Update Profile Form */}
      <div className="space-y-4 border rounded-lg p-6 shadow-sm">
        <Input
          label="First Name"
          value={firstName}
          onChange={(e) => setFirstName(e.target.value)}
        />
        <Input
          label="Last Name"
          value={lastName}
          onChange={(e) => setLastName(e.target.value)}
        />
        <input
          type="file"
          accept="image/png, image/jpeg, image/gif"
          onChange={(e) => setAvatar(e.target.files?.[0] || null)}
        />

        <Button onClick={handleUpdateProfile} disabled={loading}>
          {loading ? "Updating..." : "Update Profile"}
        </Button>
      </div>

      {/* Change Password */}
      <div className="space-y-4 border rounded-lg p-6 shadow-sm">
        <h2 className="text-lg font-semibold">Change Password</h2>
        <Button
          variant="destructive"
          onClick={handleChangePassword}
          disabled={loading}
        >
          {loading ? "Changing..." : "Change Password"}
        </Button>
      </div>
    </div>
  )
}

export default ProfilePage

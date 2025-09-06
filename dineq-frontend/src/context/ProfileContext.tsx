"use client"

import React, { createContext, useContext, useEffect, useState, ReactNode } from "react"
import { getUserProfile, UserProfile } from "@/lib/profile"
import { useSession } from "next-auth/react"

interface ProfileContextType {
  profile: UserProfile | null
  loading: boolean
  refreshProfile: () => Promise<void>
}

const ProfileContext = createContext<ProfileContextType | undefined>(undefined)

export const ProfileProvider = ({ children }: { children: ReactNode }) => {
  const { data: session } = useSession()
  const [profile, setProfile] = useState<UserProfile | null>(null)
  const [loading, setLoading] = useState(false)

  const token = session?.accessToken || ""

  const fetchProfile = async () => {
    if (!token) return
    try {
      setLoading(true)
      const res = await getUserProfile(token)
      setProfile(res.data)
    } catch (error) {
      console.error("Failed to load profile:", error)
    } finally {
      setLoading(false)
    }
  }

  useEffect(() => {
    fetchProfile()
  }, [token])

  return (
    <ProfileContext.Provider
      value={{
        profile,
        loading,
        refreshProfile: fetchProfile,
      }}
    >
      {children}
    </ProfileContext.Provider>
  )
}

export const useProfile = () => {
  const context = useContext(ProfileContext)
  if (!context) throw new Error("useProfile must be used within ProfileProvider")
  return context
}

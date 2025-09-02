// src/lib/api/userApi.ts
export interface UpdateProfileResponse {
  message: string
  data: {
    id: string
    username: string
    email: string
    first_name: string
    last_name: string
    profile_image?: string
    updated_at: string
  }
}

const BASE_URL = "https://g6-menumate.onrender.com/v1/users"

export async function updateProfile(
  token: string,
  payload: {
    first_name?: string
    last_name?: string
    bio?: string
    avatar?: File | null
  }
): Promise<UpdateProfileResponse> {
  const formData = new FormData()

  if (payload.first_name) formData.append("first_name", payload.first_name)
  if (payload.last_name) formData.append("last_name", payload.last_name)
  if (payload.bio) formData.append("bio", payload.bio)
  if (payload.avatar) formData.append("avatar", payload.avatar)

  const res = await fetch(`${BASE_URL}/update-profile`, {
    method: "PATCH",
    headers: {
      Authorization: `Bearer ${token}`,
    },
    body: formData,
  })

  if (!res.ok) {
    throw new Error(`Failed to update profile: ${res.statusText}`)
  }

  return res.json()
}

export async function changePassword(
  token: string,
  old_password: string,
  new_password: string
): Promise<{ message: string }> {
  const res = await fetch(`${BASE_URL}/change-password`, {
    method: "PATCH",
    headers: {
      "Content-Type": "application/json",
      Authorization: `Bearer ${token}`,
    },
    body: JSON.stringify({
      old_password,
      new_password,
    }),
  })

  if (!res.ok) {
    throw new Error(`Failed to change password: ${res.statusText}`)
  }

  return res.json()
}

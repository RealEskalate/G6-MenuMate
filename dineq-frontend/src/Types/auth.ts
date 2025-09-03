export interface RegisterPayload {
  username: string;
  email: string;
  password: string;
  first_name: string;
  last_name: string;
  auth_provider: string;
  role:string;
}
export interface Tokens {
  access_token: string;
  refresh_token: string;
}

export interface User {
  id: string;
  username: string;
  email: string;
  first_name: string;
  last_name: string;
  role: string;
  status: string;
  auth_provider: string;
  is_verified: boolean;
  created_at: string;
  updated_at: string;
}

export interface RegisterResponse {
  message: string;
  tokens: Tokens;
  user: User;
}

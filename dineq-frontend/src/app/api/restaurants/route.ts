import { NextResponse } from 'next/server'

const API_BASE = 'https://g6-menumate.onrender.com/v1'

export async function GET(request: Request) {
  const { searchParams } = new URL(request.url)
  const page = searchParams.get('page') || '1'
  const pageSize = searchParams.get('pageSize') || '20'

  try {
    const res = await fetch(`${API_BASE}/restaurants?page=${page}&pageSize=${pageSize}`, {
      method: 'GET',
      headers: { 'Content-Type': 'application/json' },
      // Revalidate on the server to avoid caching issues
      cache: 'no-store'
    })

    if (!res.ok) {
      return NextResponse.json({ error: 'Upstream error' }, { status: res.status })
    }

    const data = await res.json()
    return NextResponse.json(data)
  } catch (err) {
    console.error('❌ Fetch error:', err)
    return NextResponse.json({ error: 'Network error' }, { status: 500 })
  }
}





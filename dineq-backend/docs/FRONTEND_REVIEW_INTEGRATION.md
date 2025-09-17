## Review & Rating Frontend Integration Guide

This document explains how a frontend (or frontend AI agent) should integrate with the backend review and rating system. It covers the image upload flow, creating reviews with multiple images, listing reviews, request/response examples, error handling, and suggested backend contract details.

> Assumptions:
- Base URL placeholder: `{{base_url}}` (replace with the real backend base URL in runtime)
- All requests that require authentication must include the proper auth token/cookies as your application uses (JWT cookie or Authorization header depending on your flow).

---

## 1) Image upload flow (required step for images)

Use the dedicated image upload endpoint to upload images first. The frontend must upload each image file and receive the hosted image URL from the backend/cloudinary. Then include those returned URLs in the review create payload.

- Endpoint: `POST {{base_url}}/uploads/image`
- Form data key: `image` (single file per request)

Example response (success):

{
  "data": {
    "bytes": 171911,
    "content_type": "image/jpeg",
    "folder": "general",
    "public_id": "dineQ/general/qoy1eagm57jryclglehb",
    "url": "https://res.cloudinary.com/dmahwet/image/upload/v1758121933/dineQ/general/qoy1eagm57jryclglehb.jpg"
  },
  "success": true
}

Important notes for the uploader:
- Upload each image file individually to the endpoint.
- Collect the returned `data.url` for each successful upload.
- Retry network errors (with exponential backoff) and show helpful UI to users.

Example JS upload snippet (high level):

```javascript
// file: File object from input
async function uploadImage(file) {
  const form = new FormData();
  form.append('image', file);

  const resp = await fetch(`${BASE_URL}/uploads/image`, {
    method: 'POST',
    // Include credentials or headers if required by the backend
    body: form,
  });

  const json = await resp.json();
  if (!resp.ok || !json.success) throw new Error('Upload failed');
  return json.data.url; // <-- use this URL in the review payload
}
```

When uploading multiple images, you can upload them in parallel, but limit concurrency (e.g., 3 at a time) to avoid client or server overload.

---

## 2) Create a review (with multiple images)

After uploading images and collecting their hosted URLs, send the review creation request including the images as an array of strings. The backend currently accepts a single `picture` string; the frontend should send `pictures` (array) to support multiple images. For backward compatibility, the backend should also accept `picture` (single string) and convert it to an array.

- Endpoint: `POST {{base_url}}/restaurants/id/{{restaurant_id}}/items/{{item_id}}/reviews`
- Payload (recommended):

```json
{
  "pictures": [
    "https://res.cloudinary.com/.../img1.jpg",
    "https://res.cloudinary.com/.../img2.jpg"
  ],
  "description": "Great taste",
  "rating": 4.5
}
```

Notes:
- `pictures` is an array of strings (URL list). If the UI only has one image, still send an array with one string.
- `description` is optional (depending on backend validation) but recommended.
- `rating` should follow the backend's allowed range (commonly 0.5–5.0 or 1–5). Validate client-side and show helpful messages.

Example `fetch` request (includes JSON body):

```javascript
const payload = {
  pictures: uploadedUrls, // array of image URLs returned by the upload endpoint
  description: 'Delicious and fresh',
  rating: 4.5
};

const resp = await fetch(`${BASE_URL}/restaurants/id/${restaurantId}/items/${itemId}/reviews`, {
  method: 'POST',
  headers: {
    'Content-Type': 'application/json',
    // include Authorization header if required: 'Authorization': `Bearer ${token}`
  },
  body: JSON.stringify(payload),
});

const json = await resp.json();
if (!resp.ok) {
  // handle error, show server message (json.message) to user
}
// json.review contains created review (see response spec below)
```

### Backend compatibility suggestion
To avoid breaking clients, the backend should accept both forms:
- legacy: `picture` (string)
- preferred: `pictures` (array of strings)

Suggested server behavior:
- If request has `picture` string and no `pictures` array, coerce to `pictures = [picture]`.
- Validate each URL to be a well-formed URL (or minimal sanity checks).

---

## 3) Example successful response after review creation

The backend response should include the review data including the pictures array. If your current backend does not return images, ask backend engineers to add a `pictures` array to the review payload/response.

Example success response (actual current backend behavior):

```json
{
  "message": "Review created successfully",
  "review": {
    "id": "68caeef60167347f87f09e78",
    "item_id": "68bc665b96cd148fbc3d246b",
    "restaurant_id": "68bfd782cc5243154c96ee86",
    "user_id": "68bcdbec96cd148fbc3d2478",
    "image_urls": [
      "https://example.com/img.jpg",
      "https://example.com/img.jpg",
      "https://example.com/img.jpg"
    ],
    "description": "Great taste",
    "rating": 4.5,
    "created_at": "2025-09-17T17:25:10.94Z",
    "updated_at": "2025-09-17T17:25:10.94Z",
    "like_count": 0,
    "dislike_count": 0,
    "reaction_ids": null,
    "user": {
      "id": "68bcdbec96cd148fbc3d2478",
      "username": "johndoe17",
      "email": "john.doe17@example.com",
      "first_name": "John",
      "last_name": "Doe Updated",
      "role": "OWNER",
      "status": "ACTIVE",
      "auth_provider": "EMAIL",
      "profile_image": "https://avatar.iran.liara.run/public/9",
      "is_verified": false,
      "created_at": "0001-01-01T00:00:00Z",
      "updated_at": "2025-09-07T01:36:07.067Z"
    },
    "username": "johndoe17",
    "profile_image": "https://avatar.iran.liara.run/public/9"
  }
}
```

And here is an example response for listing reviews by item (current backend shape):

```json
{
  "limit": 10,
  "page": 1,
  "reviews": [
    {
      "id": "68cad042f53b68817cd3102c",
      "item_id": "68bc665b96cd148fbc3d246b",
      "restaurant_id": "68bfd782cc5243154c96ee86",
      "user_id": "68bcdbec96cd148fbc3d2478",
      "description": "Great taste",
      "rating": 4.5,
      "created_at": "2025-09-17T15:14:10.399Z",
      "updated_at": "2025-09-17T15:14:10.399Z",
      "like_count": 0,
      "dislike_count": 0,
      "reaction_ids": null,
      "username": "johndoe17",
      "profile_image": "https://avatar.iran.liara.run/public/9"
    },
    {
      "id": "68cad42e9bcb58f8641608c4",
      "item_id": "68bc665b96cd148fbc3d246b",
      "restaurant_id": "68bfd782cc5243154c96ee86",
      "user_id": "68bcdbec96cd148fbc3d2478",
      "description": "Great taste",
      "rating": 4.5,
      "created_at": "2025-09-17T15:30:54.649Z",
      "updated_at": "2025-09-17T15:30:54.649Z",
      "like_count": 0,
      "dislike_count": 0,
      "reaction_ids": null,
      "username": "johndoe17",
      "profile_image": "https://avatar.iran.liara.run/public/9"
    },
    {
      "id": "68caececc0371ed7e1c4a205",
      "item_id": "68bc665b96cd148fbc3d246b",
      "restaurant_id": "68bfd782cc5243154c96ee86",
      "user_id": "68bcdbec96cd148fbc3d2478",
      "image_urls": [
        "https://example.com/img.jpg"
      ],
      "description": "Great taste",
      "rating": 4.5,
      "created_at": "2025-09-17T17:16:28.219Z",
      "updated_at": "2025-09-17T17:16:28.219Z",
      "like_count": 0,
      "dislike_count": 0,
      "reaction_ids": null,
      "username": "johndoe17",
      "profile_image": "https://avatar.iran.liara.run/public/9"
    },
    {
      "id": "68caed4cc0371ed7e1c4a206",
      "item_id": "68bc665b96cd148fbc3d246b",
      "restaurant_id": "68bfd782cc5243154c96ee86",
      "user_id": "68bcdbec96cd148fbc3d2478",
      "image_urls": [
        "https://example.com/img.jpg",
        "https://example.com/img.jpg",
        "https://example.com/img.jpg"
      ],
      "description": "Great taste",
      "rating": 4.5,
      "created_at": "2025-09-17T17:18:04.439Z",
      "updated_at": "2025-09-17T17:18:04.439Z",
      "like_count": 0,
      "dislike_count": 0,
      "reaction_ids": null,
      "username": "johndoe17",
      "profile_image": "https://avatar.iran.liara.run/public/9"
    },
    {
      "id": "68caeedba130b7ba9a35ecc9",
      "item_id": "68bc665b96cd148fbc3d246b",
      "restaurant_id": "68bfd782cc5243154c96ee86",
      "user_id": "68bcdbec96cd148fbc3d2478",
      "image_urls": [
        "https://example.com/img.jpg",
        "https://example.com/img.jpg",
        "https://example.com/img.jpg"
      ],
      "description": "Great taste",
      "rating": 4.5,
      "created_at": "2025-09-17T17:24:43.249Z",
      "updated_at": "2025-09-17T17:24:43.249Z",
      "like_count": 0,
      "dislike_count": 0,
      "reaction_ids": null,
      "username": "johndoe17",
      "profile_image": "https://avatar.iran.liara.run/public/9"
    },
    {
      "id": "68caeeec974beb9d41b678ff",
      "item_id": "68bc665b96cd148fbc3d246b",
      "restaurant_id": "68bfd782cc5243154c96ee86",
      "user_id": "68bcdbec96cd148fbc3d2478",
      "image_urls": [
        "https://example.com/img.jpg",
        "https://example.com/img.jpg",
        "https://example.com/img.jpg"
      ],
      "description": "Great taste",
      "rating": 4.5,
      "created_at": "2025-09-17T17:25:00.127Z",
      "updated_at": "2025-09-17T17:25:00.127Z",
      "like_count": 0,
      "dislike_count": 0,
      "reaction_ids": null,
      "username": "johndoe17",
      "profile_image": "https://avatar.iran.liara.run/public/9"
    },
    {
      "id": "68caeef60167347f87f09e78",
      "item_id": "68bc665b96cd148fbc3d246b",
      "restaurant_id": "68bfd782cc5243154c96ee86",
      "user_id": "68bcdbec96cd148fbc3d2478",
      "image_urls": [
        "https://example.com/img.jpg",
        "https://example.com/img.jpg",
        "https://example.com/img.jpg"
      ],
      "description": "Great taste",
      "rating": 4.5,
      "created_at": "2025-09-17T17:25:10.94Z",
      "updated_at": "2025-09-17T17:25:10.94Z",
      "like_count": 0,
      "dislike_count": 0,
      "reaction_ids": null,
      "username": "johndoe17",
      "profile_image": "https://avatar.iran.liara.run/public/9"
    }
  ],
  "total": 7
}
```

---

## 4) Listing reviews by item ID (pagination)

- Endpoint: `GET {{base_url}}/items/{{item_id}}/reviews?page=1&limit=10`

Notes for the frontend:
- Use `page` and `limit` query params to paginate.
- Expect a paginated response. Common response shape (example):

```json
{
  "data": [ /* array of review objects (each contains pictures array) */ ],
  "page": 1,
  "limit": 10,
  "total": 123,
  "total_pages": 13
}
```

- Rendering: lazily load pages, show skeleton UI while loading, and support infinite scroll or page navigation using the `page` and `limit` responses.

---

## 5) Error handling & validation (frontend responsibilities)

- Show user-friendly error messages using server response `message` or fallback messages.
- Validate rating client-side (range & type) before sending.
- Validate at least one image OR text if your business requires. If neither is required, allow empty description but validate rating.
- If file upload fails, allow retry and preserve uploaded images state.

Typical server error response (example):

```json
{
  "success": false,
  "message": "Validation error: rating must be between 1 and 5",
  "errors": {
    "rating": "must be a number between 1 and 5"
  }
}
```

---

## 6) Frontend display suggestions

- When showing a review, always expect `pictures` to be an array. Render a gallery or carousel for multiple images.
- Use `alt` text from the user's description or a generic alt description for accessibility.
- Lazy-load images (low-quality placeholder -> full image) to improve perceived performance.

---

## 7) Backend change request checklist (to pass to backend engineers)

1. Accept `pictures` field (array of string URLs) in the Create Review API. Keep supporting legacy `picture` string by coercing it into an array server-side.
2. Persist and return `pictures` array in the review object and list endpoints.
3. Update the review create response to include the `pictures` array (see example above).
4. Validate URLs or the structure minimally (but rely on upload endpoint to produce canonical URLs).
5. Update API docs and Postman / collections with the new request/response shapes.

Suggested JSON schema (create payload):

```json
{
  "type": "object",
  "properties": {
    "pictures": { "type": "array", "items": { "type": "string", "format": "uri" } },
    "picture": { "type": "string", "format": "uri" },
    "description": { "type": "string" },
    "rating": { "type": "number" }
  },
  "required": ["rating"]
}
```

---

## 8) Example end-to-end flow summary (short)

1. User selects N image files and writes a description and rating.
2. Frontend uploads each image to `POST /uploads/image` (form key `image`). Collect returned `data.url` values.
3. Frontend sends `POST /restaurants/id/{rid}/items/{iid}/reviews` with `pictures` array (the uploaded URLs), `description` and `rating`.
4. Backend responds with created review including `pictures` array.

---

## 9) Quick checklist for frontend AI agent

- Upload images first using `/uploads/image` with form key `image`.
- Use the returned `data.url` values to form `pictures: [url1, url2, ...]`.
- Post review payload with `pictures` (array), `description`, and `rating` to `/restaurants/id/{restaurant_id}/items/{item_id}/reviews`.
- Expect `pictures` in the created review and when listing reviews.
- Fallback: if the backend returns `picture` (single string), convert to array when rendering.

---

Files changed/created in this session:
- `docs/FRONTEND_REVIEW_INTEGRATION.md` — Guide for frontend integration (this file).

Completion status:
- Review & rating guide created. Please share if you want me to also update backend code to accept `pictures` (I can open a PR and change request handlers and response mappers).

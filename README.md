# MenuMate - Dinq

A comprehensive digital dining solution comprising a **Flutter mobile app**, a **React + TypeScript frontend**, and a **Go (Golang) backend**. The system digitizes physical menus using OCR technology to create a seamless ordering and payment experience for restaurants and their customers.

![MenuMate System Overview](https://via.placeholder.com/800x400?text=MenuMate+App+Demo+GIF) *<!-- Replace with an architecture diagram or app screenshot -->*

## 🚀 System Overview

This repository is part of the larger MenuMate project. It contains the **Dinq Mobile App**, built with Flutter.

*   **`dinq-mobile/` (This Project):** The cross-platform mobile application for end-users (customers).
*   **Frontend Admin Panel (`/frontend`):** A React-based web dashboard for restaurant management.
*   **Backend API (`/backend`):** A high-performance API server written in Go.

## ✨ Features

### Mobile App (Flutter)
-   **Digital Menu Browser:** Intuitive interface to view categories, items, descriptions, and prices.
-   **OCR Menu Digitization:** Scan a physical menu to instantly digitize it (powered by Google ML Kit / Tesseract).
-   **Smart Cart & Customization:** Add items to cart, specify modifications, and special instructions.
-   **Table QR Integration:** Scan a table QR code to automatically associate your order.
-   **Secure Payment:** Integrated payment processing for a seamless checkout.
-   **Order Tracking:** Real-time updates on order status (Received, Preparing, Ready).

### Admin Panel (React + TypeScript)
-   **Menu Management:** CRUD operations for menu items, categories, and pricing.
-   **Order Dashboard:** View and manage incoming orders in real-time.
-   **Analytics:** View sales reports and customer insights.
-   **Table Management:** Manage restaurant tables and generate QR codes.

### Backend (Go)
-   **High-Performance API:** Efficiently handles concurrent requests.
-   **OCR Service Integration:** Processes images from the mobile app to extract menu text.
-   **Data Persistence:** Interacts with the database (PostgreSQL/MySQL).
-   **Authentication & Authorization:** Secure JWT-based auth for users and restaurants.

## 🛠️ Tech Stack

| Component | Technology |
| :--- | :--- |
| **Mobile App** | Flutter, Dart, Provider/Bloc (State Management) |
| **OCR Processing** | Google ML Kit (Firebase) or Tesseract OCR |
| **Admin Frontend** | React, TypeScript, Vite/CRA, Tailwind CSS |
| **Backend API** | Go (Golang), Gorilla Mux / Gin, JWT |
| **Database** | PostgreSQL |
| **Payment** | Stripe / PayPal SDK |

## 📋 Prerequisites

To run the mobile app, you need:
-   **Flutter SDK** (version specified in `pubspec.yaml`)
-   **Android Studio** / Xcode (for emulators/simulators)
-   An IDE with Flutter support (VS Code / Android Studio)
-   For OCR: A Firebase project (if using ML Kit)

## 🚀 Getting Started (Mobile App)

Follow these steps to run the Flutter mobile application:

1.  **Clone the repository and switch to the branch**
    ```bash
    git clone https://github.com/RealEskalate/G6-MenuMate.git
    cd G6-MenuMate/dinq-mobile/dinq
    git checkout kidus-mite
    ```

2.  **Get Flutter dependencies**
    ```bash
    flutter pub get
    ```

3.  **Configure Environment Variables**
    Create a `.env` file in the root of the `dinq` directory. You can base it on `.env.example`.
    ```
    API_BASE_URL=https://your-go-backend-api.com
    STRIPE_PUBLISHABLE_KEY=pk_test_...
    FIREBASE_API_KEY=your_firebase_config_here
    ```

4.  **Run the application**
    ```bash
    flutter run
    ```
    Ensure you have an emulator running or a physical device connected.

## 🔧 Building for Production

### Android (APK/AAB)
```bash
flutter build apk
# or
flutter build appbundle

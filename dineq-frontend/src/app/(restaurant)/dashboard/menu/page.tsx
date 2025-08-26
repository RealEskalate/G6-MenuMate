import NavBar from "@/components/common/NavBar";
import Sidebar from "@/components/restaurant/SideBar";
import React from "react";

const MenusPage = () => {
  return (
    <div
      style={{
        marginLeft: "200px", // Offset for sidebar
        padding: "20px",
        backgroundColor: "#fff",
        minHeight: "100vh",
      }}
    >
      <NavBar />
      <Sidebar />
      <button
        style={{
          backgroundColor: "#ff7f00",
          color: "#fff",
          border: "none",
          padding: "10px 20px",
          borderRadius: "5px",
          cursor: "pointer",
          marginBottom: "20px",
        }}
      >
        + Add menu
      </button>

      
      <h2 style={{ fontSize: "24px", marginBottom: "20px" }}>Menus</h2>

      {/* Menu Cards Container */}
      <div style={{ display: "flex", gap: "20px" }}>
       
        <div
          style={{
            width: "300px",
            padding: "20px",
            border: "1px solid #eee",
            borderRadius: "10px",
            backgroundColor: "#fff",
            boxShadow: "0 2px 4px rgba(0,0,0,0.1)",
          }}
        >
          <div
            style={{
              display: "flex",
              justifyContent: "space-between",
              alignItems: "center",
              marginBottom: "10px",
            }}
          >
            <h3>Main Menu</h3>
            <span style={{ color: "#f00", cursor: "pointer" }}>🗑️</span>{" "}
            {/* Trash icon */}
          </div>
          <p style={{ fontSize: "12px", color: "#666", marginBottom: "10px" }}>
            Created Jan 5,2025 - Updated Mar 18,2025
          </p>
          <div
            style={{
              display: "flex",
              alignItems: "center",
              gap: "10px",
              marginBottom: "20px",
            }}
          >
            <span
              style={{
                backgroundColor: "#dff0d8",
                color: "#3c763d",
                padding: "5px 10px",
                borderRadius: "20px",
                fontSize: "12px",
              }}
            >
              ✓ Published
            </span>
          </div>
          <div
            style={{
              display: "flex",
              justifyContent: "space-between",
              alignItems: "center",
              marginBottom: "10px",
            }}
          >
            <div>
              <p>Items</p>
              <p style={{ fontWeight: "bold" }}>12 Dishes</p>
            </div>
            <div>
              <p>Language</p>
              <p>Amh, Eng</p>
            </div>
            <span style={{ fontSize: "30px" }}>🔳</span> 
          </div>
          <div
            style={{
              display: "flex",
              justifyContent: "space-between",
              alignItems: "center",
              marginBottom: "20px",
            }}
          >
            <div>
              <p>Avg. rating</p>
              <p style={{ fontWeight: "bold" }}>4.3</p>
            </div>
          </div>
          <div style={{ display: "flex", gap: "10px" }}>
            <button
              style={{
                backgroundColor: "#fff",
                border: "1px solid #ff7f00",
                color: "#ff7f00",
                padding: "10px 20px",
                borderRadius: "5px",
                cursor: "pointer",
                flex: 1,
              }}
            >
              Manage QR
            </button>
            <button
              style={{
                backgroundColor: "#ff7f00",
                color: "#fff",
                border: "none",
                padding: "10px 20px",
                borderRadius: "5px",
                cursor: "pointer",
                flex: 1,
              }}
            >
              Edit Menu
            </button>
          </div>
        </div>

        {/* Fasting Menu Card */}
        <div
          style={{
            width: "300px",
            padding: "20px",
            border: "1px solid #eee",
            borderRadius: "10px",
            backgroundColor: "#fff",
            boxShadow: "0 2px 4px rgba(0,0,0,0.1)",
          }}
        >
          <div
            style={{
              display: "flex",
              justifyContent: "space-between",
              alignItems: "center",
              marginBottom: "10px",
            }}
          >
            <h3>Fasting Menu</h3>
            <span style={{ color: "#f00", cursor: "pointer" }}>🗑️</span>{" "}
            {/* Trash icon */}
          </div>
          <p style={{ fontSize: "12px", color: "#666", marginBottom: "10px" }}>
            Created Jan 5,2025 - Updated Mar 18,2025
          </p>
          <div
            style={{
              display: "flex",
              alignItems: "center",
              gap: "10px",
              marginBottom: "20px",
            }}
          >
            <span
              style={{
                backgroundColor: "#f0f0f0",
                color: "#666",
                padding: "5px 10px",
                borderRadius: "20px",
                fontSize: "12px",
              }}
            >
              ⏳ Pending
            </span>
          </div>
          <div
            style={{
              display: "flex",
              justifyContent: "space-between",
              alignItems: "center",
              marginBottom: "10px",
            }}
          >
            <div>
              <p>Items</p>
              <p style={{ fontWeight: "bold" }}>15 Dishes</p>
            </div>
            <div>
              <p>Language</p>
              <p>Amh, Eng</p>
            </div>
            <span style={{ fontSize: "30px" }}>🔳</span> {/* QR icon */}
          </div>
          <div
            style={{
              display: "flex",
              justifyContent: "space-between",
              alignItems: "center",
              marginBottom: "20px",
            }}
          >
            <div>
              <p>Avg. rating</p>
              <p style={{ fontWeight: "bold" }}>4.7</p>
            </div>
          </div>
          <div style={{ display: "flex", gap: "10px" }}>
            <button
              style={{
                backgroundColor: "#fff",
                border: "1px solid #ff7f00",
                color: "#ff7f00",
                padding: "10px 20px",
                borderRadius: "5px",
                cursor: "pointer",
                flex: 1,
              }}
            >
              Manage QR
            </button>
            <button
              style={{
                backgroundColor: "#ff7f00",
                color: "#fff",
                border: "none",
                padding: "10px 20px",
                borderRadius: "5px",
                cursor: "pointer",
                flex: 1,
              }}
            >
              Edit Menu
            </button>
          </div>
        </div>
      </div>
    </div>
  );
};

export default MenusPage;

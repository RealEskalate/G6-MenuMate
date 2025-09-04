// import React from 'react'
// import Image from 'next/image'
// function SideBar() {
//   return (
//     <>
//       <aside className="w-64 bg-white border border-gray-200 p-4 flex flex-col gap-6 rounded-2xl shadow-[0_4px_12px_#ffa55c] ml-3 mt-6">
//         <div className="space-y-6 pt-6 pb-32 pl-1 pr-5">
//           <button className="flex items-center gap-3 text-orange-600 font-medium">
//             <Image src="/icons/menu.svg" alt="Menus" width={18} height={18} />{" "}
//             Menus
//           </button>
//           <button className="flex items-center gap-3 text-gray-600 hover:text-orange-600">
//             <Image src="/icons/qr.png" alt="QR" width={18} height={18} /> QR
//             Manager
//           </button>
//           <button className="flex items-center gap-3 text-gray-600 hover:text-orange-600">
//             <Image
//               src="/icons/setting.png"
//               alt="Settings"
//               width={18}
//               height={18}
//             />{" "}
//             Settings
//           </button>
//           <button className="flex items-center gap-3 text-gray-600 hover:text-orange-600">
//             <Image
//               src="/icons/Analytics.png"
//               alt="Analytics"
//               width={18}
//               height={18}
//             />{" "}
//             Analytics
//             <span className="ml-1 text-[10px] bg-orange-500 text-white px-1 rounded">
//               PRO
//             </span>
//           </button>
//         </div>
//       </aside>
//     </>
//   );
// }


// export default SideBar;
import React from "react";

const Sidebar = () => {
  return (
    <div
      style={{
        width: "200px",
        height: "100vh",
        backgroundColor: "#fff",
        borderRight: "1px solid #eee",
        padding: "20px",
        position: "fixed",
        left: 0,
        top: 0,
        display: "flex",
        flexDirection: "column",
        gap: "20px",
      }}
    >
      {/* Menus Icon */}
      <div style={{ display: "flex", alignItems: "center", gap: "10px" }}>
        <span style={{ fontSize: "20px" }}>🍴</span>{" "}
        {/* Placeholder for fork/knife icon */}
        <span>Menus</span>
      </div>

      {/* QR Manager Icon */}
      <div style={{ display: "flex", alignItems: "center", gap: "10px" }}>
        <span style={{ fontSize: "20px" }}>🔳</span>{" "}
        {/* Placeholder for QR icon */}
        <span>QR manager</span>
      </div>

      {/* Settings Icon */}
      <div style={{ display: "flex", alignItems: "center", gap: "10px" }}>
        <span style={{ fontSize: "20px" }}>⚙️</span>{" "}
        {/* Placeholder for gear icon */}
        <span>Settings</span>
      </div>

      {/* Analytics Pro Icon */}
      <div style={{ display: "flex", alignItems: "center", gap: "10px" }}>
        <span style={{ fontSize: "20px" }}>📊</span>{" "}
        {/* Placeholder for chart icon */}
        <span>
          Analytics<sup>Pro</sup>
        </span>
      </div>
    </div>
  );
};

export default Sidebar;
// app/register/layout.tsx
import NavBar from "@/components/common/NavBar";
import RegisterSidebar from "@/components/restaurant/RegisterSidebar";
import { RegisterProvider } from "@/context/RegisterContext";

export default function RegisterLayout({ children }: { children: React.ReactNode }) {
  return (
    <RegisterProvider>
      <div className="min-h-screen bg-gray-50 flex flex-col">
        {/* Navbar */}
        <NavBar />

        <main className="flex p-8 gap-8">
          <RegisterSidebar />
          <section className="bg-white p-8 rounded-lg shadow-sm max-w-4xl w-full">
            {children}
          </section>
        </main>
      </div>
    </RegisterProvider>
  );
}

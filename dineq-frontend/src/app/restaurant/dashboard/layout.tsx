import Sidebar from "@/components/restaurant/SideBar";
import Navbar from "@/components/common/NavBar";

export default function DashboardLayout({ children }: { children: React.ReactNode }) {
  return (
    <div className="">
        <Navbar />
      
        <div className="flex gap-8">
          <Sidebar />
          <section className="mt-8 pt-2 bg-white rounded-lg shadow-sm max-w-4xl w-full">
                {children}
          </section>
        </div>
    </div>
  );
}

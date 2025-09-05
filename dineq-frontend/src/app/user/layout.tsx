import Footer from "@/components/common/Footer";
import Navbar from "@/components/common/NavBar";

export default function DashboardLayout({ children }: { children: React.ReactNode }) {
  return (
    <div className="min-h-screen flex flex-col">
        <Navbar role="USER"/>
        
        <div className="flex-grow  w-full md:w-screen  md:px-2 px-4 justify-center  ">
          
                {children}

        </div>
        <Footer/>
    </div>
  );
}
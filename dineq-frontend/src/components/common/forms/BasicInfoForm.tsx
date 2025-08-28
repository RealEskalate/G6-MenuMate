"use client";

import { FaUser, FaEnvelope, FaLock, FaStore, FaMapMarkerAlt } from "react-icons/fa";
import { useRegister } from "@/context/RegisterContext";
import { useRouter } from "next/navigation";

function FormInput({ label, value, onChange, placeholder, icon: Icon, type = "text" }: any) {
  return (
    <div className="max-w-md">
      <label className="block text-sm font-medium text-gray-700 mb-1">{label}</label>
      <div className="relative">
        <input
          type={type}
          value={value}
          onChange={(e) => onChange(e.target.value)}
          placeholder={placeholder}
          className="w-full pl-10 pr-4 py-2 border border-gray-300 rounded-md focus:ring-2 focus:ring-orange-500 focus:border-orange-500 text-sm"
        />
        <Icon className="absolute left-3 top-3 text-gray-400" />
      </div>
    </div>
  );
}

export default function BasicInfoForm() {
  const { data, updateData } = useRegister();
  const router = useRouter();

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    router.push("/register/legal-documents");
  };

  return (
    <form className="space-y-5" onSubmit={handleSubmit}>
      <FormInput
        label="First Name"
        value={data.firstName}
        onChange={(v: string) => updateData({ firstName: v })}
        placeholder="Enter your first name"
        icon={FaUser}
      />
      <FormInput
        label="Last Name"
        value={data.lastName}
        onChange={(v: string) => updateData({ lastName: v })}
        placeholder="Enter your last name"
        icon={FaUser}
      />
      <FormInput
        label="Email Address"
        value={data.email}
        onChange={(v: string) => updateData({ email: v })}
        placeholder="Enter your email"
        icon={FaEnvelope}
        type="email"
      />
      <FormInput
        label="Password"
        value={data.password}
        onChange={(v: string) => updateData({ password: v })}
        placeholder="Create a password"
        icon={FaLock}
        type="password"
      />
      <FormInput
        label="Restaurant Name"
        value={data.restaurant}
        onChange={(v: string) => updateData({ restaurant: v })}
        placeholder="Enter restaurant name"
        icon={FaStore}
      />
      <FormInput
        label="Location"
        value={data.location}
        onChange={(v: string) => updateData({ location: v })}
        placeholder="Enter restaurant location"
        icon={FaMapMarkerAlt}
      />

      {/* Button aligned bottom right */}
      <div className="pt-6 flex justify-end">
        <button
          type="submit"
          className="bg-orange-500 hover:bg-orange-600 text-white px-6 py-2 rounded-md flex items-center space-x-2"
        >
          <span>Save and Continue</span>
          <span>→</span>
        </button>
      </div>
    </form>
  );
}

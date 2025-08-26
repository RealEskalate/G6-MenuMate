import BasicInfoForm from "@/components/restaurant/forms/BasicInfoForm"

export default function BasicInfoPage() {
  return (
    <>
      <div className="flex justify-between items-center mb-6">
        <h2 className="text-xl font-semibold text-gray-900">Basic Information</h2>
        <p className="text-sm text-gray-500">Step 1 of 3</p>
      </div>
      <BasicInfoForm />
    </>
  );
}

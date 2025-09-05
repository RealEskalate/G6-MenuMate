import Image from "next/image";

function AuthImage() {
  return (
    <div className="hidden lg:flex  h-screen relative">
      <Image
        src="/loginfood.png"
        alt="Delicious Ethiopian Food"
        width={700}
        height={1200}
      />
    </div>
  );
}

export default AuthImage;

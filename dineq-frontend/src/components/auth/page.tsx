import Image from "next/image";

function LoginImage() {
  return (
    <div className="hidden md:flex w-1/2 h-screen relative">
      <Image
        src="/loginfood.png"
        alt="Delicious Ethiopian Food"
        width={700}
        height={1200}
       
      />
    </div>
  );
}

export default LoginImage;

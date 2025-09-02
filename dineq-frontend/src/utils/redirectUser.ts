// // utils/redirectUser.ts

// import { useRouter } from "next/navigation";
// import { getSession } from "next-auth/react";

// export const redirectUser = async () => {
//   const router = useRouter();
//   const session = await getSession()
// ;

//   if (session?.user.role === "user") {
//     router.push("/user/restaurant/food-display");
//   } else if (session?.user.role === "OWNER") {
//     router.push("/restaurant/dashboard");
//   } else {
//     router.push("/user/dashboard");
//   }
// };

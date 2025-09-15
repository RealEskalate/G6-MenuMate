export default interface Roles {
  // make role optional because some components may render without an explicit role
  role?: "OWNER" | "MANAGER" | "STAFF" | "CUSTOMER" | "ADMIN";
}

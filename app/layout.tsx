import "./globals.css";
import type { Metadata } from "next";

export const metadata: Metadata = {
  title: "UNIC.ai",
  description: "Operating System for AI Companies"
};

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return <html lang="en"><body>{children}</body></html>;
}

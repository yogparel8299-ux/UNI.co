import type { Metadata } from "next";
import "./globals.css";

export const metadata: Metadata = {
  title: "UNIC.ai",
  description: "Operating System for AI Companies"
};

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="en" className="dark">
      <body>{children}</body>
    </html>
  );
}

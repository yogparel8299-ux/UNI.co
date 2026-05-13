import "./globals.css";

export const metadata = {
  title: "UNIC.ai",
  description: "AI Agent Operating System"
};

export default function RootLayout({
  children
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="en">
      <body>{children}</body>
    </html>
  );
}

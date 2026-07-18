import type { Metadata } from "next";
import "./globals.css";

export const metadata: Metadata = { title: "MatriX | Operations control", description: "Construction and industrial resource management by MatriX." };

export default function RootLayout({ children }: Readonly<{ children: React.ReactNode }>) {
  return <html lang="en"><body>{children}</body></html>;
}

import type { Metadata } from 'next'
import './globals.css'

export const metadata: Metadata = {
  title: 'Para mi terroncito de azúcar 💌',
  description: 'Un regalito especial de Valery para Danilo',
}

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="es">
      <body>{children}</body>
    </html>
  )
}

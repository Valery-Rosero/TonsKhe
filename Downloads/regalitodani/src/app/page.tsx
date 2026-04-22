'use client'
import { useState, useEffect } from 'react'
import LockScreen from '@/components/LockScreen'
import GiftPage from '@/components/GiftPage'

export default function Home() {
  const [unlocked, setUnlocked] = useState(false)

  useEffect(() => {
    const saved = sessionStorage.getItem('danilo_unlocked')
    if (saved === 'yes') setUnlocked(true)
  }, [])

  const handleUnlock = () => {
    sessionStorage.setItem('danilo_unlocked', 'yes')
    setUnlocked(true)
  }

  if (!unlocked) return <LockScreen onUnlock={handleUnlock} />
  return <GiftPage />
}

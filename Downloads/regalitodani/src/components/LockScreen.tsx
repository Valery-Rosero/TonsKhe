'use client'
import { useState } from 'react'
import styles from './LockScreen.module.css'

export default function LockScreen({ onUnlock }: { onUnlock: () => void }) {
  const [password, setPassword] = useState('')
  const [error, setError] = useState(false)
  const [shake, setShake] = useState(false)

  const handleSubmit = () => {
    if (password === process.env.NEXT_PUBLIC_ACCESS_PASSWORD) {
      onUnlock()
    } else {
      setError(true)
      setShake(true)
      setPassword('')
      setTimeout(() => setShake(false), 600)
    }
  }

  return (
    <div className={styles.wrapper}>
      <div className={`${styles.box} ${shake ? styles.shake : ''}`}>
        <span className={styles.icon}>💌</span>
        <h1 className={styles.title}>Para Danilo</h1>
        <p className={styles.sub}>Ingresa la contraseña para abrir tu regalo</p>
        <input
          className={`${styles.input} ${error ? styles.inputError : ''}`}
          type="password"
          placeholder="Contraseña…"
          value={password}
          onChange={e => { setPassword(e.target.value); setError(false) }}
          onKeyDown={e => e.key === 'Enter' && handleSubmit()}
          autoFocus
        />
        {error && <p className={styles.errorMsg}>Esa no es la contraseña 🥺</p>}
        <button className={styles.btn} onClick={handleSubmit}>Abrir mi regalo 🎀</button>
        <p className={styles.hint}>Pídele a Valery si no sabes la clave 😌</p>
      </div>
    </div>
  )
}

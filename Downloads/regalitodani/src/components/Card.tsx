'use client'
import styles from './Card.module.css'

interface CardProps {
  id: string
  icon: string
  title: string
  used: boolean
  isAbre: boolean
  onClick: () => void
}

export default function Card({ icon, title, used, isAbre, onClick }: CardProps) {
  return (
    <div className={`${styles.card} ${used ? styles.used : ''}`} onClick={onClick}>
      {used && (
        <span className={styles.stamp}>
          {isAbre ? '✉️ Abierto' : '✓ Canjeado'}
        </span>
      )}
      <span className={styles.icon}>{icon}</span>
      <p className={styles.title}>{title}</p>
      {!used && <p className={styles.secret}>Toca para abrir 🔒</p>}
    </div>
  )
}

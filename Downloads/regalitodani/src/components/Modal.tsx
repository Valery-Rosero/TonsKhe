'use client'
import styles from './Modal.module.css'
import { Item } from '@/lib/data'

interface ModalProps {
  item: Item | null
  used: boolean
  onClose: () => void
  onUse: () => void
  loading: boolean
}

export default function Modal({ item, used, onClose, onUse, loading }: ModalProps) {
  if (!item) return null
  const isAbre = item.type === 'abre'

  return (
    <div className={styles.bg} onClick={e => e.target === e.currentTarget && onClose()}>
      <div className={styles.modal}>
        <button className={styles.close} onClick={onClose}>✕</button>
        <span className={styles.icon}>{item.icon}</span>
        <span className={styles.badge}>
          {isAbre ? '✉️ Abre cuando…' : '🎟️ Vale por…'}
        </span>
        <p className={styles.title}>{item.title}</p>
        <div className={styles.msg}>
          {isAbre && item.message
            ? `"${item.message}"`
            : item.category}
        </div>
        <div>
          {used ? (
            <span className={styles.usedTag}>
              {isAbre ? '✉️ Ya fue abierto' : '✓ Ya fue canjeado'} 💫
            </span>
          ) : (
            <button className={styles.useBtn} onClick={onUse} disabled={loading}>
              {loading ? 'Guardando…' : isAbre ? 'Marcar como abierto 💌' : 'Canjear este vale 🎟️'}
            </button>
          )}
        </div>
      </div>
    </div>
  )
}

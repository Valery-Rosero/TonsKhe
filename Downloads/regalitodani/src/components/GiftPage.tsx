'use client'
import { useEffect, useState } from 'react'
import { ABRE_CATS, VALE_CATS, ALL_ITEMS, Item } from '@/lib/data'
import Card from '@/components/Card'
import Modal from '@/components/Modal'
import styles from './GiftPage.module.css'

export default function GiftPage() {
  const [usedIds, setUsedIds] = useState<Set<string>>(new Set())
  const [activeTab, setActiveTab] = useState<'abre' | 'vale'>('abre')
  const [selectedItem, setSelectedItem] = useState<Item | null>(null)
  const [loadingUse, setLoadingUse] = useState(false)
  const [loaded, setLoaded] = useState(false)

  useEffect(() => {
    fetch('/api/get-used')
      .then(r => r.json())
      .then(data => {
        setUsedIds(new Set(data.usedIds || []))
        setLoaded(true)
      })
      .catch(() => setLoaded(true))
  }, [])

  const handleUse = async () => {
    if (!selectedItem) return
    setLoadingUse(true)
    try {
      await fetch('/api/use-item', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ itemId: selectedItem.id }),
      })
      setUsedIds(prev => new Set([...prev, selectedItem.id]))
    } finally {
      setLoadingUse(false)
      setSelectedItem(null)
    }
  }

  const total = ALL_ITEMS.length
  const usedCount = usedIds.size
  const allDone = usedCount >= total

  return (
    <div className={styles.app}>
      {/* Hero */}
      <div className={styles.hero}>
        <span className={styles.heroEmoji}>💌</span>
        <h1 className={styles.heroTitle}>Para mi terroncito<br />de azúcar</h1>
        <p className={styles.heroSub}>Con todo mi amor · De Valery para Danilo</p>
      </div>

      {/* Counter */}
      <div className={styles.counter}>
        {loaded ? (
          <>
            <strong>{total - usedCount}</strong> mensajitos pendientes &nbsp;·&nbsp; <strong>{usedCount}</strong> de {total} usados
          </>
        ) : 'Cargando…'}
      </div>

      {/* Tabs */}
      <div className={styles.tabs}>
        <button className={`${styles.tab} ${activeTab === 'abre' ? styles.tabActive : ''}`} onClick={() => setActiveTab('abre')}>
          Abre cuando…
        </button>
        <button className={`${styles.tab} ${activeTab === 'vale' ? styles.tabActive : ''}`} onClick={() => setActiveTab('vale')}>
          Vale por…
        </button>
      </div>

      {/* Abre cuando */}
      {activeTab === 'abre' && (
        <div className={styles.section}>
          <p className={styles.hint}>Abre el sobre que necesites hoy 🌸 El mensaje es solo para tus ojos</p>
          {ABRE_CATS.map(cat => (
            <div key={cat.cat}>
              <p className={styles.catHeader}>{cat.cat}</p>
              <div className={styles.grid}>
                {cat.items.map(item => (
                  <Card
                    key={item.id}
                    id={item.id}
                    icon={item.icon}
                    title={item.title}
                    used={usedIds.has(item.id)}
                    isAbre={true}
                    onClick={() => setSelectedItem(ALL_ITEMS.find(i => i.id === item.id) || null)}
                  />
                ))}
              </div>
            </div>
          ))}
        </div>
      )}

      {/* Vale por */}
      {activeTab === 'vale' && (
        <div className={styles.section}>
          <p className={styles.hint}>Canjea cuando quieras, todos son tuyos 🎟️</p>
          {VALE_CATS.map(cat => (
            <div key={cat.cat}>
              <p className={styles.catHeader}>{cat.cat}</p>
              <div className={styles.grid}>
                {cat.items.map(item => (
                  <Card
                    key={item.id}
                    id={item.id}
                    icon={item.icon}
                    title={item.title}
                    used={usedIds.has(item.id)}
                    isAbre={false}
                    onClick={() => setSelectedItem(ALL_ITEMS.find(i => i.id === item.id) || null)}
                  />
                ))}
              </div>
            </div>
          ))}
        </div>
      )}

      {/* Recarga */}
      {allDone && (
        <div className={styles.reload}>
          <p className={styles.reloadTitle}>¡Se acabaron todos los mensajitos! 🥺</p>
          <p className={styles.reloadSub}>Pídele a Valery que recargue con mensajes nuevitos…</p>
          <button className={styles.reloadBtn} onClick={() => alert('¡Mensaje enviado a Valery! 💌💕')}>
            Pedir más mensajitos 💌
          </button>
        </div>
      )}

      {/* Modal */}
      {selectedItem && (
        <Modal
          item={selectedItem}
          used={usedIds.has(selectedItem.id)}
          onClose={() => setSelectedItem(null)}
          onUse={handleUse}
          loading={loadingUse}
        />
      )}
    </div>
  )
}

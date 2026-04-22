export type ItemType = 'abre' | 'vale'

export interface Item {
  id: string
  type: ItemType
  category: string
  icon: string
  title: string
  message?: string
}

export const ABRE_CATS = [
  {
    cat: '💙 Emociones difíciles',
    items: [
      { id: 'a1', icon: '🌧️', title: 'Abre cuando estés triste', message: 'No estás solo, ¿sí? Yo estoy contigo incluso cuando no estoy ahí.' },
      { id: 'a2', icon: '💢', title: 'Abre cuando estés enojado', message: 'Tómate tu tiempo… aquí voy a estar cuando te sientas mejor.' },
      { id: 'a3', icon: '😨', title: 'Abre cuando tengas miedo', message: 'No tienes que ser fuerte todo el tiempo.' },
      { id: 'a4', icon: '🌊', title: 'Abre cuando sientas que todo está mal', message: 'Esto también va a pasar, confía.' },
      { id: 'a5', icon: '🏳️', title: 'Abre cuando quieras rendirte', message: 'Has llegado muy lejos, no te olvides de eso.' },
    ],
  },
  {
    cat: '🌟 Ánimo y motivación',
    items: [
      { id: 'a6', icon: '🔥', title: 'Abre cuando necesites motivación', message: 'Tú puedes con esto y con mucho más.' },
      { id: 'a7', icon: '🌱', title: 'Abre cuando no creas en ti', message: 'Yo creo en ti por los dos.' },
      { id: 'a8', icon: '⭐', title: 'Abre cuando dudes de ti', message: 'Eres mucho más capaz de lo que imaginas, yo sí lo veo.' },
      { id: 'a9', icon: '🏆', title: 'Abre cuando logres algo', message: 'Estoy orgullosa de ti, siempre.' },
      { id: 'a10', icon: '🌪️', title: 'Abre cuando tengas un mal día', message: 'Respira, todo pasa… y yo sigo aquí para ti.' },
    ],
  },
  {
    cat: '💕 Momentos de amor',
    items: [
      { id: 'a11', icon: '🥺', title: 'Abre cuando me extrañes', message: 'Yo también te estoy pensando… más de lo que crees.' },
      { id: 'a12', icon: '💭', title: 'Abre cuando pienses en mí', message: 'Yo también sonrío cuando pienso en ti.' },
      { id: 'a13', icon: '💖', title: 'Abre cuando quieras sentirte amado', message: 'Te amo más de lo que puedo escribir aquí.' },
      { id: 'a14', icon: '🤗', title: 'Abre cuando necesites un abrazo', message: 'Cierra los ojos e imagina que te estoy abrazando fuerte.' },
      { id: 'a15', icon: '☀️', title: 'Abre cuando estés feliz', message: 'Me encanta saber que estás bien, te lo mereces todo.' },
    ],
  },
  {
    cat: '🌙 Momentos de calma',
    items: [
      { id: 'a16', icon: '🌙', title: 'Abre cuando no puedas dormir', message: 'Ojalá pudiera abrazarte hasta que te duermas.' },
      { id: 'a17', icon: '🛋️', title: 'Abre cuando no tengas ganas de nada', message: 'Descansa, también está bien parar.' },
      { id: 'a18', icon: '😴', title: 'Abre cuando estés aburrido', message: 'Ve a molestarme… es tu derecho 😌' },
      { id: 'a19', icon: '🌌', title: 'Abre cuando te sientas solo', message: 'Aunque no esté físicamente, siempre estoy contigo.' },
      { id: 'a20', icon: '😊', title: 'Abre cuando quieras sonreír', message: 'Acuérdate de todas las veces que hemos sido felices juntos.' },
    ],
  },
]

export const VALE_CATS = [
  {
    cat: '💆‍♂️ Cariño y mimos',
    items: [
      { id: 'v1', icon: '🎟️', title: 'Vale por un masaje relajante' },
      { id: 'v2', icon: '🎟️', title: 'Vale por abrazos ilimitados' },
      { id: 'v3', icon: '🎟️', title: 'Vale por una sesión de mimos' },
      { id: 'v4', icon: '🎟️', title: 'Vale por besitos por toda la carita' },
      { id: 'v5', icon: '🎟️', title: 'Vale por dormir abrazados' },
    ],
  },
  {
    cat: '🍔 Comida',
    items: [
      { id: 'v6', icon: '🎟️', title: 'Vale por una comida hecha por mí' },
      { id: 'v7', icon: '🎟️', title: 'Vale por tu antojo favorito' },
      { id: 'v8', icon: '🎟️', title: 'Vale por un postre especial' },
      { id: 'v9', icon: '🎟️', title: 'Vale por elegir una cena con peli' },
      { id: 'v10', icon: '🎟️', title: 'Vale por desayuno sorpresa' },
    ],
  },
  {
    cat: '🎮 Tiempo juntos',
    items: [
      { id: 'v11', icon: '🎟️', title: 'Vale por una tarde de pelis' },
      { id: 'v12', icon: '🎟️', title: 'Vale por maratón de series' },
      { id: 'v13', icon: '🎟️', title: 'Vale por jugar lo que tú quieras' },
      { id: 'v14', icon: '🎟️', title: 'Vale por salir a donde tú elijas' },
      { id: 'v15', icon: '🎟️', title: 'Vale por una cita especial' },
    ],
  },
  {
    cat: '😏 Divertidos',
    items: [
      { id: 'v16', icon: '🎟️', title: 'Vale por no discutir (una vez 😌)' },
      { id: 'v17', icon: '🎟️', title: 'Vale por tener la razón (solo este vale jajaja)' },
      { id: 'v18', icon: '🎟️', title: 'Vale por molestarme sin consecuencias' },
      { id: 'v19', icon: '🎟️', title: 'Vale por elegir música todo el día' },
      { id: 'v20', icon: '🎟️', title: 'Vale por hacerme preguntas incómodas 😅' },
    ],
  },
  {
    cat: '💕 Especiales',
    items: [
      { id: 'v21', icon: '🎟️', title: 'Vale por un día siendo el consentido' },
      { id: 'v22', icon: '🎟️', title: 'Vale por hablar de lo que quieras' },
      { id: 'v23', icon: '🎟️', title: 'Vale por apoyo incondicional' },
      { id: 'v24', icon: '🎟️', title: 'Vale por escucharte sin interrupciones' },
      { id: 'v25', icon: '🎟️', title: 'Vale por acompañarte en algo importante' },
    ],
  },
]

export const ALL_ITEMS: Item[] = [
  ...ABRE_CATS.flatMap(c => c.items.map(i => ({ ...i, type: 'abre' as ItemType, category: c.cat }))),
  ...VALE_CATS.flatMap(c => c.items.map(i => ({ ...i, type: 'vale' as ItemType, category: c.cat }))),
]

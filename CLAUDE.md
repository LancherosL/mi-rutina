# Repo de Laura: apps personales

**Al arrancar sesión: lee este archivo y pregunta qué app tocamos.** No asumas.

**Antes de trabajar en Nutri o Nova, lee la tabla `contexto_privado` en Supabase**
(con acceso de administrador). Ahí vive todo lo personal: salud, perfil, metas e
historial de decisiones. En este repo (público) no se escribe nada personal: ni en
código, ni en comentarios, ni en SQL, ni en mensajes de commit.

Apps personales de **una sola usuaria**. No son productos. No tienen clientes, ni
onboarding, ni retención, ni adquisición. Cualquier decisión que asuma "los
usuarios" en plural está mal orientada.

Carpeta de trabajo: `/Users/lau/Documents/defile-proyecto` (repo `LancherosL/mi-rutina`,
GitHub Pages). Commits y push sólo cuando Laura lo pida.

## Apps del repo

```
mi_sistema.html         Mi Sistema: hábitos, emociones, sueño, ciclo, consumo, gatos…
nutri.html              Nutri: nutrición (en diseño)
nova.html               Nova: movimiento, Tai Chi en silla
gatos-.html             Mía y Dorito: salud de las gatas
tierra.css              Aspecto compartido de todas las apps
defile-v4-plus.html     Défile (francés)
gatos-.html             Gatos
mi_casa_2_2.html        Mi Casa
casa.html               Nuestra casa: limpieza compartida con el roommate (ES/FR). Tablas casa_*, protegidas con el código de la casa (sql/12_casa.sql)
manual-claude-v2.html   Manual para construir cosas con Claude
sql/                    Migraciones (sólo esquema y datos genéricos)
```

## Aspecto de todas las apps (desde el 18 nov 2026)

Nova, Nutri, Mi Sistema, Casa y Mía y Dorito comparten **`tierra.css`** (en la raíz).
Se enlaza con `<link rel="stylesheet" href="tierra.css?v=1">` y `<script src="tierra.js?v=1">` antes del
`<style>` de cada app; ahí viven colores, letras, radios, sombras, botones, barra de abajo e iconos.

- **Editar, no versionar:** cambios de aspecto van en `tierra.css` o en el CSS de la app. Nada de `tierra-v2.css`.
- **Hecho a mano, sin tarjetas (regla del 18 nov 2026, ajustada):** nada de cajas blancas con borde y sombra. Las secciones son bloques planos en pastel suave, **máximo 2 pasteles por pantalla** y una de cada tres sin fondo (`--p1`, `--p2`; `--p3` y `--p4` repiten). Texto en tinta oscura, sin gris (`--muted` es café oscuro). Pasteles claros: `--p-terra`, `--p-salvia`, `--p-dorado`, `--p-rosa`. Lo que se toca va en `--capa`, los campos son rayas, las listas llevan raya discontinua (`--linea`), grano de papel de fondo. **Cada app tiene su formato:** Nova editorial y orgánica (esquinas desiguales, títulos cursivos con subrayado ondulado); Mi Sistema diario (igual, con dorado y rosa); Nutri fresca y directa (verde neón propio, menta y limón pálidos, tarjeta de Hoy en neón, barra flotante neón, títulos en negrita con punto neón); Casa tablero del hogar (franjas de borde a borde, rectas, títulos en negrita); Mía y Dorito bloques parejos de 30 px con un punto del color de cada gata. Modo noche: café cálido más claro (`--fondo-oscuro #5A4638`) con los mismos pasteles también más claros, nunca negro ni sombrío; Mi Sistema los vuelve a leer en `body.night`.
- **Colores — una paleta por app:** **Nova** terra, **Nutri** verde neón (`#1FD47A`, texto oscuro encima; es su color, no se apaga a salvia), **Mi Sistema** marrón con dorado, **Casa** dorado, **Mía** salvia y **Dorito** terra. Se elige con `<html data-app="…">` (y `data-gato` en Mía y Dorito) y los tokens `--acento`, `--acento-oscuro`, `--acento-claro`, `--acento-suave`, `--acento-texto`, `--sobre-acento` y `--detalle` de `tierra.css`; `--terra` y sus variantes siguen a `--acento`. Salvia = hecho, alerta = solo "hace X días". Sin azul, lavanda ni violeta.
- **Letras:** Cormorant Garamond 600 solo para saludo, nombre de app, títulos grandes y citas; DM Sans para todo lo demás (no Inter). Texto terra pequeño usa `--terra-texto`.
- **Forma y jerarquía:** saludo y nombre de app 44 px (Cormorant), títulos de página 32 px, secciones planas (sin sombra), 24 px de margen lateral, 40 px entre secciones, botones 56 px con radio 16, toques de 44 px mínimo, un solo degradado (tarjeta de Nova).
- **Iconos, cero emojis en pantalla:** `tierra.js` cambia cada emoji o símbolo por un icono de línea (trazos de Lucide, licencia ISC, dentro de `tierra.css`). El carácter original queda dentro, oculto, así que los datos guardados y la lógica no cambian. Iconos a mano: `<i class="t-ico t-ico-nombre"></i>`. Un emoji nuevo necesita su línea `.t-emo[data-e="…"]` en `tierra.css`; si no la tiene, no se ve.
- **Marca de Nutri:** aguacate ilustrado (`aguacate.svg`). Iconos del iPhone: los de Laura, planos de un color por app (`icono-*.png`; Mía y Dorito usa `icono-180/192/512.png`).
- **Sin gamificación:** ni rachas, fuegos, puntos, confeti ni celebraciones.
- **Movimiento:** toque 150 ms, aparición 250 ms, pestañas 200 ms, sin rebote; respeta `prefers-reduced-motion`.
- **Capturas de prueba (Playwright):** solo en `~/Library/Caches/playwright-mcp-output`, nunca dentro del repo (pueden mostrar datos de salud y el repo es público).

## Supabase (compartido)

- Proyecto `snwnqjltfyqlwyeyfjba`, el mismo para todas las apps. REST, sin cliente JS.
- `contexto_privado` (tema, contenido, actualizado): RLS activo y sin políticas.
  Nunca se lee desde las apps.
- Historial de Mi Sistema (decisiones, errores, esquema): `contexto_privado`, tema
  `continuidad_mi_sistema`. Léelo antes de tocar la base de datos, el guardado o algo
  que ya se haya intentado.
- Tablas de Nutri: prefijo `nutri_`, más `comidas_items`, `comidas_digestion`, `banos`.
- Quién escribe qué (desde el 17 nov 2026), para que nadie pise a nadie:
  - **Nutri** registra comidas, "Algo de más", digestión y baño. En `registro_diario`
    escribe sólo `comidas`, `comidas_texto`, `comidas_omitidas`, `comidas_hora`, `extras`.
  - **Mi Sistema** no escribe esos campos ni el sueño; sólo los lee.
  - **Sueño** (`sueno_horas`, `sueno_calidad`, `sueno_detalle`): lo escribe el chat de sueño.
  - **Mi pie** (`recuperacion`: movilidad, ánimo, nota) y el dolor (`nova_sesiones.dolor_pie`): Nova.
- No crear ni modificar tablas sin OK explícito.

## Reglas comunes

- **Editar, no versionar**: se edita el archivo existente. Nada de `_v2`, `_old`,
  `_backup` ni copias.
- Tuteo siempre. Respuestas cortas.

---

# Mi Sistema

Instrumento de observación propia, construido pieza por pieza a lo largo de meses.
Cada función existe porque resolvió algo concreto.

## Stack

- Un solo HTML, sin dependencias, sin build, sin framework
- Supabase como base de datos (REST, sin cliente JS)
- GitHub Pages para publicar
- Se usa desde el celular, casi siempre con una mano

## Reglas técnicas

- **Nunca** fragmentos para pegar a mano: editar el archivo directamente.
- Verificar el JS antes de dar algo por terminado (`node --check` sobre el script
  extraído).
- Columnas nuevas en Supabase: aplicar la migración, no sólo escribir el código
  que las usa.
- El guardado usa un helper que sólo manda campos conocidos. Un campo nuevo tiene
  que conectarse en los cuatro puntos: guardado, sincronización, restauración de
  UI y borrado local. Fallar uno de esos cuatro produce pérdida silenciosa de datos.
- Si aparece un bug de paso, arreglarlo y decirlo.

## Marco teórico

Dos investigadoras sostienen todo lo emocional de la app.

**Lisa Feldman Barrett — emoción construida.** El cerebro no reacciona a
emociones: las construye combinando sensaciones corporales con conceptos
lingüísticos. De ahí:

- *Granularidad*: más palabras disponibles = más precisión = menos reactividad.
- *Etiquetado afectivo*: nombrar con precisión activa la prefrontal y baja la
  amígdala. Nombrar **es** la intervención.
- *Presupuesto corporal*: mucho de lo que se siente como emoción es fisiología —
  sueño, hambre, sed, falta de movimiento. Distinguirlas es media batalla.

**Wendy Suzuki — neuroplasticidad.** Acciones breves y deliberadas cambian la
neuroquímica de inmediato: movimiento de 10-15 min como fármaco biológico,
respiración para convertir activación en enfoque, pausas entre bloques.

La conducta ancla y su pregunta de control están en `contexto_privado`
(tema `personal_laura`).

## Reglas de diseño

No son preferencias estéticas. Son la diferencia entre una app que se usa y una
que se abandona.

1. **Profundizar antes que agregar.** Si se puede resolver dando una capa más a
   algo existente, no se crea una sección nueva.
2. **Una línea, nunca una pantalla.** Las intervenciones son una frase con
   contexto, no un módulo con vista propia.
3. **El registro rápido nunca se bloquea.** Anotar cuesta un tap. Lo reflexivo se
   pregunta *después* de guardar, y siempre es saltable.
4. **Nada obligatorio.** Un día sin llenar no es una falla, es un dato.
5. **Sin gamificación.** Ni rachas, ni puntos, ni logros, ni celebraciones. La
   motivación externa es justo lo que la app intenta desarmar.
6. **Peso visual cero cuando no se usa.** Lo condicional desaparece por completo.
   Nada de espacios vacíos esperando ser llenados.
7. **El vocabulario emocional vive en un solo bloque editable**, comentado, arriba
   del código. Las palabras cambian con el tiempo.
8. **El lenguaje es el de Laura**, no el clínico. Nada de "activación autonómica".
   Sí "¿qué había justo antes?".

## Antes de implementar

Si alguna falla, rediseñar:

- ¿Cuántos taps cuesta? (más de dos: rediseñar)
- ¿Qué pasa si nunca se usa? (tiene que desaparecer sin rastro)
- ¿Qué se va a poder ver en un mes que hoy no se ve?
- La pregunta de la conducta ancla (en `contexto_privado`).

## Cómo responder

- Propuesta breve primero, código después. Nunca un documento de varias páginas
  antes de haber escrito una línea.
- El porqué neurológico en una o dos frases, no en un ensayo.
- Español latino informal, directo.
- Laura ya sabe publicar en GitHub Pages. No explicar el proceso.

## Lo que no se hace

- Módulos nuevos cuando alcanza con una capa más
- Pantallas de bienvenida, tutoriales, tours
- Notificaciones o recordatorios que interrumpan
- Textos motivacionales
- Métricas de cumplimiento en vez de patrón
- Commits sin que Laura lo pida

---

# Nutri

App de nutrición. Mismo stack que Mi Sistema. Perfil, metas y contexto de salud:
`nutri_perfil` y `contexto_privado`.

**Aspecto: Nutri es de la familia Tierra, pero con su propio color** (decisión de Laura, 18 nov 2026):
usa `tierra.css`, DM Sans + Cormorant Garamond y la barra de abajo `.t-nav` (flotante y neón),
y su verde neón (`--acento #1FD47A`, con texto oscuro encima) es su identidad; no se apaga a
salvia. Las secciones van en menta y limón pálidos, la tarjeta de Hoy en neón con anillos en
tinta y blanco. Se fueron Outfit / Plus Jakarta Sans y el confeti. Sin gamificación en ninguna
app. El resto de reglas de Mi Sistema sigue aplicando (nada obligatorio, sin registro no se
juzga, lenguaje de Laura).

## Reparto con Mi Sistema

- **Mi Sistema registra**: cada comida (y "Algo de más") con buscador sobre
  `nutri_alimentos` + porciones caseras + escáner (Open Food Facts) →
  `comidas_items`. El texto libre queda de respaldo y Nutri lo marca "aprox".
  Digestión 👍😐👎 + síntoma → `comidas_digestion`. Tarjeta 🚽 Baño → `banos`.
- **Nutri no registra comidas**: lee lo de Mi Sistema y hace análisis, detonantes,
  plan semanal, despensa, compras y coach.
  Excepción aprobada por Laura (22 oct 2026): los **suplementos** se configuran y se
  marcan como tomados en Nutri (`suplementos`, `suplementos_tomas`); no son comidas y
  no se anotan en otro lado. Suman a los anillos.

## Se queda del original

- Plan desde la despensa o "sorpréndeme"
- Lista de compras
- Escáner de código de barras
- Foto de comida
- Chat IA para pedir cambios
- Macros

## Arreglos obligatorios

- Los totales **siempre** cuadran con el objetivo (se calcula, no se estima).
- Nada de resultados inventados: si no hay dato, no se muestra.
  Excepción aprobada por Laura (22 oct 2026): lo que estima la IA (texto libre o foto,
  `origen` texto/foto) y los platos de restaurante SÍ suman a los anillos, siempre
  marcados con * y la leyenda "estimados por IA". Un dato desconocido sigue siendo null
  (se muestra con ≥), nunca un número inventado.
- Sin registro no se juzga: se pregunta.
- Tuteo siempre.
- La IA tiene **un solo nombre**.
- Plan **semanal**, no de un día.

## Mejoras

1. Registro rápido: foto, voz y "repetir comida".
2. Capa digestiva: detección de detonantes a partir de digestión y baño, cruzados
   con fibra, agua, lácteos, café, ciclo y sueño del día y los 2 anteriores.
3. Lee de Mi Sistema (sueño, energía, ánimo, ciclo, actividad) para no registrar doble.
4. Base de alimentos propia con platos colombianos y porciones reales, valores de
   USDA / Health Canada CNF (fuente en cada fila; null = sin dato).
5. Compras pensadas para supermercados locales (ver `contexto_privado`).
6. Coach amable: **una sola** recomendación semanal.
7. Fibra sube gradual según la digestión; calcio y vitamina D en seguimiento.

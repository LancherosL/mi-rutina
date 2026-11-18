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
- **Página fluida, sin tarjetas (regla del 18 nov 2026):** nada de rectángulos redondeados, bordes, sombras ni una sección dentro de otra caja. Cada app es **una sola página de arriba a abajo**: franjas **a todo lo ancho**, separadas solo por aire y por color de fondo (máximo 2 pasteles por pantalla y una de cada tres franjas sin color: `--banda-a`, `--banda-b`, la fuerte `--banda-x`). Lo que antes era caja se vuelve fila con raya discontinua (`--linea`), palabra con subrayado, campo de raya o acción cuadrada (de borde a borde en Nova y Nutri). Texto en tinta oscura, sin gris (`--muted` es café oscuro).
  - **Cómo se arma:** `tierra.js` → `Tierra.fluir({en, hijos, ritmo, fuerte})` reparte `data-b` a las franjas visibles (lo oculto no cuenta); `Tierra.secciones(id, 'H2')` agrupa en franjas lo que viene suelto (Mía y Dorito). Las apps llevan `<html data-fluido>`; Nova trae su propia versión en su CSS. El borde de cada app son 4 formas de `--onda-sup-a/-inf-a/-sup-b/-inf-b` (arriba y abajo de una unión encajan exacto).
  - **Fondo vivo:** dos capas de manchas que derivan despacio (solo `transform`, `html::before/::after`; `--f1..--f4`, `--f-dur-a/b`, `--d-*`); la cabecera y la franja fuerte llevan manchas propias por dentro. Se detienen con `prefers-reduced-motion`.
  - **Cada app tiene su formato:** Nova, ondas suaves y títulos cursivos con subrayado ondulado ("Nova" es la etiqueta chiquita, el título es "Hola, Laura"); Nutri, bordes en diagonal, títulos en negrita con punto neón, manchas más vivas y barra de abajo neón de borde a borde; Mi Sistema, borde rasgado como hoja de cuaderno, manchas muy lentas, noche en café cálido claro (`body.night` pone `--tinta` crema); Casa, franjas rectas de tablero, manchas que corren en horizontal; Mía y Dorito, bordes de nubecitas, cada tramo empieza en su título.
  - **Pruebas:** que no quede ninguna caja (radio ≠ 0 con fondo, borde o sombra), toques de 44 px, cero emojis, sin scroll horizontal.
- **Colores — una paleta por app:** **Nova** terra, **Nutri** verde neón (`#1FD47A`, texto oscuro encima; es su color, no se apaga a salvia), **Mi Sistema** marrón con dorado, **Casa** dorado, **Mía** salvia y **Dorito** terra. Se elige con `<html data-app="…">` (y `data-gato` en Mía y Dorito) y los tokens `--acento`, `--acento-oscuro`, `--acento-claro`, `--acento-suave`, `--acento-texto`, `--sobre-acento` y `--detalle` de `tierra.css`; `--terra` y sus variantes siguen a `--acento`. Salvia = hecho, alerta = solo "hace X días". Sin azul, lavanda ni violeta.
- **Letras:** Cormorant Garamond 600 solo para saludo, nombre de app, títulos grandes y citas; DM Sans para todo lo demás (no Inter). Texto terra pequeño usa `--terra-texto`.
- **Forma y jerarquía (escala de letras, ajustada el 18 nov 2026 a más compacta):** título principal de página **36 px** (Cormorant en Nova y Mi Sistema; DM Sans en negrita en Casa; Mía y Dorito con su nombre), títulos de sección **22 px**, texto normal **15 px** (campos 16 px, para que el iPhone no haga zoom), número grande del anillo de Nutri **48 px** (el anillo mide 200 px para que quepan 4 cifras), etiquetas chicas 14 px o más. "Nova" es una etiqueta de 18 px y el título es "Hola, Laura". Sin tarjetas ni sombras, 24 px de margen lateral, toques de 44 px mínimo.
- **Iconos, cero emojis en pantalla:** `tierra.js` cambia cada emoji o símbolo por un icono de línea (trazos de Lucide, licencia ISC, dentro de `tierra.css`). El carácter original queda dentro, oculto, así que los datos guardados y la lógica no cambian. Iconos a mano: `<i class="t-ico t-ico-nombre"></i>`. Un emoji nuevo necesita su línea `.t-emo[data-e="…"]` en `tierra.css`; si no la tiene, no se ve.
- **Marca de Nutri:** aguacate ilustrado (`aguacate.svg`). Iconos del iPhone: los de Laura, planos de un color por app (`icono-*.png`; Mía y Dorito usa `icono-180/192/512.png`).
- **Sin gamificación:** ni rachas, fuegos, puntos, confeti ni celebraciones.
- **Movimiento (Paso 3):** toque 150 ms, aparición 250 ms, sin rebote; respeta `prefers-reduced-motion`. `tierra.js` expone `Tierra.entra(el)` (al cambiar de pantalla las secciones suben una tras otra; solo al navegar, nunca al refrescar datos), `Tierra.vivo(fn, ms)` (la app se actualiza sola al volver a ella y cada cierto tiempo, nunca mientras se escribe) `Tierra.version(ocupado)` (si se publica una versión nueva, la app abierta se recarga sola al volver a ella, solo si nada está en uso: sin escribir, sin formulario abierto ni guardado pendiente; máximo una vez por minuto) y hunde un poco lo que se toca y no es botón. Marcar algo como hecho: el círculo se llena y la palomita se traza (`.t-hecho-nuevo`, una sola vez). Los anillos de Nutri se llenan desde cero al entrar a Hoy. Ni confeti, ni rachas, ni celebraciones.
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

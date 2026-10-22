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
defile-v4-plus.html     Défile (francés)
gatos-.html             Gatos
mi_casa_2_2.html        Mi Casa
manual-claude-v2.html   Manual para construir cosas con Claude
sql/                    Migraciones (sólo esquema y datos genéricos)
```

## Supabase (compartido)

- Proyecto `snwnqjltfyqlwyeyfjba`, el mismo para todas las apps. REST, sin cliente JS.
- `contexto_privado` (tema, contenido, actualizado): RLS activo y sin políticas.
  Nunca se lee desde las apps.
- Historial de Mi Sistema (decisiones, errores, esquema): `contexto_privado`, tema
  `continuidad_mi_sistema`. Léelo antes de tocar la base de datos, el guardado o algo
  que ya se haya intentado.
- Tablas de Nutri: prefijo `nutri_`, más `comidas_items`, `comidas_digestion`, `banos`.
  Nutri **lee** las de Mi Sistema; no registra comidas.
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

**Identidad visual propia, distinta de Mi Sistema** (decisión de Laura, 22 oct 2026):
paleta crema / verde fresco / naranja, tipografías Outfit + Plus Jakarta Sans, anillos
animados en Hoy, barra de pestañas flotante abajo, modo oscuro propio (sigue al
teléfono). No copiar tokens ni tipografía de `mi_sistema.html`.

Excepción pedida por Laura: en Nutri sí hay micro-animaciones y confeti sutil al
cumplir la proteína del día o cerrar el día en objetivo (una vez por día). El resto
de reglas de Mi Sistema sigue aplicando (nada obligatorio, sin registro no se juzga,
lenguaje de Laura).

## Reparto con Mi Sistema

- **Mi Sistema registra**: cada comida (y "Algo de más") con buscador sobre
  `nutri_alimentos` + porciones caseras + escáner (Open Food Facts) →
  `comidas_items`. El texto libre queda de respaldo y Nutri lo marca "aprox".
  Digestión 👍😐👎 + síntoma → `comidas_digestion`. Tarjeta 🚽 Baño → `banos`.
- **Nutri no registra comidas**: lee lo de Mi Sistema y hace análisis, detonantes,
  plan semanal, despensa, compras y coach.

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

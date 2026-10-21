# Nova — entrenador personal de Laura, con ReX

App de una sola usuaria: Laura. Mismo stack y mismas reglas de diseño que Mi Sistema
(ver `CLAUDE.md`): un HTML (`nova.html`), Supabase REST sin cliente JS, GitHub Pages,
celular a una mano. Sin gamificación, nada obligatorio, peso visual cero, tuteo.

**Mi Sistema es sagrada.** Nova no toca `mi_sistema.html`, `mi_casa_*.html`,
`tracker_*.html` ni sus tablas (`registro_diario`, `habitos`, `recuperacion`, `basuras`,
`notas_casa`, `tareas_periodicas`…). Sólo las **lee**.

## Contexto

- 25 sep 2026: accidente de tránsito, fractura en un pie.
- Hasta 26 oct 2026 (previsto): bota + cero apoyo.
- Pendiente: radiografía nueva y cita de fisioterapia.
- Nova arranca el 22 oct 2026.

## Objetivo

Fuerte, flexible y sana. Ahora: fortalecer el resto del cuerpo + movilidad, y documentar
la fisio cuando empiece.

## ReX

Coach. Sabe en qué fase está Laura, qué hizo ayer, cómo durmió y si tiene dolor. Habla
con contexto real, nunca genérico. Con dolor alto no dice "¡vamos!": propone versión
suave o descanso, y descansar vale lo mismo. Sugiere, no castiga. Una sola voz, un solo
nombre.

v1: los mensajes de ReX se arman con reglas sobre datos reales (no hay IA en vivo; una
página estática no puede guardar una llave de API). Chat con IA real = edge function,
más adelante.

### Reglas de ReX (v1)

| Dato | Fuente | Efecto |
|---|---|---|
| Dolor del pie hoy | `recuperacion.dolor` (tarjeta Recuperación de Mi Sistema, único lugar) | duele mucho / punzante: sólo respiración + movilidad, o descanso. molesta: versión suave. nada / leve: normal. Sin dato: ReX lo dice y deja un link a Mi Sistema (no pregunta en Nova) |
| Sueño | `registro_diario.sueno_horas`, `sueno_calidad` | <5.5 h o calidad ≤2: versión suave |
| Energía | `registro_diario.energia` (1-5) | ≤2: versión suave |
| Ánimo | `registro_diario.emocion` | Se nombra, no se juzga |
| Ciclo | `registro_diario.ciclo_fase` | Menstrual: se menciona, sin cambiar el plan |
| Ayer | `nova_sesiones` de ayer | Se nombra lo que hubo (sesión, descanso o nada) sin juicio |

Si falta un dato, no se inventa: ReX dice que no lo tiene o pregunta.

## Fases

Cambian cuando el cuerpo diga, no por fecha. Un cambio de fase es un **hito**
(`nova_hitos.fase_nueva`). La fase actual = último hito no previsto con `fase_nueva`.

- **1A** Bota + sin apoyo: tren superior sentada/acostada, core sin presión en el pie,
  movilidad de lo que se puede mover, respiración.
- **1B** Transición (según radiografía): apoyo parcial.
- **2** Fisioterapia activa: registrar ejercicios del fisio (foto/video/nota); Nova los
  integra al plan.
- **3** Reintroducción: carga progresiva, equilibrio, propiocepción.
- **4** Fortalecimiento pleno: fuerza, flexibilidad, salud.

## Preferencias

Peso corporal, sin equipo. Mañanas, sin obligación. Sin rachas. Sesiones de 10-15 min.

## Tablas (`sql/06_nova.sql`)

- `nova_sesiones` — una fila por día (`fecha` única): `fase`, `dolor_pie` (sin uso desde
  el 21 oct: el dolor vive en `recuperacion`), `estado`
  (`hecha` | `descanso` | null = sólo check-in), `version` (`completa` | `suave` |
  `minima`), `duracion_min`, `completada`, `como_me_senti` (`bien` | `regular` | `mal`),
  `fatiga_percibida` 0-10, `nota`.
- `nova_ejercicios_sesion` — `sesion_id`, `catalogo_id`, `ejercicio`, `series`, `reps`,
  `como_me_senti`.
- `nova_catalogo_ejercicios` — `fase`, `zona`, `nombre`, `descripcion`,
  `contraindicaciones`, `dosis`, `orden` (null = no entra a la sesión base),
  `suave` (entra a la versión suave), `minima` (entra a la versión mínima).
- `nova_fisio_ejercicios` — `fecha`, `foto_url`, `nota`, `repeticiones`, `como_me_senti`.
  Sin UI hasta Fase 2.
- `nova_hitos` — `fecha`, `descripcion`, `fase_nueva`, `previsto`.

Lectura de Mi Sistema: `registro_diario`, `recuperacion`. Escritura: ninguna.
Al volver a la pestaña (visibilitychange), Nova relee todo.

La migración es idempotente: se puede re-correr completa.

## Pantalla principal (v1)

1. Saludo de ReX con el contexto del día.
2. Si falta el dolor del pie: una línea de ReX con link a Recuperación en Mi Sistema.
3. Tarjeta "Sesión de hoy" (versión según contexto) → **Hacer sesión** / **Hoy descanso**.
4. En sesión: lista de ejercicios, un tap marca hecho. Al terminar: 👍 😐 👎 + fatiga
   0-10 + nota opcional.
5. Timeline de recuperación (hitos) abajo.

## Pendiente

- Nutri: leer comidas/macros (de Mi Sistema) para recomendación post-entreno.
- Fase 2: pantalla de fisio (foto/video/nota).
- ReX con IA real (edge function).
- Ejercicios del pie lesionado (dedos, rodilla, elevación con bota) sólo con OK médico.

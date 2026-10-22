// analizar-plato — recibe la foto de un plato servido y devuelve una estimación
// de ingredientes, gramos y nutrientes hecha por Claude (visión).
//
// - La llave de Anthropic vive como secreto de Supabase (ANTHROPIC_API_KEY),
//   nunca en las páginas públicas.
// - Sólo responde a la sesión de Laura: exige JWT y además pregunta es_laura().
// - Lo que devuelve es una ESTIMACIÓN: la app lo marca "aprox" y pide confirmar.
import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import Anthropic from "npm:@anthropic-ai/sdk";

const CORS = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, apikey, content-type, x-client-info",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

const responder = (cuerpo: unknown, status = 200) =>
  new Response(JSON.stringify(cuerpo), { status, headers: { ...CORS, "Content-Type": "application/json" } });

const INSTRUCCIONES = `Analizas fotos de comida para una app personal de nutrición. La usuaria es colombiana, vive en Quebec y es intolerante a la lactosa.

Mira la foto del plato servido y responde SOLO con un objeto JSON, sin texto antes ni después, con esta forma exacta:
{"plato": "nombre corto en español", "ingredientes": [{"nombre": "nombre en español", "gramos": 0, "kcal": 0, "proteina": 0, "carbo": 0, "grasa": 0, "fibra": 0, "lactosa": false}], "confianza": "alta", "nota": ""}

Reglas:
- Sólo ingredientes visibles o claramente implícitos (aceite de fritura, salsa, queso derretido). No agregues lo que no se ve.
- "gramos": la cantidad que se ve en ESTE plato. Usa el plato, los cubiertos y la mano como referencia de tamaño.
- Los nutrientes son para esos gramos (no por 100 g), con valores de referencia tipo USDA. Números, no texto.
- "lactosa": true si el ingrediente es lácteo con lactosa (queso fresco, crema, leche, salsa blanca).
- "confianza": "alta", "media" o "baja" según qué tan claro se ve.
- "nota": una frase corta si algo no se distingue (por ejemplo, qué hay debajo de la salsa); si no, vacío.
- Si la foto no es comida, devuelve "ingredientes": [] y explícalo en "nota".`;

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: CORS });
  if (req.method !== "POST") return responder({ error: "metodo" }, 405);

  // Sólo Laura: la misma regla que protege las tablas
  const auth = req.headers.get("Authorization") ?? "";
  const url = Deno.env.get("SUPABASE_URL");
  const anon = Deno.env.get("SUPABASE_ANON_KEY") ?? "";
  const quien = await fetch(`${url}/rest/v1/rpc/es_laura`, {
    method: "POST",
    headers: { apikey: anon, Authorization: auth, "Content-Type": "application/json" },
    body: "{}",
  });
  if (!quien.ok || (await quien.json()) !== true) return responder({ error: "no_autorizado" }, 403);

  const llave = Deno.env.get("ANTHROPIC_API_KEY");
  if (!llave) return responder({ error: "falta_llave" }, 503);

  let imagen: string, tipo: string;
  try {
    const cuerpo = await req.json();
    imagen = String(cuerpo.imagen || "");
    tipo = String(cuerpo.media_type || "image/jpeg");
  } catch {
    return responder({ error: "cuerpo" }, 400);
  }
  if (!imagen) return responder({ error: "sin_imagen" }, 400);

  const client = new Anthropic({ apiKey: llave });
  let respuesta;
  try {
    // deno-lint-ignore no-explicit-any
    const params: any = {
      model: "claude-opus-5-5",
      max_tokens: 4000,
      output_config: { effort: "medium" },
      betas: ["server-side-fallback-2026-07-01"],
      fallbacks: "default",
      messages: [{
        role: "user",
        content: [
          { type: "image", source: { type: "base64", media_type: tipo, data: imagen } },
          { type: "text", text: INSTRUCCIONES },
        ],
      }],
    };
    respuesta = await client.beta.messages.create(params);
  } catch (e) {
    if (e instanceof Anthropic.RateLimitError) return responder({ error: "ocupado" }, 429);
    if (e instanceof Anthropic.AuthenticationError) return responder({ error: "llave_invalida" }, 503);
    if (e instanceof Anthropic.APIError) return responder({ error: "api", status: e.status }, 502);
    return responder({ error: "red" }, 502);
  }

  if (respuesta.stop_reason === "refusal") return responder({ error: "rechazo" }, 422);

  const texto = respuesta.content
    .filter((b: { type: string }) => b.type === "text")
    .map((b: { type: string; text?: string }) => b.text ?? "")
    .join("");
  const ini = texto.indexOf("{"), fin = texto.lastIndexOf("}");
  if (ini < 0 || fin <= ini) return responder({ error: "formato" }, 502);
  try {
    const datos = JSON.parse(texto.slice(ini, fin + 1));
    if (!Array.isArray(datos.ingredientes)) datos.ingredientes = [];
    return responder(datos);
  } catch {
    return responder({ error: "formato" }, 502);
  }
});

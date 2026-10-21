-- Tabla de hábitos (ya existente en producción, documentada aquí por completitud)
-- Estructura inferida del uso actual en mi_sistema.html

CREATE TABLE IF NOT EXISTS habitos (
  id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  fecha date NOT NULL,
  momento text NOT NULL,        -- 'm' (mañana) o 'n' (noche)
  habito text NOT NULL,          -- nombre del hábito
  completado boolean DEFAULT false,
  updated_at timestamp DEFAULT now(),
  UNIQUE(fecha, momento, habito)
);

ALTER TABLE habitos ENABLE ROW LEVEL SECURITY;

CREATE POLICY IF NOT EXISTS "acceso_publico" ON habitos
FOR ALL USING (true) WITH CHECK (true);

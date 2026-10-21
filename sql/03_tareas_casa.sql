CREATE TABLE IF NOT EXISTS tareas_casa (
  id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  fecha date NOT NULL UNIQUE,
  diarias jsonb DEFAULT '{}'::jsonb,
  zona_dia text,
  zona_hecha boolean DEFAULT false,
  updated_at timestamp DEFAULT now()
);

ALTER TABLE tareas_casa ENABLE ROW LEVEL SECURITY;

CREATE POLICY IF NOT EXISTS "acceso_publico_casa" ON tareas_casa
FOR ALL USING (true) WITH CHECK (true);

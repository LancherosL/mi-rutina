CREATE TABLE IF NOT EXISTS registro_diario (
  id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  fecha date NOT NULL UNIQUE,
  emocion text,
  energia int,
  agua text,
  pasos int,
  fc int,
  spo2 int,
  hrv int,
  estres int,
  recuperacion int,
  sueno_horas numeric,
  sueno_calidad int,
  movimiento int,
  ciclo_dia int,
  ciclo_fase text,
  lectura_min int,
  escribi boolean DEFAULT false,
  comidas jsonb DEFAULT '{}'::jsonb,
  comidas_texto jsonb DEFAULT '{}'::jsonb,
  gatos jsonb DEFAULT '{}'::jsonb,
  updated_at timestamp DEFAULT now()
);

ALTER TABLE registro_diario ENABLE ROW LEVEL SECURITY;

CREATE POLICY IF NOT EXISTS "acceso_publico_registro" ON registro_diario
FOR ALL USING (true) WITH CHECK (true);

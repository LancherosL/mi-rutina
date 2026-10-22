-- Texto libre analizado por IA y suplementos (sólo esquema; la precarga personal vive en Supabase).

-- Qué texto se analizó por última vez en cada comida, y lo que devolvió la IA
alter table public.comidas_detalle add column if not exists texto_analizado text;
alter table public.comidas_detalle add column if not exists analisis_texto jsonb;

-- Suplementos (Nutri). nutrientes: {"proteina": 24, "kcal": null, ...}
--   clave ausente = no aporta (0) · valor null = aporta pero no se sabe cuánto
create table if not exists public.suplementos (
  id uuid primary key default gen_random_uuid(),
  nombre text not null,
  marca text,
  dosis text,
  horario text,
  nutrientes jsonb not null default '{}'::jsonb,
  diario boolean not null default true,
  activo boolean not null default true,
  orden integer default 0,
  created_at timestamptz default now()
);
alter table public.suplementos enable row level security;
create policy solo_laura on public.suplementos for all to authenticated using (es_laura()) with check (es_laura());

-- Cada vez que se toma: fecha, hora y lo que aportó en ese momento
create table if not exists public.suplementos_tomas (
  id uuid primary key default gen_random_uuid(),
  suplemento_id uuid references public.suplementos(id) on delete cascade,
  fecha date not null default current_date,
  hora text,
  nutrientes jsonb not null default '{}'::jsonb,
  created_at timestamptz default now()
);
create index if not exists suplementos_tomas_fecha_idx on public.suplementos_tomas (fecha);
alter table public.suplementos_tomas enable row level security;
create policy solo_laura on public.suplementos_tomas for all to authenticated using (es_laura()) with check (es_laura());

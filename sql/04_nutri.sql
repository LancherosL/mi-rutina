-- Nutri + registro estructurado de comidas en Mi Sistema + baño.
-- No toca registro_diario. Mismo esquema de acceso que el resto (app de una sola usuaria).

-- Perfil y metas (una fila: 'laura'). La actividad se cambia aquí y Nutri recalcula.
create table if not exists public.nutri_perfil (
  id text primary key default 'laura',
  sexo text default 'mujer',
  edad integer,
  peso_kg numeric,
  estatura_cm numeric,
  actividad text default 'baja' check (actividad in ('baja','ligera','moderada','alta')),
  objetivo text,
  kcal integer,
  proteina_g integer,
  grasa_g integer,
  carbo_g integer,
  -- Fibra: meta final 25 g, pero sube gradual según la digestión (no de golpe).
  fibra_meta_g integer default 25,
  fibra_actual_g integer,            -- meta vigente; null = aún sin registros para fijarla
  fibra_paso_semana_g integer default 2,
  calcio_mg integer default 1000,
  vitd_ui integer default 600,
  notas text,
  actualizado timestamptz default now()
);

-- Base de alimentos. Valores por 100 g; porciones caseras en gramos.
create table if not exists public.nutri_alimentos (
  id uuid primary key default gen_random_uuid(),
  nombre text not null,
  norm text not null unique,          -- minúsculas sin tildes, para el buscador
  categoria text,
  porciones jsonb not null default '[]'::jsonb,  -- [{"u":"unidad","g":90}, {"u":"taza","g":160}]
  kcal numeric, proteina numeric, carbo numeric, grasa numeric, fibra numeric,
  calcio_mg numeric, vitd_ui numeric,
  lactosa boolean default false,
  cafeina boolean default false,
  fuente text,                         -- 'USDA SR Legacy', 'CNF', 'receta calculada', 'Open Food Facts'
  codigo_barras text unique,
  created_at timestamptz default now()
);

-- Lo que comí, estructurado. Los macros se guardan al momento (no cambian si se corrige la base).
create table if not exists public.comidas_items (
  id uuid primary key default gen_random_uuid(),
  fecha date not null default current_date,
  comida text not null check (comida in ('0','1','2','extra')),
  extra_ref text,                      -- id del ítem de "Algo de más" cuando comida = 'extra'
  alimento_id uuid references public.nutri_alimentos(id),
  codigo_barras text,
  nombre text not null,
  cantidad numeric not null default 1,
  unidad text,
  gramos numeric,
  kcal numeric, proteina numeric, carbo numeric, grasa numeric, fibra numeric,
  calcio_mg numeric, vitd_ui numeric,
  lactosa boolean default false,
  cafeina boolean default false,
  created_at timestamptz default now()
);
create index if not exists comidas_items_fecha_idx on public.comidas_items (fecha);

-- 👍😐👎 + síntoma opcional, una por comida.
create table if not exists public.comidas_digestion (
  id uuid primary key default gen_random_uuid(),
  fecha date not null default current_date,
  comida text not null check (comida in ('0','1','2','extra')),
  extra_ref text,
  reaccion text check (reaccion in ('bien','regular','mal')),
  sintomas text[] default '{}',
  hora text,
  created_at timestamptz default now()
);
create unique index if not exists comidas_digestion_uni
  on public.comidas_digestion (fecha, comida, coalesce(extra_ref,''));

-- 🚽 Baño: una fila por vez.
create table if not exists public.banos (
  id uuid primary key default gen_random_uuid(),
  fecha date not null default current_date,
  hora text,
  tipo text check (tipo in ('dura','normal','blanda')),
  bristol integer check (bristol between 1 and 7),   -- dura=2, normal=4, blanda=6
  molestias text[] default '{}',       -- inflamacion, colico, urgencia, incompleta
  created_at timestamptz default now()
);
create index if not exists banos_fecha_idx on public.banos (fecha);

alter table public.nutri_perfil enable row level security;
alter table public.nutri_alimentos enable row level security;
alter table public.comidas_items enable row level security;
alter table public.comidas_digestion enable row level security;
alter table public.banos enable row level security;

create policy acceso_publico on public.nutri_perfil for all using (true) with check (true);
create policy acceso_publico on public.nutri_alimentos for all using (true) with check (true);
create policy acceso_publico on public.comidas_items for all using (true) with check (true);
create policy acceso_publico on public.comidas_digestion for all using (true) with check (true);
create policy acceso_publico on public.banos for all using (true) with check (true);

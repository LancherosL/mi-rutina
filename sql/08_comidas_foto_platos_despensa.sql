-- Comidas con foto (IA), platos de restaurante, "Comí afuera" y despensa con Open Food Facts.
-- Todo con la misma política solo_laura (es_laura()) que el resto.

-- Lo que se sabe de cada comida además de sus alimentos: si fue afuera, dónde,
-- la foto y lo que la IA vio en ella. Una fila por comida (o por "algo de más").
create table if not exists public.comidas_detalle (
  id uuid primary key default gen_random_uuid(),
  fecha date not null default current_date,
  comida text not null check (comida in ('0','1','2','extra')),
  extra_ref text not null default '',
  afuera boolean not null default false,
  restaurante text,
  cocina text,
  ocasion text,
  foto_path text,          -- ruta en el bucket privado "platos"
  analisis jsonb,          -- respuesta de la IA tal cual (ingredientes, gramos, nutrientes)
  created_at timestamptz default now(),
  actualizado timestamptz default now(),
  unique (fecha, comida, extra_ref)
);
alter table public.comidas_detalle enable row level security;
create policy solo_laura on public.comidas_detalle for all to authenticated using (es_laura()) with check (es_laura());

-- Alimentos estimados (platos de restaurante, foto) se marcan: Nutri los muestra como "aprox".
alter table public.comidas_items add column if not exists estimado boolean not null default false;
alter table public.comidas_items add column if not exists origen text;   -- base · plato · foto · empacado

-- Platos de restaurante: valores por porción típica (estimados, no medidos).
create table if not exists public.platos_restaurante (
  id uuid primary key default gen_random_uuid(),
  nombre text not null,
  norm text not null unique,
  cocina text,
  ingredientes text,
  porcion_g numeric,
  calorias numeric,
  proteina numeric,
  carbohidratos numeric,
  grasa numeric,
  fibra numeric,
  lactosa boolean default false,
  created_at timestamptz default now()
);
alter table public.platos_restaurante enable row level security;
create policy solo_laura on public.platos_restaurante for all to authenticated using (es_laura()) with check (es_laura());

-- Despensa: datos completos de Open Food Facts.
alter table public.nutri_despensa
  add column if not exists codigo_barras text,
  add column if not exists marca text,
  add column if not exists ingredientes text,
  add column if not exists calorias_100g numeric,
  add column if not exists proteina_100g numeric,
  add column if not exists carbohidratos_100g numeric,
  add column if not exists grasa_100g numeric,
  add column if not exists fibra_100g numeric,
  add column if not exists alergenos text[],
  add column if not exists cantidad_disponible text,
  add column if not exists fecha_vencimiento date,
  add column if not exists tiendas text;

-- Fotos de platos: bucket privado, sólo Laura.
insert into storage.buckets (id, name, public) values ('platos', 'platos', false) on conflict (id) do nothing;
create policy platos_solo_laura on storage.objects for all to authenticated
  using (bucket_id = 'platos' and es_laura()) with check (bucket_id = 'platos' and es_laura());

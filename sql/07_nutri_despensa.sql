-- Despensa de Nutri: lo que hay en casa y lo que toca comprar.
-- estado 'hay' = está en casa · 'comprar' = se acabó (aparece en la lista de compras).
create table if not exists public.nutri_despensa (
  id uuid primary key default gen_random_uuid(),
  alimento_id uuid references public.nutri_alimentos(id) on delete set null,
  nombre text not null,
  estado text not null default 'hay' check (estado in ('hay','comprar')),
  created_at timestamptz default now(),
  actualizado timestamptz default now()
);
alter table public.nutri_despensa enable row level security;
create policy solo_laura on public.nutri_despensa for all to authenticated using (es_laura()) with check (es_laura());

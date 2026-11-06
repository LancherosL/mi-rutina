-- Nuestra casa, entre los dos (casa.html)
-- Todo pasa por el código de la casa: el navegador manda el header x-casa
-- y las políticas lo comparan con casa_secretos (que nadie puede leer con la llave pública).
-- Laura manda además x-laura: sólo con eso se corrige o borra el registro.
-- Los códigos NO van en este archivo: se cargan aparte con un insert en casa_secretos.

create table if not exists casa_secretos (
  clave text primary key,
  valor text not null
);
alter table casa_secretos enable row level security;
-- sin políticas: la llave pública no lo ve

create or replace function casa_ok() returns boolean
language sql stable security definer set search_path = public as $$
  select exists(select 1 from casa_secretos where clave = 'casa'
    and valor = coalesce(current_setting('request.headers', true)::json->>'x-casa', ''));
$$;

create or replace function casa_es_laura() returns boolean
language sql stable security definer set search_path = public as $$
  select casa_ok() and exists(select 1 from casa_secretos where clave = 'laura'
    and valor = coalesce(current_setting('request.headers', true)::json->>'x-laura', ''));
$$;

-- Ajustes compartidos: nombre del roommate, fecha de revisión, referencia de bacs
create table if not exists casa_config (
  clave text primary key,
  valor jsonb not null,
  updated_at timestamptz default now(),
  updated_por text
);

-- Tareas base del calendario. dia_def: 1=lunes … 7=domingo, null = cualquier día de la semana.
-- quien_base: quién la hace en la semana par; se turnan cada semana.
create table if not exists casa_tareas (
  id uuid default gen_random_uuid() primary key,
  orden int not null default 0,
  es text not null,
  fr text not null,
  nota_es text,
  nota_fr text,
  dia_def int check (dia_def between 1 and 7),
  hora_def text,
  quien_base text not null check (quien_base in ('laura','roommate')),
  activa boolean default true
);

-- Lo que se movió esta semana (día, hora, quién). Si no hay fila, vale lo de casa_tareas.
create table if not exists casa_semana (
  id uuid default gen_random_uuid() primary key,
  tarea_id uuid not null references casa_tareas(id) on delete cascade,
  lunes date not null,
  dia int check (dia between 1 and 7),
  hora text,
  quien text check (quien in ('laura','roommate')),
  updated_at timestamptz default now(),
  updated_por text,
  unique (tarea_id, lunes)
);

-- El registro: la prueba. Guarda roles ('laura'/'roommate'), no nombres,
-- para que el nombre del roommate cambie en todo el historial.
create table if not exists casa_registro (
  id uuid default gen_random_uuid() primary key,
  created_at timestamptz not null default now(),
  fecha date not null,                 -- el día en que se hizo (lo elige quien anota; por defecto hoy)
  quien text not null check (quien in ('laura','roommate')),
  tipo text not null check (tipo in ('tarea','basura','loza','insumo_falta','insumo_comprado','libre')),
  tarea_id uuid references casa_tareas(id) on delete set null,
  insumo_id uuid,
  texto text,
  nota text,
  creado_por text not null check (creado_por in ('laura','roommate')),
  editado_at timestamptz,
  borrado_at timestamptz
);
create index if not exists casa_registro_fecha on casa_registro (created_at desc);

create table if not exists casa_insumos (
  id uuid default gen_random_uuid() primary key,
  orden int not null default 0,
  es text not null,
  fr text not null,
  falta boolean default false,
  updated_at timestamptz default now(),
  updated_por text
);

alter table casa_config   enable row level security;
alter table casa_tareas   enable row level security;
alter table casa_semana   enable row level security;
alter table casa_registro enable row level security;
alter table casa_insumos  enable row level security;

grant select, insert, update on casa_config, casa_tareas, casa_semana, casa_insumos to anon;
grant select, insert, update, delete on casa_registro to anon;
grant execute on function casa_ok(), casa_es_laura() to anon;

create policy casa_leer   on casa_config for select using (casa_ok());
create policy casa_crear  on casa_config for insert with check (casa_ok() and (clave <> 'roommate' or casa_es_laura()));
create policy casa_editar on casa_config for update using (casa_ok()) with check (clave <> 'roommate' or casa_es_laura());

create policy casa_leer   on casa_tareas for select using (casa_ok());

create policy casa_leer   on casa_semana for select using (casa_ok());
create policy casa_crear  on casa_semana for insert with check (casa_ok());
create policy casa_editar on casa_semana for update using (casa_ok()) with check (casa_ok());

-- Registro: los dos anotan; sólo Laura corrige o borra. Nadie anota a nombre de Laura sin ser Laura.
create policy casa_leer   on casa_registro for select using (casa_ok());
create policy casa_crear  on casa_registro for insert with check (casa_ok() and (creado_por = 'roommate' or casa_es_laura()));
create policy casa_editar on casa_registro for update using (casa_es_laura()) with check (casa_es_laura());
create policy casa_borrar on casa_registro for delete using (casa_es_laura());

create policy casa_leer   on casa_insumos for select using (casa_ok());
create policy casa_editar on casa_insumos for update using (casa_ok()) with check (casa_ok());

-- Datos iniciales
insert into casa_config (clave, valor) values
  ('roommate', '"Adam"'),
  ('revision', to_jsonb((current_date + ((4 - extract(isodow from current_date)::int + 7) % 7))::text))
on conflict (clave) do nothing;

insert into casa_tareas (orden, es, fr, nota_es, nota_fr, dia_def, hora_def, quien_base) values
  (1, 'Barrer cocina, sala y pasillo', 'Balayer la cuisine, le salon et le corridor', 'Piso de las zonas comunes, también debajo de la mesa.', 'Plancher des espaces communs, aussi sous la table.', 1, null, 'laura'),
  (2, 'Sacar el bac de la calle', 'Sortir le bac de la rue', 'El bac que toca esta semana, al borde de la entrada.', 'Le bac de cette semaine, au bord de l''entrée.', 3, '19:00', 'roommate'),
  (3, 'Entrar el bac y barrer', 'Rentrer le bac et balayer', 'Entrar el bac vacío y barrer cocina y sala.', 'Rentrer le bac vide et balayer la cuisine et le salon.', 4, null, 'laura'),
  (4, 'Limpieza a fondo de la cocina', 'Ménage à fond de la cuisine', 'Mesones, estufa, lavaplatos y trapeada. Pasos en la sección 4.', 'Comptoirs, cuisinière, évier et vadrouille. Étapes à la section 4.', 6, null, 'roommate'),
  (5, 'Limpiar el baño', 'Nettoyer la salle de bain', 'Turnándonos, 1 vez por semana. Pasos en la sección 4.', 'À tour de rôle, 1 fois par semaine. Étapes à la section 4.', 6, null, 'laura');

insert into casa_insumos (orden, es, fr) values
  (1, 'Bolsas de basura', 'Sacs poubelle'),
  (2, 'Jabón de loza', 'Savon à vaisselle'),
  (3, 'Esponjas', 'Éponges'),
  (4, 'Producto para el baño', 'Produit pour la salle de bain'),
  (5, 'Producto para pisos', 'Produit pour planchers'),
  (6, 'Papel higiénico del baño común', 'Papier de toilette de la salle de bain commune'),
  (7, 'Detergente / suavizante compartido', 'Détergent / assouplissant partagé');

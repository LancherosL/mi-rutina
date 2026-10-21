-- Nova: entrenador personal con ReX. Tablas propias con prefijo nova_.
-- No toca ninguna tabla de Mi Sistema (sólo las lee desde nova.html).
-- Mismo esquema de acceso que el resto (app de una sola usuaria).

-- Una fila por día: check-in de dolor + sesión o descanso.
create table if not exists public.nova_sesiones (
  id uuid primary key default gen_random_uuid(),
  fecha date not null unique,
  fase text not null default '1A',
  dolor_pie integer check (dolor_pie between 0 and 10),
  estado text check (estado in ('hecha','descanso')),    -- null = sólo check-in
  version text check (version in ('completa','suave','minima')),
  duracion_min integer,
  completada boolean default false,
  como_me_senti text check (como_me_senti in ('bien','regular','mal')),
  fatiga_percibida integer check (fatiga_percibida between 0 and 10),
  nota text,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

create table if not exists public.nova_catalogo_ejercicios (
  id uuid primary key default gen_random_uuid(),
  fase text not null,
  zona text,
  nombre text not null,
  descripcion text,
  contraindicaciones text,
  dosis text,              -- "2 × 12", "5 × 10 s", "2 min"
  orden integer,           -- null = no entra a la sesión base
  suave boolean default false,
  minima boolean default false,
  unique (fase, nombre)
);

create table if not exists public.nova_ejercicios_sesion (
  id uuid primary key default gen_random_uuid(),
  sesion_id uuid not null references public.nova_sesiones(id) on delete cascade,
  catalogo_id uuid references public.nova_catalogo_ejercicios(id),
  ejercicio text not null,
  series integer,
  reps text,
  como_me_senti text,
  created_at timestamptz default now(),
  unique (sesion_id, ejercicio)
);

create table if not exists public.nova_fisio_ejercicios (
  id uuid primary key default gen_random_uuid(),
  fecha date not null default current_date,
  foto_url text,
  nota text,
  repeticiones text,
  como_me_senti text,
  created_at timestamptz default now()
);

-- Timeline. Un hito con fase_nueva cambia la fase; previsto = aún no pasa.
create table if not exists public.nova_hitos (
  id uuid primary key default gen_random_uuid(),
  fecha date,
  descripcion text not null,
  fase_nueva text,
  previsto boolean default false,
  created_at timestamptz default now()
);

alter table public.nova_sesiones enable row level security;
alter table public.nova_catalogo_ejercicios enable row level security;
alter table public.nova_ejercicios_sesion enable row level security;
alter table public.nova_fisio_ejercicios enable row level security;
alter table public.nova_hitos enable row level security;

-- Políticas: drop + create para poder re-correr el archivo.
do $$
declare t text;
begin
  foreach t in array array['nova_sesiones','nova_catalogo_ejercicios','nova_ejercicios_sesion','nova_fisio_ejercicios','nova_hitos'] loop
    execute format('drop policy if exists acceso_publico on public.%I', t);
    execute format('create policy acceso_publico on public.%I for all using (true) with check (true)', t);
    execute format('grant select, insert, update, delete on public.%I to anon, authenticated', t);
  end loop;
end $$;

-- Índices. nova_sesiones.fecha ya tiene índice por el unique;
-- nova_ejercicios_sesion.sesion_id, por el unique (sesion_id, ejercicio).
create index if not exists nova_catalogo_fase_orden_idx on public.nova_catalogo_ejercicios (fase, orden);
create index if not exists nova_hitos_fecha_idx on public.nova_hitos (fecha);
create index if not exists nova_fisio_fecha_idx on public.nova_fisio_ejercicios (fecha);

-- ── Catálogo Fase 1A: bota + cero apoyo. Nada carga ni mueve el pie lesionado. ──
insert into public.nova_catalogo_ejercicios (fase, zona, nombre, descripcion, contraindicaciones, dosis, orden, suave, minima) values
('1A','respiración','Respiración 4-6',
 'Acostada boca arriba, pie con bota apoyado en un cojín. Inhala por la nariz en 4, exhala lento en 6. Una mano en la barriga.',
 null,'2 min',1,true,true),
('1A','movilidad','Cuello y hombros',
 'Sentada con la espalda apoyada. Inclina la oreja al hombro (5 por lado), luego círculos de hombros hacia atrás (10).',
 'Si hay mareo, hazlo acostada.','2 min',2,true,true),
('1A','tren superior','Elevaciones de brazos',
 'Sentada. Brazos al frente hasta la altura de los hombros, bajas lento; luego a los lados. Sin peso, despacio: 3 s subir, 3 s bajar.',
 null,'2 × 12',3,true,false),
('1A','tren superior','Palmas que empujan',
 'Sentada. Palmas juntas frente al pecho, codos abiertos. Empuja una contra otra con fuerza sin aguantar la respiración.',
 'Si sube la presión o hay dolor de cabeza, suaviza la fuerza.','5 × 10 s',4,false,false),
('1A','tren superior','Remo con toalla',
 'Sentada. Toalla agarrada con las dos manos al frente. Jálala como para romperla y junta los omóplatos.',
 null,'5 × 10 s',5,true,false),
('1A','core','Encogimiento corto',
 'Acostada, piernas estiradas sobre la cama, pie con bota sobre cojín. Manos en el pecho, despegas sólo los hombros, exhalando.',
 'Nada de doblar rodillas ni apoyar el pie lesionado para impulsarte.','2 × 8',6,false,false),
('1A','core','Pierna sana arriba',
 'Acostada boca arriba. Sólo la pierna SANA: estirada, la subes unos 30 cm y bajas lento. La otra descansa en el cojín.',
 'Solo pierna sana. Si tira de la espalda baja, sube menos.','2 × 8',7,false,false),
('1A','respiración','Cierre: respiración 4-6',
 'Igual que al inicio. Nota cómo quedó el cuerpo.',
 null,'1 min',8,true,true),
-- Fuera de la sesión base (orden null): sólo con OK médico o para días específicos.
('1A','movilidad','Muñecas y manos',
 'Círculos de muñeca, abrir y cerrar los puños.',null,'1 min',null,false,false),
('1A','pie lesionado','Mover dedos del pie',
 'Mover los dedos que salen de la bota.',
 'SOLO si tu médico o fisio lo indicó.','1 min',null,false,false),
('1A','pie lesionado','Elevación de pierna con bota',
 'Acostada, subir la pierna lesionada con la bota puesta.',
 'SOLO con OK médico. Puede cargar el foco de fractura.','2 × 8',null,false,false)
on conflict (fase, nombre) do nothing;

-- ── Hitos iniciales ──
insert into public.nova_hitos (fecha, descripcion, fase_nueva, previsto)
select v.fecha::date, v.descripcion, v.fase_nueva, v.previsto
from (values
  ('2026-09-25','Accidente de tránsito. Fractura en el pie.','1A',false),
  ('2026-10-22','Empiezo Nova.',null,false),
  ('2026-10-26','Fin previsto de bota sin apoyo (según radiografía).',null,true),
  (null,'Radiografía nueva',null,true),
  (null,'Primera cita de fisioterapia',null,true)
) as v(fecha, descripcion, fase_nueva, previsto)
where not exists (select 1 from public.nova_hitos h where h.descripcion = v.descripcion);

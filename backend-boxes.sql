-- Bibliothèque de Thanh Nghiem — table des "cadres" (rectangles repérant la tranche d'un livre sur sa photo)
-- À coller dans Supabase : SQL Editor > New query > Run.
--
-- Chaque ligne = un cadre dessiné à la main sur la photo agrandie (outil « ✏️ Encadrer ce livre »).
-- Coordonnées NORMALISÉES (0..1) relatives à l'image : x,y = coin haut-gauche ; w,h = largeur/hauteur.
-- L'application lit le cadre le plus récent par livre et l'affiche en surimpression (effet « projecteur »).

create table if not exists public.boxes (
  id          bigint generated always as identity primary key,
  book_id     integer     not null,
  photo       text        not null,
  x           real        not null,
  y           real        not null,
  w           real        not null,
  h           real        not null,
  nom         text,
  created_at  timestamptz not null default now()
);

create index if not exists boxes_book_id_idx on public.boxes (book_id);

alter table public.boxes enable row level security;

-- Tout le monde peut LIRE les cadres
drop policy if exists "lecture publique" on public.boxes;
create policy "lecture publique"
  on public.boxes for select
  to anon
  using (true);

-- Tout le monde peut AJOUTER un cadre (coordonnées bornées 0..1, photo 1..200 car., nom <= 60 car.)
drop policy if exists "ajout public" on public.boxes;
create policy "ajout public"
  on public.boxes for insert
  to anon
  with check (
    x >= 0 and x <= 1 and y >= 0 and y <= 1
    and w > 0 and w <= 1 and h > 0 and h <= 1
    and char_length(coalesce(photo,'')) between 1 and 200
    and char_length(coalesce(nom,'')) <= 60
  );

-- (Volontairement : pas de policy UPDATE/DELETE pour anon. Les cadres sont en "ajout seul" ;
--  le dernier cadre d'un livre fait foi. Pour corriger/purger un cadre, faites-le depuis le
--  Table Editor de Supabase.)

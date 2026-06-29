-- BibliHaudri — table des "livres" gérés par les utilisateurs (listes personnelles)
-- À coller dans Supabase : SQL Editor > New query > Run.
--
-- Chaque utilisateur (identifié simplement par son nom) gère SA propre liste de livres :
-- il peut en ajouter, les modifier ou les supprimer. La bibliothèque historique de
-- Thanh Nghiem (186 ouvrages) reste chargée depuis data/books.json ; cette table ne
-- contient que les livres ajoutés depuis le site.
--
-- IMPORTANT — espace d'identifiants : l'identité commence à 1 000 000 pour ne JAMAIS
-- entrer en collision avec les identifiants des livres d'origine (1..186). Les
-- commentaires (« intérêts ») restent ainsi compatibles avec les deux catalogues.

create table if not exists public.livres (
  id          bigint generated always as identity (start with 1000000) primary key,
  owner       text        not null,          -- nom de l'utilisateur propriétaire de la fiche
  title       text        not null,
  author      text,
  publisher   text,
  year        integer,
  type        text,
  genre       text,
  summary     text,
  cover_url   text,                            -- image du livre (photo uploadée OU URL collée)
  status      text,                            -- disponibilité : 'emprunter' | 'donner' | 'vendre'
  price       numeric(10,2),                   -- prix (si à vendre)
  location    text,                            -- localisation libre : « Étagère entrée du 47 », « Chez Duc »…
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now()
);

-- Pour les bases déjà créées avec une version précédente : ajoute les colonnes manquantes.
alter table public.livres add column if not exists status   text;
alter table public.livres add column if not exists price    numeric(10,2);
alter table public.livres add column if not exists location text;

create index if not exists livres_owner_idx  on public.livres (owner);
create index if not exists livres_status_idx on public.livres (status);

alter table public.livres enable row level security;

-- Tout le monde peut LIRE les livres (catalogue partagé)
drop policy if exists "lecture publique" on public.livres;
create policy "lecture publique"
  on public.livres for select
  to anon
  using (true);

-- Tout le monde peut AJOUTER un livre à SA liste
-- (propriétaire 1..60 car., titre 1..300 car., et bornes raisonnables sur le reste)
drop policy if exists "ajout public" on public.livres;
create policy "ajout public"
  on public.livres for insert
  to anon
  with check (
    char_length(owner) between 1 and 60
    and char_length(title) between 1 and 300
    and char_length(coalesce(author,'')) <= 300
    and char_length(coalesce(publisher,'')) <= 200
    and char_length(coalesce(type,'')) <= 120
    and char_length(coalesce(genre,'')) <= 120
    and char_length(coalesce(summary,'')) <= 4000
    and char_length(coalesce(cover_url,'')) <= 1000
    and (status is null or status in ('emprunter','donner','vendre'))
    and (price is null or (price >= 0 and price <= 100000))
    and char_length(coalesce(location,'')) <= 200
  );

-- Modèle de confiance (« on se fait confiance », comme pour les commentaires) :
-- chacun peut modifier / supprimer une fiche. L'application ne propose ces actions
-- que sur VOS propres livres (owner = votre nom), mais il n'y a pas d'authentification
-- côté serveur. Pour un verrouillage strict, passez à Supabase Auth + RLS par auth.uid().
drop policy if exists "modification publique" on public.livres;
create policy "modification publique"
  on public.livres for update
  to anon
  using (true)
  with check (
    char_length(owner) between 1 and 60
    and char_length(title) between 1 and 300
  );

drop policy if exists "suppression publique" on public.livres;
create policy "suppression publique"
  on public.livres for delete
  to anon
  using (true);


-- =====================================================================
-- STOCKAGE DES PHOTOS (pour « numériser » un livre en uploadant une photo)
-- =====================================================================
-- Crée un bucket public « livres-photos » et autorise l'upload depuis le site
-- (clé anon). Les photos sont servies publiquement via une URL.
--
-- Si l'éditeur SQL refuse ces commandes (droits sur le schéma "storage"),
-- créez plutôt le bucket à la main : Supabase → Storage → New bucket →
-- nom « livres-photos », cochez « Public bucket ». Puis exécutez seulement
-- les deux "create policy" ci-dessous.

insert into storage.buckets (id, name, public)
values ('livres-photos', 'livres-photos', true)
on conflict (id) do update set public = true;

-- Lecture publique des photos
drop policy if exists "livres-photos lecture publique" on storage.objects;
create policy "livres-photos lecture publique"
  on storage.objects for select
  to anon
  using (bucket_id = 'livres-photos');

-- Upload public des photos (dans ce bucket uniquement)
drop policy if exists "livres-photos ajout public" on storage.objects;
create policy "livres-photos ajout public"
  on storage.objects for insert
  to anon
  with check (bucket_id = 'livres-photos');

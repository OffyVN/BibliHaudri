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
  cover_url   text,
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now()
);

create index if not exists livres_owner_idx on public.livres (owner);

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

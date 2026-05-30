-- Bibliothèque de Thanh Nghiem — table des "intérêts" (commentaires partagés)
-- À coller dans Supabase : SQL Editor > New query > Run.

create table if not exists public.interets (
  id          bigint generated always as identity primary key,
  book_id     integer    not null,
  nom         text       not null,
  commentaire text,
  created_at  timestamptz not null default now()
);

alter table public.interets enable row level security;

-- Tout le monde peut LIRE les commentaires
drop policy if exists "lecture publique" on public.interets;
create policy "lecture publique"
  on public.interets for select
  to anon
  using (true);

-- Tout le monde peut AJOUTER un commentaire (nom 1..60 car., commentaire <= 500 car.)
drop policy if exists "ajout public" on public.interets;
create policy "ajout public"
  on public.interets for insert
  to anon
  with check (
    char_length(nom) between 1 and 60
    and char_length(coalesce(commentaire,'')) <= 500
  );

-- (Volontairement : pas de policy UPDATE/DELETE pour anon, donc personne ne peut
--  modifier ou effacer les messages des autres depuis le site public.)

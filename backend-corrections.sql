-- Bibliothèque de Thanh Nghiem — table des "corrections / validations" des fiches « à vérifier »
-- À coller dans Supabase : SQL Editor > New query > Run.
--
-- Chaque ligne = une vérification d'une fiche : le titre / l'auteur confirmés (ou corrigés)
-- en regardant la photo d'origine. L'application lit la correction la plus récente par livre
-- et masque alors le badge « à vérifier ».

create table if not exists public.corrections (
  id          bigint generated always as identity primary key,
  book_id     integer     not null,
  titre       text,
  auteur      text,
  validated   boolean     not null default true,
  nom         text,
  -- infos rafraîchies depuis Open Library quand on corrige le titre/auteur
  cover_url   text,        -- couverture retrouvée
  editeur     text,
  annee       integer,
  resume      text,
  note        real,        -- note moyenne
  note_count  integer,     -- nombre d'avis
  created_at  timestamptz not null default now()
);

-- Pour les bases déjà créées avec une version précédente : ajoute les colonnes manquantes.
alter table public.corrections add column if not exists cover_url  text;
alter table public.corrections add column if not exists editeur    text;
alter table public.corrections add column if not exists annee      integer;
alter table public.corrections add column if not exists resume     text;
alter table public.corrections add column if not exists note       real;
alter table public.corrections add column if not exists note_count integer;

create index if not exists corrections_book_id_idx on public.corrections (book_id);

alter table public.corrections enable row level security;

-- Tout le monde peut LIRE les corrections
drop policy if exists "lecture publique" on public.corrections;
create policy "lecture publique"
  on public.corrections for select
  to anon
  using (true);

-- Tout le monde peut AJOUTER une correction/validation
-- (titre obligatoire 1..300 car., auteur <= 300 car., nom <= 60 car.)
drop policy if exists "ajout public" on public.corrections;
create policy "ajout public"
  on public.corrections for insert
  to anon
  with check (
    char_length(coalesce(titre,'')) between 1 and 300
    and char_length(coalesce(auteur,'')) <= 300
    and char_length(coalesce(nom,'')) <= 60
    and char_length(coalesce(cover_url,'')) <= 1000
    and char_length(coalesce(editeur,'')) <= 200
    and char_length(coalesce(resume,'')) <= 4000
  );

-- (Volontairement : pas de policy UPDATE/DELETE pour anon. L'historique est en "ajout seul" ;
--  la dernière correction d'un livre fait foi. Pour purger une correction erronée,
--  faites-le depuis le Table Editor de Supabase.)

# Club Livre de la tribu du 47 — guide d'utilisation

L'application est un site statique composé de **plusieurs fichiers/dossiers — à déployer ensemble** :

- **`index.html`** — la bibliothèque (l'application).
- **`data/books.json`** — la liste des 186 livres (chargée par `index.html`). **Indispensable.**
- **`photos/`** — les 32 photos d'étagères (pour la vérification des fiches « à vérifier »). **Indispensable.**
- **`backend-commentaires.sql`** — à coller dans Supabase, pour les commentaires partagés.
- **`backend-corrections.sql`** — à coller dans Supabase, pour les **corrections/validations partagées** des fiches « à vérifier ».
- **`backend-boxes.sql`** — à coller dans Supabase, pour les **cadres partagés** (rectangles qui repèrent la tranche d'un livre sur sa photo).
- **`backend-livres.sql`** — à coller dans Supabase, pour les **livres de la communauté** : chaque membre gère ses propres livres (table `livres`, avec disponibilité « à emprunter / à donner / à vendre », prix, localisation) **et** le stockage des photos (bucket `livres-photos`).
- **`GUIDE-MISE-EN-LIGNE.md`** — ce guide.

> ⚠️ Depuis cette version, les livres sont dans `data/books.json` (et non plus dans `index.html`).
> Il faut donc **toujours** déployer `index.html` **avec** les dossiers `data/` et `photos/`.

---

## 1. Essayer tout de suite (sur votre ordinateur)

Le plus simple est d'ouvrir le **lien en ligne** (voir étape 2). Pour tester en local, un simple
double-clic **ne suffit plus** (le navigateur bloque le chargement de `data/books.json` en `file://`).
Lancez un petit serveur depuis le dossier du projet :

```bash
cd <dossier-du-projet>
python3 -m http.server 8000
# puis ouvrez http://localhost:8000 dans le navigateur
```

> À ce stade, commentaires et corrections sont **locaux** (dans votre navigateur) tant que Supabase
> n'est pas configuré. Pour les partager, faites les étapes 2 et 3.

---

## 2. Mettre la bibliothèque en ligne (pour faire tourner le lien)

Le site actuel est publié sur **GitHub Pages** : https://offyvn.github.io/BibliHaudri/

Pour mettre à jour, poussez/déposez sur le dépôt `OffyVN/BibliHaudri` **l'ensemble** :
`index.html`, le dossier **`data/`** et le dossier **`photos/`** (sans ces deux dossiers, la liste
des livres et les photos de vérification ne s'afficheront pas).

> Variantes équivalentes : Netlify Drop, Cloudflare Pages, Vercel… N'importe quel hébergement de
> fichiers statiques convient, à condition d'y déposer **index.html + data/ + photos/** ensemble.

---

## 3. Activer les commentaires PARTAGÉS (visibles par tout le monde)

On utilise **Supabase** (gratuit). Comptez ~5 minutes, une seule fois.

### a. Créer le projet
1. Allez sur **https://supabase.com** → *Start your project* → connectez-vous (GitHub ou e-mail).
2. *New project* : donnez un nom (ex. `biblio-thanh`), choisissez une région (Europe),
   définissez un mot de passe de base de données (gardez-le, peu importe lequel).
3. Attendez ~1 minute que le projet soit prêt.

### b. Créer les tables (commentaires + corrections)
1. Dans le menu de gauche, ouvrez **SQL Editor** → *New query*.
2. Ouvrez le fichier **`backend-commentaires.sql`**, copiez **tout** son contenu, collez-le, puis
   cliquez **Run**. Vous devez voir « Success ». (table `interets`, pour les intérêts)
3. *New query* à nouveau, puis faites de même avec **`backend-corrections.sql`** → **Run**.
   (table `corrections`, pour les **validations / corrections** des fiches « à vérifier »)
4. *New query* encore une fois, puis **`backend-boxes.sql`** → **Run**.
   (table `boxes`, pour les **cadres** dessinés sur les photos qui repèrent la tranche d'un livre)
5. *New query* une dernière fois, puis **`backend-livres.sql`** → **Run**.
   (table `livres` + bucket de photos `livres-photos` — les livres que chaque membre ajoute,
   avec leur disponibilité, prix, localisation et photo)

> **Photos.** Le fichier `backend-livres.sql` tente aussi de créer le bucket de stockage
> **`livres-photos`** (public). Si l'éditeur SQL refuse cette partie (droits sur le schéma
> `storage`), créez le bucket à la main : Supabase → **Storage** → **New bucket** → nom
> `livres-photos`, cochez **Public bucket** ; puis ré-exécutez seulement les deux `create policy`
> de la fin du fichier. Sans ce bucket, l'appli reste utilisable mais l'envoi d'une photo
> échouera (on peut alors coller une URL d'image à la place).

> Sans la table `livres`, l'appli reste utilisable mais l'ajout d'un livre via « ➕ Ajouter un livre »
> affichera une erreur (la bibliothèque d'origine de Thanh Nghiem reste consultable).
>
> Sans la table `corrections`, l'appli reste utilisable mais le bouton « ✓ Valider la fiche »
> affichera une erreur (les validations ne pourront pas être enregistrées en ligne).
> De même, sans la table `boxes`, le bouton « ✏️ Encadrer ce livre » affichera une erreur.

### c. Récupérer les 2 clés
1. Menu de gauche → **Project Settings** (la roue dentée) → **API**.
2. Copiez :
   - **Project URL** (ex. `https://abcdwxyz.supabase.co`)
   - **anon public** (une longue clé) — c'est bien la clé *anon*, **pas** la *service_role*.

### d. Les coller dans l'application
1. Ouvrez **`index.html`** avec un éditeur de texte (Bloc-notes, TextEdit, VS Code…).
2. Tout en haut du `<script>`, repérez ces deux lignes et complétez-les entre les guillemets :
   ```js
   const SUPABASE_URL = "https://abcdwxyz.supabase.co";
   const SUPABASE_ANON_KEY = "collez-ici-la-cle-anon-public";
   ```
3. Enregistrez le fichier.
4. Re-déposez `index.html` sur Netlify (étape 2). Le bandeau en haut de la page passera au vert :
   **« Commentaires partagés activés »**.

C'est tout. Désormais, chaque personne qui ouvre le lien voit les intérêts laissés par les autres,
et peut ajouter le sien — sans login.

---

## Questions fréquentes

**La clé « anon » est-elle un risque ?**
Non, elle est conçue pour être publique (côté navigateur). Les règles de sécurité posées par le
fichier SQL n'autorisent que **lire** et **ajouter** un commentaire — impossible d'effacer ou de
modifier les commentaires des autres depuis le site.

**Quelqu'un peut-il modérer / supprimer un commentaire ou une correction ?**
Oui, vous. Dans Supabase → **Table Editor** → table `interets` (commentaires) ou `corrections`
(validations), vous voyez toutes les lignes et pouvez en supprimer. Pour les corrections, c'est la
**ligne la plus récente** d'un livre qui fait foi.

**Comment mettre à jour la liste des livres plus tard ?**
La bibliothèque d'origine est dans **`data/books.json`** (un livre = un objet avec `title`, `author`,
`summary`…). On peut l'éditer directement, ou me le demander. Pensez à redéployer `data/books.json`
ensuite. Les livres ajoutés depuis le site (listes personnelles) vivent dans la table Supabase
`livres`, pas dans ce fichier.

**Comment plusieurs personnes peuvent-elles gérer leur propre liste ?**
En haut de la page, cliquez **« Gérer ma liste de livres »** et indiquez votre nom (mémorisé dans
ce navigateur, sans création de compte). Vous pouvez alors **➕ ajouter** des livres, et **modifier
/ supprimer** ceux de votre liste depuis leur fiche. Le sélecteur **« bibliothèque »** de la barre
d'outils permet de filtrer par personne (ou « ⭐ Ma liste »). La bibliothèque d'origine reste celle
de **Thanh Nghiem**.

**Comment « numériser » un livre en prenant une photo ?**
Cliquez **« ➕ Ajouter un livre »**, puis **« 📷 Photo du livre »** : sur téléphone, l'appareil photo
s'ouvre directement. La photo devient l'illustration du livre. Cliquez ensuite
**« ✨ Lire le titre sur la photo »** : l'application lit le texte de la couverture (OCR, dans le
navigateur) et propose un titre — corrigez-le si besoin. La lecture automatique n'est jamais
parfaite : vous pouvez toujours tout saisir/ajuster à la main.

**Comment indiquer qu'un livre est à emprunter / à donner / à vendre, et où le trouver ?**
Dans la fiche d'ajout/modification, choisissez la **Disponibilité** (à emprunter, à donner, à vendre —
avec un **prix** dans ce dernier cas) et renseignez **« Où le trouver »** en texte libre
(ex. « Étagère entrée du 47 », « Chez Duc »). La disponibilité apparaît en pastille sur la carte et
dans la fiche ; la barre d'outils permet de **filtrer par disponibilité**, et la recherche couvre
aussi la localisation.

> Note : les 186 livres d'origine de Thanh Nghiem n'ont pas de disponibilité/localisation (c'est la
> collection existante). Ces informations concernent les livres ajoutés par la communauté.

> Modèle de confiance : comme pour les commentaires, il n'y a **pas d'authentification** côté serveur.
> L'application ne propose la modification/suppression que sur *vos* livres (ceux à votre nom), mais
> techniquement un visiteur averti pourrait agir sous un autre nom. Pour un verrouillage strict
> (vrais comptes), il faudrait passer à **Supabase Auth** — me le demander.

**Un badge « à vérifier » apparaît sur certains livres — comment le faire disparaître ?**
Le titre/auteur a été lu automatiquement sur une photo et peut comporter une erreur. Ouvrez la
fiche : sous les **photos d'origine**, le bloc « Vérifier cette fiche » permet de corriger le
titre/auteur si besoin puis de cliquer **« ✓ Valider la fiche »**. Le badge disparaît alors pour
tout le monde (validation enregistrée dans la table `corrections`).

**Comment « encadrer » la tranche d'un livre sur la photo (pour aider à le repérer) ?**
Ouvrez la fiche puis **cliquez une photo** pour l'agrandir. En haut à gauche, cliquez
**« ✏️ Encadrer ce livre »**, puis **glissez** (doigt ou souris) pour entourer la tranche du livre,
et **« Enregistrer le cadre »**. Ensuite, à chaque ouverture de cette fiche, la photo s'ouvre avec
la tranche mise en évidence (effet « projecteur »). Le cadre est partagé avec tout le monde
(enregistré dans la table `boxes` ; le dernier cadre dessiné fait foi). Quelques livres sont déjà
pré-encadrés.

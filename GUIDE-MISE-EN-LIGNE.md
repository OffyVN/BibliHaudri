# Bibliothèque de Thanh Nghiem — guide d'utilisation

Vous avez trois fichiers :

- **`index.html`** — la bibliothèque (l'application). C'est le seul fichier à mettre en ligne.
- **`GUIDE-MISE-EN-LIGNE.md`** — ce guide.
- **`backend-commentaires.sql`** — à copier-coller dans Supabase (étape 3), pour les commentaires partagés.

---

## 1. Essayer tout de suite (sur votre ordinateur)

Double-cliquez sur **`index.html`** : il s'ouvre dans votre navigateur. Vous pouvez parcourir,
chercher, filtrer, ouvrir une fiche et laisser un commentaire.

> À ce stade les commentaires sont **locaux** : ils restent dans **votre** navigateur et ne sont
> pas vus par les autres. Pour les partager, faites les étapes 2 et 3.

---

## 2. Mettre la bibliothèque en ligne (pour faire tourner le lien)

Le plus simple, gratuit et sans compte technique : **Netlify Drop**.

1. Allez sur **https://app.netlify.com/drop**
2. Glissez-déposez le fichier **`index.html`** dans la zone indiquée.
3. Netlify vous donne aussitôt une **adresse publique** (ex. `https://joli-nom-123.netlify.app`).
   C'est le lien que vous faites circuler.
4. (Conseillé) Créez un compte gratuit Netlify pour que le lien reste permanent et que vous
   puissiez redéposer une version mise à jour.

> Variantes possibles : GitHub Pages, Cloudflare Pages, Vercel, ou tout hébergement de fichier
> statique. N'importe lequel fait l'affaire — il n'y a qu'un fichier HTML.

---

## 3. Activer les commentaires PARTAGÉS (visibles par tout le monde)

On utilise **Supabase** (gratuit). Comptez ~5 minutes, une seule fois.

### a. Créer le projet
1. Allez sur **https://supabase.com** → *Start your project* → connectez-vous (GitHub ou e-mail).
2. *New project* : donnez un nom (ex. `biblio-thanh`), choisissez une région (Europe),
   définissez un mot de passe de base de données (gardez-le, peu importe lequel).
3. Attendez ~1 minute que le projet soit prêt.

### b. Créer la table des commentaires
1. Dans le menu de gauche, ouvrez **SQL Editor** → *New query*.
2. Ouvrez le fichier **`backend-commentaires.sql`**, copiez **tout** son contenu, collez-le, puis
   cliquez **Run**. Vous devez voir « Success ».

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

**Quelqu'un peut-il modérer / supprimer un commentaire ?**
Oui, vous. Dans Supabase → **Table Editor** → table `interets`, vous voyez tous les messages et
pouvez en supprimer.

**Comment mettre à jour la liste des livres plus tard ?**
La liste est intégrée dans `index.html`. Dites-le moi et je régénère le fichier ; vous n'aurez qu'à
le redéposer sur Netlify.

**Un badge « à vérifier » apparaît sur certains livres.**
Le titre/auteur a été lu automatiquement sur la photo et peut comporter une petite erreur. Signalez
-les moi et je corrige.

# Supabase account and progress backend setup

Bloompath uses Supabase Auth for email/password accounts and Postgres for account-scoped progress. The browser uses only a Supabase **publishable** key. The migration enforces row-level security (RLS): each account can read and change only its own progress. Never use a secret/service-role key in browser code or GitHub.

## 1. Create and configure a Supabase project

1. Sign in to Supabase and create a project. Choose the free plan if it suits your use; review current limits and region choices before confirming.
2. In **SQL Editor**, run the complete file `supabase/migrations/20261101000000_bloompath_accounts.sql`.
3. In **Project Settings → API Keys** (or the project **Connect** dialog), copy the project URL and the `sb_publishable_...` key. Do not copy a secret key.
4. Put the public values in `supabase-config.js`:

   ```js
   window.BLOOMPATH_SUPABASE = {
     url: 'https://YOUR_PROJECT_REF.supabase.co',
     publishableKey: 'sb_publishable_...'
   };
   ```

5. In **Authentication → URL Configuration**, set Site URL to `https://bloompath.runs-on.dev` after it is live. Add allowed redirect URLs for the live origin and local development:
   - `https://bloompath.runs-on.dev/**`
   - `http://localhost:5500/**`
   - `http://127.0.0.1:5500/**`
6. Ensure `public` is enabled for the Supabase Data API. The SQL grants and RLS policies are required even though the publishable key is public.

## 2. Run in VS Code

Open this folder in VS Code and serve `index.html` using Live Server. Use an HTTP URL such as `http://127.0.0.1:5500/`; direct `file://` pages cannot reliably use Auth redirects. Guest mode remains available without Supabase. If guest progress exists, the app asks before moving it into a newly signed-in account.

## 3. Create the owner account and enable admin tools

1. Open the site's **Account** page and create your account. Verify your email if Supabase requires it.
2. In Supabase SQL Editor, find your UUID by your own email:

   ```sql
   select id, email from auth.users where email = 'YOUR_EMAIL';
   ```

3. Add only your UUID to the owner allowlist:

   ```sql
   insert into public.bloompath_admins (user_id)
   values ('YOUR_USER_UUID')
   on conflict (user_id) do nothing;
   ```

4. Sign out and back in. The **Admin** page shows registered account emails, profile name/role, roadmap/skill counts, and last save time. It can export progress JSON and reset a user's saved progress. It cannot read passwords or secret keys.

Do not add a browser-accessible policy for writing the admin table. Admin membership must be managed from trusted SQL Editor only.

## 4. User data behavior

- One JSONB progress record is stored per Supabase Auth user ID. RLS prevents accounts from reading or changing another user's progress.
- Guest progress remains in the current browser. Signed-in changes sync after a short delay. If the network fails, local changes remain saved and the site shows a sync warning.
- The allowlisted site owner can view emails and saved progress, reminders, and resume details. This is disclosed on the Account page. Passwords are handled by Supabase Auth.
- Reminders sync as data, but notifications require the site open and permission on that device.

## 5. GitHub Pages and runs-on.dev

For `bloompath.runs-on.dev`, enable GitHub Pages and add a root-level `CNAME` file containing exactly `bloompath.runs-on.dev`. Claim `bloompath` on runs-on.dev and set its CNAME target to `Anurag-Singh19.github.io`. Add the live URL to Supabase Auth's allowed redirects and enable Enforce HTTPS when GitHub Pages offers it.

GitHub Pages serves only frontend files. Supabase hosts user accounts and progress. The URL and publishable key are public by design; RLS protects account records.
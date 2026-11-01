# Frontend deployment

GitHub Pages serves Bloompath's static files. Supabase provides authentication and the database; runs-on.dev provides the custom subdomain.

1. Configure `supabase-config.js` with the public Supabase URL and publishable key, and run the SQL migration described in `SETUP.md`.
2. Add a root `CNAME` file containing exactly `bloompath.runs-on.dev`.
3. Push the project to `Anurag-Singh19/bloompath-learning-studio` and enable GitHub Pages from `main` / root.
4. Claim `bloompath` at runs-on.dev and add the CNAME record `Anurag-Singh19.github.io`.
5. Add `https://bloompath.runs-on.dev/**` to Supabase Auth allowed redirect URLs. Enable Enforce HTTPS when GitHub Pages offers it.
6. Create your account, then add your Supabase Auth UUID to `bloompath_admins` as documented in `SETUP.md`.

The live website is public. The frontend uses a publishable key and the SQL migration protects user rows with RLS. No secret/service-role key belongs in this repository.
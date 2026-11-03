# Food to Go

Simple Flutter sign-in and account creation for USJ-R email addresses, backed
by Supabase Auth.

## Configure Supabase

1. Create or open your Supabase project.
2. In the project dashboard, copy the project URL and the publishable key (or
   legacy anon key).
3. Run the app with those values:

   ```powershell
   flutter run --dart-define=SUPABASE_URL=https://YOUR_PROJECT.supabase.co --dart-define=SUPABASE_PUBLISHABLE_KEY=YOUR_PUBLISHABLE_KEY
   ```

   The Supabase URL and publishable key are client configuration values. Never
   put a Supabase service-role key in the app. For legacy projects, you can
   provide the anon key as `SUPABASE_PUBLISHABLE_KEY`.

4. To restrict account creation on the server as well as in the app, run
   [`supabase/allow_usjr_email.sql`](supabase/allow_usjr_email.sql) in the
   Supabase SQL Editor. Then open **Authentication → Hooks**, add a
   **Before User Created** hook, and select
   `public.allow_usjr_email`.
5. In **Authentication → Providers → Email**, enable email confirmations if
   you want users to verify that they can access their USJ-R inbox.

The app checks the email domain for both sign-up and sign-in. The database
hook rejects non-USJ-R addresses on the server during account creation too.

## Account types

Account creation lets a user choose **Regular** (for students and professors)
or **Food stall**. After login, the app opens the matching dashboard.
**Admin** accounts are assigned by the developer and cannot be selected at
public sign-up.

When creating an account, the selected type is saved as Supabase user metadata:

- Regular: `{"account_type":"regular"}`
- Food stall: `{"account_type":"foodstall"}`

For admins, set the user's **app metadata** in the Supabase dashboard to
`{"account_type":"admin"}`. This is separate from user metadata, which users
can change. Enforce data access with Supabase Row Level Security policies;
client-side role selection is for directing users to the appropriate screen,
not for granting secure access.

## Regular-user dashboard

The regular dashboard displays an available-stalls list. It currently shows an
empty state until food stall listings are connected to a backend. The food-stall
dashboard has a placeholder for incoming orders.

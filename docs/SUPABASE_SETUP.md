# Supabase Setup Guide

## Step 1: Create Supabase Project

1. Go to [supabase.com](https://supabase.com)
2. Sign up or login
3. Click **"New Project"**
4. Fill in:
   - **Name**: `currency-exchange`
   - **Database Password**: Create a strong password (SAVE THIS!)
   - **Region**: Choose closest to your location
5. Click **"Create new project"**
6. Wait 2-3 minutes for setup to complete

## Step 2: Run Database Schema

1. In your Supabase dashboard, go to **SQL Editor** (left sidebar)
2. Click **"New Query"**
3. Open the file `backend/src/database/supabase-schema.sql`
4. Copy ALL the content
5. Paste it into the Supabase SQL Editor
6. Click **"Run"** (or press Ctrl/Cmd + Enter)
7. You should see "Success. No rows returned"

## Step 3: Get Your Credentials

In your Supabase dashboard:

1. Go to **Settings** → **API** (left sidebar)
2. Copy these values:

   - **Project URL**: `https://xxxxx.supabase.co`
   - **anon public key**: `eyJhbGc...` (long string)
   - **service_role key**: `eyJhbGc...` (long string, keep secret!)

3. Go to **Settings** → **Database**
4. Scroll down to **Connection string** → **URI**
5. Copy the connection string (it looks like):
   ```
   postgresql://postgres:[YOUR-PASSWORD]@db.xxxxx.supabase.co:5432/postgres
   ```
6. Replace `[YOUR-PASSWORD]` with your actual database password

## Step 4: Configure Backend

1. Copy the example env file:
   ```bash
   cd backend
   cp .env.example .env
   ```

2. Edit `backend/.env` and add your Supabase credentials:
   ```env
   SUPABASE_URL=https://xxxxx.supabase.co
   SUPABASE_ANON_KEY=eyJhbGc...your-anon-key
   SUPABASE_SERVICE_KEY=eyJhbGc...your-service-key
   DB_CONNECTION_STRING=postgresql://postgres:your-password@db.xxxxx.supabase.co:5432/postgres
   ```

## Step 5: Set Up Storage (for file uploads)

1. In Supabase dashboard, go to **Storage** (left sidebar)
2. Click **"Create a new bucket"**
3. Name it: `exchange-proofs`
4. Make it **Public** (so users can upload payment proofs)
5. Click **"Create bucket"**

### Set Storage Policies:

1. Click on the `exchange-proofs` bucket
2. Go to **Policies** tab
3. Click **"New Policy"**
4. Choose **"For full customization"**
5. Add these policies:

**Upload Policy:**
```sql
CREATE POLICY "Allow authenticated uploads"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (bucket_id = 'exchange-proofs');
```

**Read Policy:**
```sql
CREATE POLICY "Allow public reads"
ON storage.objects FOR SELECT
TO public
USING (bucket_id = 'exchange-proofs');
```

## Step 6: Test Connection

```bash
cd backend
npm install
npm run dev
```

You should see:
```
✅ Database connected to Supabase
Server running on port 3000
```

## Step 7: Verify Tables

In Supabase dashboard:
1. Go to **Table Editor** (left sidebar)
2. You should see all tables:
   - users
   - bank_cards
   - transactions
   - wallet_transactions
   - exchange_rates
   - payment_instructions
   - chat_messages
   - notifications

## Troubleshooting

**Connection Error:**
- Double-check your connection string
- Make sure you replaced `[YOUR-PASSWORD]` with actual password
- Check if your IP is allowed (Supabase allows all by default)

**Tables not showing:**
- Re-run the schema SQL in SQL Editor
- Check for any error messages

**Upload errors:**
- Make sure storage bucket is created
- Check storage policies are set correctly

## Benefits of Supabase

✅ No local PostgreSQL installation needed
✅ Automatic backups
✅ Built-in authentication (can use later)
✅ Real-time subscriptions
✅ File storage included
✅ Free tier: 500MB database, 1GB storage
✅ Dashboard to view/edit data easily

## Next Steps

Once connected, you can:
1. Start the backend: `npm run dev`
2. Test with the demo app: Open `demo-app.html` in browser
3. Or run the Flutter app: `cd flutter_app && flutter run`

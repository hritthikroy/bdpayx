# ⚡ Vercel Quick Start (5 Minutes)

## 🎯 What You Need

1. **Supabase Account** (FREE) - [supabase.com](https://supabase.com)
2. **Vercel Account** (FREE) - [vercel.com](https://vercel.com)
3. **GitHub Account** (FREE) - [github.com](https://github.com)

---

## 🚀 Deploy in 5 Steps

### Step 1: Setup Supabase (2 minutes)

```bash
1. Go to supabase.com → "New Project"
2. Name: bdpayx
3. Database Password: (save this!)
4. Region: (closest to you)
5. Click "Create Project"
```

**Get your credentials:**
- Settings → API → Copy these:
  - `Project URL`
  - `anon public key`
  - `service_role key`

**Create storage bucket:**
- Storage → New Bucket → Name: `exchange-proofs` → Public: YES

**Enable Realtime:**
- Database → Replication → Enable for `chat_messages`

### Step 2: Push to GitHub (1 minute)

```bash
git init
git add .
git commit -m "Ready for Vercel"
git remote add origin https://github.com/YOUR_USERNAME/bdpayx.git
git push -u origin main
```

### Step 3: Deploy Backend (1 minute)

1. Go to [vercel.com/new](https://vercel.com/new)
2. Import your GitHub repo
3. **Root Directory**: `backend`
4. Add these environment variables:

```
SUPABASE_URL=https://xxxxx.supabase.co
SUPABASE_ANON_KEY=eyJhbGc...
SUPABASE_SERVICE_KEY=eyJhbGc...
DB_CONNECTION_STRING=postgresql://postgres:PASSWORD@db.xxxxx.supabase.co:5432/postgres
JWT_SECRET=your-random-secret-key-min-32-chars
GOOGLE_CLIENT_ID=your-google-client-id
GOOGLE_CLIENT_SECRET=your-google-secret
NODE_ENV=production
```

5. Click **Deploy**
6. Copy your backend URL: `https://your-project.vercel.app`

### Step 4: Update Flutter Config (30 seconds)

Edit `flutter_app/lib/config/api_config.dart`:
```dart
static const String baseUrl = 'https://your-backend.vercel.app/api';
```

Edit `flutter_app/lib/config/supabase_config.dart`:
```dart
static const String supabaseUrl = 'https://xxxxx.supabase.co';
static const String supabaseAnonKey = 'eyJhbGc...';
```

### Step 5: Deploy Frontend (30 seconds)

```bash
cd flutter_app
flutter build web --release
cd ..
git add .
git commit -m "Update API config"
git push
```

**Deploy to Vercel:**
1. New Project → Import same repo
2. **Root Directory**: `flutter_app`
3. **Build Command**: `flutter build web`
4. **Output Directory**: `build/web`
5. Add environment variables:
```
SUPABASE_URL=https://xxxxx.supabase.co
SUPABASE_ANON_KEY=eyJhbGc...
```
6. Click **Deploy**

---

## ✅ Done!

Your app is now live at:
- **Backend**: `https://your-backend.vercel.app`
- **Frontend**: `https://your-frontend.vercel.app`

---

## 🧪 Test It

```bash
# Test backend
curl https://your-backend.vercel.app/api/health

# Test frontend
Open https://your-frontend.vercel.app in browser
```

---

## 💰 Cost

**Total: $0/month** (100% FREE)

- Vercel: FREE tier
- Supabase: FREE tier
- GitHub: FREE

---

## 🆘 Issues?

### Backend not working?
- Check Vercel logs
- Verify environment variables
- Check Supabase connection string

### Frontend not loading?
- Check API config has correct backend URL
- Check Supabase credentials
- Rebuild Flutter web

### Chat not working?
- Enable Realtime in Supabase
- Check `chat_messages` table exists
- Verify Supabase credentials in Flutter

---

## 📚 Full Guide

For detailed instructions, see: `VERCEL_DEPLOYMENT_GUIDE.md`

---

**🎉 Your app is live and FREE!**

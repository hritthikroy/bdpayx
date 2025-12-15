# 🚀 Vercel Deployment Guide

## ✅ What's Been Changed

### Backend Changes:
1. ✅ **Removed Socket.io** → Replaced with Supabase Realtime
2. ✅ **File uploads** → Now use Supabase Storage (not local disk)
3. ✅ **Serverless compatible** → Created `backend/src/index.js` for Vercel
4. ✅ **Memory storage** → Multer uses memory instead of disk

### Flutter Changes:
1. ✅ **Added Supabase Flutter** → For realtime chat
2. ✅ **Updated chat screen** → Uses Supabase Realtime instead of Socket.io
3. ✅ **Supabase config** → Created `flutter_app/lib/config/supabase_config.dart`

---

## 📋 Prerequisites

### 1. Supabase Setup (FREE)

**Create Supabase Project:**
1. Go to [supabase.com](https://supabase.com)
2. Click "Start your project"
3. Create new project (choose region close to your users)
4. Wait 2-3 minutes for setup

**Get Credentials:**
```
Project Settings → API
- Project URL: https://xxxxx.supabase.co
- anon/public key: eyJhbGc...
- service_role key: eyJhbGc... (keep secret!)
```

**Create Storage Bucket:**
1. Go to Storage in Supabase dashboard
2. Create new bucket: `exchange-proofs`
3. Make it **public** (for deposit proof images)
4. Set policies:
   - Allow authenticated users to upload
   - Allow public read access

**Enable Realtime:**
1. Go to Database → Replication
2. Enable realtime for `chat_messages` table
3. Enable realtime for `notifications` table

### 2. Vercel Account (FREE)

1. Go to [vercel.com](https://vercel.com)
2. Sign up with GitHub (recommended)
3. No credit card required

---

## 🚀 Deployment Steps

### Step 1: Push Code to GitHub

```bash
# Initialize git (if not already)
git init
git add .
git commit -m "Vercel deployment ready"

# Create GitHub repo and push
git remote add origin https://github.com/yourusername/bdpayx.git
git branch -M main
git push -u origin main
```

### Step 2: Deploy Backend to Vercel

1. Go to [vercel.com/new](https://vercel.com/new)
2. Import your GitHub repository
3. Configure project:
   - **Framework Preset**: Other
   - **Root Directory**: `backend`
   - **Build Command**: (leave empty)
   - **Output Directory**: (leave empty)

4. Add Environment Variables (click "Environment Variables"):
   ```
   SUPABASE_URL=https://your-project.supabase.co
   SUPABASE_ANON_KEY=eyJhbGc...
   SUPABASE_SERVICE_KEY=eyJhbGc...
   DB_CONNECTION_STRING=postgresql://postgres:...
   JWT_SECRET=your-secret-key-here
   GOOGLE_CLIENT_ID=your-client-id
   GOOGLE_CLIENT_SECRET=your-client-secret
   NODE_ENV=production
   ```

5. Click "Deploy"
6. Wait 1-2 minutes
7. Your backend will be live at: `https://your-project.vercel.app`

### Step 3: Build Flutter Web

```bash
cd flutter_app
flutter build web --release
```

### Step 4: Deploy Flutter Web to Vercel

**Option A: Same Vercel Project (Recommended)**
1. In Vercel dashboard, go to your project
2. Settings → General → Root Directory
3. Change to: `/` (root)
4. Settings → Build & Development
   - Build Command: `cd flutter_app && flutter build web`
   - Output Directory: `flutter_app/build/web`
5. Redeploy

**Option B: Separate Vercel Project**
1. Create new Vercel project
2. Import same GitHub repo
3. Root Directory: `flutter_app`
4. Build Command: `flutter build web`
5. Output Directory: `build/web`
6. Add environment variables:
   ```
   SUPABASE_URL=https://your-project.supabase.co
   SUPABASE_ANON_KEY=eyJhbGc...
   ```

### Step 5: Update Flutter API Config

Update `flutter_app/lib/config/api_config.dart`:
```dart
class ApiConfig {
  static const String baseUrl = 'https://your-backend.vercel.app/api';
  // ... rest of config
}
```

Update `flutter_app/lib/config/supabase_config.dart`:
```dart
static const String supabaseUrl = 'https://your-project.supabase.co';
static const String supabaseAnonKey = 'your-anon-key';
```

### Step 6: Rebuild and Redeploy

```bash
cd flutter_app
flutter build web --release
git add .
git commit -m "Update API endpoints"
git push
```

Vercel will auto-deploy!

---

## 🧪 Testing Your Deployment

### Test Backend:
```bash
# Health check
curl https://your-backend.vercel.app/api/health

# Test login
curl -X POST https://your-backend.vercel.app/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"phone":"+8801234567890","password":"test123"}'
```

### Test Frontend:
1. Open `https://your-frontend.vercel.app`
2. Try Google login
3. Test exchange rate display
4. Test chat (should use Supabase Realtime)

---

## 💰 Cost Breakdown

### Vercel (FREE Tier):
- ✅ 100 GB bandwidth/month
- ✅ Unlimited deployments
- ✅ Serverless functions
- **Cost: $0/month**

### Supabase (FREE Tier):
- ✅ 500 MB database
- ✅ 1 GB file storage
- ✅ 2 GB bandwidth
- ✅ Unlimited realtime connections
- **Cost: $0/month**

### Total: **$0/month** 🎉

---

## 🔧 Troubleshooting

### Issue: "Module not found"
**Solution:** Make sure all dependencies are in `package.json`:
```bash
cd backend
npm install
```

### Issue: "Supabase connection failed"
**Solution:** Check environment variables in Vercel dashboard

### Issue: "File upload fails"
**Solution:** 
1. Check Supabase Storage bucket exists
2. Verify bucket is public
3. Check storage policies

### Issue: "Chat not working"
**Solution:**
1. Enable Realtime in Supabase for `chat_messages` table
2. Check Supabase credentials in Flutter app
3. Rebuild Flutter web

### Issue: "CORS errors"
**Solution:** Add your Vercel domain to Supabase allowed origins:
- Supabase Dashboard → Settings → API → CORS

---

## 📊 Monitoring

### Vercel Dashboard:
- View deployment logs
- Monitor function execution
- Check bandwidth usage

### Supabase Dashboard:
- Database queries
- Storage usage
- Realtime connections
- API requests

---

## 🎯 Next Steps

### After Successful Deployment:

1. **Custom Domain** (Optional - $12/year):
   - Buy domain from Namecheap/GoDaddy
   - Add to Vercel project
   - Update Flutter API config

2. **Enable Analytics**:
   - Vercel Analytics (free)
   - Google Analytics

3. **Set up Monitoring**:
   - Sentry for error tracking
   - Vercel monitoring

4. **Optimize Performance**:
   - Enable Vercel Edge Network
   - Optimize Flutter web build

---

## 🆘 Need Help?

**Common Issues:**
- Check Vercel deployment logs
- Check Supabase logs
- Check browser console for errors

**Resources:**
- [Vercel Docs](https://vercel.com/docs)
- [Supabase Docs](https://supabase.com/docs)
- [Flutter Web Docs](https://docs.flutter.dev/platform-integration/web)

---

## ✅ Deployment Checklist

- [ ] Supabase project created
- [ ] Storage bucket created and configured
- [ ] Realtime enabled for chat_messages
- [ ] GitHub repository created
- [ ] Code pushed to GitHub
- [ ] Backend deployed to Vercel
- [ ] Environment variables added
- [ ] Flutter web built
- [ ] Frontend deployed to Vercel
- [ ] API endpoints updated in Flutter
- [ ] Tested login functionality
- [ ] Tested file uploads
- [ ] Tested chat functionality
- [ ] Tested exchange rates

---

**🎉 Congratulations! Your app is now live on Vercel!**

Your app is now:
- ✅ Globally distributed
- ✅ Auto-scaling
- ✅ Free to host
- ✅ Production-ready

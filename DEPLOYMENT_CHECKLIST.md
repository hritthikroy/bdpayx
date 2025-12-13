# ✅ Deployment Checklist

## 📋 Pre-Deployment

### Supabase Setup
- [ ] Create Supabase account at [supabase.com](https://supabase.com)
- [ ] Create new project
- [ ] Save database password
- [ ] Copy Project URL
- [ ] Copy anon/public key
- [ ] Copy service_role key
- [ ] Create storage bucket: `exchange-proofs`
- [ ] Make bucket public
- [ ] Set storage policies (authenticated upload, public read)
- [ ] Enable Realtime for `chat_messages` table
- [ ] Enable Realtime for `notifications` table
- [ ] Run database schema from `backend/src/database/supabase-schema.sql`

### GitHub Setup
- [ ] Create GitHub account (if needed)
- [ ] Create new repository
- [ ] Initialize git in project: `git init`
- [ ] Add remote: `git remote add origin <url>`
- [ ] Commit all changes: `git add . && git commit -m "Initial commit"`
- [ ] Push to GitHub: `git push -u origin main`

### Vercel Setup
- [ ] Create Vercel account at [vercel.com](https://vercel.com)
- [ ] Connect GitHub account
- [ ] Verify email

### Google OAuth Setup
- [ ] Go to [Google Cloud Console](https://console.cloud.google.com)
- [ ] Create new project or select existing
- [ ] Enable Google+ API
- [ ] Create OAuth 2.0 credentials
- [ ] Add authorized origins (Vercel domains)
- [ ] Copy Client ID
- [ ] Copy Client Secret

---

## 🚀 Backend Deployment

### Vercel Backend Setup
- [ ] Go to [vercel.com/new](https://vercel.com/new)
- [ ] Import GitHub repository
- [ ] Set Root Directory: `backend`
- [ ] Framework Preset: Other
- [ ] Build Command: (leave empty)
- [ ] Output Directory: (leave empty)

### Environment Variables
Add these in Vercel dashboard:
- [ ] `SUPABASE_URL` = https://xxxxx.supabase.co
- [ ] `SUPABASE_ANON_KEY` = eyJhbGc...
- [ ] `SUPABASE_SERVICE_KEY` = eyJhbGc...
- [ ] `DB_CONNECTION_STRING` = postgresql://postgres:...
- [ ] `JWT_SECRET` = (generate random 32+ char string)
- [ ] `GOOGLE_CLIENT_ID` = your-client-id.apps.googleusercontent.com
- [ ] `GOOGLE_CLIENT_SECRET` = GOCSPX-...
- [ ] `NODE_ENV` = production

### Deploy
- [ ] Click "Deploy" button
- [ ] Wait for deployment (1-2 minutes)
- [ ] Copy backend URL: `https://your-project.vercel.app`
- [ ] Test health endpoint: `curl https://your-project.vercel.app/api/health`

---

## 🎨 Frontend Deployment

### Update Flutter Config
- [ ] Edit `flutter_app/lib/config/api_config.dart`
- [ ] Update `baseUrl` to your Vercel backend URL
- [ ] Edit `flutter_app/lib/config/supabase_config.dart`
- [ ] Update `supabaseUrl` with your Supabase URL
- [ ] Update `supabaseAnonKey` with your anon key

### Build Flutter Web
- [ ] Run: `cd flutter_app`
- [ ] Run: `flutter pub get`
- [ ] Run: `flutter build web --release`
- [ ] Verify build: `ls build/web/`

### Commit Changes
- [ ] Run: `git add .`
- [ ] Run: `git commit -m "Update API config for production"`
- [ ] Run: `git push`

### Vercel Frontend Setup
- [ ] Go to [vercel.com/new](https://vercel.com/new)
- [ ] Import same GitHub repository
- [ ] Set Root Directory: `flutter_app`
- [ ] Framework Preset: Other
- [ ] Build Command: `flutter build web`
- [ ] Output Directory: `build/web`

### Environment Variables (Frontend)
- [ ] `SUPABASE_URL` = https://xxxxx.supabase.co
- [ ] `SUPABASE_ANON_KEY` = eyJhbGc...

### Deploy
- [ ] Click "Deploy" button
- [ ] Wait for deployment (2-3 minutes)
- [ ] Copy frontend URL: `https://your-frontend.vercel.app`

---

## 🧪 Testing

### Backend Tests
- [ ] Health check: `curl https://your-backend.vercel.app/api/health`
- [ ] Exchange rate: `curl https://your-backend.vercel.app/api/exchange/rate`
- [ ] Test registration endpoint
- [ ] Test login endpoint
- [ ] Check Vercel logs for errors

### Frontend Tests
- [ ] Open frontend URL in browser
- [ ] Check if page loads
- [ ] Test user registration
- [ ] Test traditional login
- [ ] Test Google OAuth login
- [ ] Test exchange rate display
- [ ] Test currency conversion
- [ ] Test wallet deposit
- [ ] Test file upload (deposit proof)
- [ ] Test real-time chat
- [ ] Test notifications
- [ ] Test transaction history
- [ ] Test KYC upload
- [ ] Test admin panel (if admin user)

### Mobile Tests (Optional)
- [ ] Test on mobile browser
- [ ] Test responsive design
- [ ] Test touch interactions

---

## 🔧 Post-Deployment

### Domain Setup (Optional)
- [ ] Buy domain from Namecheap/GoDaddy
- [ ] Add domain to Vercel project
- [ ] Update DNS records
- [ ] Wait for SSL certificate
- [ ] Update Google OAuth authorized domains
- [ ] Update Flutter API config with custom domain

### Monitoring Setup
- [ ] Enable Vercel Analytics
- [ ] Set up error tracking (Sentry)
- [ ] Configure uptime monitoring
- [ ] Set up email alerts

### Security
- [ ] Review Supabase RLS policies
- [ ] Check API rate limiting
- [ ] Verify JWT secret is strong
- [ ] Review CORS settings
- [ ] Check environment variables are not exposed

### Performance
- [ ] Test page load speed
- [ ] Check Lighthouse score
- [ ] Optimize images if needed
- [ ] Enable caching headers

---

## 📊 Monitoring

### Daily Checks
- [ ] Check Vercel deployment status
- [ ] Review error logs
- [ ] Monitor Supabase usage
- [ ] Check bandwidth usage

### Weekly Checks
- [ ] Review user feedback
- [ ] Check performance metrics
- [ ] Update dependencies if needed
- [ ] Backup database

### Monthly Checks
- [ ] Review costs (Vercel + Supabase)
- [ ] Check for security updates
- [ ] Review and optimize queries
- [ ] Update documentation

---

## 🆘 Troubleshooting

### Common Issues

**Backend not responding:**
- [ ] Check Vercel deployment logs
- [ ] Verify environment variables
- [ ] Test database connection
- [ ] Check Supabase status

**Frontend not loading:**
- [ ] Check build logs
- [ ] Verify API config
- [ ] Check browser console
- [ ] Test on different browser

**File upload fails:**
- [ ] Verify Supabase Storage bucket exists
- [ ] Check bucket is public
- [ ] Review storage policies
- [ ] Check file size limits

**Chat not working:**
- [ ] Verify Realtime is enabled
- [ ] Check Supabase credentials
- [ ] Review browser console
- [ ] Test database connection

**Google OAuth fails:**
- [ ] Verify credentials
- [ ] Check authorized domains
- [ ] Review redirect URIs
- [ ] Test in incognito mode

---

## 📈 Scaling Checklist

### When You Exceed Free Tier

**Supabase ($25/month Pro):**
- [ ] Upgrade when database > 500 MB
- [ ] Upgrade when storage > 1 GB
- [ ] Upgrade when bandwidth > 2 GB/month

**Vercel ($20/month Pro):**
- [ ] Upgrade when bandwidth > 100 GB/month
- [ ] Upgrade when functions > 100 GB-hours
- [ ] Upgrade for team features

---

## ✅ Final Checklist

- [ ] Backend deployed and working
- [ ] Frontend deployed and working
- [ ] All features tested
- [ ] Environment variables secured
- [ ] Monitoring enabled
- [ ] Documentation updated
- [ ] Team notified
- [ ] Users can access the app
- [ ] Support channels ready

---

## 🎉 Success!

If all items are checked, your app is:
- ✅ Live and accessible
- ✅ Secure and monitored
- ✅ Ready for users
- ✅ Scalable and performant

**Congratulations! Your app is deployed! 🚀**

---

## 📚 Next Steps

1. Share your app URL
2. Gather user feedback
3. Monitor performance
4. Plan new features
5. Scale as needed

---

**Need help?** Check:
- `VERCEL_QUICK_START.md` - Quick deployment
- `VERCEL_DEPLOYMENT_GUIDE.md` - Detailed guide
- `VERCEL_SETUP_COMPLETE.md` - What's been done

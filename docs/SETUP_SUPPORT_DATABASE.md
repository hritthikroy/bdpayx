# Setup Support Database Tables

## Quick Setup

You need to run the SQL schema in your Supabase database to create the support tables.

### Option 1: Supabase Dashboard (Recommended)

1. Go to your Supabase SQL Editor:
   https://supabase.com/dashboard/project/cvsdypdlpngytpshivgw/sql/new

2. Copy and paste the SQL below:

```sql
-- Support Tickets Schema
CREATE TABLE IF NOT EXISTS support_tickets (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
    subject VARCHAR(255) NOT NULL,
    category VARCHAR(50) DEFAULT 'general',
    status VARCHAR(20) DEFAULT 'open',
    priority VARCHAR(20) DEFAULT 'normal',
    assigned_to INTEGER REFERENCES admin_users(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    closed_at TIMESTAMP
);

CREATE TABLE IF NOT EXISTS support_messages (
    id SERIAL PRIMARY KEY,
    ticket_id INTEGER REFERENCES support_tickets(id) ON DELETE CASCADE,
    sender_id INTEGER NOT NULL,
    sender_type VARCHAR(20) NOT NULL, -- 'user' or 'admin'
    message TEXT NOT NULL,
    attachment_url TEXT,
    is_read BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Indexes for better performance
CREATE INDEX IF NOT EXISTS idx_support_tickets_user_id ON support_tickets(user_id);
CREATE INDEX IF NOT EXISTS idx_support_tickets_status ON support_tickets(status);
CREATE INDEX IF NOT EXISTS idx_support_tickets_assigned_to ON support_tickets(assigned_to);
CREATE INDEX IF NOT EXISTS idx_support_messages_ticket_id ON support_messages(ticket_id);

-- Update timestamp trigger
CREATE OR REPLACE FUNCTION update_support_ticket_timestamp()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER support_ticket_update_timestamp
    BEFORE UPDATE ON support_tickets
    FOR EACH ROW
    EXECUTE FUNCTION update_support_ticket_timestamp();
```

3. Click "Run" to execute the SQL

### Option 2: Using psql Command Line

If you have PostgreSQL client installed:

```bash
# Get your database password from Supabase dashboard
# Then run:
psql "postgresql://postgres:[YOUR-PASSWORD]@db.cvsdypdlpngytpshivgw.supabase.co:5432/postgres" -f backend/src/database/support-schema.sql
```

## Verify Tables Created

After running the SQL, verify the tables exist:

```sql
-- Check if tables exist
SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'public' 
AND table_name IN ('support_tickets', 'support_messages');
```

You should see both tables listed.

## Test the System

### 1. Reload Admin Dashboard

Clear your browser cache and reload: http://localhost:8080

### 2. Check Support Menu

You should see "Support Tickets" in the sidebar menu.

### 3. Create a Test Ticket (Optional)

You can create a test ticket using curl or from your Flutter app:

```bash
# Replace YOUR_USER_TOKEN with a valid user JWT token
curl -X POST http://localhost:8081/api/support/tickets/create \
  -H "Authorization: Bearer YOUR_USER_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "subject": "Test Support Ticket",
    "category": "general",
    "message": "This is a test message for support"
  }'
```

### 4. View in Admin Dashboard

1. Login to admin dashboard
2. Click "Support Tickets" in sidebar
3. You should see the test ticket (if created)

## Troubleshooting

### "relation does not exist" error
- Make sure you ran the SQL in the correct database
- Check that you're connected to the right Supabase project

### "permission denied" error
- Make sure you're using the correct database credentials
- Check that your Supabase user has permission to create tables

### Tables not showing in admin dashboard
- Clear browser cache (Ctrl+Shift+R or Cmd+Shift+R)
- Check browser console for errors
- Verify backend server is running on port 8081

## Next Steps

Once the tables are created:
1. ✅ Backend server is already running with support routes
2. ✅ Admin dashboard has support management UI
3. 🔄 Update your Flutter app to use the support API (see SUPPORT_SYSTEM_SETUP.md)

The support system is now ready to use!

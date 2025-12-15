# Support Ticket System Setup Guide

## Overview
A complete support ticket management system has been added to your BDPayX application. Users can create support tickets from the Flutter app, and admins can manage and respond to them from the admin dashboard.

## Database Setup

### 1. Run the SQL Schema
Execute the support schema to create the necessary tables:

```bash
# Connect to your Supabase database and run:
psql -h your-supabase-host -U postgres -d postgres -f backend/src/database/support-schema.sql
```

Or manually run the SQL from `backend/src/database/support-schema.sql` in your Supabase SQL editor.

### Tables Created:
- **support_tickets**: Stores all support tickets
- **support_messages**: Stores all messages in tickets (from users and admins)

## Backend Setup

### 1. Support Routes Added
The support routes have been added to your backend at `backend/src/routes/support.js`

### 2. Server Configuration
The support routes are already integrated into `backend/src/server.js`

### 3. API Endpoints

#### Admin Endpoints:
- `GET /api/support/tickets` - Get all tickets (with filters)
- `GET /api/support/tickets/:id` - Get single ticket with messages
- `POST /api/support/tickets/:id/reply` - Reply to a ticket
- `PUT /api/support/tickets/:id/status` - Update ticket status
- `PUT /api/support/tickets/:id/priority` - Update ticket priority
- `PUT /api/support/tickets/:id/assign` - Assign ticket to admin
- `GET /api/support/stats` - Get support statistics

#### User Endpoints:
- `POST /api/support/tickets/create` - Create new ticket
- `GET /api/support/my-tickets` - Get user's tickets
- `POST /api/support/tickets/:id/message` - Add message to ticket

## Admin Dashboard

### New Features Added:

1. **Support Tickets Menu Item**
   - Located in the sidebar with a badge showing open tickets
   - Icon: Headset

2. **Support Tickets Page**
   - View all support tickets
   - Filter by status (open, replied, closed)
   - Filter by priority (high, normal, low)
   - Filter by category (general, transaction, KYC, technical, account)
   - Search tickets by subject
   - Real-time statistics

3. **Ticket Details Modal**
   - View full ticket conversation
   - Reply to tickets
   - Update ticket priority
   - Close tickets
   - See user information

### How to Access:
1. Login to admin dashboard: `http://localhost:8080`
2. Click "Support Tickets" in the sidebar
3. Click "View" on any ticket to see details and reply

## Flutter App Integration

### Update Support Screen
You need to update your Flutter app's support screen to use the new API endpoints:

```dart
// In flutter_app/lib/screens/chat/support_screen.dart

// Create a new ticket
Future<void> createTicket(String subject, String category, String message) async {
  final response = await http.post(
    Uri.parse('${ApiConfig.baseUrl}/support/tickets/create'),
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
    body: jsonEncode({
      'subject': subject,
      'category': category,
      'message': message,
    }),
  );
  
  if (response.statusCode == 200) {
    // Ticket created successfully
  }
}

// Get user's tickets
Future<List<Ticket>> getMyTickets() async {
  final response = await http.get(
    Uri.parse('${ApiConfig.baseUrl}/support/my-tickets'),
    headers: {
      'Authorization': 'Bearer $token',
    },
  );
  
  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return (data['tickets'] as List)
        .map((t) => Ticket.fromJson(t))
        .toList();
  }
  return [];
}

// Add message to ticket
Future<void> addMessage(int ticketId, String message) async {
  final response = await http.post(
    Uri.parse('${ApiConfig.baseUrl}/support/tickets/$ticketId/message'),
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
    body: jsonEncode({
      'message': message,
    }),
  );
}
```

## Features

### For Users:
- Create support tickets with categories
- View all their tickets
- Add messages to existing tickets
- See ticket status (open, replied, closed)

### For Admins:
- View all support tickets
- Filter and search tickets
- Reply to tickets
- Update ticket priority (low, normal, high)
- Close tickets
- Real-time notifications for new tickets
- Support statistics dashboard

## Categories Available:
- General
- Transaction
- KYC
- Technical
- Account

## Ticket Statuses:
- **open**: New ticket or user replied
- **replied**: Admin has replied
- **closed**: Ticket is closed

## Priority Levels:
- **low**: Low priority
- **normal**: Normal priority (default)
- **high**: High priority (urgent)

## Real-time Features

The system includes real-time updates via Socket.IO:
- Admins get notified when new tickets are created
- Admins get notified when users reply to tickets
- Statistics update automatically
- Ticket list refreshes when new tickets arrive

## Testing

### 1. Restart Backend Server
```bash
cd backend
npm start
```

### 2. Test Admin Dashboard
1. Open `http://localhost:8080`
2. Login with admin credentials
3. Click "Support Tickets" in sidebar
4. You should see the support tickets page

### 3. Create Test Ticket (via API)
```bash
curl -X POST http://localhost:8081/api/support/tickets/create \
  -H "Authorization: Bearer YOUR_USER_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "subject": "Test Ticket",
    "category": "general",
    "message": "This is a test support ticket"
  }'
```

## Next Steps

1. **Run the database schema** to create the tables
2. **Restart your backend server** to load the new routes
3. **Clear browser cache** and reload admin dashboard
4. **Update Flutter app** to integrate with the new support API
5. **Test the system** by creating tickets and replying to them

## Troubleshooting

### Tables not found error:
- Make sure you ran the SQL schema in your database
- Check Supabase dashboard to verify tables exist

### 404 on support endpoints:
- Restart the backend server
- Check that support routes are imported in server.js

### Admin dashboard not showing support menu:
- Clear browser cache (Ctrl+Shift+R)
- Check that you're using the latest version of index.html

## Support

If you encounter any issues, check:
1. Backend logs: `backend.log`
2. Browser console for JavaScript errors
3. Network tab to see API responses

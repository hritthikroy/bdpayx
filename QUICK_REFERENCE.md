# 📋 Quick Reference - Charts & Theme System

## 🚀 Quick Start

### Flutter App
```bash
cd flutter_app
flutter run
```

### Admin Dashboard
```bash
# Start backend
cd backend
npm start

# Open browser
http://localhost:8080/admin-dashboard/
```

## 📊 Chart Locations

### Flutter App
| Screen | Chart Type | Location |
|--------|-----------|----------|
| Home | Line Chart | Below exchange section |
| Statement | Bar + Pie | Top of screen |

### Admin Dashboard
| Chart | Type | Data |
|-------|------|------|
| Transaction Trend | Line | 7-day count |
| Status Distribution | Doughnut | Current status % |
| Revenue Overview | Bar | 7-day revenue |

## 🎨 Theme Toggle

### Flutter App
- **Automatic**: Follows device theme
- **Change**: Device Settings → Display → Theme

### Admin Dashboard
- **Manual**: Click floating button (bottom right)
- **Icon**: 🌙 = Light mode, ☀️ = Dark mode
- **Saved**: Preference stored in localStorage

## 🎯 Key Features

### Charts
✅ Interactive tooltips
✅ Smooth animations
✅ Theme-adaptive colors
✅ Responsive design
✅ Touch-friendly

### Themes
✅ Light & Dark modes
✅ Consistent colors
✅ Smooth transitions
✅ Persistent preferences
✅ Accessible contrast

## 📁 Important Files

### Flutter
```
lib/
├── main.dart                          # Theme config
├── widgets/
│   ├── rate_chart.dart               # Rate chart
│   └── transaction_analytics.dart    # Analytics
└── screens/
    ├── home/home_screen.dart         # With rate chart
    └── statement/statement_screen.dart # With analytics
```

### Admin
```
admin-dashboard/
├── index.html        # Chart containers
├── charts.js         # Chart logic
├── app.js           # Theme toggle
└── styles-modern.css # Chart styles
```

## 🎨 Color Reference

### Light Theme
```css
Primary:    #6366F1  /* Indigo */
Secondary:  #8B5CF6  /* Purple */
Success:    #10B981  /* Green */
Warning:    #F59E0B  /* Amber */
Danger:     #EF4444  /* Red */
Background: #F8FAFC  /* Slate */
```

### Dark Theme
```css
Primary:    #818CF8  /* Light Indigo */
Secondary:  #A78BFA  /* Light Purple */
Success:    #10B981  /* Green */
Warning:    #F59E0B  /* Amber */
Danger:     #F87171  /* Light Red */
Background: #0F172A  /* Dark Slate */
```

## 🔧 Troubleshooting

### Charts Not Showing

**Flutter:**
```bash
flutter clean
flutter pub get
flutter run
```

**Admin:**
- Clear browser cache
- Check console for errors
- Verify Chart.js loaded

### Theme Not Working

**Flutter:**
- Check device theme settings
- Restart app

**Admin:**
- Clear localStorage
- Hard refresh (Ctrl+Shift+R)

## 📊 Chart Customization

### Flutter (rate_chart.dart)
```dart
// Change colors
gradient: LinearGradient(
  colors: [primary, secondary, tertiary],
)

// Change animation speed
duration: Duration(milliseconds: 2000)

// Change data points
for (int i = 0; i < 24; i++) // 24 hours
```

### Admin (charts.js)
```javascript
// Change colors
backgroundColor: 'rgb(99, 102, 241)'

// Change animation
duration: 1500

// Change data range
for (let i = 6; i >= 0; i--) // 7 days
```

## 🎯 Best Practices

### Performance
- ✅ Use const constructors
- ✅ Minimize rebuilds
- ✅ Cache chart data
- ✅ Optimize animations

### Accessibility
- ✅ High contrast colors
- ✅ Clear labels
- ✅ Touch targets ≥ 44px
- ✅ Screen reader support

### UX
- ✅ Loading states
- ✅ Error handling
- ✅ Empty states
- ✅ Smooth transitions

## 📱 Responsive Breakpoints

### Flutter
- Mobile: < 600dp
- Tablet: 600-900dp
- Desktop: > 900dp

### Admin
- Mobile: < 768px
- Tablet: 768-1024px
- Desktop: > 1024px

## 🔗 Dependencies

### Flutter
```yaml
fl_chart: ^0.66.0
```

### Admin
```html
Chart.js 4.4.0
```

## 📚 Documentation

- [Flutter Charts Guide](CHARTS_AND_THEME_GUIDE.md)
- [Implementation Summary](CHART_IMPLEMENTATION_SUMMARY.md)
- [Visual Showcase](VISUAL_SHOWCASE.md)

## 🎉 Quick Tips

1. **Charts load slowly?**
   - Reduce data points
   - Disable animations temporarily
   - Check network connection

2. **Colors look wrong?**
   - Verify theme is applied
   - Check color scheme values
   - Clear cache and reload

3. **Want more charts?**
   - Check fl_chart documentation
   - Check Chart.js examples
   - Copy existing chart code

4. **Need help?**
   - Check console for errors
   - Review documentation
   - Test in different browsers/devices

## ✨ That's It!

You now have beautiful, interactive charts with full theme support. Enjoy! 🎨📊

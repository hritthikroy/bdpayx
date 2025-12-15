# Flutter App Frontend Fixes Plan

## Issues to Fix:

### 1. **Logo Section** - Currently showing "BDPayX" text, need Kiro-style logo
**Location:** `lib/screens/main_navigation.dart` (line 122) and `lib/screens/home/home_screen.dart` (line 354)

**Current Code:**
```dart
const Text(
  'BDPayX',
  style: TextStyle(
    color: Colors.white,
    fontSize: 20,
    fontWeight: FontWeight.bold,
  ),
),
```

**Fix Needed:**
- Create a logo asset (PNG/SVG) with Kiro-style design
- Add to `assets/` folder
- Update `pubspec.yaml` to include the asset
- Replace Text widget with Image.asset()

---

### 2. **Icons Not Showing Issue**
**Possible Causes:**
- Missing icon fonts in pubspec.yaml
- Icon data not properly imported
- Material icons not loading

**Check:**
- `pubspec.yaml` for `uses-material-design: true`
- Icon imports in each screen file
- Custom icon fonts if any

---

### 3. **Navigation Bar Issues**
**Location:** `lib/screens/main_navigation.dart` - Bottom navigation bar

**Current Implementation:**
- Glass morphism navigation bar
- Animated water flow effect
- Icon animations

**Potential Issues:**
- Icons not rendering
- Animation performance
- Touch targets too small
- Visual glitches

---

### 4. **Boxes Issue** (Need more details)
**Possible Issues:**
- Balance cards not displaying properly
- Quick action boxes misaligned
- Exchange section box styling
- Shadow/elevation issues
- Border radius problems

---

## Files to Check and Fix:

### Primary Files:
1. `lib/screens/main_navigation.dart` - Navigation bar and logo
2. `lib/screens/home/home_screen.dart` - Home screen UI
3. `pubspec.yaml` - Assets and dependencies
4. `assets/` - Logo and image assets

### Secondary Files:
5. `lib/widgets/` - Custom widgets
6. `lib/config/` - Theme and styling configuration

---

## Step-by-Step Fix Plan:

### Step 1: Create Kiro-Style Logo
- [ ] Generate logo image (gradient purple to pink)
- [ ] Save as `assets/images/logo.png`
- [ ] Update pubspec.yaml

### Step 2: Fix Logo Display
- [ ] Update main_navigation.dart (top bar logo)
- [ ] Update home_screen.dart (app bar logo)
- [ ] Test on different screen sizes

### Step 3: Fix Icons
- [ ] Verify Material icons are enabled
- [ ] Check all icon references
- [ ] Test icon rendering

### Step 4: Fix Navigation Bar
- [ ] Review glass effect implementation
- [ ] Check icon sizes and spacing
- [ ] Test animations
- [ ] Verify touch targets (min 44x44)

### Step 5: Fix Boxes/Cards
- [ ] Review balance cards styling
- [ ] Fix quick action buttons
- [ ] Check exchange section
- [ ] Verify shadows and borders

---

## Next Steps:

Please provide more details about:
1. Which specific icons are not showing?
2. What exactly is wrong with the boxes?
3. What navigation bar issues are you seeing?
4. Do you have a screenshot or can describe the visual problems?

Then I can provide targeted fixes for each issue.

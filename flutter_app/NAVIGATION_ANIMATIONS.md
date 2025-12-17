# Navigation Bar Animated Icons

## Overview
Custom animated icons for the navigation bar that provide unique, detailed animations when users tap on them.

## Icon Animations

### 🏠 Home Icon
**Animation Details:**
- Door opens and closes (swinging animation)
- Chimney smoke particles rise and fade
- Window with cross pattern
- Smooth house structure with roof

**Animation Sequence:**
1. Door swings open (0-50% progress)
2. Smoke particles start rising from chimney (30-100% progress)
3. Particles fade as they rise

### 🕐 History Icon
**Animation Details:**
- Clock face with 12 tick marks
- Hour hand rotates slowly (1 full rotation)
- Minute hand rotates faster (2 full rotations)
- Circular arrow appears around clock (history symbol)
- Arrow head animation

**Animation Sequence:**
1. Clock hands start rotating
2. History arrow appears at 20% progress
3. Arrow sweeps around clock face
4. All elements animate simultaneously

### 🎧 Support Icon
**Animation Details:**
- Headset with curved headband
- Left and right earpieces
- Microphone boom with mic
- Sound waves emanate from earpieces
- Pulsing indicator on microphone

**Animation Sequence:**
1. Sound waves start at 10% progress (3 waves per side)
2. Waves expand and fade outward
3. Microphone pulses at 50% progress
4. Continuous wave animation

### 👤 Profile Icon
**Animation Details:**
- Person silhouette with head and shoulders
- Waving hand animation
- Smile appears on face
- Eyes appear
- Sparkles around head

**Animation Sequence:**
1. Hand waves back and forth (sine wave motion)
2. Smile appears at 30% progress
3. Eyes appear with smile
4. Sparkles twinkle around head at 50% progress

## Technical Implementation

### Animation Controllers
- Each icon has its own `AnimationController` (600ms duration)
- Animations trigger on tap
- Combined with bounce, scale, and rotation effects from main navigation

### Animation Types
1. **Scale Animation**: Bounce effect (1.0 → 0.7 → 1.3 → 0.95 → 1.0)
2. **Rotation Animation**: Wiggle effect (-0.1 → 0.1 → 0)
3. **Bounce Animation**: Vertical movement (0 → -8 → 2 → 0)
4. **Custom Icon Animation**: Unique per icon (0 to 1 progress)

### Performance
- Uses `CustomPainter` for efficient rendering
- `shouldRepaint` optimized to only repaint when necessary
- Smooth 60fps animations
- Minimal memory footprint

## Usage

The icons automatically animate when:
- User taps on a navigation item
- Animation plays for 600ms
- Can be triggered multiple times

## Customization

To modify animations:
1. Edit `flutter_app/lib/widgets/animated_nav_icons.dart`
2. Adjust `progress` calculations in each painter
3. Modify animation sequences in `main_navigation.dart`
4. Change duration in `AnimationController` initialization

## Color Scheme
- Selected: White color
- Unselected: Grey (400 shade)
- Background gradient matches nav item color
- Opacity variations for depth effects

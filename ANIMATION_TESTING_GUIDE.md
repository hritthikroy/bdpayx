# Animation Testing Guide

## How to See the Animations

### Method 1: Wait for Automatic Update (60 seconds)
The animations will automatically trigger when the exchange rate updates from the server every 60 seconds.

### Method 2: Click the "Test" Button ⚡
I've added a **purple "Test" button** next to the "Hide/Show" button above the balance cards.
- Click this button to manually trigger all animations
- You'll see all effects immediately without waiting

## What You Should See

### 1. **INR Balance Card Animations**

#### Card Effects:
- ✨ **Glow Effect** - Purple glow radiates around the card edges
- 🔄 **Pulse Animation** - Card smoothly scales up and down (1.0 → 1.08 → 1.0)
- 🎨 **Color Shift** - Card slightly brightens during animation
- 🎯 **Bounce Finish** - Card bounces when animation completes (1.0 → 1.15 → 0.95 → 1.0)

#### Number Effects:
- 🔢 **Smooth Counting** - Numbers smoothly count from old to new value
- ✨ **Shimmer Effect** - Shiny light sweeps across the text (left to right)
- 💫 **Text Glow** - White glow shadow appears on the text

#### Badge Effects:
- 🟢 **"LIVE" Badge** - Shows when stable (green with pulsing dot)
- 🔄 **"UPDATING" Badge** - Shows during animation (green with spinner)

#### Status Indicator:
- 📊 **"Animating..." Label** - Appears below the card during animation
- Shows a small spinner to confirm animations are running

### 2. **Animation Timeline** (1.8 seconds total)

```
Click "Test" Button
    ↓
0.0s  - 🎬 Animation starts
      - Card starts pulsing
      - Glow appears
      - Shimmer sweeps across
      - Number starts counting
      - Badge changes to "UPDATING"
      - "Animating..." label appears
      
0.6s  - Glow reaches full intensity
      
1.2s  - Number counting completes
      - Pulse stops
      - Bounce animation plays
      
1.6s  - Bounce completes
      
1.8s  - Glow fades out
      - Badge changes back to "LIVE"
      - "Animating..." label disappears
      - ✅ Animation complete!
```

### 3. **Console Logs**

Watch your console/terminal for these messages:
```
🔄 Exchange rate changed! New rate: 0.6997
💰 Target INR balance: ₹69.97
📊 Current INR balance: ₹69.50
✅ Animating INR balance update...
✨ INR balance animation complete!
```

## Troubleshooting

### If you don't see animations:

1. **Check the "Test" button works**
   - Click it and watch for the "Animating..." label
   - If label appears, animations are running

2. **Check console logs**
   - Look for the emoji messages
   - If you see "⏭️ Change too small, skipping animation"
   - The rate didn't change enough (< 0.01 difference)

3. **Try multiple clicks**
   - Click "Test" button 2-3 times
   - Each click should trigger the full animation sequence

4. **Check the countdown timer**
   - Watch the countdown in the yellow box
   - Numbers should smoothly fade and scale
   - When < 10 seconds, badge should pulse and glow red

## Animation Details

### Card Glow
- **Color**: Purple (matches card color)
- **Intensity**: 0% → 60% → 0%
- **Blur Radius**: 0px → 40px → 0px
- **Spread**: 0px → 4px → 0px

### Pulse Effect
- **Scale Range**: 1.0 → 1.08
- **Speed**: 800ms per cycle
- **Curve**: EaseInOut
- **Repeats**: Until number counting completes

### Shimmer Effect
- **Direction**: Left to Right
- **Colors**: Transparent → White24 → White54 → White24 → Transparent
- **Duration**: 1500ms
- **Curve**: EaseInOut

### Number Counter
- **Duration**: 1200ms
- **Curve**: EaseInOutCubic
- **Updates**: Smooth interpolation between values

### Bounce Effect
- **Sequence**: 
  - Up: 1.0 → 1.15 (50% of time)
  - Down: 1.15 → 0.95 (25% of time)
  - Settle: 0.95 → 1.0 (25% of time)
- **Duration**: 400ms
- **Curve**: EaseInOut

## Performance Notes

- All animations use hardware acceleration
- Minimal CPU usage
- Smooth 60 FPS on most devices
- Animations are cancelled if user navigates away
- No memory leaks (all controllers properly disposed)

## Expected Behavior

✅ **Working Correctly:**
- Smooth transitions
- No jank or stuttering
- Animations complete fully
- Badge updates correctly
- Console logs appear

❌ **Issues to Report:**
- Animations skip or jump
- Card doesn't glow
- Numbers jump instead of counting
- Badge doesn't change
- No console logs

## Demo Mode

The BDT balance shows **৳100.00** with an orange "DEMO" badge.
The INR balance automatically calculates based on the current exchange rate:
- Formula: `INR = 100 BDT × Exchange Rate`
- Example: If rate is 0.6997, INR shows ₹69.97

Click "Test" to see the INR balance animate to a new value!

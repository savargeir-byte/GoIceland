# 🎬 Animation Quick Reference Guide

## Basic Animations

### FadeInAnimation

Fade element from transparent to opaque.

```dart
FadeInAnimation(
  duration: Duration(milliseconds: 600),
  delay: Duration(milliseconds: 200),
  curve: Curves.easeOut,
  child: YourWidget(),
)
```

**Use for:** Initial screen content, overlays, tooltips

---

### SlideInAnimation

Slide element with fade from specified offset.

```dart
SlideInAnimation(
  duration: Duration(milliseconds: 600),
  delay: Duration(milliseconds: 300),
  offset: Offset(0, 40),  // 40px from bottom
  child: YourWidget(),
)
```

**Common offsets:**

- `Offset(0, 40)` - Bottom to top
- `Offset(40, 0)` - Right to left
- `Offset(-40, 0)` - Left to right
- `Offset(0, -40)` - Top to bottom

**Use for:** Cards, list items, headers, sections

---

### SpringAnimation

Interactive scale animation on tap.

```dart
SpringAnimation(
  scale: 0.95,  // Scale to 95% on press
  child: YourButton(),
)
```

**Use for:** Buttons, cards, interactive elements

---

### StaggeredListAnimation

Sequential reveal of list items.

```dart
StaggeredListAnimation(
  staggerDelay: Duration(milliseconds: 100),
  initialDelay: Duration(milliseconds: 200),
  children: [
    ListItem1(),
    ListItem2(),
    ListItem3(),
  ],
)
```

**Use for:** Vertical lists, feature grids, menus

---

## Page Transitions

### FadePageRoute

Simple cross-fade between screens.

```dart
// Method 1: Extension
context.fadeTo(NextScreen());

// Method 2: Static
PremiumNavigation.fadeToPage(context, NextScreen());

// Method 3: Direct
Navigator.push(
  context,
  FadePageRoute(page: NextScreen()),
);
```

**Use for:** Settings, profiles, simple screens

---

### SlideUpPageRoute

Slide from bottom with fade (modal-style).

```dart
context.slideUpTo(ModalScreen());
```

**Use for:** Modals, sheets, detail views

---

### ScalePageRoute

Scale from center with fade.

```dart
context.scaleTo(DetailScreen());
```

**Use for:** Image viewers, detail pages, dialogs

---

### SharedAxisPageRoute

Material Design shared axis (recommended default).

```dart
context.sharedAxisTo(NextScreen());
```

**Use for:** Main navigation flow, primary screens

---

## Scroll Effects

### PremiumScrollPhysics

Enhanced scroll with better bounce.

```dart
ListView(
  physics: PremiumScrollPhysics(),
  children: [...],
)
```

**Features:**

- Improved bounce at edges
- Subtle resistance at boundaries
- Custom fling velocity range

**Use for:** All scrollable content

---

### ParallaxScrollDelegate

Custom parallax in CustomScrollView.

```dart
SliverPersistentHeader(
  delegate: ParallaxScrollDelegate(
    minExtent: 100,
    maxExtent: 300,
    parallaxFactor: 0.5,
    child: YourWidget(),
  ),
)
```

**Use for:** Hero images, headers, backgrounds

---

## Timing Guidelines

### Duration Recommendations:

- **Quick feedback:** 150-200ms
- **Standard transitions:** 300-400ms
- **Decorative animations:** 600-800ms
- **Ambient motion:** 2000-8000ms

### Delay Recommendations:

- **First element:** 0-100ms
- **Stagger increment:** 80-120ms
- **Between sections:** 200-400ms

### Curves:

- **Enter animations:** `Curves.easeOut`, `Curves.easeOutCubic`
- **Exit animations:** `Curves.easeIn`, `Curves.easeInCubic`
- **Interactive:** `Curves.easeInOut`
- **Bouncy:** `Curves.elasticOut`

---

## Common Patterns

### Hero Section

```dart
FadeInAnimation(
  duration: Duration(milliseconds: 800),
  child: HeroWidget(),
)
```

### Chip List

```dart
SlideInAnimation(
  delay: Duration(milliseconds: 200),
  offset: Offset(0, 20),
  child: ChipList(),
)
```

### Card Grid

```dart
ListView.builder(
  itemBuilder: (context, index) {
    return SlideInAnimation(
      delay: Duration(milliseconds: 300 + (index * 100)),
      offset: Offset(30, 0),
      child: Card(...),
    );
  },
)
```

### Interactive Button

```dart
SpringAnimation(
  child: ElevatedButton(...),
)
```

### Section Title

```dart
SlideInAnimation(
  delay: Duration(milliseconds: 400),
  offset: Offset(0, 15),
  child: Text('Section Title'),
)
```

---

## Performance Tips

1. **Avoid over-animating:** Not every element needs animation
2. **Use const constructors:** Where possible for duration/offset
3. **Dispose controllers:** Always dispose animation controllers
4. **Limit simultaneous animations:** Max 3-5 concurrent animations
5. **Profile on device:** Test performance on real hardware
6. **Use AnimatedBuilder:** For complex custom animations
7. **Cache animations:** Reuse controllers when possible

---

## Accessibility

- **Respect `MediaQuery.disableAnimations`:** Check before animating
- **Provide alternatives:** Ensure functionality without animations
- **Test with reduced motion:** Simulate accessibility settings
- **Semantic labels:** Add for screen readers

---

## Debug Mode

Check animations in slow motion:

```dart
import 'package:flutter/scheduler.dart';

void main() {
  timeDilation = 2.0;  // 2x slower
  runApp(MyApp());
}
```

---

## Examples in Fresh Explorer

### Home Screen Load:

1. Weather banner: `FadeInAnimation(800ms)`
2. Chips: `SlideInAnimation(200ms delay, 20px)`
3. Title: `SlideInAnimation(400ms delay, 15px)`
4. Cards: `SlideInAnimation(500ms + 100ms per card, 30px)`

### Navigation:

- Main flow: `SharedAxisPageRoute`
- Detail view: `ScalePageRoute`
- Modal: `SlideUpPageRoute`

### Interactions:

- All buttons: `SpringAnimation(0.95)`
- Category chips: Custom scale + glow animation
- Place cards: Pan gesture parallax

---

## Customization

All animations accept custom parameters:

```dart
SlideInAnimation(
  duration: Duration(milliseconds: 400),  // Speed
  delay: Duration(milliseconds: 100),     // Wait time
  offset: Offset(20, 0),                  // Distance
  child: widget,
)
```

Experiment to find the perfect feel for your app! 🎨

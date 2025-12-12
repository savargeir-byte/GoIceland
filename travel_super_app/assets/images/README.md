# 📸 Image Assets

This folder contains image assets used throughout the Fresh Explorer app.

## Required Images

### Onboarding Screens (3 images)

**Format:** JPG or PNG  
**Recommended size:** 1080x1920px (portrait, mobile)

1. **`ob1.jpg`** - First onboarding slide

   - **Theme:** Icelandic landscape/nature
   - **Text overlay:** "Uppgötvaðu Ísland"
   - Suggested: Waterfall, mountains, or aurora

2. **`ob2.jpg`** - Second onboarding slide

   - **Theme:** Travel experience/journey
   - **Text overlay:** "Persónulegar leiðir"
   - Suggested: Road trip, hiking trail, or scenic view

3. **`ob3.jpg`** - Third onboarding slide
   - **Theme:** Technology/AI/Maps
   - **Text overlay:** "Ellie • AI ferðaráðgjafi"
   - Suggested: Map interface, phone with app, or tech concept

### General Assets

4. **`placeholder.jpg`** - Fallback image
   - **Theme:** Generic placeholder
   - **Recommended size:** 800x600px
   - Used when images fail to load in cards/posts

## Image Sources

### Free Stock Photo Sites:

- **Unsplash** - https://unsplash.com/s/photos/iceland
- **Pexels** - https://www.pexels.com/search/iceland/
- **Pixabay** - https://pixabay.com/images/search/iceland/

### Search Terms:

- "Iceland landscape"
- "Iceland waterfall"
- "Aurora borealis"
- "Iceland travel"
- "Road trip Iceland"
- "Hiking Iceland"

## Current Status

✅ Directory created  
⏳ **Action needed:** Add the 4 required images to this folder

## Temporary Behavior

The app will show placeholder icons if images are missing:

- OnboardingScreen: Shows colored container with icon
- SavedPlacesScreen: Shows place icon
- ExploreFeedScreen: Shows image icon

**The app will NOT crash** if images are missing - graceful fallback is implemented.

## Adding Images

1. Download or create images matching the descriptions above
2. Rename them exactly as: `ob1.jpg`, `ob2.jpg`, `ob3.jpg`, `placeholder.jpg`
3. Place them in this folder: `assets/images/`
4. Run: `flutter pub get` (to ensure assets are registered)
5. Restart the app to see the images

---

**Note:** Images are already declared in `pubspec.yaml` under `assets: - assets/images/`

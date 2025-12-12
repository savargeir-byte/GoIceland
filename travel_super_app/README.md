# Travel Super App – Fresh Explorer Starter

This repo bootstraps the MVP for the Fresh Explorer travel companion: Mapbox map, Firebase-ready data layer, AI concierge hooks, and a modern Flutter UI scaffold.

## Requirements

- Flutter 3.35+ (`flutter doctor` must be green)
- Mapbox token (`MAPBOX_ACCESS_TOKEN`)
- OpenAI key (for AI concierge)
- Optional: OpenWeather + Vegagerðin feeds for weather/road overlays

## Structure

```
lib/
	app.dart                    # shell + bottom navigation
	main.dart                   # .env + Firebase bootstrap
	core/
		theme/                    # ColorPalette + ThemeData
		routes/                   # Named routes used by Navigator
		services/                 # AI, weather, location, road helpers
		widgets/                  # Shared UI atoms (card, button, sheets)
	data/
		models/                   # POI, Weather, User models
		api/                      # Firestore repositories
		local/                    # In-memory caching stubs
	features/
		map/                      # Mapbox view, controllers, pins
		home/                     # Landing experience
		explore/, discovery/, etc # Future modules per roadmap
assets/
	icons/, images/, rive/      # Custom pins + placeholders
```

## Environment

1. Duplicate `.env.example` → `.env`
2. Fill in:

```
MAPBOX_ACCESS_TOKEN=pk...
OPENAI_API_KEY=sk...
OPENWEATHER_API_KEY=...
VEGAGERDIN_FEED_URL=https://...
```

3. Run FlutterFire CLI when you are ready to connect Firebase:

```powershell
dart pub global activate flutterfire_cli
flutterfire configure
```

The generated `firebase_options.dart` should be imported in `main.dart` once available.

## Install deps & run

```powershell
flutter pub get
flutter test
flutter run
```

If you change native Mapbox/Firebase settings re-run `flutter pub get`.

## Feature roadmap

- **Week 1**: Base shell, working Mapbox view, smart pins
- **Week 2**: Discovery/feed modules for Food Radar + Photo Spots
- **Week 3**: Weather + road overlays, Surprise Me AI
- **Phase 2**: AI route generator, computer-vision powered pin insights

See `lib/features/*` for placeholders that can be expanded iteratively.

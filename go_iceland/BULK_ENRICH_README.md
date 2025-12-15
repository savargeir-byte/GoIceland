# 🤖 AUTOMATED BULK ENRICHMENT

## Hvað gerir þetta?

Sækir sjálfkrafa myndir og lýsingar fyrir alla 4,972 staði í einu.

## API Keys (Allt FREE!)

### 1. Unsplash (50 myndir/klst)

1. Farðu á: https://unsplash.com/developers
2. Smelltu á "Register as a developer"
3. Búðu til nýtt app
4. Afritaðu "Access Key"

### 2. Pixabay (100 myndir/mín)

1. Farðu á: https://pixabay.com/api/docs/
2. Smelltu á "Get Started"
3. Afritaðu API key

### 3. Pexels (200 myndir/klst)

1. Farðu á: https://www.pexels.com/api/
2. Smelltu á "Get Started"
3. Afritaðu API key

## Uppsetning

1. Opnaðu `go_iceland/bulk_enrich.py`
2. Settu inn API keys:

```python
UNSPLASH_ACCESS_KEY = "your_key_here"
PIXABAY_API_KEY = "your_key_here"
PEXELS_API_KEY = "your_key_here"
```

## Keyra

```powershell
cd c:\GitHub\Radio_App\GoIceland
python go_iceland/bulk_enrich.py
```

## Hvað gerist?

✅ Sækir 3-5 myndir fyrir hvern stað
✅ Sækir Wikipedia lýsingu (ef til)
✅ Býr til lýsingu ef Wikipedia finnst ekki
✅ Vistar progress á 50 stöðum fresti
✅ Tekur ~2-3 klst fyrir alla 4,972 staði

## Eftir enrichment

Upload í Firestore:

```powershell
cd go_iceland/firebase
python upload_to_firestore.py
```

## Rate Limits

- **Unsplash**: 50 requests/klst = ~1 sekúnda á milli
- **Pixabay**: 100 requests/mín = ~0.6 sekúndur á milli
- **Pexels**: 200 requests/klst = ~1.8 sekúndur á milli
- **Wikipedia**: Engin limit fyrir lestur

Script-ið tekur tillit til þessara limita.

## Ef það fer á taugarnar

Ctrl+C til að stoppa - progress er vistað!
Keyra aftur og það heldur áfram þar sem það hætti.

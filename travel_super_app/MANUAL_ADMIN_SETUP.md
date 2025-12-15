# 🔧 Manual Admin Setup Guide

Firebase Authentication virðist ekki vera enabled. Hér er hvernig á að setja upp admin notanda handvirkt:

## Skref 1: Enable Firebase Authentication

1. Farðu á: https://console.firebase.google.com/
2. Veldu "**go-iceland**" project
3. Vinstra menu → **Authentication**
4. Klikka á "**Get Started**" eða "**Sign-in method**"
5. Enable "**Email/Password**"
6. Vista

## Skref 2: Búa til Admin Notanda

### A. Í Firebase Authentication:

1. Farðu á **Authentication** → **Users** tab
2. Klikka á "**Add user**"
3. Sláðu inn:
   - **Email**: `admin@goiceland.is`
   - **Password**: `admin123456` (eða eitthvað betra!)
4. Klikka "**Add user**"
5. **Afritaðu UID** (t.d. `abc123def456...`) - þú þarft þetta!

### B. Í Firestore Database:

1. Farðu á **Firestore Database** → **Data** tab
2. Finndu eða búðu til **`users`** collection
3. Klikka "**Add document**"
4. **Document ID**: Notaðu UID frá Authentication (paste það)
5. Bættu við fields:

```
Field: email
Type: string
Value: admin@goiceland.is

Field: displayName
Type: string
Value: Admin User

Field: role
Type: string
Value: admin

Field: createdAt
Type: timestamp
Value: (current time)
```

6. Klikka "**Save**"

## Skref 3: Test Login

1. Farðu aftur í admin panel í Chrome
2. Þú ættir að sjá Login screen
3. Skráðu þig inn með:
   - **Email**: `admin@goiceland.is`
   - **Password**: (það sem þú bjóst til í Authentication)
4. Ætti að virka! 🎉

## Alternative: Nota Firebase CLI

Ef þú vilt gera þetta með CLI:

```bash
# Install Firebase CLI (if not already)
npm install -g firebase-tools

# Login
firebase login

# Go to project
cd c:\GitHub\Radio_App\GoIceland\travel_super_app

# Use project
firebase use go-iceland

# This will show you how to enable Authentication
firebase open
```

## Firestore Security Rules

Ekki gleyma að deploy security rules:

```bash
cd c:\GitHub\Radio_App\GoIceland\travel_super_app
firebase deploy --only firestore:rules,storage
```

## Tjékklisti

- [ ] Firebase Authentication enabled
- [ ] Email/Password sign-in method enabled
- [ ] User created in Authentication
- [ ] UID copied
- [ ] User document created in Firestore users/{uid}
- [ ] Document has 'role': 'admin'
- [ ] Security rules deployed
- [ ] Test login works

---

**Þegar þetta er allt gert, getur þú skráð þig inn í admin panel! 🚀**

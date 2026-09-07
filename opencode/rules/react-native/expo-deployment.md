---
paths:
  - "app.json"
  - "eas.json"
  - "*.config.*"
---
# Expo Deployment

> Reference for EAS Build, Submit, and OTA updates.

## EAS Configuration

### eas.json

```json
{
  "cli": {
    "version": ">= 5.0.0"
  },
  "build": {
    "development": {
      "developmentClient": true,
      "distribution": "internal",
      "ios": {
        "simulator": true
      }
    },
    "preview": {
      "distribution": "internal",
      "ios": {
        "simulator": false
      }
    },
    "production": {
      "autoIncrement": true
    }
  },
  "submit": {
    "production": {
      "ios": {
        "appleId": "your-apple-id@example.com",
        "ascAppId": "your-app-store-connect-app-id",
        "appleTeamId": "your-team-id"
      },
      "android": {
        "serviceAccountKeyPath": "./google-services.json"
      }
    }
  }
}
```

### app.json

```json
{
  "expo": {
    "name": "My App",
    "slug": "my-app",
    "version": "1.0.0",
    "orientation": "portrait",
    "icon": "./assets/icon.png",
    "userInterfaceStyle": "automatic",
    "splash": {
      "image": "./assets/splash.png",
      "resizeMode": "contain",
      "backgroundColor": "#ffffff"
    },
    "assetBundlePatterns": ["**/*"],
    "ios": {
      "supportsTablet": true,
      "bundleIdentifier": "com.example.myapp",
      "buildNumber": "1"
    },
    "android": {
      "adaptiveIcon": {
        "foregroundImage": "./assets/adaptive-icon.png",
        "backgroundColor": "#ffffff"
      },
      "package": "com.example.myapp",
      "versionCode": 1
    },
    "web": {
      "favicon": "./assets/favicon.png"
    },
    "plugins": [
      "expo-router",
      "expo-secure-store",
      "expo-local-authentication"
    ],
    "scheme": "myapp"
  }
}
```

## Build Commands

### Development Build

```bash
# iOS Simulator
eas build --platform ios --profile development

# Android Emulator
eas build --platform android --profile development

# Both platforms
eas build --platform all --profile development
```

### Preview Build (Internal Testing)

```bash
# iOS (TestFlight)
eas build --platform ios --profile preview

# Android (APK)
eas build --platform android --profile preview
```

### Production Build

```bash
# Build for production
eas build --platform all --profile production

# Build with auto-increment
eas build --platform ios --profile production
```

## App Store Submission

### iOS (App Store)

```bash
# Submit to App Store
eas submit --platform ios --profile production

# Submit to TestFlight
eas submit --platform ios --profile preview
```

### Google Play Store

```bash
# Submit to Google Play
eas submit --platform android --profile production

# Submit to internal track
eas submit --platform android --profile preview
```

## OTA Updates

### EAS Update

```bash
# Push OTA update
eas update --branch production --message "Bug fix for login"

# Preview update
eas update --branch preview --message "New feature preview"
```

### Update Configuration

```json
// app.json
{
  "expo": {
    "updates": {
      "url": "https://u.expo.dev/your-project-id",
      "fallbackToCacheTimeout": 0,
      "checkAutomatically": "ON_LOAD"
    },
    "runtimeVersion": {
      "appVersion": "1.0.0"
    }
  }
}
```

### Code Push Strategy

```typescript
// lib/updates.ts
import * as Updates from 'expo-updates'

export async function checkForUpdates() {
  try {
    const update = await Updates.checkForUpdateAsync()

    if (update.isAvailable) {
      await Updates.fetchUpdateAsync()
      await Updates.reloadAsync()
    }
  } catch (error) {
    console.error('Error checking for updates:', error)
  }
}

// Check on app launch
Updates.addListener((event) => {
  if (event.type === Updates.UpdateEventType.UPDATE_AVAILABLE) {
    // Notify user about update
  }
})
```

## Environment Configuration

### Environment Variables

```bash
# .env.development
EXPO_PUBLIC_API_URL=http://localhost:3000
EXPO_PUBLIC_APP_NAME=My App (Dev)

# .env.staging
EXPO_PUBLIC_API_URL=https://staging-api.myapp.com
EXPO_PUBLIC_APP_NAME=My App (Staging)

# .env.production
EXPO_PUBLIC_API_URL=https://api.myapp.com
EXPO_PUBLIC_APP_NAME=My App
```

### Environment Configuration

```typescript
// config/env.ts
import Constants from 'expo-constants'

const ENV = {
  development: {
    apiUrl: 'http://localhost:3000',
    appName: 'My App (Dev)',
  },
  staging: {
    apiUrl: 'https://staging-api.myapp.com',
    appName: 'My App (Staging)',
  },
  production: {
    apiUrl: 'https://api.myapp.com',
    appName: 'My App',
  },
}

type Environment = keyof typeof ENV

export function getEnvironment(): Environment {
  const channel = Constants.expoConfig?.extra?.eas?.channel

  switch (channel) {
    case 'staging':
      return 'staging'
    case 'production':
      return 'production'
    default:
      return 'development'
  }
}

export const config = ENV[getEnvironment()]
```

## CI/CD with EAS

### GitHub Actions

```yaml
# .github/workflows/eas-build.yml
name: EAS Build

on:
  push:
    branches:
      - main
      - staging

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - uses: actions/setup-node@v4
        with:
          node-version: '20'
          cache: 'npm'

      - run: npm ci

      - uses: eas-cli/setup@v3
        with:
          eas-version: 'latest'

      - run: eas build --platform all --profile production --non-interactive
        env:
          EXPO_TOKEN: ${{ secrets.EXPO_TOKEN }}
```

## Version Management

### Auto-Increment

```json
// eas.json
{
  "build": {
    "production": {
      "autoIncrement": true
    }
  }
}
```

### Manual Version Control

```bash
# Update version in app.json
npx expo prebuild

# Or use EAS
eas build:configure
```

## Checklist

- [ ] eas.json configured for all environments
- [ ] app.json properly configured
- [ ] Environment variables set
- [ ] Build profiles defined (development, preview, production)
- [ ] Submit configuration ready
- [ ] OTA updates configured
- [ ] CI/CD pipeline set up
- [ ] Version management strategy defined
- [ ] App store metadata prepared
- [ ] Screenshots and descriptions ready

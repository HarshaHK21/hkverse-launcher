# Flutter Launcher App - Developer Requirements Document

## 1. Project Overview
This document outlines the UI/UX and functional requirements for a custom Android Launcher developed using **Flutter**. 
The launcher focuses on a minimalist, distraction-free design similar to Niagara Launcher, but infused with the brand identity of [harshakarunarathna.com](https://www.harshakarunarathna.com/).

## 2. UI/UX & Design Guidelines

### 2.1. Color Palette & Typography
* **Base Theme:** Dark Mode (Deep Black / Dark Grey backgrounds) to ensure readability and battery saving.
* **Accent Colors:** Extract the exact primary and secondary color palettes from `harshakarunarathna.com` and use them for highlights (e.g., A-Z scroll text, active states).
* **Typography:** Use the primary font from the website (e.g., Poppins, Montserrat, or Roboto). Fonts should be clean, sans-serif, and easily readable.

### 2.2. Home Screen Layout
Based on the provided reference image (`image_a42365.jpg`), the layout must consist of the following elements:

1. **Top Section (Time & Date):**
   * Placed at the Top-Left.
   * Large, bold digital clock (e.g., `12:27`).
   * Subtle date text right below the time (e.g., `Fri, 11 Sep`).

2. **Main App List (Left Aligned):**
   * A vertical scrolling list of apps.
   * **List Item:** [App Icon] + [App Name].
   * App icons should be slightly rounded or circular, maintaining a consistent size.
   * Text should be white/light grey for contrast.
   * Top of the list should have a section title (e.g., "Choose Your Productivity Features").

3. **A-Z Quick Scroll (Right Aligned):**
   * A vertical alphabet list (`# A B C D ... Z`) permanently fixed on the right edge.
   * Dragging over these letters should quickly jump/scroll the app list to apps starting with that letter.

4. **Background / Wallpaper:**
   * Support transparent backgrounds to allow the system wallpaper to show through, OR include custom dark-themed artistic wallpapers (like the Zen/Buddha theme provided in the reference).

## 3. Technical Requirements (Flutter)

### 3.1. Core Launcher Functionality
* **AndroidManifest.xml Configuration:** The app must be registered as a home launcher.
  ```xml
  <intent-filter>
      <action android:name="android.intent.action.MAIN" />
      <category android:name="android.intent.category.HOME" />
      <category android:name="android.intent.category.DEFAULT" />
  </intent-filter>
  ```
* **App Fetching:** Query installed applications using Android's `PackageManager`. Map these to simple App data models (Name, Package Name, Icon). *Note: Use stable Flutter packages like `device_apps` or write platform channels if custom logic is needed.*
* **App Launching:** Use `getLaunchIntentForPackage` to open apps directly when the user taps an item in the list.

### 3.2. Performance & Animations
* The list scrolling must be smooth at 60Hz/120Hz.
* Consider caching app icons in memory since loading icons from the OS every time can cause UI stuttering.
* Add a subtle ripple effect (InkWell) when an app is tapped.

## 4. Development Milestones
1. **Phase 1:** Setup basic Flutter project, configure Android Manifest for Launcher category, and fetch/display a raw list of installed apps.
2. **Phase 2:** Implement the UI (Time/Date widget, custom list view, A-Z scrollbar on the right).
3. **Phase 3:** Apply the color scheme and typography from the website, optimize icon loading, and polish animations.

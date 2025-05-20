# 🌿 Water Plants Tracker

This small shell project helps me and my household keep track of when each plant was last watered. It's especially useful when multiple people are responsible for plant care — no more overwatering!

---

## 🛠 How It Works

This is a terminal-based app written in **Bash**. It logs watering events to a file and helps you monitor when each plant needs attention.

### ✅ Features

- See watering status for each plant
- Add new plants with a short name and watering frequency
- Log watering events with a timestamp
- Prevent overwatering by tracking last watered dates

---

## 🚀 Getting Started

1. Make sure you have `bash`, `jq`, and `date` installed.
2. Run the script:

```bash
./plants.sh
```
3. You'll see something like this:
```
----- Watering Status -----
⚠️ Plant pothos young and air plants has not been watered for 10 days! (Needs watering every 7 days)
🌱 Plant orchids was watered 0 days ago.
🌱 Plant succulents has never been watered.
🌱 Plant others has never been watered.
Do you want to water a plant (w) or add a new plant (a) or exit (e)?
Enter your choice: w

Which plant do you want to water? Options: s p o ot
Enter plant short name:

```

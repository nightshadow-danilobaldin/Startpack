# Startpack – Pick your starter kit

**Startpack** is a modular and fully customizable system for distributing starter kits to the player at the beginning of a new game in *Skyrim Special Edition*. You can choose between predefined archetypes (e.g., Mage, Thief, Paladin) or create your own kits using structured JSON files.

## ✅ Features

- **Highly modular and plug-and-play**: Comes with a default set of kits for immediate use.
- **Optional level selection**: Receive bonus skill points based on your chosen level.
- **Kit preview system**: View items, spells, shouts, and skill bonuses before confirming.
- **Supports items from other mods**: As long as FormID and plugin name are correct.
- **Localization-friendly**: All UI text is externalized into a JSON file.
- **Optional Alternate Start integration**: Retrieve your kit from a chest after escaping the prison.

---

## 📦 Installation

Install the mod with your mod manager of choice (MO2 or Vortex) and follow the FOMOD instructions:

- If using **Alternate Start – Live Another Life**, you’ll be given the option to enable a more immersive integration.
- If not using Alternate Start, the kit selection will begin automatically shortly after character creation.

---

## 📁 Repository Structure

Startpack/
├── FOMOD/
│ └── ModuleConfig.xml # FOMOD installer configuration
├── SKSE/
│ └── Plugins/
│ └── Startpack - Pick your starter kit/
│ ├── Kits/ # JSON files for each starter kit
│ ├── levels.json # Level presets
│ ├── options.json # List of kit options
│ ├── langData.json # Translatable UI text
│ └── settings.json # General mod configuration
├── Source/
│ └── Scripts/
│ └── StartpackPlayerKitSelector.psc # Main Papyrus script
├── Startpack - Pick your pack.esp # ESL-flagged plugin


If using the Alternate Start addon, an additional plugin and configuration will be installed.

---

## ⚙️ Customization Guide

Refer to this Nexus article for a full breakdown of kit customization:

**📄 [Advanced Customization Guide](https://www.nexusmods.com/skyrimspecialedition/articles/10534)**

You can define your own:
- Starter kits and their contents
- Available class options
- Skill scaling per level
- Languages and labels

---

## 📋 Requirements

- [SKSE64](https://skse.silverlock.org/)
- [JContainers](https://www.nexusmods.com/skyrimspecialedition/mods/49743)
- [UIExtensions](https://www.nexusmods.com/skyrimspecialedition/mods/17561)
- [Papyrus MessageBox - SKSE NG](https://www.nexusmods.com/skyrimspecialedition/mods/10820)
- (Optional) [Alternate Start – Live Another Life](https://www.nexusmods.com/skyrimspecialedition/mods/272)

---

## 📣 Feedback & Contributions

Suggestions, bug reports, and contributions are welcome! Feel free to create you on addons and payches. 

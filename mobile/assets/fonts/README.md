# KerjaFlow Fonts

This directory contains fonts required for rendering complex scripts in ASEAN languages.

## Required Fonts

Download from [Google Fonts - Noto Sans](https://fonts.google.com/noto):

### Primary Latin Font
- **Roboto** - Regular (400), Medium (500), Bold (700)

### Complex Script Fonts

| Font | Script | Languages | Download |
|------|--------|-----------|----------|
| NotoSansKhmer | Khmer | Khmer (Cambodia) | [Download](https://fonts.google.com/noto/specimen/Noto+Sans+Khmer) |
| NotoSansMyanmar | Myanmar | Burmese (Myanmar) | [Download](https://fonts.google.com/noto/specimen/Noto+Sans+Myanmar) |
| NotoSansThai | Thai | Thai (Thailand) | [Download](https://fonts.google.com/noto/specimen/Noto+Sans+Thai) |
| NotoSansTamil | Tamil | Tamil (Malaysia, Singapore) | [Download](https://fonts.google.com/noto/specimen/Noto+Sans+Tamil) |
| NotoSansBengali | Bengali | Bengali (Bangladesh migrants) | [Download](https://fonts.google.com/noto/specimen/Noto+Sans+Bengali) |
| NotoSansDevanagari | Devanagari | Nepali (Nepal migrants) | [Download](https://fonts.google.com/noto/specimen/Noto+Sans+Devanagari) |
| NotoSansLao | Lao | Lao (Laos) | [Download](https://fonts.google.com/noto/specimen/Noto+Sans+Lao) |

## Font File Naming Convention

For each font family, download these weights:
- Regular (400)
- Medium (500)
- Bold (700)

Name files as:
```
{FontFamily}-Regular.ttf
{FontFamily}-Medium.ttf
{FontFamily}-Bold.ttf
```

Example:
```
NotoSansKhmer-Regular.ttf
NotoSansKhmer-Medium.ttf
NotoSansKhmer-Bold.ttf
```

## Quick Setup

Run the download script:
```bash
./scripts/download_fonts.sh
```

Or manually download from Google Fonts and place in this directory.

## Verification

After adding fonts, run:
```bash
flutter pub get
flutter analyze
```

## License

All Noto fonts are licensed under the [SIL Open Font License](https://scripts.sil.org/OFL).

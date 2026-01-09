# KERJAFLOW DESIGN SYSTEM
## The Complete Visual Language

---

## 1. DESIGN PHILOSOPHY

### 1.1 Core Principles

| Principle | Description | Implementation |
|-----------|-------------|----------------|
| **Clarity** | Information is immediately understandable | Visual hierarchy, clear labels |
| **Efficiency** | Minimize steps to complete tasks | Smart defaults, shortcuts |
| **Inclusivity** | Works for all abilities and literacy levels | Accessibility, visual-first |
| **Trust** | Conveys security and reliability | Consistent patterns, feedback |
| **Delight** | Enjoyable to use | Micro-animations, polish |

### 1.2 Design Pillars

```
┌─────────────────────────────────────────────────────────────┐
│                     KERJAFLOW DESIGN                        │
├───────────────┬───────────────┬───────────────┬────────────┤
│   FUNCTIONAL  │   BEAUTIFUL   │  ACCESSIBLE   │ CONSISTENT │
├───────────────┼───────────────┼───────────────┼────────────┤
│ Task-focused  │ Modern design │ WCAG 2.2 AA   │ Pattern    │
│ Error-proof   │ Subtle motion │ All abilities │ library    │
│ Offline-ready │ Brand colors  │ All literacy  │ Tokens     │
│ Fast          │ Professional  │ All languages │ Guidelines │
└───────────────┴───────────────┴───────────────┴────────────┘
```

---

## 2. BRAND IDENTITY

### 2.1 Logo

**Primary Logo**
- Minimum size: 32px height (digital), 10mm (print)
- Clear space: Height of 'K' in KerjaFlow on all sides
- File formats: SVG (preferred), PNG with transparency

**Logo Variants**
- Full color on light background
- Full color on dark background
- Monochrome white
- Monochrome black

### 2.2 Brand Colors

**Primary Palette - "KerjaFlow Blue"**
Represents: Trust, Professionalism, Reliability

| Shade | Hex | Usage |
|-------|-----|-------|
| 50 | #EBF5FB | Light backgrounds |
| 100 | #D4E6F1 | Hover states |
| 200 | #85C1E9 | Borders |
| 300 | #5DADE2 | Icons |
| 400 | #2E86AB | Links |
| **600** | **#1A5276** | **Primary (Default)** |
| 700 | #145470 | Emphasis |
| 900 | #0D3B50 | Text on light |

**Secondary Palette - "KerjaFlow Gold"**
Represents: Action, Urgency, Warmth

| Shade | Hex | Usage |
|-------|-----|-------|
| 100 | #FCF3CF | Light backgrounds |
| 300 | #F9E79F | Borders |
| **500** | **#F39C12** | **Secondary (Default)** |
| 600 | #D68910 | Emphasis |

### 2.3 Typography

**Primary Font: Plus Jakarta Sans**
- Modern, geometric sans-serif
- Excellent readability
- Wide language support
- Open source (Google Fonts)

**Language-Specific Fonts**
| Language | Font |
|----------|------|
| Arabic (Jawi) | IBM Plex Sans Arabic |
| Thai | Noto Sans Thai |
| Chinese | Noto Sans SC |
| Tamil | Noto Sans Tamil |
| Khmer | Noto Sans Khmer |
| Myanmar | Noto Sans Myanmar |

---

## 3. VISUAL HIERARCHY

### 3.1 Layer Model

```
┌─────────────────────────────────────┐  z-index: 1080
│            TOAST/TOAST              │
├─────────────────────────────────────┤  z-index: 1070
│            TOOLTIP                  │
├─────────────────────────────────────┤  z-index: 1060
│            POPOVER                  │
├─────────────────────────────────────┤  z-index: 1050
│            MODAL                    │
├─────────────────────────────────────┤  z-index: 1040
│            MODAL BACKDROP           │
├─────────────────────────────────────┤  z-index: 1030
│            FIXED (FAB)              │
├─────────────────────────────────────┤  z-index: 1020
│            STICKY (Header)          │
├─────────────────────────────────────┤  z-index: 1000
│            DROPDOWN                 │
├─────────────────────────────────────┤  z-index: 0
│            BASE CONTENT             │
└─────────────────────────────────────┘
```

### 3.2 Content Hierarchy

```
DISPLAY       ────────────────────────  Screen titles
                                        (32-48sp, Bold)
HEADLINE      ────────────────────────  Section headers
                                        (20-24sp, Semibold)
TITLE         ────────────────────────  Card titles
                                        (16-18sp, Semibold)
BODY          ────────────────────────  Content text
                                        (14-16sp, Regular)
CAPTION       ────────────────────────  Supporting text
                                        (12sp, Regular)
LABEL         ────────────────────────  UI elements
                                        (12-14sp, Medium)
```

---

## 4. GRID & LAYOUT

### 4.1 8-Point Grid

All spacing and sizing should be multiples of 8dp.
Exceptions: 4dp for tight spacing, 12dp for specific needs.

```
┌────────────────────────────────────────────────────────┐
│ 16dp │                                        │ 16dp │
├──────┤                                        ├──────┤
│      │  ┌────────────────────────────────┐   │      │
│      │  │                                │   │      │
│      │  │         CONTENT AREA           │   │      │
│      │  │                                │   │      │
│      │  │                                │   │      │
│      │  └────────────────────────────────┘   │      │
│      │                                        │      │
│      │            16dp gap                   │      │
│      │                                        │      │
│      │  ┌────────────────────────────────┐   │      │
│      │  │                                │   │      │
│      │  │         CONTENT AREA           │   │      │
│      │  │                                │   │      │
│      │  └────────────────────────────────┘   │      │
└────────────────────────────────────────────────────────┘
```

### 4.2 Content Width

| Screen Size | Max Content Width | Margins |
|-------------|-------------------|---------|
| Phone | 100% | 16dp |
| Small Tablet | 100% | 24dp |
| Large Tablet | 840dp | 24dp |
| Desktop | 1200dp | 32dp |
| Large Desktop | 1400dp | auto |

---

## 5. ELEVATION & DEPTH

### 5.1 Shadow Scale

| Level | Elevation | Usage |
|-------|-----------|-------|
| 0 | None | Flat elements, dividers |
| 1 | Subtle | Cards at rest |
| 2 | Low | Cards hovered, chips |
| 3 | Medium | FAB, bottom sheets |
| 4 | High | Modals, dialogs |

### 5.2 Shadow Definitions

```css
/* Level 1 - Subtle */
box-shadow: 0 1px 3px rgba(0,0,0,0.1), 
            0 1px 2px rgba(0,0,0,0.06);

/* Level 2 - Low */
box-shadow: 0 4px 6px -1px rgba(0,0,0,0.1), 
            0 2px 4px -1px rgba(0,0,0,0.06);

/* Level 3 - Medium */
box-shadow: 0 10px 15px -3px rgba(0,0,0,0.1), 
            0 4px 6px -2px rgba(0,0,0,0.05);

/* Level 4 - High */
box-shadow: 0 20px 25px -5px rgba(0,0,0,0.1), 
            0 10px 10px -5px rgba(0,0,0,0.04);
```

---

## 6. ICONOGRAPHY

### 6.1 Icon Style

- Style: Material Icons Rounded
- Stroke: 2dp consistent
- Sizes: 16, 20, 24, 32, 40, 48dp
- Color: Inherit from context

### 6.2 Core Icons

| Function | Icon | Usage |
|----------|------|-------|
| Home | home | Dashboard |
| Payslip | receipt_long | Payslip section |
| Leave | event_note | Leave section |
| Notifications | notifications | Inbox |
| Profile | person | Profile section |
| Settings | settings | Settings |
| Back | arrow_back | Navigation |
| Close | close | Dismiss |
| Add | add | Create new |
| Edit | edit | Modify |
| Delete | delete | Remove |
| Search | search | Search |
| Filter | filter_list | Filter |
| Calendar | calendar_today | Date picker |
| Download | download | Download file |
| Share | share | Share |
| Check | check | Success/confirm |
| Error | error | Error state |
| Warning | warning | Warning state |
| Info | info | Information |

### 6.3 Leave Type Icons

| Leave Type | Icon | Color |
|------------|------|-------|
| Annual | beach_access | #27AE60 |
| Medical | local_hospital | #E74C3C |
| Emergency | priority_high | #F39C12 |
| Unpaid | money_off | #8E8E9A |
| Maternity | pregnant_woman | #E91E63 |
| Paternity | child_friendly | #2196F3 |
| Compassionate | sentiment_satisfied | #9C27B0 |
| Replacement | swap_horiz | #00BCD4 |

---

## 7. MOTION DESIGN

### 7.1 Timing

| Type | Duration | Use |
|------|----------|-----|
| Instant | 0ms | Immediate feedback |
| Fast | 100ms | Micro-interactions |
| Normal | 200ms | Standard transitions |
| Slow | 300ms | Complex transitions |
| Emphasis | 500ms | Draw attention |

### 7.2 Easing

| Curve | Use |
|-------|-----|
| ease-out | Enter animations |
| ease-in | Exit animations |
| ease-in-out | State changes |
| spring | Playful emphasis |

---

## 8. RESPONSIVE DESIGN

### 8.1 Breakpoints

| Name | Width | Navigation |
|------|-------|------------|
| Watch | 0-199 | Single screen |
| Phone | 320-599 | Bottom nav |
| Tablet | 600-1023 | Rail + content |
| Desktop | 1024+ | Drawer + content |

### 8.2 Content Adaptation

| Component | Phone | Tablet | Desktop |
|-----------|-------|--------|---------|
| Payslip list | 2 col grid | 3-4 col grid | Table view |
| Leave balance | Stack | 2-3 col | 4 col |
| Dashboard | Single col | 2 col | 3 col |
| Forms | Full width | Max 600px | Max 600px |

---

## 9. DARK MODE

### 9.1 Dark Colors

| Element | Light | Dark |
|---------|-------|------|
| Background | #FAFAFA | #0F0F1A |
| Surface | #FFFFFF | #1A1A2E |
| Surface Elevated | #FFFFFF | #2D2D44 |
| Border | #E0E0E5 | #3D3D54 |
| Text Primary | #1A1A2E | #FFFFFF |
| Text Secondary | #6B6B7B | #A8A8B3 |
| Primary | #1A5276 | #5DADE2 |

### 9.2 Dark Mode Rules

1. **Don't invert** - Redesign for dark, don't just invert
2. **Reduce contrast** - Use #FFFFFF sparingly
3. **Desaturate colors** - Reduce vibrance
4. **Test readability** - Ensure WCAG compliance
5. **Respect system** - Follow OS preference

---

## 10. ACCESSIBILITY

### 10.1 Color Contrast

| Element | Minimum | Our Standard |
|---------|---------|--------------|
| Body text | 4.5:1 | 7:1+ |
| Large text | 3:1 | 5:1+ |
| UI components | 3:1 | 4.5:1+ |

### 10.2 Touch Targets

| Element | Minimum | Recommended |
|---------|---------|-------------|
| Buttons | 44×44dp | 48×48dp |
| List items | 44dp height | 56dp height |
| Spacing | 8dp | 12dp |

### 10.3 Screen Reader

- All images have `alt` text
- Icons have `aria-label`
- Forms have visible labels
- Errors are announced
- Focus is managed

---

## 11. WRITING STYLE

### 11.1 Tone

- **Clear** - Simple words, short sentences
- **Helpful** - Guide users to success
- **Friendly** - Warm but professional
- **Respectful** - Acknowledge user's time

### 11.2 UI Text Guidelines

| Element | Guideline | Example |
|---------|-----------|---------|
| Buttons | Action verb | "Submit", "Apply", "Cancel" |
| Labels | Noun | "Email", "Password" |
| Errors | What + How | "Invalid email. Check format." |
| Empty | What + Why + Action | "No payslips yet. They'll appear here." |
| Success | Confirm action | "Leave request submitted" |

### 11.3 Terminology

| Use | Don't Use |
|-----|-----------|
| Leave | Time off, PTO |
| Payslip | Pay stub |
| Approve | Accept |
| Reject | Deny, Decline |
| Submit | Send |

---

## 12. IMPLEMENTATION CHECKLIST

### Design System Files

- [ ] Design tokens (JSON/Dart)
- [ ] Component library (Flutter widgets)
- [ ] Icon set (SVG)
- [ ] Font files
- [ ] Color assets
- [ ] Animation specs
- [ ] Documentation

### Quality Checks

- [ ] All colors from tokens
- [ ] All fonts from tokens
- [ ] All spacing from tokens
- [ ] WCAG 2.2 AA compliance
- [ ] Responsive testing
- [ ] Dark mode testing
- [ ] RTL testing
- [ ] Animation testing
- [ ] Performance testing

---

**Document Version:** 4.0
**Last Updated:** January 9, 2026
**Maintainer:** KerjaFlow Design Team

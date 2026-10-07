# Changelog

## Unreleased

### Breaking changes

The APIs deprecated in 0.3.1 are removed. [UPGRADING.md](https://github.com/gwtbootstrap5/gwtbootstrap5-parent/blob/master/UPGRADING.md#upgrading-to-040) has the replacement for each one.

- `Affix`: use `StickyHelper` and `StickyPosition`. `Affix.affix(widget)` is `StickyHelper.setSticky(widget, StickyPosition.TOP, 10)`.
- Extras: `BootboxGlobal.init(JsSimpleCallback)`: use `Bootbox.init(SimpleCallback)` or `setOnShown`.
- `Tooltip` / `Popover`: `setViewportSelector` and `getViewportSelector` are removed. `viewport` was a Bootstrap 3 option, and the setter wrote `data-bs-selector`, which overrode the `selector` option of the tip. Use `setSelector` for tips on descendants added later.
- Extras: jQuery 4.0.0 instead of 3.7.1, and jQuery Migrate (4.0.2) is only loaded by Summernote and ColorPicker, which need it with jQuery 4. Code of your own that relied on the Migrate the extras loaded may need it in the host page; see [UPGRADING.md](https://github.com/gwtbootstrap5/gwtbootstrap5-parent/blob/master/UPGRADING.md#jquery-4).

### Features

Bootstrap 5.3 classes and options that had no API, from an audit against Bootstrap 5.3.8:

- Grid: `ColumnOffset.XXL_5`, which was missing; `ColumnSize.XS_AUTO` … `XXL_AUTO` (`col-auto`, `col-md-auto`…) and `RowColSize.XS_AUTO` … `XXL_AUTO` (`row-cols-auto`…).
- Gutters: `Row.setGutter`, `setGutterX` and `setGutterY` with `Gutter`, `GutterX` and `GutterY` (`g-*`, `gx-*`, `gy-*`, one per breakpoint). In UiBinder, `<b:Row gutter="XS_2 MD_4">`.
- `TableResponsive`: a wrapper that scrolls a wide table, at every width or below a `TableResponsiveBreakpoint`.
- `ProgressStacked`: several `Progress` in one bar, each with `Progress.setPercent`.
- `Tooltip` / `Popover`: `setOffset`, `setFallbackPlacements`, `setBoundary`, `setCustomClass`, `setSanitize` and `setAllowList`. Turning the sanitizer off lets HTML in the title run: only do it for trusted content.
- Dropdowns (`DropDown`, `ListDropDown`, `NavbarDropdown`): `setOffset`, `setBoundary`, `setReference` (`DropDownReference`) and `setDisplay` (`DropDownDisplay`).
- `ScrollSpy`: `setRootMargin`, `setSmoothScroll` and `setThreshold`.
- `Carousel.setKeyboard` and `setTouch`; `Modal.setDataFocus`.
- `ListBox.setSize` (`form-select-lg` / `-sm`) and `FormLabel.setSize` (`col-form-label-lg` / `-sm`).
- Validation: `HelpBlock.setValidText` shows a success message (`valid-feedback`) and marks the control as valid when it passes; `setFeedbackTooltip(true)` shows the messages as tooltips (`invalid-tooltip` / `valid-tooltip`).
- `DropDownItemText`: plain text in a dropdown menu (`dropdown-item-text`).
- `CardHeader`: a `NavTabs` or `NavPills` added to it gets `card-header-tabs` or `card-header-pills`.
- `NavbarNav.setScroll` (`navbar-nav-scroll`) and `setScrollHeight`.
- `BlockQuoteFooter`: the source of a quote (`figcaption.blockquote-footer`).
- `Styles`: `TABLE_GROUP_DIVIDER`, `CAPTION_TOP`, `CARD_LINK`, `DROPDOWN_TOGGLE_SPLIT`, `INITIALISM` and the other classes above.

### Updated libraries

| Library | Before | Now |
| --- | --- | --- |
| jQuery | 3.7.1 | 4.0.0 |
| jQuery Migrate | 3.5.0 | 4.0.2, only with Summernote and ColorPicker |

## 0.3.1 (2026-10-07)

### Features

- `StickyHelper` and `StickyPosition`: Bootstrap 5.3's sticky positions, `sticky-top`, `sticky-bottom` and their breakpoint variants (`sticky-md-top`…), with an optional offset from the edge, and `removeSticky` to undo them. In UiBinder, `<b.html:Div sticky="TOP">`. The demo has a Sticky page.
- Extras: `DialogOptions` and the alert, confirm and prompt options take `setOnShow`, `setOnShown`, `setOnHide` and `setOnHidden`, which run when that dialog shows or hides.

### Updated libraries

| Library | Before | Now |
| --- | --- | --- |
| Tom Select | 2.5.2 | 2.6.2 |
| Font Awesome Free | 7.0.1 | 7.3.1: 17 new icons in `IconTypeFASolid` / `IconTypeFARegular` and 60 in `IconTypeFABrands`, none removed |
| Air Datepicker | 3.5.3 | 3.6.0 |
| jQuery UI | 1.14.1 | 1.14.2 |

- Extras: the URL variants (`TempusDominusURL`, `AirDatepickerURL`…) load the same version as the bundled one. `TempusDominusURL` loaded 6.9.4 while 6.10.4 was bundled, and `AirDatepickerURL` loaded 3.6.0 while 3.5.3 was bundled.
- Extras: the bundled Tom Select CSS is the one of its version; it was the CSS of an older release.
- Extras: the `animate.compat` CSS bundled with Animate.css is the one of 4.1.1, like the rest; it was the one of 4.0.0.
- Extras: the bundled jQuery UI is the complete build, the same as `JQueryUIURL` loads, with the theme's icon images, which were missing.

### Fixes

- Extras: `Bootbox.init(SimpleCallback)` never called its callback. It now runs every time a Bootbox dialog is shown; calling it again replaces the callback, and `null` removes it.

### Deprecated

- `Affix`, replaced by `StickyHelper`; it will be removed in 0.4.0. It gains `unaffix`, and its javadoc says that its default offset is 10 pixels.
- Extras: `BootboxGlobal.init(JsSimpleCallback)`. In Bootbox 6, `bootbox.init(...)` creates a new Bootbox instead of registering a callback. Use `Bootbox.init(SimpleCallback)` or `setOnShown`.

## 0.3.0 (2026-10-07)

### Breaking changes

The APIs deprecated in 0.2.x are removed. [UPGRADING.md](https://github.com/gwtbootstrap5/gwtbootstrap5-parent/blob/master/UPGRADING.md#upgrading-to-030) has the replacement for each one.

- `ListBox(boolean)`: use `new ListBox()` and `setMultipleSelect(true)`.
- `Tooltip` and `Popover`: `reconfigure()`, which did nothing, and `setText(String)`, which only called `setTitle(String)`. **UiBinder templates with `<b:Tooltip text="…">` or `<b:Popover text="…">` stop compiling with GWT** (not with javac): use `title="…"`.
- `ComplexWidget` overrides `insert(Widget, com.google.gwt.dom.client.Element, int, boolean)` instead of GWT's deprecated variant with `com.google.gwt.user.client.Element`. Only subclasses that override that protected method need to change.

### Fixes

- Extras: `Select`, `MultipleSelect`, `DatePicker`, `TimePicker` and `DateTimePicker` destroy their JavaScript widget when they are removed from the page, and create it again when they are added back, keeping the selected value or date. Tempus Dominus pickers used to leave their widget in `<body>` every time their page was shown again.
- `Icon`'s option getters (`isSpin()`, `isBorder()`…) and `UnorderedList.isUnstyled()` / `isInline()` returned `false` as soon as the widget had any other class.
- `RoleHelper.hasRole` returned `true` for elements without a `role`.
- `OrderedList.setInline(false)` didn't remove `list-inline`.
- Extras: `SummernoteLanguage.GL_ES`, `LT_LV` and `SR_RS_LATIN` left the editor in English: their codes weren't the ones their translation files register.

### Documentation

- Javadoc for the whole public API of core and extras, with links to the Bootstrap 5.3 pages and UiBinder examples. CI fails if a documented package gets a gap again.

## 0.2.0 (2026-10-06)

Bootstrap 5.3.8 for GWT, now on Maven Central as `io.github.gwtbootstrap5`.

**[See every widget running in the demo](https://gwtbootstrap5.github.io/)**, next to the UiBinder code that creates it.

```xml
<dependency>
  <groupId>io.github.gwtbootstrap5</groupId>
  <artifactId>gwtbootstrap5</artifactId>
  <version>0.2.0</version>
</dependency>
<dependency>
  <groupId>io.github.gwtbootstrap5</groupId>
  <artifactId>gwtbootstrap5-extras</artifactId>
  <version>0.2.0</version>
</dependency>
```

### Highlights

- **JsInterop instead of JSNI**, and **no jQuery in the core module**. Popper is loaded by core; the extras that still need jQuery load it themselves.
- **New components:** Offcanvas, Accordion items, Switch, FloatingLabel, Placeholder, InputColor, Ratio, HStack / VStack, VerticalRule, NavUnderline and CardGroup.
- **Color modes:** light and dark for the page or for a single widget, or following the system.
- **More Bootstrap 5.3 options:** dropdowns controlled from Java, fullscreen, centered and scrollable modals, horizontal and flush list groups, check and radio buttons with `btn-check`, validation messages with Bootstrap 5 markup.
- **Many fixes** to markup that was still Bootstrap 3 or 4: breadcrumbs, pagination, dropdown items, navs, popovers, carousel indicators, spinners, alerts, collapse and more. The [demo](https://gwtbootstrap5.github.io/) covers every component.
- **Extras:** Bootbox 6, Tempus Dominus 6 and Air Datepicker 3, Tom Select 2, Summernote 0.9, bootstrap-slider 11, animate.css 4 and Font Awesome 7. `Select` now works without a subclass.

### Upgrading from 0.1.x

The groupId, the jQuery wrapper and several Bootstrap 3/4 widgets and constants changed. [UPGRADING.md](https://github.com/gwtbootstrap5/gwtbootstrap5-parent/blob/master/UPGRADING.md) lists every breaking change with the code to update.

### Links

- [Demo](https://gwtbootstrap5.github.io/) and [getting started](https://gwtbootstrap5.github.io/#setup)
- Javadoc: [core](https://javadoc.io/doc/io.github.gwtbootstrap5/gwtbootstrap5/0.2.0), [extras](https://javadoc.io/doc/io.github.gwtbootstrap5/gwtbootstrap5-extras/0.2.0)
- Maven Central: [core](https://central.sonatype.com/artifact/io.github.gwtbootstrap5/gwtbootstrap5/0.2.0), [extras](https://central.sonatype.com/artifact/io.github.gwtbootstrap5/gwtbootstrap5-extras/0.2.0)
- Issues: [core](https://github.com/gwtbootstrap5/gwtbootstrap5/issues), [extras](https://github.com/gwtbootstrap5/gwtbootstrap5-extras/issues)

# Upgrading to 0.2.0

GWTBootstrap5 0.2.0 replaces all JSNI (`/*-{ }-*/` methods) and `JavaScriptObject` overlay types with JsInterop, in both `gwtbootstrap5` and `gwtbootstrap5-extras`. Core widgets now call Bootstrap 5's own JavaScript API instead of jQuery.

This is a clean break: the old signatures are removed, not deprecated. Most applications only use the widgets and won't need to change any code. You need to change code if you use any of the following:

| You use | Section |
| --- | --- |
| jQuery in your own code, relying on GWTBootstrap5 to load it | [jQuery is no longer loaded by core](#jquery-is-no-longer-loaded-by-core) |
| `org.gwtbootstrap5.client.shared.js.JQuery` or `EventHandler` | [Core jQuery wrapper removed](#core-jquery-wrapper-removed) |
| `GwtBootstrap5ClientBundle.gwtBootstrap5()`, `jQuery()` or `jQueryMigrate()` | [Client bundle resources removed](#client-bundle-resources-removed) |
| `Affix` | [Affix uses sticky positioning](#affix-uses-sticky-positioning) |
| `Styles.FORM_CONTROL_RANGE`, or `InputRange` with custom CSS | [InputRange uses form-range](#inputrange-uses-form-range) |
| The extras `org.gwtbootstrap5.extras.popper` module | [Popper is loaded by core](#popper-is-loaded-by-core) |
| Bootbox `DialogOptions`, `AlertOptions`, `ConfirmOptions` or `PromptOptions` as a `JavaScriptObject` | [Bootbox](#bootbox) |
| `TempusDominusLocales` or `AirDatepickerLocales` | [Datetimepicker locales](#datetimepicker-locales) |
| `Range.toJsArray()`, `new Range(JsArrayNumber)`, or a subclass of `RangeBase` | [Range / slider](#range--slider) |
| `SummernoteImageUploadEvent.ImageFile`, `getImages()` or `insertImages()` | [Summernote](#summernote) |

## Update the dependency

```xml
<dependency>
  <groupId>org.gwtbootstrap5</groupId>
  <artifactId>gwtbootstrap5</artifactId>
  <version>0.2.0</version>
</dependency>
<dependency>
  <groupId>org.gwtbootstrap5</groupId>
  <artifactId>gwtbootstrap5-extras</artifactId>
  <version>0.2.0</version>
</dependency>
```

Both modules now depend on `elemental2-dom` (which brings in `elemental2-core` and `jsinterop-base`). Maven pulls them in for you, and the GWT modules inherit `elemental2.dom.Dom` and `jsinterop.base.Base`, so your `.gwt.xml` doesn't need to change.

## Host page and script loading

### jQuery is no longer loaded by core

`gwtbootstrap5` no longer loads jQuery or jQuery Migrate. Only the extras whose third-party library still needs jQuery load it, and only when jQuery isn't already on the page:

| Module | Loads jQuery |
| --- | --- |
| Core `gwtbootstrap5` | No |
| Bootbox, Summernote, ColorPicker, jQuery UI | Yes (bundled, or from the jQuery CDN in the `*URL` modules) |
| Range (bootstrap-slider) | No. It uses bootstrap-slider's vanilla API |
| Everything else in extras | No |

**If your own code uses jQuery** (`$`, `jQuery`, or jQuery plugins you add yourself), load it in your host page before the GWT module:

```html
<script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
<script src="mymodule/mymodule.nocache.js"></script>
```

Bootstrap only registers its jQuery plugins (`$.fn.modal`, `$.fn.tooltip`, ...) if jQuery is already present when Bootstrap loads. When an extra loads jQuery after core has loaded Bootstrap, it registers those plugins itself, so jQuery-based libraries such as Bootbox keep working. You don't need to do anything for this.

### Bootstrap detection

Core checks for `window.bootstrap` to decide whether to inject Bootstrap's JavaScript. If your host page already loads Bootstrap 5, core won't inject it again.

### Popper is loaded by core

Bootstrap 5's dropdowns, popovers and tooltips need Popper, and so does Tempus Dominus. In 0.1.x, `GwtBootstrap5` didn't load Popper, so tooltips failed with `Bootstrap's tooltips require Popper` unless you also inherited the extras `popper` module.

Core now includes Popper 2.11.8. `GwtBootstrap5` injects it (and `GwtBootstrap5URL` loads it from jsDelivr) before Bootstrap, whenever the `window.Popper` global is missing. This happens even if your host page already loads Bootstrap, because `bootstrap.bundle.js` embeds Popper without exposing that global, and Tempus Dominus needs it.

The extras `popper` module is removed. Remove these inherits from your `.gwt.xml`:

```xml
<inherits name="org.gwtbootstrap5.extras.popper.Popper"/>
<inherits name="org.gwtbootstrap5.extras.popper.PopperURL"/>
<inherits name="org.gwtbootstrap5.extras.popper.PopperNoResources"/>
```

If you use `GwtBootstrap5NoResources`, your host page loads Bootstrap itself and must also provide the `window.Popper` global (load `popper.min.js`) if you use Tempus Dominus.

## Core (`gwtbootstrap5`)

### Core jQuery wrapper removed

`org.gwtbootstrap5.client.shared.js.JQuery` and `org.gwtbootstrap5.client.shared.js.EventHandler` are removed. Use the widget's own API where it has one. Otherwise, use the native Bootstrap types in the same package (`BootstrapModal`, `BootstrapToast`, `BootstrapCarousel`, `BootstrapCollapse`, `BootstrapTab`, `BootstrapTooltip`, `BootstrapPopover`, `BootstrapAlert`, `BootstrapScrollSpy`) and plain DOM events.

Before:

```java
JQuery.jQuery(element).modal("show");
JQuery.jQuery(element).on("shown.bs.modal", event -> onShown());
```

After:

```java
BootstrapModal.getOrCreateInstance(element, null).show();

// Bootstrap 5 events are native DOM events
DomEventListeners listeners = new DomEventListeners();
listeners.add(element, "shown.bs.modal", event -> onShown());
// ... and when the widget is detached:
listeners.removeAll();
```

If you only need jQuery itself, load it in your host page (see above). The extras module has its own `org.gwtbootstrap5.extras.shared.js.JQuery` type, but it only covers the plugins the extras need (Summernote, bootstrap-colorpicker) and isn't meant as a general jQuery API.

### Client bundle resources removed

`GwtBootstrap5ClientBundle.gwtBootstrap5()`, `jQuery()` and `jQueryMigrate()` are removed, and so are the files behind them (`gwtbootstrap5.js` and the bundled jQuery / jQuery Migrate). `GwtBootstrap5ClientBundle.bootstrap()` is still there.

If you injected jQuery from the core bundle, load it in your host page instead, or call `org.gwtbootstrap5.extras.shared.js.JQueryLoader.ensureLoaded()` if you depend on `gwtbootstrap5-extras`.

### Affix uses sticky positioning

Bootstrap 5 removed the affix plugin, so `Affix` didn't work on 0.1.x: it called `$.fn.affix`, which no longer exists. It now uses CSS sticky positioning (Bootstrap's `sticky-top` class):

- The offset is the distance in pixels **from the top of the viewport** at which the element sticks. In Bootstrap 3's affix it was the number of pixels scrolled before the element was pinned.
- A sticky element sticks within its parent, so the parent must be taller than the element.

### InputRange uses form-range

`InputRange` used the Bootstrap 4 classes `form-control form-control-range`, so it rendered as an unstyled slider inside a text-field border. It now has only Bootstrap 5's `form-range` class.

`Styles.FORM_CONTROL_RANGE` (`"form-control-range"`) is replaced by `Styles.FORM_RANGE` (`"form-range"`). If you styled `.form-control-range` yourself, target `.form-range` instead.

## Extras (`gwtbootstrap5-extras`)

### Bootbox

The options classes are no longer `JavaScriptObject`s. `newOptions()` and every setter are unchanged, so code that only uses them compiles as before. Only code that called `JavaScriptObject` methods breaks.

Before:

```java
DialogOptions options = JavaScriptObject.createObject().cast();
AlertOptions alert = someJavaScriptObject.cast();
```

After:

```java
DialogOptions options = DialogOptions.newOptions("Message");
AlertOptions alert = AlertOptions.newOptions("Message");
```

The callback interfaces (`SimpleCallback`, `ConfirmCallback`, `PromptCallback`) are unchanged.

Bootbox 6 requires a title for prompts. `PromptOptions.newOptions(message)` sets only the message, so also call `setTitle(...)`, or Bootbox throws `prompt requires a title`.

### Datetimepicker locales

The locale lookups return `Object` instead of `JavaScriptObject`:

- `TempusDominusLocales.getLocaleAndLoadItIfNotLoaded(String)`
- `TempusDominusLocales.getLocale(String)`
- `AirDatepickerLocales.getLocaleAndLoadItIfNotLoaded(String)`

Before:

```java
JavaScriptObject locale = TempusDominusLocales.getLocaleAndLoadItIfNotLoaded("de");
```

After:

```java
Object locale = TempusDominusLocales.getLocaleAndLoadItIfNotLoaded("de");
```

The built-in English Tempus Dominus locale (`"en"`) now returns `null` instead of throwing a `NullPointerException`, and a `null` locale isn't loaded.

### Range / slider

`Range` uses elemental2 arrays instead of `JsArrayNumber`:

Before:

```java
JsArrayNumber array = range.toJsArray();
Range range = new Range(jsArrayNumber);
```

After:

```java
elemental2.core.JsArray<Double> array = range.toJsArray();
Range range = new Range(jsArrayOfDoubles);
```

`Range.fromString(String)` and `new Range(double, double)` are unchanged.

**Subclasses of `RangeBase`** (most applications only use `Slider` and `RangeSlider`, and can skip this): the protected hooks that took `Element`, `Event` or `JavaScriptObject` are replaced by two conversion methods. Remove `setValue(Element, T)`, `getValue(Element)`, `setFormatterOption(JavaScriptObject)`, `setFormatter(Element)`, `onSlide(Event)`, `onSlideStart(Event)`, `onSlideStop(Event)` and `onSlideChange(Event)`, and implement:

```java
/** Converts a value to the number (or two-number array) bootstrap-slider expects. */
protected abstract Object toJsValue(T value);

/** Converts a number (or two-number array) from bootstrap-slider; may receive null. */
protected abstract T toValue(Object value);
```

`isSliderNamespaceAvailable()` is removed: Range no longer uses jQuery, so there is no `slider` / `bootstrapSlider` namespace to check.

Behavior changes:

- Options set before the slider is attached are now applied. In 0.1.x they were written to `data-bs-slider-*` attributes, which bootstrap-slider ignores. If you set those attributes yourself (for example in UiBinder), rename them to `data-slider-*`.
- Changing an option on an attached slider (`setStep`, `setTicks`, `setFormatter`, ...) recreates the slider and keeps its current value. In 0.1.x the value was reset, and adding ticks after creation broke the layout. `refresh()` still calls bootstrap-slider's `refresh()`.
- `getOrientation()`, `getTooltip()`, `getSelection()`, `getHandle()`, `getScale()` and `getTooltipPosition()` return the actual setting. They used to always return the default.

### Summernote

`SummernoteImageUploadEvent.ImageFile` is removed. Uploaded images are `elemental2.dom.File` objects:

| Method | 0.1.x | 0.2.0 |
| --- | --- | --- |
| `SummernoteImageUploadEvent.getImages()` | `com.google.gwt.core.client.JsArray<ImageFile>` | `elemental2.core.JsArray<File>` |
| `SummernoteBase.insertImages(...)` | `com.google.gwt.core.client.JsArray<ImageFile>` | `elemental2.core.JsArray<File>` |

Before:

```java
summernote.addSummernoteImageUploadHandler(event -> {
    JsArray<ImageFile> images = event.getImages();
    for (int i = 0; i < images.length(); i++) {
        ImageFile image = images.get(i);
        upload(image.getName(), image.getSize(), image.getType());
    }
});
```

After:

```java
summernote.addSummernoteImageUploadHandler(event -> {
    JsArray<File> images = event.getImages();
    for (int i = 0; i < images.length; i++) {
        File image = images.getAt(i);
        upload(image.name, image.size, image.type);
    }
});
```

`ImageFile.getMetadata()` has no replacement. Build the string from `name`, `size` and `type` if you need it.

`insertImages(...)` now inserts the images as data URLs. In 0.1.x it called a command that doesn't exist in Summernote 0.9, so it never inserted anything.

## Other fixes that change behavior

- `Toast.isShown()` returns whether the toast is shown. It used to return the jQuery object.
- `Modal.setHideOtherModals(true)` works again: opening the modal hides the other open modals. It used the Bootstrap 3 `.modal.in` selector, which never matched in Bootstrap 5.
- `DateTimePicker`, `DatePicker` and `TimePicker` with the Tempus Dominus engine work. In 0.1.x they threw `b.display is undefined` when attached, and reading the value failed because `picked` is a getter. Each picker now gets its own localization, so an English picker created after a German one stays in English, and `setLocale(...)` after attach switches the language. English month names are in English rather than the browser's language.
- The native `TempusDominus` type's `setLocale(String)`, which doesn't exist in Tempus Dominus 6, is replaced by `locale(String)`.
- `RangeBase.isVisible()` no longer recurses forever when the slider isn't attached.
- A `RangeSlider` with a formatter no longer throws a `NullPointerException`. bootstrap-slider also passes single numbers, for the separate min / max tooltips, and those become a `Range` with equal bounds.

## Known issues

- `Bootbox.init(SimpleCallback)` never calls its callback. In Bootbox 6, `bootbox.init(...)` reinitialises Bootbox instead of registering a callback. This was already the case in 0.1.x.

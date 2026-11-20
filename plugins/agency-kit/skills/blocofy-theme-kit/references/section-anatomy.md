# Section anatomy

A section = one `.liquid` file in `section/`: markup on top, `{% schema %}`
JSON at the bottom. The filename (minus extension) is the `type` referenced by
page documents.

## Skeleton

```liquid
<section class="xy-example">
  <div class="xy-wrap">
    {%- if props.title and props.title != blank -%}
    <h2 class="xy-example__title" data-reveal>{{ props.title | escape }}</h2>
    {%- endif -%}
    {%- for b in blocks -%}
      <div class="xy-example__item">{{ b.settings.text | escape }}</div>
    {%- endfor -%}
  </div>
</section>

{% schema %}
{
  "name": "Readable Name",
  "category": "Content",
  "settings": [
    { "type": "text", "id": "title", "label": "Title", "translatable": true, "bindable": true }
  ],
  "blocks": [
    { "type": "item", "settings": [
      { "type": "text", "id": "text", "label": "Text", "translatable": true }
    ]}
  ],
  "presets": [
    { "name": "Example", "settings": { "title": "Placeholder title" },
      "blocks": [ { "type": "item", "settings": { "text": "Placeholder" } } ] }
  ]
}
{% endschema %}
```

## Rules learned the hard way

- Access settings via `props.x`; guard every optional with
  `and props.x != blank`: empty settings render as empty strings, not nil.
- **Liquid does not escape output.** Print every value through the filter
  for its field type (Blocofy docs, "Tema şeması"):

  | Value | Filter |
  |---|---|
  | `text`, `textarea`, `number`, select fields, plain-text entry fields (in attributes too) | `escape` |
  | `richtext`, `inline_richtext` | `sanitize_html` |
  | `html` (embed code) | `sanitize_embed` |
  | `url`, `video_url` and anything printed into `href`/`src` (menu, social, legal links included) | `safe_url` |

  `escape` does not protect a link: `safe_url` prints the value only when it
  starts with `https://`, `http://`, `mailto:`, `tel:` or is a path inside
  the site, otherwise `#`. Link settings use the `url` field type. Pattern:
  `href="{{ props.cta_url | default: '#' | safe_url }}"`. A possibly rich
  field shown as short text: `strip_html | escape`.
- Multi-value inputs that editors type freely: accept a delimited string and
  `split` in Liquid (comma for short tags, `;` for sentence lists).
- Images: run through `image_url` filter with explicit size/format params;
  it accepts media IDs and CDN URLs.
- `richtext` settings output HTML (print with `sanitize_html`); style
  descendant tags in CSS (`.xy-article__body h2 {…}`), don't wrap each element.
- Chrome sections declare `"areas": ["header"]` or `["footer"]`.
- Forms: fixed fields in markup, POST to `/api/forms/{{ props.form_key }}/submit`
  via fetch; include a honeypot input, consent checkbox with a legal link, and
  an `aria-live` status line. `"type": "form"` in schema gives the picker.
- JSON-LD: emit from section data where natural (e.g. FAQPage from qa blocks)
  using `| json` for values.

## Alias (legacy) sections

When a new theme goes onto a site whose chrome/pages reference older type
names, ship silent alias files for those types: a comment + empty render +
minimal schema. This prevents visitor-facing "unknown section" boxes during
migration. List every alias in the theme README with a removal plan.

# Contract: content-model.json (contractVersion 1)

Written by Phase 3; read by Phases 4-5. Maps every planned section and page to
its data source, and declares the collections/forms to exist on the platform.

```json
{
  "contractVersion": 1,
  "collections": [
    {
      "key": "case_studies",
      "name": "",
      "content_page": true,
      "fields": [ { "name": "", "label": "", "type": "text|textarea|image|richtext|date|select|multi_select|relation|number", "options": [] } ]
    }
  ],
  "forms": [ { "key": "contact", "fields": "fixed-in-theme", "redirect": "/thanks", "notify": "set-in-panel" } ],
  "pages": [
    {
      "slug": "/",
      "template": false,
      "sections": [ { "type": "XySectionName", "data": "static|collection:case_studies|form:contact|globals" } ]
    },
    { "slug": "/work/[slug]", "template": true, "bound_collection": "case_studies",
      "bindings": { "XyCaseHero.title": "entry.title", "XyCaseHero.image": "entry.data.cover" } }
  ]
}
```

Rules:
- Field lists here are the single source when creating/patching collections.
  `fields` in this file is what the platform API calls `field_schema`; send
  the whole list every time (the platform replaces the schema on save).
- `multi_select` options must be complete before entries are written.
- Every dynamic template page lists its bindings explicitly; Phase 5 verifies
  each binding against a real entry.

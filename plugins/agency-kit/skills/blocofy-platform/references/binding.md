# Data binding: collections → sections

## In page documents (dynamic templates like `/blog/[slug]`)

Bind a section setting to the routed entry:

```json
"settings": {
  "heading": { "$bind": "entry.title" },
  "image":   { "$bind": "entry.data.cover" },
  "content": { "$bind": "entry.data.body" }
}
```

Only settings declared `"bindable": true` in the section schema accept binds.

## In Liquid (listing sections)

```liquid
{%- assign items = entries[props.collectionKey] -%}
{%- for item in items limit: props.limit -%}
  {{ item.title }} · {{ item.url }} · {{ item.data[props.imageField] }}
{%- endfor -%}
```

Sorting: `| sort: '-id'` (newest) / `| sort: 'title'`.

### Grouping by relation: filter, don't nest

`where` works on a first-level relation path:

```liquid
{%- assign items = entries[props.itemsKey] -%}
{%- for cat in entries[props.categoriesKey] -%}
  {%- assign in_cat = items | where: 'data.<relation>.id', cat.id -%}
  {%- for item in in_cat -%} … {%- endfor -%}
{%- endfor -%}
```

Replacing a nested category × item loop (inner `if item.data.<relation>.id ==
cat.id`) with this cuts render time sharply once a collection has a few
hundred entries. Use it for any menu/catalog grouped by a relation field.

### Image fields in entries

Media-library URLs (`/cdn/<id>/…`, `/assets/<id>`) written into entry `data`
(e.g. from an import script) are **normalized to media ids**; reading them back
returns the id, not the URL. External URLs are stored as-is. Always render
through `image_url`, which accepts both:
`{{ item.data.image | image_url: 'width=800&format=webp' }}`.
Need the URL in an API read? `?include=media` (MCP `include_media: true`)
adds a separate `media` object; `data` keeps the id.

## Section schema types that power the editor

| Type | Purpose |
|---|---|
| `collection` | picker for a collection key |
| `collectionField` + `dependsOn` | picker for a field of the chosen collection |
| `form` | picker for a form key |
| `richtext` | rich text, render with `{{ props.x }}` |
| any + `"bindable": true` | allows `$bind` in dynamic pages |

## Collection CRUD traps

- `update_collection` with `field_schema` **replaces the whole schema** —
  GET first, modify, send the FULL list, check `removed_fields: []` in the reply.
- Entry `data` on update is also full-replace: GET → merge → PATCH.
- `multi_select` values must match the declared options; add options via a
  full-schema update before writing entries that use them.
- Collections with `content_page: true` give each entry its own routed page
  (`/key/[slug]` template).

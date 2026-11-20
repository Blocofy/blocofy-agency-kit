# Blocofy adapter

Platform mekaniği `blocofy-platform`, tema kuralları `blocofy-theme-kit`, faz makinesi
`blocofy-orchestrator`, QA `blocofy-qa` skill'lerindedir. Bu dosya onları tekrar etmez;
statik prototipten Blocofy temasına geçişe özgü eşlemeyi, hattı ve kuralları verir.
Geçici platform hataları `known-issues.md`'de.

## Prototip → Blocofy eşlemesi

| Prototip | Blocofy | Not |
|---|---|---|
| `templates/pages/*.liquid` | `section/<Önek>*.liquid` + sayfa belgesi (v2) | Sayfa = section listesi; metin ve görsel section ayarında |
| `templates/partials/` | `partial/<önek>-*.liquid` | Aynı işlev; veri `entries[...]` / `entry` üzerinden |
| `templates/layouts/base.liquid` | `layout/theme.liquid` | head, noindex kilidi, JSON-LD, asset yükleme |
| header / footer | chrome section'ları | Oluşturma API'si hatalıysa sitedeki mevcut chrome tiplerinin dosyaları yeniden yazılır (PS-03) |
| Birincil koleksiyon (`data/collections/*.json`) | Koleksiyon + `content_page: true` | Dinamik rota `/<yol>/[slug]` |
| İkincil koleksiyon (kategori vb.) | Koleksiyon (ilişki hedefi) + statik sayfalar | İki koleksiyon aynı `[slug]` desenini paylaşamaz; ilk eşleşen kazanır |
| UI sözlüğü `ui-*.json` | `config/settings_schema.json` + ayar değerleri | Script ile üretilir; panelden düzenlenebilir |
| Form (`data-endpoint`) | `/api/forms/<key>/submit` + form tanımı | Aynı JS; honeypot alanı platform adıyla |
| `src/css`, `src/js` | `asset/theme.css`, `asset/*.js` | Script üretir: `/assets` URL'leri CDN'e, küçültme, `{{ }}` koruması; elle düzenlenmez |
| `assets/img`, video | Medya kütüphanesi (CDN) | Manifest: yerel yol → medya id/URL |

Kategori benzeri ikincil koleksiyonlar için editör alanı eklerken (ör. kısa ad) şema
PATCH'i tam liste ister: önce GET, birleştir, tam `field_schema` gönder.

## Hat

```
theme-build     src/css + src/js → asset/ (CDN URL, minify, Liquid kalıntı koruması)
ui-settings     ui-*.json → settings_schema.json + değerler
theme-check     ayar referansları mevcut, JSON geçerli, section'da locale dallanması yok
theme push      --instance <handle>, geçici hata (5xx, body_hash_mismatch) için yeniden deneme
settings PATCH  → push tekrar (ayar ancak push ile yansıyor olabilir: PS-06)
```

**Hedef durum (henüz kitte hazır script yok):** scriptler proje kökünde
`project.config.json` + env okur: `BLOCOFY_URL`, `INSTANCE`, rota listesi (sitemap'ten),
diller, koleksiyon anahtarları. Varsayılan instance ya da adres gömülmez; eksikse hata
verir. Canlıya yazma `--live` + `LIVE_CONFIRM` ister (`references/change-control.md`).
Bir projeden diğerine kopyalanan script, önce bu kurala göre parametreleştirilir;
gömülü proje değeri taşıyan script yeni projede çalıştırılmaz.

İçerik ve medya:
- `media` scripti: yükler, manifest tutar, tekrar yüklemez. MIME bayrağı zorunlu.
- `entries` scripti: dil başına idempotent upsert, `translation_key` ile eşleme, ilişkiler ikinci geçişte.
- `pages` scripti: sayfa belgelerini spec'ten kurar. Belge PATCH tek başına, SEO PATCH ayrı, sonra publish.

Eşdeğerlik: `textdiff` (metin), `geom` (blok geometrisi), `compare` (yan yana görüntü),
`sweep` (konsol, yinelenen id, kırık bağlantı/görsel), `form-qa`, `home-qa` (motion ve sayaçlar).
Hepsi render edilmiş sayfa üzerinde çalışır; yayın sonrası doğrulama sabit beklemeyle değil
içerik işareti gelene kadar yoklamayla yapılır (PS-07).

## Kalıcı kurallar (tasarım gereği)

- Varsayılan dil URL'i öneksiz; ikinci dil `/<kod>/` ve dil başına slug. 301 haritası buna göre.
- Sayfa ve kayıtlar dil başına satırdır; dil sürümleri `translation_key` / translation-link ile bağlanır.
- Section'larda `locale` dallanması yok; çevrilebilir ayar, `localized_url`, `locale_alternates` kullan (i18n sözleşmesi push'ta uygulanır, PS-10).
- `field_schema` ve kayıt `data` replace-on-save.
- Sayfa belgesi PATCH'i tek başına gönderilir.
- Platform her section'ı belge id'siyle sarar; belge id'lerine önek ver (`b-`), section içi id'lerle çakışmasın (PS-08; düzeltilse de önek zararsız).
- API istemcisi olarak curl kullan; bazı istemci kitaplıkları WAF tarafından engellenebilir (doctor adımında test et).
- Eski instance'lardaki dinamik şablon sayfaları canlıyı etkileyebilir; kurulumda envantere al, yedekle, çöpe at (PS-02).
- **İkinci dil ve görseller (tasarım gereği):** varsayılan dil dışındaki sayfada her görsel/video için panelde karar ("Aynısı uygun" / "Bu dile özel") ve alt metin ya da Dekoratif gerekir; aksi halde yayın `422 media_review_required`. Karar şimdilik yalnız panelden. Bu yüzden: (1) ikinci dil sayfasını **yayından önce** varsayılan dildeki karşılığına bağla (bağsızken "Aynısı uygun" seçilemez), (2) yayını kararlar verildikten sonra yalnız `publish` ile yap, (3) görselli sayfa listesini ve önerilen alt metinleri müşteri/editör için hazırla. Blocker nedenleri: `docs.blocofy.com/docs/cok-dilli#dil-sürümlerinde-görseller`.
- **Taslağı okumak:** `GET /pages/{id}?include=document` yayındaki sürümü döndürür; taslak için `&document=draft`. Panel kararları API `PATCH` ile silinmez; eşzamanlı değişiklikte `409 conflict` + `error.details.current_version`.
- **404 sayfası** çeviri grubuna bağlanamaz; her dilde ayrı işaretlenir (`is_404_page`).

## Taslak/canlı kararı

`blocofy-orchestrator` taslak instance'ta kurmayı ister. Faz 8'de deneme sayfasıyla test et:
sayfalar taslak instance'a bağlanabiliyor mu (PS-05)? Bağlanamıyorsa canlıda kurulum yalnız
test alan adında, `layout/theme.liquid` içinde noindex kilidiyle ve `decisions.md` kaydıyla.
Bu durumda sync hattı canlıya yazdığı için onay bayrağı zorunludur.

# Blocofy adapter

Platform mekaniği `blocofy-platform`, tema kuralları `blocofy-theme-kit`, faz makinesi
`blocofy-orchestrator`, QA `blocofy-qa` skill'lerindedir. Bu dosya onları tekrar etmez;
statik prototipten Blocofy temasına geçişe özgü eşlemeyi, hattı ve kuralları verir.
Tarihli hata geçmişi `known-issues.md`'de.

İki kural bu dosyanın her satırından önce gelir (`blocofy-platform`):

- Ajan canlı temaya yazmaz; `--live`, `theme publish` ve `allow_live` kullanmaz. Tema
  değişikliği bir tema çalışmasına yazılır; bir kişi önizlemeyi görür ve
  Blocofy panelinde onaylar.
- Önizlemesi olmayan yazımlar (yayınlanmış kayıt, koleksiyon şeması, menü, site ayarı,
  form, canlı sayfanın SEO ve yayın durumu, silme) `blocofy-platform`
  `references/live-writes.md`'deki dört satırlık durağı ister. Aşağıda "durak" bu demektir.

## Prototip → Blocofy eşlemesi

| Prototip | Blocofy | Not |
|---|---|---|
| `templates/pages/*.liquid` | `section/<Önek>*.liquid` + sayfa belgesi (v2) | Sayfa = section listesi; metin ve görsel section ayarında |
| `templates/partials/` | `partial/<önek>-*.liquid` | Aynı işlev; veri `entries[...]` / `entry` üzerinden |
| `templates/layouts/base.liquid` | `layout/theme.liquid` | head, noindex kilidi, JSON-LD, asset yükleme |
| header / footer | chrome section'ları | `blocofy-theme-kit` chrome desenine göre. PS-03 düzeldi olarak kayıtlı: yeniden test et, geçici çözümü yalnız hâlâ başarısızsa uygula |
| Birincil koleksiyon (`data/collections/*.json`) | Koleksiyon + `content_page: true` | Dinamik rota `/<yol>/[slug]` |
| İkincil koleksiyon (kategori vb.) | Koleksiyon (ilişki hedefi) + statik sayfalar | İki koleksiyon aynı `[slug]` desenini paylaşamaz; ilk eşleşen kazanır |
| UI sözlüğü `ui-*.json` | `config/settings_schema.json` + ayar değerleri | Script ile üretilir; panelden düzenlenebilir |
| Form (`data-endpoint`) | `/api/forms/<key>/submit` + form tanımı | Aynı JS; honeypot alanı platform adıyla |
| `src/css`, `src/js` | `asset/theme.css`, `asset/*.js` | Proje scripti üretir: `/assets` URL'leri CDN'e, küçültme, `{{ }}` koruması; elle düzenlenmez |
| `assets/img`, video | Medya kütüphanesi (CDN) | `.blocofy-build/media-registry.json`: anahtar → `media_id` |

Kategori benzeri ikincil koleksiyonlar için editör alanı eklerken (ör. kısa ad) şema
PATCH'i tam liste ister: önce GET, birleştir, tam `field_schema` gönder. Var olan bir
koleksiyonun şemasını değiştirmek durak ister.

## Hat

Kit bu hat için script taşımaz. Kitteki scriptler yalnız şunlardır:
`<skill-dir>/../blocofy-platform/scripts/` altında `api.sh` ve `doctor.sh` (`bash` ile);
`<skill-dir>/../blocofy-qa/scripts/` altında `verify-page.mjs`, `reference-recon.mjs`
(`node` ile) ve `legacy-scan-liquid.sh` (`bash` ile). Hepsi site klasöründen çalıştırılır;
`<skill-dir>` için `../../SKILL.md` Terimler. Aşağıdaki adımları
proje kendi scriptleriyle kurar; adlar öneridir, sağ sütun scriptin ne yapması
gerektiğini söyler.

| Adım (proje scripti) | Yapması gereken |
|---|---|
| Tema build | `src/css` + `src/js` → `asset/`: `/assets` URL'lerini CDN'e çevirir, küçültür, Liquid kalıntısını korur |
| UI ayarları | `ui-*.json` → `config/settings_schema.json` + ayar değerleri |
| Tema kontrolü | Ayar referansları mevcut, JSON geçerli, section'da `locale` dallanması yok |
| Tema yazımı | Yalnız tema çalışmasına yazar (`blocofy theme push <dizin> --draft --work <wk_…>`, `blocofy-platform`); geçici hatada (5xx, `body_hash_mismatch`) en çok 2–3 kez yeniden dener |
| Ayar yazımı | Ayarı tema çalışmasına yazar, render'ı kontrol eder; değişmediyse yeniden push eder (PS-06: önce yeniden test et) |

Hat canlıya yazmaz ve canlıya yazan bir bayrağı yoktur. Canlıya çıkış onay akışıdır:
ajan onay ister, kişi panelde onaylar.

Proje scriptleri site adresini, instance'ı, rota listesini, dilleri ve koleksiyon
anahtarlarını proje yapılandırmasından ve env'den okur. Varsayılan instance ya da adres
gömülmez; eksikse script hata verir. Bir projeden diğerine kopyalanan script önce buna
göre parametreleştirilir; gömülü proje değeri taşıyan script yeni projede çalıştırılmaz.

İçerik ve medya (proje scriptleri; kitte yok):
- Medya: yükler, `media_id`'yi `.blocofy-build/media-registry.json`'a yazar, tekrar yüklemez. MIME bayrağı zorunlu.
- Kayıtlar: dil başına idempotent upsert, `translation_key` ile eşleme, ilişkiler ikinci geçişte. Kayıtlar taslak yazılır; yayınlanmış kaydı oluşturmak, değiştirmek ya da silmek durak ister.
- Sayfalar: sayfa belgelerini spec'ten, taslak temaya bağlı olarak kurar. Belge PATCH tek başına, SEO PATCH ayrı. Taslak temanın sayfasını yayınlamak serbesttir; canlı temadaki sayfanın yayını ve SEO alanları durak ister.

Eşdeğerlik: kapıların istediği kanıt ve kitte script olmadığında yedek kanıt
`references/quality-gates.md`'de. Ölçüm render edilmiş taslak önizlemesi üzerinde,
sayfa başına önizleme bağlantısıyla yapılır (`blocofy-qa`). Doğrulama sabit beklemeyle
değil içerik işareti gelene kadar yoklamayla yapılır.

## Kalıcı kurallar (tasarım gereği)

`known-issues.md`'de düzeldi yazan bir satır burada kural değildir: yeniden test et,
geçici çözümü yalnız test hâlâ başarısızsa uygula.

- Varsayılan dil URL'i öneksiz; ikinci dil `/<kod>/` ve dil başına slug. 301 haritası buna göre.
- Sayfa ve kayıtlar dil başına satırdır; dil sürümleri `translation_key` / translation-link ile bağlanır.
- Section'larda `locale` dallanması yok; çevrilebilir ayar, `localized_url`, `locale_alternates` kullan (i18n sözleşmesi push'ta uygulanır).
- `field_schema` ve kayıt `data` replace-on-save.
- Sayfa belgesi PATCH'i tek başına gönderilir.
- Belge id'leri section içi id'lerle çakışmamalıdır. PS-08 düzeldi olarak kayıtlı: yeniden test et; belge id'lerine `b-` önekini yalnız çakışma hâlâ görülüyorsa ver.
- API istemcisi olarak curl kullan; bazı istemci kitaplıkları WAF tarafından engellenebilir (doctor adımında test et).
- Başka instance'lardaki eski dinamik şablon sayfaları: PS-02 düzeldi olarak kayıtlı, yeniden test et. Hâlâ canlıyı etkiliyorsa sayfaları envantere al, yedekle ve insana bildir; silmek ya da çöpe atmak durak ister.
- **İkinci dil ve görseller (tasarım gereği):** varsayılan dil dışındaki sayfada her görsel/video için panelde karar ("Aynısı uygun" / "Bu dile özel") ve alt metin ya da Dekoratif gerekir; aksi halde yayın `422 media_review_required`. Karar panelden verilir (her sitede yeniden doğrula). Bu yüzden: (1) ikinci dil sayfasını **yayından önce** varsayılan dildeki karşılığına bağla (bağsızken "Aynısı uygun" seçilemez), (2) yayını kararlar verildikten sonra yalnız `publish` ile yap (canlı temadaki sayfada durakla), (3) görselli sayfa listesini ve önerilen alt metinleri müşteri/editör için hazırla. Blocker nedenleri: `docs.blocofy.com/docs/cok-dilli#dil-sürümlerinde-görseller`.
- **Taslağı okumak:** `GET /pages/{id}?include=document` yayındaki sürümü döndürür; taslak için `&document=draft`. Panel kararları API `PATCH` ile silinmez; eşzamanlı değişiklikte `409 conflict` + `error.details.current_version`.
- **404 sayfası** çeviri grubuna bağlanamaz; her dilde ayrı işaretlenir (`is_404_page`).

## Taslak izolasyonu

`blocofy-orchestrator` taslak temada kurar. Faz 8'de deneme sayfasıyla doğrula: sayfa
taslak temaya bağlanıyor ve canlıda görünmüyor mu (PS-05 düzeldi olarak kayıtlı; yeniden
test et)? Bağlanamıyorsa dur, bulguyu insana bildir ve `decisions.md`'ye yaz. Ajan
kurulumu canlı temaya taşımaz; nasıl ilerleneceğine kişi karar verir ve ziyaretçiye
ulaşan her adım onay akışından ya da duraktan geçer.

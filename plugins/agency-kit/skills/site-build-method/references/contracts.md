# Sözleşme şablonları

Her dosyanın **tek yazarı** vardır. Sonraki fazlar okur, düzenlemez; değişiklik ilgili
fazı yeniden açarak yapılır. Yollar öneridir (`<proje>/` kökü).

---

## STATE.md (proje durumu; tek yazar: yöntemi yürüten ana oturum)

Proje kökünde durur (`<proje>/STATE.md`) ve yöntemin Faz 0–12'sini taşır. Platform
orchestrator'ının durum dosyası ayrı bir dosyadır: `.blocofy-build/STATE.md`
(orchestrator Phase 0–7, sözleşmesi `blocofy-orchestrator`
`references/contracts/build-state.md`, tek yazarı orchestrator). Bu dosya onu kapsamaz
ve kopyalamaz; Blocofy adapter'ı çalışırken Faz 8–11 satırları yalnız onu gösterir.
Yöntemi yürüten oturum `.blocofy-build/STATE.md`'ye, orchestrator da bu dosyaya yazmaz.
Faz eşlemesi `../SKILL.md`'de.

```markdown
# Build State — <proje dizini>
contractVersion: 1
method: site-build-method
updated: YYYY-MM-DD HH:MM

## Mod
mode: prototype-first | theme-direct | takeover | migration
sourceOfTruth: prototype | prototype (frozen) | theme
platform: <ad> · adapter: adapters/<ad>/
nextAction: <tek cümle, sıradaki somut adım>

## Platform (Faz 8–11)
- Platform durum dosyası: .blocofy-build/STATE.md (taslak instance, tema dizini ve themeOrigin orada yazar; burada tekrarlanmaz)
- Noindex kilidi: <açık/kapalı>

## Phases
| # | Faz | Durum | Çıktı | Kapı notu (tarih + kanıt) |
|---|---|---|---|---|
| 0 | Intake | pending | STATE.md | |
| 1 | Keşif | pending | brief.md, design-dna.md, url-map.csv | |
| 2 | Kararlar | pending | decisions.md | |
| 3 | Spec ve plan | pending | spec, plan | |
| 4 | Prototip | pending | dist/ | |
| 5 | Bağımsız inceleme | pending | docs/qa/ | |
| 6 | İçerik ve medya | pending | content-inventory.csv, .blocofy-build/media-registry.json | |
| 7 | Onay ve dondurma | pending | client-signoff.md | |
| 8 | Platform kurulumu | pending | capture-map.md → .blocofy-build/STATE.md Phase 0–3 | |
| 9 | Tema ve eşdeğerlik | pending | parity-report.md → .blocofy-build/STATE.md Phase 4–6 | |
| 10 | Yayın öncesi | pending | prelaunch-checklist.md → .blocofy-build/STATE.md Phase 6 | |
| 11 | Yayın | pending | yayın notu → .blocofy-build/STATE.md Phase 7 | HUMAN APPROVAL |
| 12 | Devir-teslim | pending | handover.md | |

## Engeller ve bekleyen onaylar
- …

## Session cache pointers (gitignored, bilgi amaçlı)
- …
```

Kurallar: durum yalnız kapı kontrolüyle ilerler; `done` kanıt ister; bir faz yeniden
açılınca sonrakiler `pending` olur. Karar ve açık sorular bu dosyada birikmez, kendi
dosyalarına yazılır. Faz 8–11 satırı ancak hem yöntemin kendi kapısı kanıtlı hem de
gösterdiği orchestrator Phase'leri `.blocofy-build/STATE.md`'de `done` ise `done` olur.
Başka bir platformda adapter kendi durum dosyasını adlandırır; kural aynıdır.

---

## decisions.md (yazar: Faz 2, sonra değişiklik kontrolü)

```markdown
## D-003 · 2026-..-.. · Varsayılan dil URL öneki
- Karar: varsayılan dil öneksiz, ikinci dil /en/
- Alternatifler: her dil önekli (/tr/, /en/)
- Gerekçe: platform varsayılanı; 301 haritası daha kısa
- Etki: url-map.csv yeni sütunu, hreflang, prototip url filtresi
- Onaylayan: <ad, kanal> · Durum: geçerli | yerini aldı: D-0xx
```

Kabul edilmiş riskler de buraya karar olarak yazılır (ör. "platformdaki performans puanı bütçenin altında; neden sunucu yanıt süresi; 30. gün yeniden ölçülecek").

---

## open-questions.md

| # | Soru | Sahibi (müşteri/ajans) | Son tarih | Etkilediği faz | Durum / yanıt |
|---|---|---|---|---|---|

---

## content-inventory.csv

```csv
sayfa,alan,kaynak,sahibi,durum,hak_lisans,kanit,not
/hakkimizda,hero_baslik,mevcut site,müşteri,onaylı,-,-,
/kalite,sertifika_listesi,müşteri e-postası,müşteri,müşteride,-,belge PDF bekleniyor,desteksiz iddia
```

`durum`: `taslak | müşteride | onaylı`. İddia içeren alanlarda `kanit` boş kalamaz.

---

## url-map.csv

```csv
eski_url,yeni_url,kod,kaynak,dogrulandi
/eski/ornek-kayit/,/koleksiyon/ornek-kayit,301,sitemap+GSC,2026-..-..
/eski-kampanya/,,410,crawl,2026-..-..
```

Her satır tek atlamayla 200'e varmalı (kanıt: `quality-gates.md`). Yeni URL şeması platformda değişirse yeni sütun Faz 8'de yeniden üretilir.

---

## data-schema.md (yazar: Faz 3)

- Çok dilli alan: `{"<locale>": "…"}`; dil listesi `site.json.locales`.
- Koleksiyon başına alan tablosu: ad, tip, zorunlu, örnek, kaynak (content-inventory satırı).
- Bilinmeyen değer `null`; şablonlar boş alanı atlar.
- Görsel alanları rol bazlı: `{koleksiyon}--{slug}-{rol}[-{genişlik}].{webp|avif}`; genişlikler performans bütçesinden.
- İlişkiler kimlikle (`"kategori": "<id>"`), çift yönlü ilişkiler tek tarafta tutulur.

---

## dom-contract.md (yazar: Faz 3; motion/JS buna bağlanır)

| Seçici / öznitelik | Nerede | Davranış | Sahibi |
|---|---|---|---|
| `[data-reveal]` | tüm sayfalar | toplu belirme; içerik CSS ile gizlenmez, başlangıcı JS verir | motion |
| `[data-count]` | istatistik blokları | tek seferlik sayaç; SSR değeri son değer | motion |
| `[data-pin]` | seçili sahneler | pin; mobilde yok | motion |
| `[data-accent="<anahtar>"]` | koleksiyon bazlı renk | `--accent` değişkenini ayarlar | brand |

Sınıf adları projeye aittir; öznitelik adları rol bazlı ve kararlı tutulur. Şablon ve
motion ayrı ajanlarca, bu tabloya göre yazılır. Öznitelik adları tema iskeletindekilerle
aynıdır (`blocofy-theme-kit` `references/motion-adapter.md`).

---

## capture-map.md (yazar: Faz 8, yöntemi yürüten oturum)

Prototip çıktısının hangi platform sözleşmesine nasıl çevrileceğini söyler. Haritayı
yöntem yazar; `.blocofy-build/` altındaki sözleşme dosyalarını orchestrator'ın ilgili
Phase'i bu haritadan yazar (her dosyanın tek yazarı). Blocofy örneği:

| Prototip kaynağı | Platform sözleşmesi | Alan eşlemesi | Durum |
|---|---|---|---|
| `src/css/tokens.css` + `design-dna.md` | `.blocofy-build/design-dna.json` (sözleşme v2) | `design_read`, `dials`, `color`, `typography`, `shape`, `layout`, `style` (imza öğesi dahil), `motion` | |
| `design-dna.md` kavram bölümü + spec + medya kararları | aynı dosya, `visual_language` | `concept`, `vocabulary`, `families` | |
| `decisions.md` + `client-signoff.md` | aynı dosya, `decisions[]` ve `meta.revision` | müşterinin yön seçimi ve sonraki tasarım kararları, kendi sözleriyle | |
| `templates/pages/*` | aynı dosya, `sections_sketch` | sayfa → section listesi | |
| `ia-sitemap.md` + `brief.md` | `.blocofy-build/brief.md` | site haritası, sayfa amaçları | |
| `data/*.json` + `data-schema.md` | `.blocofy-build/content-model.json` | koleksiyonlar, alan tipleri, sayfa → section bağları | |
| UI sözlüğü | tema ayarları şeması | anahtar → ayar id | |

Alanların tam listesi ve kapı kontrolü `blocofy-orchestrator`
`references/contracts/design-dna.md` ve `content-model.md`'dedir; burada yinelenmez.

Kapı: her satır `done`; sözleşme dosyaları platform skill'lerinin kapı kontrolünden geçiyor.

---

## parity-report.md (yazar: Faz 9)

```markdown
# Eşdeğerlik raporu: <tarih>
| Dil | Sayfa türü | Sayfa | Metin birebir | Geometri (blok) | Tarama | Not |
|---|---|---|---|---|---|---|

## Bilinçli farklar
| Sayfa | Fark | Neden | Karar (D-xxx) |

## Eşdeğerlik aracının prototipte bulduğu hatalar
- …
```

---

## Medya kaydı: `.blocofy-build/media-registry.json`

Ayrı bir manifest tutulmaz. Tek kayıt `blocofy-media`'nın dosyasıdır; alanları
`blocofy-media` `references/asset-system.md`'de. Yöntemin gerek duyduğu ek alanlar aynı
kayda eklenir: `source` (`client | stock | ai`), `license`, `local_path`,
`alt` (`{"<locale>": "…"}`). Maliyet ve deneme sayısı kayda değil
`.blocofy-build/credits.md`'ye yazılır; başarısız ve reddedilen üretimler de orada sayılır.

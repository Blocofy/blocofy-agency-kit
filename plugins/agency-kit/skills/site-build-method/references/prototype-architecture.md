# Statik prototip mimarisi

Amaç: tasarım, içerik, motion ve kaliteyi platformdan bağımsız, hızlı döngüde bitirmek ve
şablonları hedef platformun şablon diline az değişiklikle çevirebilmek. Hedef platform
Liquid kullanıyorsa prototip de LiquidJS ile yazılır.

## Bağımlılıklar

Şablon motoru (LiquidJS), küçültücü (esbuild), tarayıcı otomasyonu (Playwright ya da
Puppeteer), Lighthouse. Başka çerçeve yok; çıktı düz HTML.

## Klasör yapısı

```
data/                 site.json (marka, iletişim, menü, locales) · pages.json · ui-*.json (UI sözlüğü)
                      collections/<koleksiyon>.json   (ör. products, services, locations)
templates/
  layouts/base.liquid         head, header, footer, script yükleme, hreflang
  partials/                   tekrar eden bileşenler (kart, CTA bandı, sayfa başlığı …)
  pages/                      site haritasından türeyen sayfa tipleri
src/css/              tokens · fonts · base · components · sections · <alan>.css · motion
src/js/               main (menü, form, dil) · <alan>.js · motion.js
assets/               img/ · video/ · fonts/ (dil alt kümeli)
scripts/              build.mjs · check.mjs · shoot.mjs · qa-interactions.mjs · prepare-images
docs/                 research/ · specs/ · plans/ · qa/
```

CSS dosyaları alan bazlı bölünür (ana sayfa, koleksiyon sayfaları, iç sayfalar); taşımada
tek `theme.css`'e birleştirilir.

## Build hattı

```
data/*.json → LiquidJS + çekirdek filtreler → dist/<locale>/… → sitemap.xml + hreflang + kök yönlendirme → check
```

### Çekirdek filtreler

| Filtre | Görev |
|---|---|
| `t` | UI sözlüğünden anahtar çevirir; bulunamayan anahtar check'te hata |
| `l` | `{"<locale>": …}` nesnesinden aktif dili seçer |
| `url` | Dile göre yol üretir; çapa (#) çevirisi dahil |
| `entry_url` | Koleksiyon kaydının dile göre adresi (koleksiyon başına yardımcılar projeye ait) |
| `n` | Dile göre sayı biçimi |

Koleksiyona özgü yardımcılar (sayım, ilişki çözme) projede tanımlanır, yönteme girmez.

### check.mjs (0 hata kapısı)

- Sayfa sayısı beklenen alt sınırın üstünde (`locales × sayfa tipleri`).
- Şablon kalıntısı yok (`{{`, `{%`).
- Her `<img>` alt metinli; dekoratifse `alt="" aria-hidden="true"`.
- İç bağlantılar kırık değil; hreflang çift yönlü.
- Çevrilmemiş anahtar yok (`t` ham anahtar döndürmemiş).

## Veri kuralları

- Çevrilebilir her alan `{"<locale>": …}`; arayüz metinleri `ui-*.json`'da.
- Bilinmeyen değer `null`; şablon boş alanı atlar (dil nesnesi dolu ama değer boşsa çevrilmiş değere bak).
- Görsel adları veriden türetilir ve rol bazlıdır; kart boyutu için küçük varyant (`-sm`) + `srcset`.
- İlk ekrandaki görseller `eager` + `fetchpriority`; diğerleri `lazy`.

## Tasarım sistemi kuralları

- **Renk:** tüm renkler token değişkenlerinden; token dışı hex yasak. Koleksiyon bazlı aksan gerekiyorsa `[data-accent]` ile `--accent` değişir. Aksan metninin arkasına ton koyma: kontrastı düşürür. Kontrast matrisi dosyası: `docs/qa/contrast.json`.
- **Tipografi:** üç rol (display, gövde, aksan/etiket). Sınıflar role göre (`.t-display`, `.t-accent`, `.t-label`); font değişince HTML değişmez. Modüler ölçek. Fontlar sitenin dillerine göre alt kümelenir, metrik uyumlu fallback tanımlanır.
- **Şekil ve boşluk:** radius, çizgi kalınlığı ve boşluk ölçeği token. Sibling grupları `gap` ile; kart/çerçeve/gölge rol bazlı harcanır.
- **İmza öğesi:** tek, somut, marka dünyasından. Geri kalan sakin.
- **İçerik cihazı:** kaynağa özgü veriyi (tablo, oran, süreç, hesap) içerik olarak görselleştir; süs için değil.

## Motion kuralları

- Kütüphane ve sürüm plan'da sabitlenir (ör. GSAP + ScrollTrigger + Lenis).
- Yalnız `transform` ve `opacity`. Pin bütçesi sayfa başına sınırlı, mobilde 0.
- Reduced-motion: kapatma değil alternatif senaryo (fade, sayaçlar son değerde).
- İçerik CSS ile gizlenmez; başlangıç durumunu JS verir. JS ya da CDN düşerse perde/emniyet zamanlayıcısı içeriği açar.
- Video: sayfa yüklendikten sonra bağlanır; reduced-motion / veri tasarrufu / autoplay reddinde poster kalır.

## Formlar

Prototipte form, `data-endpoint` varsa oraya `FormData` gönderir, yoksa gönderimi konsola
yazar. Honeypot alanı, istemci doğrulaması, başarı/hata durumları prototipte biter; platform
fazında yalnız endpoint bağlanır.

## QA araçları

- `shoot.mjs`: sayfa + genişlik → ekran görüntüsü + konsol + gizli reveal sayımı.
- `qa-interactions.mjs`: menü, mega menü, dil, form modları, no-JS.
- Lighthouse: mobil emülasyon, 3 temsilci sayfa (ana sayfa, koleksiyon dizini, kayıt detayı).

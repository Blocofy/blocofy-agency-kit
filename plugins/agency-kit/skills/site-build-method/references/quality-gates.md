# Kalite kapıları

Her kapı üç parçalıdır: **kanıt** (komut ya da dosya) · **eşik** · **onaylayan + tarih**.
Sonuç yalnız `geçti | geçmedi | kabul edilmiş risk (D-xxx)` olabilir. Proje değerleri
bu dosyaya değil `docs/qa/` ve `STATE.md`'ye yazılır. "Proje scripti" yazan satırlarda
kit script taşımaz; ne gerektiği ve script yoksa hangi kanıtın geçerli olduğu aşağıdaki
"Kitte scripti olmayan kapılar" bölümündedir.

## Kapı tablosu

| Ölçüt | Faz | Eşik (varsayılan, spec'te değiştirilebilir) | Kanıt nasıl üretilir | Kanıt dosyası |
|---|---|---|---|---|
| Prototip check | 4 | 0 hata | Proje scripti (`prototype-architecture.md` check maddeleri) | `docs/qa/<tarih>-check.txt` |
| Konsol hatası | 4, 9 | 0 (390 / 1024 / 1440 px) | Proje scripti ya da yedek kanıt | `docs/qa/<tarih>-console.json` |
| Gizli içerik | 4 | reduced-motion ve no-JS'de 0 gizli reveal | Proje scripti ya da yedek kanıt; `prefers-reduced-motion` ve JS kapalı | aynı |
| Plan görevleri | 4 | Her görev tam (kısmi yok) | Görev inceleme dosyaları | ledger |
| Bağımsız inceleme | 5 | Kritik bulgu 0 | Reviewer raporu | `docs/qa/<tarih>-final-review.md` |
| Performans (prototip) | 5 | Lighthouse mobil ≥ 85; LCP ≤ 2,5 s; CLS ≤ 0,05; toplam JS ≤ bütçe | Lighthouse 3 temsilci sayfa | `docs/qa/<tarih>-lighthouse.json` |
| Performans (platform) | 10 | Spec'teki platform bütçesi; tutmazsa kabul edilmiş risk | Lighthouse aynı sayfalar, taslak önizlemesinde; yayından sonra canlıda yeniden | `docs/qa/<tarih>-lighthouse-platform.json` |
| Erişilebilirlik otomatik | 5, 10 | Lighthouse a11y 100 | Lighthouse | lighthouse dosyaları |
| Kontrast matrisi | 3, 10 | Her kullanılan ön/arka plan çifti metinde ≥ 4,5:1, büyük metin/UI ≥ 3:1 | Proje scripti ya da yedek kanıt | `docs/qa/contrast.json` |
| Klavye yolu | 10 | Menü, mega menü, formlar, pin'li bölümler klavyeyle kullanılabilir; odak görünür | Elle, adımlı kayıt | `docs/qa/<tarih>-keyboard.md` |
| Ekran okuyucu | 10 | İki kritik akış (ör. kayıt bulma, form gönderme) VoiceOver/NVDA ile tamamlanıyor | Elle | `docs/qa/<tarih>-screenreader.md` |
| Dokunma hedefi | 5 | ≥ 24 px (tercihen 44) | Script ya da Lighthouse | lighthouse |
| İçerik onayı | 6 | `content-inventory.csv` durum sütunu %100 onaylı | CSV sayımı | csv |
| Medya | 6 | İşaretsiz yer tutucu 0; lisans alanı tam; bütçe içinde | Kayıt sayımı ve kredi toplamı | `.blocofy-build/media-registry.json`, `.blocofy-build/credits.md` |
| Metin eşdeğerliği | 9 | Her dilde birebir; farklar gerekçeli | Proje scripti ya da yedek kanıt | `parity-report.md` |
| Geometri eşdeğerliği | 9 | Blok konum/boyut toleransı (ör. ±4 px); font kaynaklı satır kırılımı not edilir | Proje scripti ya da yedek kanıt | `parity-report.md` |
| Section sözleşmesi | 9 | content-model section tipleri ↔ tema dosyaları iki yönlü eşleşiyor | Proje scripti ya da yedek kanıt | `parity-report.md` |
| Rota taraması | 9, 11 | Yinelenen id 0, kırık iç bağlantı/görsel 0 | Proje scripti ya da yedek kanıt | `docs/qa/<tarih>-sweep.txt` |
| 301 | 10, 11 | `url-map.csv` her satırı tek atlamayla 200 | Proje scripti ya da yedek kanıt | `docs/qa/<tarih>-redirects.csv` |
| hreflang / canonical / sitemap | 10 | Çift yönlü hreflang; canonical kendine; sitemap yeni şemada | tarama | aynı |
| Yapılandırılmış veri | 10 | Prototipteki şemalar platformda da var ve geçerli | Rich Results test / tarama | `docs/qa/<tarih>-schema.md` |
| Formlar | 10 | Her formdan bir gerçek test; alıcı müşteri adresi | Gönderim + gelen kutusu kontrolü; Blocofy'da gerçek gönderim durak ister (`blocofy-platform` `references/live-writes.md`) | `prelaunch-checklist.md` |

## Kitte scripti olmayan kapılar

Kit bu kapılar için script taşımaz ve böyle bir script varmış gibi davranılmaz. Kitteki
tek tarama aracı `blocofy-qa` skill'indeki `verify-page.mjs`'tir
(`node <skill-dir>/../blocofy-qa/scripts/verify-page.mjs`, site klasöründen): sayfa başına önizleme
bağlantısı alır; rota başına HTTP durumu, konsol hatası, bilinmeyen section sayısı ve
ekran görüntüsü verir. Proje kendi scriptini aşağıdaki tanıma göre yazar. Yazmadıysa
yedek kanıt geçerlidir: yedek kanıtı işi yapan değil gözden geçiren üretir ve dosyaya
tarih, sayfa listesi ve sonucu yazar.

| Kapı | Proje scripti neyi kontrol etmeli | Script yoksa yedek kanıt |
|---|---|---|
| Prototip check | `prototype-architecture.md`'deki check maddelerini `dist/` üzerinde sayar, hata varsa sıfırdan farklı çıkar | Aynı maddelerin elle işaretli listesi (`docs/qa/<tarih>-check.txt`) |
| Konsol hatası ve gizli içerik (Faz 4) | Her sayfa tipini üç genişlikte, ayrıca reduced-motion ve JS kapalı açar; konsol hatasını ve görünmeyen `[data-reveal]` öğelerini sayar | Tarayıcıda elle: sayfa tipi başına üç genişlik ve iki mod, adımlı kayıt |
| Kontrast matrisi | Kullanılan her ön/arka plan token çiftinin kontrast oranını hesaplar, eşiğin altını listeler | Aynı çiftlerin elle ölçülmüş tablosu (`docs/qa/contrast.json` ya da `.md`) |
| Metin eşdeğerliği | Aynı rotanın prototip ve platform render'ından görünür metni çıkarır, dil başına farkı listeler | `verify-page.mjs` taraması + sayfa tipi ve dil başına elle metin karşılaştırması, `parity-report.md`'de "elle" notuyla |
| Geometri eşdeğerliği | Aynı genişlikte iki render'da ana blokların konum ve boyutunu ölçer, toleransı aşanı listeler | Sayfa tipi başına 390 ve 1440 px yan yana ekran görüntüleri + gözden geçirenin notu |
| Section sözleşmesi | content-model'deki section tipleri ile temadaki section dosyalarını iki yönlü karşılaştırır | `verify-page.mjs` bilinmeyen section 0 + iki listenin elle karşılaştırması |
| Rota taraması | Tüm rotalarda konsol hatasını, yinelenen id'yi, kırık iç bağlantı ve görseli sayar | `verify-page.mjs` tüm rotalarda (HTTP 200, konsol 0, bilinmeyen section 0) + yinelenen id ve kırık bağlantı için kayıtlı elle kontrol |
| 301 | `url-map.csv`'nin her satırını ister; atlama sayısını ve son durum kodunu yazar | Satır başına `curl -sIL` çıktısı dosyada |

## Kurallar

- İşi yapanın raporu kapıyı kapatmaz; ölçümü gözden geçiren ya da script yeniden çalıştırır.
- İki ayrı performans bütçesi vardır. Platform bütçesi tutmazsa neden (TTFB, asset servis, enjeksiyon), kim kabul etti ve ne zaman yeniden ölçüleceği `decisions.md`'ye yazılır.
- Noindex'li test ortamında SEO skoru düşük çıkar; bu beklenen durum olarak not edilir, yayından sonra yeniden ölçülür.
- Eşdeğerlik aracı prototipte hata bulursa (ör. boş alanın etiketi basılıyor) önce prototip düzeltilir, sonra eşdeğerlik yeniden çalışır.

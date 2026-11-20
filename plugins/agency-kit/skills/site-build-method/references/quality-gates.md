# Kalite kapıları

Her kapı üç parçalıdır: **kanıt** (komut ya da dosya) · **eşik** · **onaylayan + tarih**.
Sonuç yalnız `geçti | geçmedi | kabul edilmiş risk (D-xxx)` olabilir. Proje değerleri
bu dosyaya değil `docs/qa/` ve `STATE.md`'ye yazılır.

## Kapı tablosu

| Ölçüt | Faz | Eşik (varsayılan, spec'te değiştirilebilir) | Ölçüm yöntemi | Kanıt dosyası |
|---|---|---|---|---|
| Prototip check | 4 | 0 hata | `npm run check` | `docs/qa/<tarih>-check.txt` |
| Konsol hatası | 4, 9 | 0 (390 / 1024 / 1440 px) | shoot / sweep scripti | `docs/qa/<tarih>-console.json` |
| Gizli içerik | 4 | reduced-motion ve no-JS'de 0 gizli reveal | shoot scripti, `prefers-reduced-motion` ve JS kapalı | aynı |
| Plan görevleri | 4 | Her görev tam (kısmi yok) | Görev inceleme dosyaları | ledger |
| Bağımsız inceleme | 5 | Kritik bulgu 0 | Reviewer raporu | `docs/qa/<tarih>-final-review.md` |
| Performans (prototip) | 5 | Lighthouse mobil ≥ 85; LCP ≤ 2,5 s; CLS ≤ 0,05; toplam JS ≤ bütçe | Lighthouse 3 temsilci sayfa | `docs/qa/<tarih>-lighthouse.json` |
| Performans (platform) | 10 | Spec'teki platform bütçesi; tutmazsa kabul edilmiş risk | Lighthouse aynı sayfalar, canlı/taslak | `docs/qa/<tarih>-lighthouse-platform.json` |
| Erişilebilirlik otomatik | 5, 10 | Lighthouse a11y 100 | Lighthouse | lighthouse dosyaları |
| Kontrast matrisi | 3, 10 | Her kullanılan ön/arka plan çifti metinde ≥ 4,5:1, büyük metin/UI ≥ 3:1 | Token çiftleri scripti | `docs/qa/contrast.json` |
| Klavye yolu | 10 | Menü, mega menü, formlar, pin'li bölümler klavyeyle kullanılabilir; odak görünür | Elle, adımlı kayıt | `docs/qa/<tarih>-keyboard.md` |
| Ekran okuyucu | 10 | İki kritik akış (ör. kayıt bulma, form gönderme) VoiceOver/NVDA ile tamamlanıyor | Elle | `docs/qa/<tarih>-screenreader.md` |
| Dokunma hedefi | 5 | ≥ 24 px (tercihen 44) | Script ya da Lighthouse | lighthouse |
| İçerik onayı | 6 | `content-inventory.csv` durum sütunu %100 onaylı | CSV sayımı | csv |
| Medya | 6 | İşaretsiz yer tutucu 0; lisans sütunu tam; bütçe içinde | manifest sayımı | `media-manifest.json` |
| Metin eşdeğerliği | 9 | Her dilde birebir; farklar gerekçeli | textdiff scripti | `parity-report.md` |
| Geometri eşdeğerliği | 9 | Blok konum/boyut toleransı (ör. ±4 px); font kaynaklı satır kırılımı not edilir | geom scripti | `parity-report.md` |
| Section sözleşmesi | 9 | content-model section tipleri ↔ tema dosyaları iki yönlü eşleşiyor | eşleme scripti | `parity-report.md` |
| Rota taraması | 9, 11 | Yinelenen id 0, kırık iç bağlantı/görsel 0 | sweep scripti | `docs/qa/<tarih>-sweep.txt` |
| 301 | 10, 11 | `url-map.csv` her satırı tek atlamayla 200 | redirect scripti | `docs/qa/<tarih>-redirects.csv` |
| hreflang / canonical / sitemap | 10 | Çift yönlü hreflang; canonical kendine; sitemap yeni şemada | tarama | aynı |
| Yapılandırılmış veri | 10 | Prototipteki şemalar platformda da var ve geçerli | Rich Results test / tarama | `docs/qa/<tarih>-schema.md` |
| Formlar | 10 | Her formdan bir gerçek test; alıcı müşteri adresi | Gönderim + gelen kutusu kontrolü | `prelaunch-checklist.md` |

## Kurallar

- İşi yapanın raporu kapıyı kapatmaz; ölçümü gözden geçiren ya da script yeniden çalıştırır.
- İki ayrı performans bütçesi vardır. Platform bütçesi tutmazsa neden (TTFB, asset servis, enjeksiyon), kim kabul etti ve ne zaman yeniden ölçüleceği `decisions.md`'ye yazılır.
- Noindex'li test ortamında SEO skoru düşük çıkar; bu beklenen durum olarak not edilir, yayından sonra yeniden ölçülür.
- Eşdeğerlik aracı prototipte hata bulursa (ör. boş alanın etiketi basılıyor) önce prototip düzeltilir, sonra eşdeğerlik yeniden çalışır.

# Yayın öncesi kontrol listesi (Faz 10)

Projeye kopyalanır ve işaretlenir. Her maddenin yanına kanıt dosyası ya da bağlantı yazılır.
İşaretsiz madde varken Faz 11'e geçilmez; bilinçli atlananlar `decisions.md`'de.

## SEO taşıma
- [ ] `url-map.csv` tam: eski sitemap + tarama + (varsa) Search Console tıklama/backlink sayfaları
- [ ] Her satır tek atlamayla 200'e varıyor ya da bilinçli 410 (script çıktısı)
- [ ] Canonical kendine; hreflang çift yönlü ve `x-default` var
- [ ] Sitemap yeni URL şemasında; robots doğru
- [ ] Yapılandırılmış veri (Organization, Breadcrumb, kayıt tipine uygun şema) geçerli
- [ ] Başlık ve meta açıklamaları her dilde dolu, tekrar yok
- [ ] Yayından sonra kaldırılacak noindex kilidinin yeri ve kaldırma adımı yazılı

## Hukuk
- [ ] Aydınlatma metni, çerez politikası, kullanım koşulları müşteri (hukukçusu) onaylı
- [ ] Formlardaki onay kutusu metne bağlantılı, zorunluluk durumu doğru
- [ ] Veri saklama süresi ve form bildirimlerinin kime gittiği kayıtlı
- [ ] Görsel, font ve video lisansları `media-manifest.json`'da tam

## İzin ve analitik
- [ ] Çerez/izin bandı çalışıyor ve markaya uygun
- [ ] Analitik ve pazarlama etiketleri izinden sonra yükleniyor
- [ ] Dönüşüm olayları ölçülüyor (form gönderimi, telefon/WhatsApp tıklaması, teklif)
- [ ] Test trafiği analitikten ayrılıyor

## Formlar
- [ ] Her formdan tek gerçek test gönderildi (müşteri izniyle) ve bildirim ulaştı
- [ ] Bildirim alıcıları müşteriye ait adresler; geçici test alıcıları geri alındı
- [ ] Spam koruması (honeypot / rate limit) çalışıyor
- [ ] Başarı ve hata durumları her dilde doğru

## Performans
- [ ] Prototip bütçesi ölçüldü
- [ ] Platform bütçesi aynı sayfalarda ölçüldü; tutmayan metrik için kabul edilmiş risk kaydı var
- [ ] İlk ekran görselleri önceliklendirildi; video yalnız sayfa yüklendikten sonra bağlanıyor

## Erişilebilirlik
- [ ] Lighthouse a11y 100 (temsilci sayfalar)
- [ ] Klavye yolu: menü, mega menü, formlar, pin'li bölümler
- [ ] İki kritik akış ekran okuyucuyla tamamlandı
- [ ] Kontrast matrisi dosyası güncel
- [ ] `lang` öznitelikleri doğru (platform yeniden yazıyorsa değer kontrol edildi)
- [ ] Reduced-motion ve no-JS'de içerik tam

## Güvenlik
- [ ] Depoda ve `.mcp.json`'da literal token yok (grep)
- [ ] Anahtarlar en az yetkiyle; devir-teslimde döndürülecekler listelendi
- [ ] Canlıya yazan scriptler onay bayrağı olmadan çalışmıyor
- [ ] CDN'den yüklenen her script ve stil dosyası tam sürüme sabitli, `integrity` ve `crossorigin` taşıyor (grep; Google Fonts CSS hariç)

## Geri dönüş
- [ ] Önceki canlı durumun yedeği: instance/sürüm id, tema dosyaları, sayfa belgeleri, eski site
- [ ] Geri alma komutu ya da adımları yazılı ve bir kez denendi (taslakta)
- [ ] Geri alınamaz işlemler listelendi (platformda silinemeyen dosyalar vb.)

## Onay
- [ ] Alan adı bağlama ve noindex kaldırma için tarihli açık onay
- [ ] Yayın penceresi ve iletişim kişisi belirlendi

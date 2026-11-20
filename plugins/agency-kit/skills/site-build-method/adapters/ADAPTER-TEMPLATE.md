# Platform adapter şablonu

Yeni bir CMS için `adapters/<platform>/README.md` bu sorularla doldurulur. Faz 2'de
platform seçimine girdi olur; Faz 8'de kurulumun kontrol listesidir.

## 1. Platform seçimi soruları

| Konu | Soru | Neden önemli |
|---|---|---|
| Çok dil | Dil ekleme API/panelden mi; varsayılan dil önekli mi; kayıtlar dil başına satır mı alan mı; çeviri bağı nasıl kurulur? | URL şeması, hreflang, içerik modeli |
| Rota | Dinamik şablon deseni nedir (`/x/[slug]`); iki koleksiyon aynı deseni paylaşabilir mi; eşleşme sırası? | Kategori/kayıt sayfalarının nasıl kurulacağı |
| Taslak/canlı | Taslak tema ya da sürüm izolasyonu gerçekten var mı; önizleme nasıl imzalanır? | Canlıya dokunmadan kurulum |
| Ayar yayılımı | Tema ayarı ve içerik değişikliği ne zaman render'a yansır; önbellek süresi? | Doğrulama bekleme stratejisi |
| Medya | Kabul edilen tipler (SVG, woff2, video), boyut sınırı, CDN dönüşüm parametreleri? | Logo, font, görsel stratejisi |
| Asset servis | Tema CSS/JS dosya olarak mı servis edilir, satır içi mi; önbellek başlıkları? | Performans tavanı |
| Enjeksiyon | Platform `<html>`, font, çerez bandı, section sarmalayıcısı gibi ne ekler? | Çakışma ve a11y |
| Şablon dili | Liquid/Twig/JSX; ilişki derinliği; SEO alanları şablonda erişilebilir mi? | Prototipten çeviri maliyeti |
| Formlar | Gönderim ucu, spam koruması, alıcı yönetimi, kayıtlara API erişimi? | Form akışı ve test |
| Yönlendirme | 301 yönetimi panel/API/dosya; toplu içe aktarma? | SEO taşıma |
| Silme ve geri alma | Tema dosyası silinebilir mi; sürüm geri alma var mı? | Geri dönüş planı |
| Editör deneyimi | Section ayarları, koleksiyon düzenleme, önizleme müşteri için anlaşılır mı? | Devir-teslim |
| Otomasyon | CLI, REST, MCP; WAF engelleri; yetki kapsamları? | Scriptler ve güvenlik |
| Maliyet ve destek | Plan, limitler, hata bildirme kanalı, düzeltme süresi? | Takvim ve risk |
| Ajans kiti | Bu platform için kit/skill var mı, olgun mu? | Mod kararı (`theme-direct` eşiği) |

## 2. Adapter README bölümleri

1. Prototip → platform eşleme tablosu (sayfa, partial, koleksiyon, UI sözlüğü, form, asset)
2. Sync/deploy hattı (komutlar, onay bayrakları)
3. İçerik ve medya aktarım scriptleri (idempotent, manifestli)
4. Eşdeğerlik araçlarının platforma uyarlanması (render edilmiş sayfa nasıl alınır)
5. Kalıcı kurallar (tasarım gereği davranışlar)
6. `known-issues.md` bağlantısı (geçici hatalar)

## 3. known-issues.md sütunları

`Kod | Başlık | Son doğrulama | Yeniden test tarifi | Geçici çözüm | Etki | Kaldırma koşulu`

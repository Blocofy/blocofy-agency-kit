# Değişiklik kontrolü, kayma, güvenlik ve maliyet

## Dondurma ve revizyon

- Faz 7 onayıyla prototip `proto-signoff` etiketiyle dondurulur; `STATE.md` `sourceOfTruth: prototype (frozen)`.
- Dondurmadan sonra gelen her revizyon `templates/revision-request.md` ile kaydedilir: sayfa, ekran görüntüsü, beklenen, öncelik, kapsam içi/dışı.
- **Etki analizi** her revizyon için: prototip şablonu · tema section'ı · içerik modeli / koleksiyon şeması · veri · çeviri · eşdeğerlik · URL.
- Tartışmalı tasarım revizyonunda: seçenekleri görsel taslakla sun, gerekirse bağımsız tasarım görüşü al, onay al, uygula.
- Kullanıcının istediği biçim ile uzman önerisi çeliştiğinde ikisini de gösterip kullanıcıya seçtir; sessizce birini uygulama.

## Kayma politikası (prototip ↔ tema)

CSS ve JS tek kaynaktan (`src/`) tema asset'ine üretildiği sürece kaymaz. Şablonlar
(prototip Liquid ↔ tema section) ve içerik modeli elle iki kopya tutulursa kayar. Faz 7'de
aşağıdakilerden biri seçilir ve `decisions.md`'ye yazılır:

| Politika | Ne zaman | Kural |
|---|---|---|
| **A · Arşiv (varsayılan)** | Yayından sonra | Prototip `proto-archive` etiketiyle salt-okunur; tema ve CMS tek doğru kaynak; `src/` tema build'inin parçası kalır; eşdeğerlik yerine görsel regresyon (canlı ↔ önceki canlı) |
| **B · Laboratuvar** | Tasarım denemeleri sürecekse | Her değişiklik commit'i eşdeğerlik kanıtı içerir (metin + geometri); content-model her section değişikliğinde güncellenir |
| **C · Üretim** | Tekrarlı müşteri / çok site | Tema section'ları prototip şablonlarından script ile üretilir; yatırım ister |

Kapı: "iki elle yazılmış kaynak yok" ya da "her birleşen değişiklikte eşdeğerlik kanıtı var".

## Güvenlik kuralları

- Tüm anahtarlar `.env.local`'de (izin 600, gitignore). Oturumlarda token metni yazdırılmaz.
- `.mcp.json` yalnız `${ENV}` açılımı kullanır; literal token bulunursa hemen kaldırılır ve anahtar döndürülür.
- Anahtarlar en az yetkiyle açılır; eksik yetki (ör. form kayıtlarını okuma) açıkça istenir.
- **Canlıya yazma:** sync/deploy scriptleri varsayılan olarak taslağa yazar. Canlıya yazmak `--live` bayrağı ve `LIVE_CONFIRM=<instance-id>` ister. Test alan adında canlıya kurulum bir karar kaydı ister; yayından sonra bayrak yalnız onaylı yayın penceresinde kullanılır. Blocofy'da ajan `--live` kullanmaz: tema değişikliği tema çalışmasına yazılır ve bir kişi önizlemeyi görüp onaylar (`blocofy-platform`).
- Form test alıcısı ajansa ait, belgelenmiş bir adrestir; kişisel adres geçici bile olsa `decisions.md`'ye yazılır ve yayın öncesi geri alınır.
- Kalıcı silme (koleksiyon, medya, kayıt) yalnız kullanıcı eliyle ya da açık onayla; önce yedek.

## AI medya maliyet kuralları

- Faz 2'de kredi/para üst sınırı belirlenir.
- Her üretimden önce bakiye; hesabın sınırsız modu o oturumda geçerli değilse kullanıcıya söylenir.
- Model listesi her projede o gün doğrulanır; kit matrisleri tarihlidir.
- Varyant sayısı üst sınırlı (ör. istem başına 2). Her üretim turu `blocofy-media` harcama kapısından geçer: liste, tahmini maliyet, insan onayı. Onaylı listenin ya da toplamın dışına çıkan her şey yeniden onay ister.
- `media-manifest.json`'a model, kredi, deneme sayısı ve kaynak yazılır; başarısız ve reddedilen üretimler de sayılır.
- Uzun video istemleri moderasyona takılabilir: kısa klipler + kare kilitli birleştirme, kurgu yerelde (ffmpeg) yapılır.

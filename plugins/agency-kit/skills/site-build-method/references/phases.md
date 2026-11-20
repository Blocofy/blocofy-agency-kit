# Faz kartları

Her kart aynı çerçeveyi izler: **Giriş** (başlamak için ne doğru olmalı) · **Yapılacaklar** ·
**Çıktı** (sözleşme dosyaları) · **Kapı** (kanıt + eşik) · **Onay** · **STATE satırı**.
Şablonlar `contracts.md`'de. Dosya yolları öneridir; proje başka düzen seçerse `STATE.md`'de yazar.

---

## Faz 0: Intake ve kurulum

**Giriş:** Kapsam ya da teklif müşteri tarafından kabul edildi.

**Yapılacaklar**
- Proje dizini, git, `.gitignore` (`.env*`, `session/`, `dist/` gerekiyorsa).
- `.env.local` (izin 600). Anahtarlar en az yetkiyle; `.mcp.json` yalnız `${ENV}` açılımı kullanır, literal token yasak.
- `STATE.md`, `decisions.md`, `open-questions.md` şablondan açılır.
- Intake soruları: karar vericiler ve onay kanalı; marka varlıkları (logo, kılavuz, font lisansları); içerik kaynakları (katalog, Excel/ERP, mevcut site, hiçbiri); mevcut alan adı ve barındırma; hukuki gereksinim (KVKK, GDPR, sektör); analitik/pazarlama araçları; bütçe (efor, AI medya); hedef tarih.
- Hedef platform biliniyorsa doctor çalışır (Blocofy: `blocofy-platform` `scripts/doctor.sh`). API istemcisinin WAF/CDN tarafından engellenmediği doğrulanır.
- Çok dilli sitede **ikinci dil platformda şimdi açılır ve aktif olduğu doğrulanır**. Açılamazsa platforma bildirilir; tema ve içerik modeli dil-bağımsız ilerler.

**Çıktı:** `STATE.md` (mod henüz `undecided`), `decisions.md`, `open-questions.md`.
**Kapı:** Tüm erişimler doğrulandı (komut çıktısı); gizli bilgi kuralları uygulandı (`grep` ile literal token yok).
**Onay:** Ajans.
**STATE:** `| 0 | Intake | done | STATE.md | 2026-..: doctor OK, en-US aktif (GET /site), token grep temiz |`

---

## Faz 1: Keşif

**Giriş:** Faz 0 kapısı kapandı.

**Yapılacaklar** (bağımsız araştırmalar paralel alt ajanlarla)
- **Marka → design DNA.** Kaynağa göre dal:
  - Katalog/marka kılavuzu var: vektör renk çıkarımı, font tespiti, tekrar eden kalıplar, font lisans sorusu.
  - Yalnız mevcut site var: `blocofy-qa` `scripts/reference-recon.mjs` ile keşif + ekran görüntüleri (dış skill gerekmez); ücretli tema/şablon lisans uyarısı.
  - Hiçbir şey yok: brief + rakip taraması + sanat yönetimi alt ajanı; müşteriye 2–3 yön panosu (dış tasarım skill'i gerekmez).
- **Mevcut site denetimi:** sayfa ve içerik envanteri, taşınacak/bırakılacak içerik, desteksiz iddialar (sertifika, sayı, ülke listesi) işaretlenir.
- **Eski URL envanteri:** sitemap + tam tarama + (erişim varsa) Search Console'da son 12 ayda tıklama/backlink alan sayfalar → `url-map.csv` eski sütunu.
- **Kitle ve bilgi mimarisi:** personalar, işe yarar görevler, benchmark, site haritası, URL/slug ağacı, dönüşüm hedefleri.
- **Veri kaynağı kesinleştirilir.** Geç gelen kaynak (ör. resmi ürün listesi) kapsamı değiştirir; bu durumda `decisions.md`'ye kapsam değişikliği yazılır ve etkilenen fazlar yeniden açılır.
- **Motion senaryosu** (motion düzeyi orta/yüksekse): ilkeler, easing seti, süre skalası, pin bütçesi, reduced-motion alternatifi, tek imza öğesi.

**Çıktı:** `brief.md`, `design-dna.md`, `site-audit.md`, `ia-sitemap.md`, `motion-spec.md` (gerekirse), `content-inventory.csv`, `url-map.csv` (eski URL'ler).
**Kapı:** Sayfa envanteri %100; eski URL listesi tarama çıktısıyla eşleşiyor; her açık sorunun sahibi ve son tarihi var.
**Onay:** Müşteri: site haritası ve veri kaynağı.

---

## Faz 2: Kararlar

**Giriş:** Faz 1 çıktıları diskte.

**Yapılacaklar** (`superpowers:brainstorming`, soru soru)
- **Mod:** `prototype-first | theme-direct | takeover | migration` (ölçütler SKILL.md).
- **Platform:** `adapters/ADAPTER-TEMPLATE.md` sorularıyla adaylar karşılaştırılır.
- **Diller ve URL şeması:** varsayılan dilin öneki, slug çeviri kuralı, eksik çeviri politikası (gizle / varsayılana düş).
- **İş modeli:** lead-gen, e-ticaret, kurumsal vitrin, içerik. Dönüşüm olayları.
- **Yargı alanı:** KVKK / GDPR / ikisi; yasal metinlerin kaynağı (müşterinin hukukçusu).
- **Analitik ve izin:** araç, izin yönetimi, form olay ölçümü.
- **Bütçeler:** performans (prototip ve platform ayrı), AI medya (kredi/para üst sınırı), efor.
- **Form bildirim alıcıları** ve test gelen kutusu politikası.

**Çıktı:** `decisions.md` (her karar: tarih, karar, alternatifler, gerekçe, onaylayan).
**Kapı:** Her kararın alternatifi ve onaylayanı yazılı; `STATE.md` `mode` alanı dolu.
**Onay:** Müşteri.

---

## Faz 3: Spec ve plan

**Giriş:** Faz 2 kapısı kapandı.

**Yapılacaklar**
- **Spec:** karar özeti, tasarım sistemi (token değerleri, tipografi, şekil, bileşen kütüphanesi), kavram ve imza öğesi, sayfa senaryoları, site haritası, rol/ekip.
- **Plan** (`superpowers:writing-plans`): Global Constraints (token değerleri, fontlar, motion bütçesi, URL kuralı, a11y, veri kuralı), dosya yapısı, `data-schema.md`, `dom-contract.md`, 8–12 görev; her görevin test ve kabul ölçütü.
- **Roller** `roles.md` şablonlarından üretilir; girdi yolları gerçek dosyalarla doğrulanır.
- **Bütçeler** spec'e yazılır: LCP, INP, CLS, toplam JS KB, hero medya KB; AI medya üst sınırı.

**Çıktı:** `docs/specs/<tarih>-site-design.md`, `docs/plans/<tarih>-prototype.md`, `data-schema.md`, `dom-contract.md`, `.claude/agents/<önek>-*.md`.
**Kapı:** Plan öz-incelemesi (spec kapsaması, yer tutucu taraması, isim tutarlılığı) temiz; rol tanımlarındaki her girdi yolu `test -e` ile var.
**Onay:** Müşteri: spec'i okudu ve onayladı (tarihli).

---

## Faz 4: Statik prototip

**Giriş:** Plan onaylı; `data-schema.md` ve `dom-contract.md` sabit.

**Yapılacaklar**
- Sıra: veri → build/check → tokenlar → layout/header/footer → sayfa şablonları → etkileşim JS → motion → QA.
- `superpowers:subagent-driven-development`: görev başına taze alt ajan, görev sonu spec + kalite incelemesi, ledger dosyası.
- Gerçek içerikle çalış. Yer tutucu yalnız verisi olmayan alanda, görünür biçimde işaretli ve `content-inventory.csv`'de kayıtlı.
- Mimari: `prototype-architecture.md`.

**Çıktı:** `dist/`, `docs/qa/<tarih>-check.txt`, görev inceleme dosyaları.
**Kapı:** `check` 0 hata (çıktı dosyada); 390 / 1024 / 1440 px'te konsol hatası 0; reduced-motion ve no-JS'de gizli içerik 0; plandaki her görev "tam" (kısmi yok).
**Onay:** Yok; Faz 5 bağımsız incelemesi kapıyı teyit eder.
**STATE:** `| 4 | Prototip | done | dist/ | 2026-..: check 0 (docs/qa/..-check.txt), konsol 0 ×3 genişlik |`

---

## Faz 5: Bağımsız inceleme ve v2

**Giriş:** Faz 4 kapısı kapandı.

**Yapılacaklar**
- **Son inceleme:** işe dahil olmayan bir ajan spec ve planla karşılaştırır; bulgular önem sırasıyla, dosya:satır kanıtıyla. Bulgular tek düzeltme dalgasında kapanır, kapsamlı yeniden inceleme yapılır.
- **UX eleştirisi:** yine bağımsız ajan + `design:design-critique`; persona görevleri üzerinden.
- **v2 planı** üç pakete ayrılır: A düzeltme, B yapısal, C kreatif. Müşteri paket paket onaylar.
- Ölçüm: Lighthouse mobil (3 temsilci sayfa), kaydırma probu, etkileşim testleri.

**Çıktı:** `docs/qa/<tarih>-final-review.md`, `-ux-critique.md`, `-v2-plan.md`, `-v2-report.md`.
**Kapı:** Kritik bulgu 0; prototip bütçeleri tutuyor (ölçüm tablosu dosyada).
**Onay:** Müşteri: v2 paketleri.

---

## Faz 6: İçerik ve medya

**Giriş:** Faz 3 kapısı kapandı (Faz 4 ile paralel yürüyebilir).

**Yapılacaklar**
- `content-inventory.csv` doldurulur: alan, kaynak, sahibi, durum (taslak / müşteride / onaylı), hak/lisans, kanıt (iddialar için).
- AI ile yazılan metin müşteri onayı olmadan canlıya çıkmaz.
- **Medya:** önce müşterinin kendi varlıkları. Eksik *uygulama/atmosfer* görselleri referans güdümlü ve yazısız üretilir (`blocofy-media`). Gerçekliği temsil eden görsel üretilmez.
- Üretimden önce kredi kontrolü; model listesi o gün doğrulanır; varyant sayısı üst sınırlı; her sonuç tam boyutta incelenir (yazı, logo, bozulma).
- `media-manifest.json`: dosya, kaynak (müşteri / stok / AI), model, maliyet, deneme sayısı, lisans.

**Çıktı:** Onay sütunu dolu `content-inventory.csv`, `media-manifest.json`, `assets/`.
**Kapı:** İşaretsiz yer tutucu 0; hak/lisans sütunu tam; medya harcaması bütçe içinde (manifest toplamı).
**Onay:** Müşteri: metinler.

---

## Faz 7: Onay ve dondurma

**Giriş:** Faz 5 ve 6 kapıları kapandı.

**Yapılacaklar**
- Müşteriye prototip bağlantısı + kontrol listesi; onay `client-signoff.md` şablonuyla yazılı alınır.
- Git etiketi `proto-signoff`. `STATE.md` `sourceOfTruth: prototype (frozen)`.
- Değişiklik kontrolü başlar (`change-control.md`).

**Çıktı:** `client-signoff.md`, etiket.
**Kapı:** Tarihli yazılı onay dosyası var.
**Onay:** Müşteri.

---

## Faz 8: Platform kurulumu

**Giriş:** Faz 7 kapısı kapandı (`theme-direct` modunda Faz 3 + 6).

**Yapılacaklar**
- **İlk adım:** `adapters/<platform>/known-issues.md`'deki her maddeyi tarifle yeniden test et, sonucu tabloya yaz. Ancak sonra geçici çözüm uygula.
- **Taslak/canlı izolasyonunu** küçük bir deneme sayfasıyla test et. Bozuksa canlıda kurulum yalnız test alan adında, noindex kilidiyle ve `decisions.md` kaydıyla.
- **Capture:** `capture-map.md` doldurulur ve platform sözleşmeleri üretilir. Blocofy için: tokenlar + `design-dna.md` → `design-dna.json`; `ia-sitemap.md` → `brief.md`; `data/*.json` → `content-model.json`.
- Eski tenant verisi varsa yedeklenir (`legacy-backup/`), kullanıcı onayıyla temizlenir.
- Koleksiyonlar ve formlar sözleşmeden kurulur; kayıt ve medya aktarımı idempotent scriptlerle, id manifestleri commit'lenir.
- URL şeması platformda değiştiyse `url-map.csv` yeni sütunu burada yeniden üretilir.
- Blocofy'da bu fazı `blocofy-orchestrator` yürütür; bu skill sözleşmeleri teslim eder ve kapıyı denetler.

**Çıktı:** `capture-map.md`, platform sözleşmeleri, manifestler, known-issues test sonuçları.
**Kapı:** Diller aktif (API çıktısı); taslak/canlı stratejisi kayıtlı; content-model'deki her section'ın veri kaynağı çözüldü.
**Onay:** Ajans (canlıya dokunan her şey için ayrıca insan onayı).

---

## Faz 9: Tema taşıma ve eşdeğerlik

**Giriş:** Faz 8 kapısı kapandı.

**Yapılacaklar**
- Greenfield tema: platform varsayılan teması tasarım tabanı yapılmaz. Önekli section adları.
- Sıra: layout ve chrome → tokenlar ve ortak parçalar → sayfa sayfa section'lar → dinamik şablonlar.
- CSS/JS prototipin `src/` dizininden üretilir, temada elle düzenlenmez. UI sözlüğü tema ayarlarına script ile dönüşür.
- Her sayfa canlıya (ya da taslağa) alındığında eşdeğerlik: metin farkı, blok geometrisi, yan yana ekran görüntüsü, etkileşim ve form testleri, tüm rotaların taraması (konsol, yinelenen id, kırık bağlantı/görsel).
- Farklar ya düzeltilir ya `parity-report.md`'de "bilinçli fark" olarak gerekçelendirilir. Eşdeğerlik aracı prototipte hata bulursa prototip de düzeltilir.
- Uzun iş sayfa/section başına alt ajanlara bölünür.
- Platform hataları bulunduğu anda istek → yanıt → beklenen → geçici çözüm → etki formatında kaydedilir.

**Çıktı:** Tema dizini, `parity-report.md`, platform bulgu raporu.
**Kapı:** Her dilde metin birebir (bilinçli farklar kayıtlı); geometri toleransı içinde; tarama 0; content-model ↔ tema section tipleri iki yönlü eşleşiyor (script çıktısı).
**Onay:** Yok.

---

## Faz 10: Yayın öncesi

**Giriş:** Faz 9 kapısı kapandı.

**Yapılacaklar:** `prelaunch-checklist.md` baştan sona. Özellikle: 301 doğrulaması, hukuk metinleri, izin + analitik, gerçek form testi (müşteri izniyle, her formdan bir), platform performans ölçümü, klavye ve ekran okuyucu testi, geri dönüş planı, form alıcılarının müşteri adresine alınması.

**Çıktı:** İşaretli `prelaunch-checklist.md`; tutmayan metrikler için `decisions.md`'de kabul edilmiş risk.
**Kapı:** Listede işaretsiz madde yok; her madde kanıt dosyasına bağlı.
**Onay:** Müşteri + ajans.

---

## Faz 11: Yayın

**Giriş:** Açık, tarihli yayın onayı.

**Yapılacaklar:** Önceki canlı durumun yedeği (instance id, tema dosyaları, sayfa belgeleri), alan adı bağlama, noindex kaldırma, 301'lerin etkinleştirilmesi, sitemap gönderimi, smoke testi, 7 gün 404/konsol izleme.

**Çıktı:** Yayın notu (ne, ne zaman, kim onayladı, geri dönüş komutu).
**Kapı:** Smoke yeşil; `robots` ve meta noindex kaldırıldı (çıktı); 7. gün raporu dosyada.
**Onay:** Müşteri.

---

## Faz 12: Devir-teslim ve bakım

**Giriş:** Faz 11 kapısı kapandı.

**Yapılacaklar**
- `handover.md` (şablon): editör paneli rehberi, erişimler, bilinen sınırlar (müşteri diliyle), destek kapsamı.
- 30–60 dk kayıtlı editör eğitimi.
- Ajans anahtarları döndürülür; test alıcıları ve geçici erişimler kaldırılır.
- **Prototip kararı** (`change-control.md`): varsayılan arşiv.
- 30. gün: 404 raporu, dizin kapsama, saha performans verisi.
- Retro: işe yarayanlar/yaramayanlar; kalıcı dersler bu skill'e ya da adapter'a PR, platform hataları known-issues'a.

**Çıktı:** `handover.md`, eğitim kaydı bağlantısı, retro notu, arşiv etiketi.
**Kapı:** Anahtar döndürme kanıtı; eğitim yapıldı; 30. gün raporu dosyada; dersler PR olarak açıldı.
**Onay:** Müşteri.

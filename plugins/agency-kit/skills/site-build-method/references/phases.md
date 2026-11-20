# Faz kartları

Her kart aynı çerçeveyi izler: **Giriş** (başlamak için ne doğru olmalı) · **Yapılacaklar** ·
**Çıktı** (sözleşme dosyaları) · **Kapı** (kanıt + eşik) · **Onay** · **STATE satırı**.
Şablonlar `contracts.md`'de. Dosya yolları öneridir; proje başka düzen seçerse `STATE.md`'de yazar.
"Faz N" bu yöntemin fazıdır, `STATE.md` proje kökündeki dosyadır. Orchestrator fazları
"orchestrator Phase N" diye yazılır; eşleme tablosu `../SKILL.md`'de.

---

## Faz 0: Intake ve kurulum

**Giriş:** Kapsam ya da teklif müşteri tarafından kabul edildi.

**Yapılacaklar**
- Proje dizini, git, `.gitignore` (`.env*`, `session/`, `dist/` gerekiyorsa).
- `.env.local` (izin 600). Anahtarlar en az yetkiyle; `.mcp.json` yalnız `${ENV}` açılımı kullanır, literal token yasak.
- `STATE.md`, `decisions.md`, `open-questions.md` şablondan açılır.
- Intake soruları: karar vericiler ve onay kanalı; marka varlıkları (logo, kılavuz, font lisansları); içerik kaynakları (katalog, Excel/ERP, mevcut site, hiçbiri); mevcut alan adı ve barındırma; hukuki gereksinim (KVKK, GDPR, sektör); analitik/pazarlama araçları; bütçe (efor, AI medya); hedef tarih.
- Hedef platform biliniyorsa doctor çalışır (Blocofy: `blocofy-platform` `scripts/doctor.sh`). API istemcisinin WAF/CDN tarafından engellenmediği doğrulanır.
- Çok dilli sitede **platformun ikinci bir dili etkinleştirebildiği şimdi doğrulanır** (plan, belge ve salt okuma ile). Hangi diller olacağı burada değil Faz 2'de kararlaştırılır; kararlaştırılan diller Faz 8'in başında etkinleştirilip doğrulanır. Doğrulamak için deneme etkinleştirmesi gerekiyorsa bu bir site ayarı yazımıdır: Blocofy'da `blocofy-platform` `references/live-writes.md` durağıyla, açık onayla yapılır. Etkinleştirilemiyorsa engel `open-questions.md`'ye yazılır; tema ve içerik modeli dil-bağımsız ilerler.

**Çıktı:** `STATE.md` (mod henüz `undecided`), `decisions.md`, `open-questions.md`.
**Kapı:** Tüm erişimler doğrulandı (komut çıktısı); gizli bilgi kuralları uygulandı (`grep` ile literal token yok); çok dilli sitede ikinci dilin etkinleştirilebildiğinin kanıtı yazılı.
**Onay:** Ajans.
**STATE:** `| 0 | Intake | done | STATE.md | 2026-..: doctor OK, ikinci dil etkinleştirilebilir (kanıt), token grep temiz |`

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

**Yapılacaklar** (soru soru; `superpowers:brainstorming` kuruluysa onunla, kit dışı ve isteğe bağlı)
- **Mod:** `prototype-first | theme-direct | takeover | migration` (ölçütler SKILL.md).
- **Platform:** `adapters/ADAPTER-TEMPLATE.md` sorularıyla adaylar karşılaştırılır.
- **Diller ve URL şeması:** sitenin dilleri burada kararlaştırılır (Faz 0 yalnız platformun yapabildiğini doğrular); varsayılan dilin öneki, slug çeviri kuralı, eksik çeviri politikası (gizle / varsayılana düş).
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
- **Plan** (`superpowers:writing-plans` kuruluysa onunla; kit dışı, yoksa elle): Global Constraints (token değerleri, fontlar, motion bütçesi, URL kuralı, a11y, veri kuralı), dosya yapısı, `data-schema.md`, `dom-contract.md`, 8–12 görev; her görevin test ve kabul ölçütü.
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
- Görev başına taze alt ajan, görev sonu spec + kalite incelemesi, ledger dosyası (`superpowers:subagent-driven-development` kuruluysa onunla; kit dışı, yoksa aynı düzen elle).
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
- **UX eleştirisi:** yine bağımsız ajan, persona görevleri üzerinden (`design:design-critique` kuruluysa ek girdi; kit dışı, isteğe bağlı).
- **v2 planı** üç pakete ayrılır: A düzeltme, B yapısal, C kreatif. Müşteri paket paket onaylar.
- Ölçüm: Lighthouse mobil (3 temsilci sayfa), kaydırma ve etkileşim testleri (proje scriptleri; kitte yok).

**Çıktı:** `docs/qa/<tarih>-final-review.md`, `-ux-critique.md`, `-v2-plan.md`, `-v2-report.md`.
**Kapı:** Kritik bulgu 0; prototip bütçeleri tutuyor (ölçüm tablosu dosyada).
**Onay:** Müşteri: v2 paketleri.

---

## Faz 6: İçerik ve medya

**Giriş:** Faz 3 kapısı kapandı (Faz 4 ile paralel yürüyebilir).

`blocofy-media` görsel ailelerini `.blocofy-build/design-dna.json` dosyasından okur. Bu rotada o dosya Faz 8'i beklemez: üretimden önce `design-dna.md` ve `decisions.md`'den sözleşme v2 biçiminde yazılır (en az `visual_language` ve `decisions[]`).

**Yapılacaklar**
- `content-inventory.csv` doldurulur: alan, kaynak, sahibi, durum (taslak / müşteride / onaylı), hak/lisans, kanıt (iddialar için).
- AI ile yazılan metin müşteri onayı olmadan canlıya çıkmaz.
- **Medya:** önce müşterinin kendi varlıkları. Eksik *uygulama/atmosfer* görselleri referans güdümlü ve yazısız üretilir (`blocofy-media`). Gerçekliği temsil eden görsel üretilmez.
- Her üretim turu `blocofy-media` harcama kapısından geçer; müşteri malzemesi bir üretim servisine yalnız açık onayla yüklenir. Model listesi o gün doğrulanır; varyant sayısı üst sınırlı; her sonuç tam boyutta incelenir (yazı, logo, bozulma).
- Medya kaydı tek dosyadır: `.blocofy-build/media-registry.json` (alanlar `blocofy-media` `references/asset-system.md`). Yöntemin ek alanları (kaynak: müşteri / stok / AI, lisans) aynı dosyaya eklenir; maliyet ve deneme sayısı `.blocofy-build/credits.md`'ye yazılır.

**Çıktı:** Onay sütunu dolu `content-inventory.csv`, `.blocofy-build/media-registry.json`, `.blocofy-build/credits.md`, `assets/`.
**Kapı:** İşaretsiz yer tutucu 0; hak/lisans sütunu tam; medya harcaması bütçe içinde (`credits.md` toplamı).
**Onay:** Müşteri: metinler.

---

## Faz 7: Onay ve dondurma

**Giriş:** Faz 5 ve 6 kapıları kapandı.

**Yapılacaklar**
- Müşteriye prototip bağlantısı + kontrol listesi; onay `client-signoff.md` şablonuyla yazılı alınır.
- Git etiketi `proto-signoff`. Proje `STATE.md`'sinde `sourceOfTruth: prototype (frozen)`.
- Değişiklik kontrolü başlar (`change-control.md`).

**Çıktı:** `client-signoff.md`, etiket.
**Kapı:** Tarihli yazılı onay dosyası var.
**Onay:** Müşteri.

---

## Faz 8: Platform kurulumu

**Giriş:** Faz 7 kapısı kapandı (`theme-direct` modunda Faz 3 + 6).

**Yapılacaklar**
- **İlk adım:** `adapters/<platform>/known-issues.md`'deki her maddeyi tarifle yeniden test et, sonucu tabloya yaz. Geçici çözümü yalnız test hâlâ başarısızsa uygula.
- **Diller:** Faz 2'de kararlaştırılan diller etkinleştirilir ve aktif oldukları salt okumayla doğrulanır. Dil etkinleştirme site ayarı yazımıdır; Blocofy'da durak ister (`blocofy-platform` `references/live-writes.md`).
- **Taslak izolasyonunu** küçük bir deneme sayfasıyla test et: sayfa taslak temaya bağlanıyor ve canlıda görünmüyor mu. Bozuksa dur, bulguyu insana bildir ve `decisions.md`'ye yaz; ajan kurulumu canlıya taşımaz.
- **Capture:** `capture-map.md` doldurulur. Blocofy'da sözleşme dosyalarını orchestrator Phase 1–3 bu haritadan yazar: tokenlar + `design-dna.md` + `decisions.md` → `design-dna.json` (sözleşme v2); `ia-sitemap.md` → `brief.md`; `data/*.json` → `content-model.json`.
- Eski tenant verisi varsa yedeklenir (`legacy-backup/`). Silme ancak durakla alınan açık onaydan sonra yapılır.
- Koleksiyon şemaları ve formlar sözleşmeden kurulur. Yeni koleksiyon serbesttir; var olan şema, form, menü ve site ayarı değişikliği durak ister.
- URL şeması platformda değiştiyse `url-map.csv` yeni sütunu burada yeniden üretilir.
- Blocofy'da bu fazı `blocofy-orchestrator` yürütür (Phase 0–3) ve durumunu `.blocofy-build/STATE.md`'ye yazar; bu skill `capture-map.md`'yi teslim eder, kapıyı denetler ve proje `STATE.md`'sine yalnız işaretçi ile kendi kapı kanıtını yazar.

**Çıktı:** `capture-map.md`, platform sözleşmeleri, known-issues test sonuçları.
**Kapı:** Kararlaştırılan diller aktif (API çıktısı); taslak izolasyonu doğrulandı; content-model'deki her section'ın veri kaynağı çözüldü.
**Onay:** Ajans (önizlemesi olmayan her yazım için ayrıca insan onayı).

---

## Faz 9: Tema taşıma ve eşdeğerlik

**Giriş:** Faz 8 kapısı kapandı.

**Yapılacaklar**
- Greenfield tema: platform varsayılan teması tasarım tabanı yapılmaz. Önekli section adları.
- Blocofy'da bu faz orchestrator Phase 4–6'dır. Tema yalnız taslağa ya da tema çalışmasına yazılır; ajan canlı temaya yazmaz.
- Sıra: layout ve chrome → tokenlar ve ortak parçalar → sayfa sayfa section'lar → dinamik şablonlar.
- Kayıt ve medya aktarımı idempotent olur, id eşlemeleri commit'lenir. Taslak kayıt serbesttir; yayınlanmış kayıt yazımı durak ister. Medya `.blocofy-build/media-registry.json`'a kaydedilir.
- CSS/JS prototipin `src/` dizininden üretilir, temada elle düzenlenmez. UI sözlüğü tema ayarlarına proje scriptiyle dönüşür.
- Her sayfa taslağa alındığında önizleme bağlantısı üzerinden eşdeğerlik: metin farkı, blok geometrisi, yan yana ekran görüntüsü, etkileşim ve form testleri, tüm rotaların taraması (konsol, yinelenen id, kırık bağlantı/görsel).
- Farklar ya düzeltilir ya `parity-report.md`'de "bilinçli fark" olarak gerekçelendirilir. Eşdeğerlik aracı prototipte hata bulursa prototip de düzeltilir.
- Uzun iş sayfa/section başına alt ajanlara bölünür.
- Platform hataları bulunduğu anda istek → yanıt → beklenen → geçici çözüm → etki formatında kaydedilir.

**Çıktı:** Tema dizini, `parity-report.md`, platform bulgu raporu.
**Kapı:** Her dilde metin birebir (bilinçli farklar kayıtlı); geometri toleransı içinde; tarama 0; content-model ↔ tema section tipleri iki yönlü eşleşiyor. Her kapının kanıtı ve kitte script olmadığında yedek kanıt `quality-gates.md`'de.
**Onay:** Yok.

---

## Faz 10: Yayın öncesi

**Giriş:** Faz 9 kapısı kapandı.

**Yapılacaklar:** `prelaunch-checklist.md` baştan sona. Özellikle: 301 doğrulaması, hukuk metinleri, izin + analitik, gerçek form testi (müşteri izniyle, her formdan bir; Blocofy'da gerçek gönderim durak ister), platform performans ölçümü, klavye ve ekran okuyucu testi, geri dönüş planı, form alıcılarının müşteri adresine alınması.

**Çıktı:** İşaretli `prelaunch-checklist.md`; tutmayan metrikler için `decisions.md`'de kabul edilmiş risk.
**Kapı:** Listede işaretsiz madde yok; her madde kanıt dosyasına bağlı.
**Onay:** Müşteri + ajans.

---

## Faz 11: Yayın

**Giriş:** Açık, tarihli yayın onayı.

**Yapılacaklar:** Önceki canlı durumun yedeği (instance id, tema dosyaları, sayfa belgeleri), alan adı bağlama, noindex kaldırma, 301'lerin etkinleştirilmesi, sitemap gönderimi, smoke testi, 7 gün 404/konsol izleme. Blocofy'da tema canlıya onay akışıyla çıkar (orchestrator Phase 7): ajan onay ister, bir kişi panelde onaylar. Önizlemesi olmayan adımları (noindex, yönlendirme, site ayarı) ya o kişi yapar ya da ajan durakla onay alıp yapar.

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
- Retro: işe yarayanlar/yaramayanlar; kalıcı dersler bu skill'e ya da adapter'a PR, platform hataları yeniden test tarifiyle known-issues'a.

**Çıktı:** `handover.md`, eğitim kaydı bağlantısı, retro notu, arşiv etiketi.
**Kapı:** Anahtar döndürme kanıtı; eğitim yapıldı; 30. gün raporu dosyada; dersler PR olarak açıldı.
**Onay:** Müşteri.

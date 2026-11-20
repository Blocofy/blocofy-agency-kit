---
name: site-build-method
description: Use when the human wants the agency process around a client website - a static prototype approved before the CMS build, written decisions and sign-off, a prelaunch checklist, handover - or asks whether that two-stage route is worth it, or resumes a project that has a root STATE.md with phases 0-12. A plain request to build a site on Blocofy belongs to blocofy-orchestrator. TR triggers - yeni müşteri sitesi, site yapım yöntemi, prototipten temaya, hangi fazdayız, siteyi taşı, yayına hazırlık, devir teslim.
---

# Site Yapım Yöntemi: prototipten CMS temasına

Özgün tasarımlı, yapılandırılmış verisi olan bir kurumsal siteyi önce platformdan
bağımsız statik bir prototipte bitir, sonra CMS temasına taşı ve iki sürümün aynı
olduğunu ölçülmüş kanıtla göster. Yöntem dört şeye dayanır: tek doğru kaynak, kanıtlı faz
kapıları, işi yapmayan bir gözden geçiren ve dosyada yaşayan durum.

Platforma özgü ayrıntılar `adapters/<platform>/` altında. Kuralların hangi hatalardan
çıktığı `examples/lessons.md` içinde. Bu skill hiçbir müşteri verisi içermez; müşteriye ait her
değer proje çalışma alanındaki dosyalardan okunur.

## Demir kurallar

1. **Tek doğru kaynak.** Hangi dosyanın doğru kaynak olduğu proje `STATE.md`'sinde yazılıdır:
   onaydan önce prototip, dondurmadan sonra tema/CMS. Aynı şey iki yerde elle
   yazılıyorsa her değişiklik eşdeğerlik kanıtıyla birleşir.
2. **Kanıtsız kapı yok.** "done" = tarih + komut ya da dosya + sonuç. "Temiz", "hazır",
   "çalışıyor" tek başına kanıt değildir.
3. **İşi yapan onaylamaz.** Faz sonu incelemesi işe dahil olmayan bir ajanla yapılır.
4. **Geri alınamaz ya da dışa dönük her adım insan onayı ister:** canlıya yazma,
   yayın, alan adı, noindex kaldırma, kredi/para harcama, müşteri adına gönderim,
   kalıcı silme.
5. **Uydurma veri yok.** Bilinmeyen alan `null` kalır ve `open-questions.md`'ye yazılır.
   Gerçekliği temsil eden hiçbir görsel AI ile üretilmez: ürün/ambalaj, ekip, tesis,
   sertifika, müşteri logosu, proje fotoğrafı.
6. **Durum dosyada yaşar.** Konuşma hafızasına güvenilmez. Her oturum `STATE.md` ile
   başlar, "sıradaki adım" yazılarak biter.
7. **Platform geçici çözümü kural değildir.** `adapters/<platform>/known-issues.md`'deki
   her madde yeni projede önce yeniden test edilir, sonra uygulanır.

## Ne zaman kullanılır: mod kararı

Mod Faz 2'de seçilir ve `decisions.md`'ye gerekçesiyle yazılır.

| Mod | Ne zaman | Fazlar |
|---|---|---|
| `prototype-first` | Tasarım platform kitinin section sözlüğünü aşıyor; motion yoğun; veri yapılandırılmış ve büyük (≥ 20 kayıt ya da ≥ 2 koleksiyon); gerekli platform desenleri (çok dil, dinamik rota, form) ajansta henüz kanıtlanmamış; müşteri tasarımı platform kurulumundan önce onaylamak istiyor | 0–12 |
| `theme-direct` | ≤ 8 şablon, motion düşük, içerik az, platform kiti olgun | 0–3, 6, 8–12 (prototip yok; platform orchestrator'ı doğrudan) |
| `takeover` | Ajansın önceden kurduğu bir tema/site devralınıyor | 0, 1 (denetim), 2, 8–12 |
| `migration` | Mevcut bir prototip ya da site yeni platforma taşınıyor | 0, 1, 2, 7 (mevcut sürüm onayı), 8–12 |

İki aşamalı yolun bedeli: taşıma + eşdeğerlik + kayma riski. Kit olgunlaştıkça
`theme-direct` eşiği yükselir.

## Kitteki skill'lerle ilişki

| Faz | Skill / araç | Kitte mi; kurulu değilse |
|---|---|---|
| 2 Kararlar | `superpowers:brainstorming` | Kit dışı, isteğe bağlı. Yoksa kararları tek tek soru sorarak al |
| 1–2 Tasarım yönü (kaynak yoksa) | sanat yönetimi alt ajanı + yön panosu (`blocofy-orchestrator` `concept-process.md`); referans site varsa `blocofy-orchestrator` `reference-recon.md` | Kitte |
| 3 Spec ve plan | `superpowers:writing-plans` | Kit dışı, isteğe bağlı. Yoksa planı `references/phases.md` Faz 3 maddelerine göre elle yaz |
| 4 Prototip | `superpowers:subagent-driven-development` | Kit dışı, isteğe bağlı. Yoksa görev başına taze alt ajan ve görev sonu incelemeyi elle yürüt |
| 4 Motion | `gsap-skills` (scrolltrigger, performance, plugins) | Kit dışı; platform fazında `blocofy-orchestrator` ön koşul olarak kontrol eder. Prototipte yoksa API'yi kütüphanenin kendi belgesinden doğrula |
| 5 İnceleme | bağımsız gözden geçiren + `design:design-critique` | Gözden geçiren zorunlu. `design:design-critique` kit dışı, isteğe bağlı. Yoksa gözden geçiren eleştiriyi persona görevleri üzerinden kendisi yazar |
| 6 Medya | `blocofy-media` (model matrisi tarihlidir, her projede doğrula) | Kitte |
| 8–11 Platform | Blocofy için `blocofy-orchestrator` → `blocofy-platform`, `blocofy-theme-kit`, `blocofy-qa` | Kitte |
| Rapor ve karar sayfaları | `artifact-design` | Kit dışı, isteğe bağlı. Yoksa düz HTML ya da Markdown dosyası yaz |

Kit dışı bir skill kurulu değilse iş durmaz ve insandan kurması istenmez; sağ sütundaki
yol izlenir.

### Yöntem fazları ve orchestrator fazları

`prototype-first` modunda bu skill Faz 0–7'yi yürütür. Faz 8–11'de Blocofy adapter'ı
çalışırken platform işini `blocofy-orchestrator` kendi faz makinesiyle (Phase 0–7)
yürütür; bu skill `capture-map.md`'yi teslim eder ve kendi kapılarını denetler. Bu
skill'in dosyalarında "Faz N" her zaman yöntemin fazıdır; orchestrator'ınki
"orchestrator Phase N" diye yazılır. Aynı numara aynı iş değildir: Faz 4 prototiptir,
orchestrator Phase 4 tema kurulumudur.

| Yöntem fazı | Orchestrator Phase | Not |
|---|---|---|
| 8 Platform kurulumu | 0 Bootstrap, 1 Brief, 2 Design DNA, 3 Content model | Phase 1–3 yeniden keşif yapmaz; sözleşmelerini `capture-map.md`'den yazar. Müşterinin yön seçimi Faz 1–2 ve Faz 7 kayıtlarından gelir |
| 9 Tema taşıma ve eşdeğerlik | 4 Theme build, 5 Content & media, 6 QA | Yöntem eşdeğerlik kapısını ekler |
| 10 Yayın öncesi | 6 QA ve Phase 7 öncesi yayın kapısı (`blocofy-qa`) | Yöntem `references/prelaunch-checklist.md`'yi ekler |
| 11 Yayın | 7 Publish & retro | Canlıya çıkışı bir kişi Blocofy panelinde onaylar |
| 12 Devir-teslim | karşılığı yok | Yalnız bu yöntem |

İki durum dosyası vardır; her birinin tek yazarı olur:

- **Proje durumu (Faz 0–12):** proje kökündeki `STATE.md`. Yazarı yöntemi yürüten ana
  oturumdur.
- **Platform kurulum durumu (orchestrator Phase 0–7):** `.blocofy-build/STATE.md`.
  Yazarı yalnız orchestrator'dır. Blocofy adapter'ı çalışırken proje `STATE.md`'sinin
  Faz 8–11 satırları platform ayrıntısı taşımaz: bu dosyayı ve ilgili Phase'i gösterir,
  yanına yöntemin kendi kapı kanıtını yazar.

Şablon: `references/contracts.md`.

## Fazlar

Her fazın kartı (giriş, yapılacaklar, çıktı, kapı, onay) `references/phases.md`'de.

| # | Faz | Giriş | Sözleşme çıktısı | Çıkış kapısı (kanıtlı) | Onay |
|---|---|---|---|---|---|
| 0 | Intake ve kurulum | Kapsam/teklif kabul | `STATE.md`, `decisions.md`, `open-questions.md`, `.env.local` | Erişimler doğrulandı; gizli bilgi kuralları uygulandı; platform doctor yeşil; çok dilli sitede platformun ikinci dili etkinleştirebildiği doğrulandı | Ajans |
| 1 | Keşif | Faz 0 | `brief.md`, `design-dna.md`, `site-audit.md`, `content-inventory.csv`, `url-map.csv` (eski URL'ler) | Sayfa envanteri tam; eski site tam tarandı; her açık sorunun sahibi var | Müşteri: site haritası |
| 2 | Kararlar | Faz 1 | `decisions.md`: mod, platform, diller, URL şeması, iş modeli, yargı alanı, analitik, bütçeler | Her kararın alternatifi ve onaylayanı yazılı | Müşteri |
| 3 | Spec ve plan | Faz 2 | `spec.md`, `plan.md`, `data-schema.md`, `dom-contract.md`, performans + medya bütçesi | Plan öz-incelemesi temiz; yer tutucu yok | Müşteri: spec |
| 4 | Prototip | Plan onaylı | `dist/`, check çıktısı, görev incelemeleri | check 0 hata; 3 genişlikte konsol 0; reduced-motion ve no-JS'de gizli içerik 0; plandaki her görev tam | — |
| 5 | Bağımsız inceleme ve v2 | Faz 4 | `docs/qa/*-review.md`, v2 planı (düzeltme / yapısal / kreatif) | Kritik bulgu 0; prototip bütçeleri tutuyor | Müşteri: paketler |
| 6 | İçerik ve medya | Faz 3 (paralel başlar) | `content-inventory.csv` onay sütunu, `.blocofy-build/media-registry.json`, `.blocofy-build/credits.md` | Yer tutucu 0 ya da işaretli ve kayıtlı; hak/lisans tam; medya bütçesi aşılmadı | Müşteri: metin |
| 7 | Onay ve dondurma | 5 + 6 | `client-signoff.md`, git etiketi `proto-signoff` | Yazılı onay; değişiklik kontrolü başladı | Müşteri |
| 8 | Platform kurulumu | Faz 7 | `capture-map.md`, platform sözleşmeleri, known-issues yeniden test sonuçları | Faz 2'de kararlaştırılan diller aktif ve doğrulandı; taslak izolasyonu doğrulandı; her section'ın veri kaynağı çözüldü | Ajans |
| 9 | Tema taşıma ve eşdeğerlik | Faz 8 | Tema dizini (taslakta), `parity-report.md` | Metin birebir (bilinçli farklar kayıtlı); geometri toleransta; tarama 0; content-model ↔ tema section tipleri eşleşiyor | — |
| 10 | Yayın öncesi | Faz 9 | `prelaunch-checklist.md` işaretli | 301 doğrulandı; hukuk metinleri; izin + analitik; gerçek form testi; platform bütçesi ya da kabul edilmiş risk; geri dönüş planı | Müşteri + ajans |
| 11 | Yayın | Açık onay; canlıya çıkışı kişi onaylar | Yayın notu | Smoke yeşil; noindex kalktı; 7. gün 404/konsol raporu | Müşteri |
| 12 | Devir-teslim ve bakım | Faz 11 | `handover.md`, eğitim kaydı, retro, prototip arşiv kararı | Anahtarlar döndürüldü; editör eğitimi yapıldı; 30. gün SEO kontrolü; dersler kite geri yazıldı | Müşteri |

Bir faz yeniden açılırsa sonraki tüm fazlar `pending`'e düşer.

## Devam protokolü

1. Proje `STATE.md`'sini oku. Kapısı kanıtla kapanmamış ilk faza git. Faz 8–11'deysen
   `.blocofy-build/STATE.md`'yi de oku ve `blocofy-orchestrator` ile devam et.
2. O fazın girdilerini diskten yeniden oku; konuşma özetine güvenme.
3. Uzun fazları (sayfa/section taşıma) alt ajanlara böl; ana bağlam koordinasyon,
   kapı ve kullanıcı iletişimi için kalır.
4. Oturum sonunda proje `STATE.md`'sine sıradaki adımı, engelleri ve bekleyen onayları
   yaz. Kalıcı hafızaya yalnızca işaretçi yaz (ör. "Faz 8 başında known-issues yeniden
   test edilecek").

## Kırmızı bayraklar: dur

- "Prototip zaten onaylı sayılır" ama `client-signoff.md` yok.
- Aynı değişiklik prototip şablonuna ve tema section'ına elle yazıldı, eşdeğerlik çalışmadı.
- Bir script ya da ajan canlı temaya yazıyor (Blocofy'da `--live`, `theme publish`, `allow_live`) ya da önizlemesi olmayan bir yazım dört satırlık durak olmadan yapılıyor (`blocofy-platform` `references/live-writes.md`).
- Kapı notunda kanıt yok ya da kanıt işi yapanın kendi raporu.
- AI medya üretimi `blocofy-media` harcama kapısından geçmeden başladı ya da gerçekliği temsil eden bir görsel üretiliyor.
- Form bildirim alıcısı müşteriye ait olmayan bir adres ve bu `decisions.md`'de kayıtlı değil.
- Rol tanımındaki girdi yolları diskte yok (tanım eskimiş).
- Platform "başarılı" yanıt verdi, render edilmiş sayfa kontrol edilmedi.
- Performans kapısı geçmedi ve "kabul edilmiş risk" kaydı yok.
- Bir geçici çözüm önceki projeden yeniden test edilmeden kopyalandı.

## Bahane tablosu

| Bahane | Gerçek |
|---|---|
| "İşi yapan ajan hazır dedi" | İşi yapanın "taşımaya hazır" raporundan sonra bağımsız inceleme kritik eksikler bulabilir; rapor kanıt değildir |
| "Küçük tasarım değişikliği, eşdeğerlik gerekmez" | Tek bir bileşen değişikliği prototip şablonu, tema section'ı, içerik modeli ve veri dosyasına aynı anda dokundu |
| "Görev incelemesini sona toplu bırakırız" | Görev başına inceleme atlanınca eksikler sonda toplu çıkar ve görevlerin çoğu yeniden açılır |
| "Rol tanımı yazıldı, yeterli" | Tanımlar spec değiştikçe güncellenmezse ajan olmayan dosyalara ve eski sayılara göre çalışır |
| "Test adresinde canlıya yazmak sorun değil" | Aynı script yayından sonra değiştirilmeden çalıştırılırsa üretimi onaysız değiştirir. Ajan yalnız taslağa ve tema çalışmasına yazar |
| "Bu hata düzelmiştir" | Düzeldiği yeniden test edilmeden geçici çözüm kaldırılmaz, düzeltilmediği test edilmeden eklenmez |
| "Lighthouse a11y 100, erişilebilirlik tamam" | Otomatik test klavye yolu, ekran okuyucu akışı ve kontrast matrisini kapsamaz |

## Referanslar

| Dosya | İçerik |
|---|---|
| `references/phases.md` | Faz 0–12 kartları: giriş, yapılacaklar, çıktı, kapı, onay, STATE satırı örneği |
| `references/contracts.md` | Proje STATE.md (ve `.blocofy-build/STATE.md` ile ilişkisi), decisions, open-questions, content-inventory, url-map, data-schema, dom-contract, capture-map, parity-report şablonları; medya kaydının yeri |
| `references/roles.md` | Yedi rol şablonu (marka sistemi, içerik/IA, frontend, medya, motion, QA/SEO, bağımsız gözden geçiren) ve güncellik kontrolü |
| `references/prototype-architecture.md` | Statik prototipin genel mimarisi: veri, i18n, build filtreleri, CSS katmanları, DOM sözleşmesi, check |
| `references/quality-gates.md` | Ölçüt, eşik, kanıt dosyası; kitte scripti olmayan kapılar ve yedek kanıt; iki ayrı performans bütçesi |
| `references/prelaunch-checklist.md` | SEO taşıma, hukuk, izin/analitik, formlar, performans, erişilebilirlik, güvenlik, geri dönüş |
| `references/change-control.md` | Dondurma, revizyon talebi, kayma politikası, prototipin emekliye ayrılması, güvenlik ve maliyet kuralları |
| `references/estimates.md` | Kendi efor verini tutacağın boş tablo ve planlama kuralları |
| `adapters/ADAPTER-TEMPLATE.md` | Yeni bir CMS için doldurulacak sorular; platform seçimine girdi |
| `adapters/blocofy/README.md` | Prototip → Blocofy eşlemesi, taslak hattı, kalıcı platform kuralları |
| `adapters/blocofy/known-issues.md` | Tarihli hata geçmişi; her sitede yeniden test edilir: test tarifi, geçici çözüm, kaldırma koşulu |
| `templates/` | Oturum başlatma, revizyon talebi, müşteri onayı, devir-teslim şablonları |
| `examples/lessons.md` | Hangi hata hangi kurala dönüştü; işe yarayanlar |

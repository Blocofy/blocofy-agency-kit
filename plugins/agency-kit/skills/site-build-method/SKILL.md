---
name: site-build-method
description: Use when starting, planning or resuming a client website that is designed as a platform-independent static prototype and then ported to a CMS theme (Blocofy adapter included), or when deciding whether that two-stage route is worth it. Covers intake, discovery, decisions, spec/plan, prototype, independent review, content/media, sign-off, platform port with machine-checked parity, prelaunch, launch and handover. TR triggers - yeni müşteri sitesi, site yapım yöntemi, prototipten temaya, hangi fazdayız, siteyi taşı, yayına hazırlık, devir teslim.
---

# Site Yapım Yöntemi: prototipten CMS temasına

Özgün tasarımlı, yapılandırılmış verisi olan bir kurumsal siteyi önce platformdan
bağımsız statik bir prototipte bitir, sonra CMS temasına taşı ve iki sürümün aynı
olduğunu makineyle kanıtla. Yöntem dört şeye dayanır: tek doğru kaynak, kanıtlı faz
kapıları, işi yapmayan bir gözden geçiren ve dosyada yaşayan durum.

Platforma özgü ayrıntılar `adapters/<platform>/` altında. Kuralların hangi hatalardan
çıktığı `examples/lessons.md` içinde. Bu skill hiçbir müşteri verisi içermez; müşteriye ait her
değer proje çalışma alanındaki dosyalardan okunur.

## Demir kurallar

1. **Tek doğru kaynak.** Hangi dosyanın doğru kaynak olduğu `STATE.md`'de yazılıdır:
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

| Faz | Skill / araç |
|---|---|
| 2 Kararlar | `superpowers:brainstorming` |
| 1–2 Tasarım yönü (kaynak yoksa) | sanat yönetimi alt ajanı + yön panosu (`blocofy-orchestrator` `concept-process.md`); referans site varsa `blocofy-orchestrator` `reference-recon.md` |
| 3 Spec ve plan | `superpowers:writing-plans` |
| 4 Prototip | `superpowers:subagent-driven-development` (görev başına inceleme dahil) |
| 4 Motion | `gsap-skills` (scrolltrigger, performance, plugins) |
| 5 İnceleme | bağımsız gözden geçiren + `design:design-critique` |
| 6 Medya | `blocofy-media` (model matrisi tarihlidir, her projede doğrula) |
| 8–11 Platform | Blocofy için `blocofy-orchestrator` → `blocofy-platform`, `blocofy-theme-kit`, `blocofy-qa` |
| Rapor ve karar sayfaları | `artifact-design` |

`prototype-first` modunda bu skill Faz 0–7'yi yürütür; Faz 8'de `capture-map.md` ile
prototip çıktılarını orchestrator sözleşmelerine (`brief.md`, `design-dna.json`,
`content-model.json`) çevirip platform fazlarını ona devreder. Tek `STATE.md` her iki
skill'in fazlarını birlikte taşır (`references/contracts.md`).

## Fazlar

Her fazın kartı (giriş, yapılacaklar, çıktı, kapı, onay) `references/phases.md`'de.

| # | Faz | Giriş | Sözleşme çıktısı | Çıkış kapısı (kanıtlı) | Onay |
|---|---|---|---|---|---|
| 0 | Intake ve kurulum | Kapsam/teklif kabul | `STATE.md`, `decisions.md`, `open-questions.md`, `.env.local` | Erişimler doğrulandı; gizli bilgi kuralları uygulandı; platform doctor yeşil | Ajans |
| 1 | Keşif | Faz 0 | `brief.md`, `design-dna.md`, `site-audit.md`, `content-inventory.csv`, `url-map.csv` (eski URL'ler) | Sayfa envanteri tam; eski site tam tarandı; her açık sorunun sahibi var | Müşteri: site haritası |
| 2 | Kararlar | Faz 1 | `decisions.md`: mod, platform, diller, URL şeması, iş modeli, yargı alanı, analitik, bütçeler | Her kararın alternatifi ve onaylayanı yazılı | Müşteri |
| 3 | Spec ve plan | Faz 2 | `spec.md`, `plan.md`, `data-schema.md`, `dom-contract.md`, performans + medya bütçesi | Plan öz-incelemesi temiz; yer tutucu yok | Müşteri: spec |
| 4 | Prototip | Plan onaylı | `dist/`, check çıktısı, görev incelemeleri | check 0 hata; 3 genişlikte konsol 0; reduced-motion ve no-JS'de gizli içerik 0; plandaki her görev tam | — |
| 5 | Bağımsız inceleme ve v2 | Faz 4 | `docs/qa/*-review.md`, v2 planı (düzeltme / yapısal / kreatif) | Kritik bulgu 0; prototip bütçeleri tutuyor | Müşteri: paketler |
| 6 | İçerik ve medya | Faz 3 (paralel başlar) | `content-inventory.csv` onay sütunu, `media-manifest.json` (model, maliyet) | Yer tutucu 0 ya da işaretli ve kayıtlı; hak/lisans tam; medya bütçesi aşılmadı | Müşteri: metin |
| 7 | Onay ve dondurma | 5 + 6 | `client-signoff.md`, git etiketi `proto-signoff` | Yazılı onay; değişiklik kontrolü başladı | Müşteri |
| 8 | Platform kurulumu | Faz 7 | `capture-map.md`, platform sözleşmeleri, known-issues yeniden test sonuçları | Diller aktif ve doğrulandı; taslak/canlı stratejisi seçildi; her section'ın veri kaynağı çözüldü | Ajans |
| 9 | Tema taşıma ve eşdeğerlik | Faz 8 | Tema dizini, `parity-report.md` | Metin birebir (bilinçli farklar kayıtlı); geometri toleransta; tarama 0; content-model ↔ tema section tipleri eşleşiyor | — |
| 10 | Yayın öncesi | Faz 9 | `prelaunch-checklist.md` işaretli | 301 doğrulandı; hukuk metinleri; izin + analitik; gerçek form testi; platform bütçesi ya da kabul edilmiş risk; geri dönüş planı | Müşteri + ajans |
| 11 | Yayın | Açık onay | Yayın notu | Smoke yeşil; noindex kalktı; 7. gün 404/konsol raporu | Müşteri |
| 12 | Devir-teslim ve bakım | Faz 11 | `handover.md`, eğitim kaydı, retro, prototip arşiv kararı | Anahtarlar döndürüldü; editör eğitimi yapıldı; 30. gün SEO kontrolü; dersler kite geri yazıldı | Müşteri |

Bir faz yeniden açılırsa sonraki tüm fazlar `pending`'e düşer.

## Devam protokolü

1. `STATE.md`'yi oku. Kapısı kanıtla kapanmamış ilk faza git.
2. O fazın girdilerini diskten yeniden oku; konuşma özetine güvenme.
3. Uzun fazları (sayfa/section taşıma) alt ajanlara böl; ana bağlam koordinasyon,
   kapı ve kullanıcı iletişimi için kalır.
4. Oturum sonunda `STATE.md`'ye sıradaki adımı, engelleri ve bekleyen onayları yaz.
   Kalıcı hafızaya yalnızca işaretçi yaz (ör. "platform yanıt verince known-issues
   yeniden test edilecek").

## Kırmızı bayraklar: dur

- "Prototip zaten onaylı sayılır" ama `client-signoff.md` yok.
- Aynı değişiklik prototip şablonuna ve tema section'ına elle yazıldı, eşdeğerlik çalışmadı.
- Sync/deploy scripti canlıya yazıyor ve açık onay bayrağı yok.
- Kapı notunda kanıt yok ya da kanıt işi yapanın kendi raporu.
- AI medya üretimi bütçe kaydı olmadan başladı ya da gerçekliği temsil eden bir görsel üretiliyor.
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
| "Test adresinde canlıya yazmak sorun değil" | Aynı script yayından sonra değiştirilmeden çalıştırılırsa üretimi onaysız değiştirir |
| "Platform düzeltmiştir" | Düzeltildiği yeniden test edilmeden geçici çözüm kaldırılmaz, düzeltilmediği test edilmeden eklenmez |
| "Lighthouse a11y 100, erişilebilirlik tamam" | Otomatik test klavye yolu, ekran okuyucu akışı ve kontrast matrisini kapsamaz |

## Referanslar

| Dosya | İçerik |
|---|---|
| `references/phases.md` | Faz 0–12 kartları: giriş, yapılacaklar, çıktı, kapı, onay, STATE satırı örneği |
| `references/contracts.md` | STATE.md, decisions, open-questions, content-inventory, url-map, data-schema, dom-contract, capture-map, parity-report şablonları |
| `references/roles.md` | Yedi rol şablonu (marka sistemi, içerik/IA, frontend, medya, motion, QA/SEO, bağımsız gözden geçiren) ve güncellik kontrolü |
| `references/prototype-architecture.md` | Statik prototipin genel mimarisi: veri, i18n, build filtreleri, CSS katmanları, DOM sözleşmesi, check |
| `references/quality-gates.md` | Ölçüt, eşik, ölçüm komutu, kanıt dosyası; iki ayrı performans bütçesi |
| `references/prelaunch-checklist.md` | SEO taşıma, hukuk, izin/analitik, formlar, performans, erişilebilirlik, güvenlik, geri dönüş |
| `references/change-control.md` | Dondurma, revizyon talebi, kayma politikası, prototipin emekliye ayrılması, güvenlik ve maliyet kuralları |
| `references/estimates.md` | Kendi efor verini tutacağın boş tablo ve planlama kuralları |
| `adapters/ADAPTER-TEMPLATE.md` | Yeni bir CMS için doldurulacak sorular; platform seçimine girdi |
| `adapters/blocofy/README.md` | Prototip → Blocofy eşlemesi, sync hattı, kalıcı platform kuralları |
| `adapters/blocofy/known-issues.md` | Bilinen platform hataları: yeniden test tarifi, geçici çözüm, kaldırma koşulu |
| `templates/` | Oturum başlatma, revizyon talebi, müşteri onayı, devir-teslim şablonları |
| `examples/lessons.md` | Hangi hata hangi kurala dönüştü; işe yarayanlar |

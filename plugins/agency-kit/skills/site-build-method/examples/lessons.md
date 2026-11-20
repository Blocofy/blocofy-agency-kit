# Yöntemin dayandığı dersler

Bu yöntemdeki kurallar gerçek kurulumlarda yaşanan hatalardan çıktı. Aşağıda hangi
hatanın hangi kurala dönüştüğü yazılı. Hiçbir satır belirli bir müşteriyi, siteyi ya da
tarihi anlatmaz; sayılar ve proje ayrıntıları bilerek yoktur.

## İşe yarayanlar

- Önce statik prototip: tasarım kararları platform engellerinden bağımsız ve hızlı alınır.
- Bağımsız son inceleme: işi yapanın "hazır" raporunu sınar.
- Metin ve geometri eşdeğerlik araçları: hem taşıma hatalarını hem prototipteki hataları bulur.
- CSS/JS'nin tek kaynaktan tema asset'ine üretilmesi: bu katmanda kayma olmaz.
- Arayüz sözlüğünün script ile tema ayarlarına dönüşmesi: metinler panelden düzenlenebilir olur.
- Platform hatalarının tekrar üretilebilir kaydı ve "her yeni sitede hepsini yeniden test et"
  notu.

## Hatadan kurala

| Olan | Yönteme giren kural |
|---|---|
| Görev başına inceleme atlandı; eksikler sonda toplu çıktı | Faz 4 kapısı: plandaki her görev tam, görev incelemesi zorunlu |
| İşi yapan "taşımaya hazır" dedi; bağımsız inceleme kritik eksikler ve hiç yapılmamış görevler buldu | Faz 5: işi yapmayan bir gözden geçiren |
| `STATE.md` yalnız taşımada açıldı; prototip durumu dağınık belgelerdeydi | STATE Faz 0'da açılır, tüm fazları kapsar |
| Taşımadan sonra tasarım revizyonları prototip şablonu, tema section'ı, içerik modeli ve veriye elle birlikte yazıldı; içerik modelinde temada olmayan section tipleri kaldı | Kayma politikası (A/B/C) ve section sözleşmesi eşleme kapısı |
| Platformdaki performans ölçümü hedefin altında kaldı, karar kaydı açılmadı | İki ayrı performans bütçesi ve kabul edilmiş risk kaydı |
| Yönlendirme haritası eksikti ve eski adres şemasına göreydi | Faz 1 `url-map.csv` + Faz 10 yönlendirme doğrulaması |
| Hukuk metinleri ve ölçüm kararı sona kaldı | Faz 2 yargı alanı kararı + yayın öncesi hukuk/izin bölümü |
| Form bildirimleri geçici olarak kişisel bir adrese yönlendirildi | Ajansa ait test kutusu, karar kaydı, yayın öncesi geri alma |
| Eşitleme scripti her çalışmada canlıya yazıyordu | Scriptler ve ajan yalnız taslağa yazar; canlıya çıkışı bir kişi onaylar |
| Yapay zekâ ile medya harcaması kayıt dışıydı | Medya bütçesi, harcama kapısı ve `credits.md` |
| İkinci dilin açılışı takıldı ve fark edildiğinde iş ilerlemişti | Faz 0'da platformun ikinci dili etkinleştirebildiğini doğrula; diller Faz 2'de kararlaştırılır, Faz 8 başında etkinleştirilip doğrulanır |
| Kontrast iddiası kanıt dosyasına bağlı değildi | Kontrast matrisi dosyası kapıda |
| Rol tanımları yazıldı ama alt ajanlar genel tiple başlatıldı; tanımlar spec değiştikçe güncellenmedi | Rolü kendi tanımıyla başlat; her faz başında güncellik kontrolü |
| Kapsam, geç gelen resmi veriyle büyüdü | Faz 3 planında veri kaynağının onay tarihi; değişiklik kontrolü |

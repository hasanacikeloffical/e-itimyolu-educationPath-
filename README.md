# 📚 Eğitim Yolu (Education Path) - Mobil Öğrenme Platformu

![Flutter](https://img.shields.io/badge/Flutter-%3E%3D3.0.0-blue.svg?style=flat&logo=flutter) ![Dart](https://img.shields.io/badge/Dart-%3E%3D2.17.0-blue.svg?style=flat&logo=dart) ![Lisans](https://img.shields.io/badge/Lisans-MIT-green.svg)

**Eğitim Yolu**, öğrencilerin ve öğrenmeyi seven herkesin kendi eğitim süreçlerini planlamasını, kişisel gelişim süreçlerini takip etmesini, güncel eğitim bloglarını okumasını ve toplulukla etkileşimde kalmasını sağlayan modern bir mobil uygulamadır.

Bu proje, dönem sonu bitirme ödevi/hackathon teslimi amacıyla **Flutter** framework'ü ve **Dart** programlama dili kullanılarak performans odaklı ve kullanıcı dostu mimariyle geliştirilmiştir.

---

## 📱 Uygulama Akışı ve Özellikleri

Uygulamanın arayüz tasarımlarına, kullanıcı deneyimi (UX) adımlarına ve fonksiyonel özelliklerine aşağıdaki galerilerden göz atabilirsiniz.

### 1. Karşılama ve Tanıtım (Onboarding) Ekranları
Uygulama açılışında kullanıcıyı modern bir logo karşılar. Ardından uygulamanın temel vizyonunu (Öğrenme, Takip ve Hedefleme) anlatan dinamik tanıtım kartları sunulur.

| Açılış Ekranı | Öğren, Takip Et, Bağlan | Hedeflerine Ulaş |
| :---: | :---: | :---: |
| <img src="assets/ekran_goruntuleri/1_splash.jpg" width="220"> | <img src="assets/ekran_goruntuleri/2_onboarding1.jpg" width="220"> | <img src="assets/ekran_goruntuleri/3_onboarding2.jpg" width="220"> |

### 2. Kullanıcı Girişi ve Üyelik İşlemleri
Kullanıcıların güvenli bir şekilde sisteme dahil olabilmesi için tasarlanmış kişiselleştirilmiş hoş geldin ekranı ve modern giriş yapma/kayıt olma formu.

| Karşılama Paneli | Hesap Girişi / Kayıt |
| :---: | :---: |
| <img src="assets/ekran_goruntuleri/4_welcome.jpg" width="220"> | <img src="assets/ekran_goruntuleri/5_login.jpg" width="220"> |

### 3. Ana Panel, Keşfet ve Eğitim Blogları
Giriş yapan kullanıcıyı karşılayan kişisel özet ekranı, kategorilere ayrılmış ders/konu keşif alanı ve güncel makalelerin yer aldığı zengin blog sistemi.

| Kullanıcı Paneli | Dersleri Keşfet | Eğitim Blogları |
| :---: | :---: | :---: |
| <img src="assets/ekran_goruntuleri/6_dashboard.jpg" width="220"> | <img src="assets/ekran_goruntuleri/7_kesfet.jpg" width="220"> | <img src="assets/ekran_goruntuleri/8_blog.jpg" width="220"> |

### 4. Topluluk Sohbeti ve İlerleme İstatistikleri
Öğrencilerin birbiriyle fikir alışverişi yapabileceği canlı mesajlaşma odası ve öğrenme verilerini görsel grafiklerle sunan performans takip ekranı.

| Topluluk Odası (Chat) | İlerleme ve Grafik Takibi |
| :---: | :---: |
| <img src="assets/ekran_goruntuleri/9_chat.jpg" width="220"> | <img src="assets/ekran_goruntuleri/10_profil.jpg" width="220"> |

---

## 🛠️ Kullanılan Teknolojiler ve Kütüphaneler

Projede performans, veri yönetimi ve şık bir arayüz sunabilmek adına şu teknolojilerden yararlanılmıştır:

* **Tasarım & UI:** `google_fonts`, `flutter_svg`, `shimmer` (Yükleme efektleri için)
* **Veri Yönetimi & State:** [Buraya kullandığın yönetim paketini yaz örn: Provider / Bloc / Riverpod / setState]
* **Veritabanı / Servis:** [Kullanıldıysa Firebase Firestore / Realtime DB / Local Hive / Sqflite belirtin]
* **Grafikler:** Performans ekranındaki veri görselleştirmeleri için özel grafik kütüphaneleri kullanılmıştır.

---

## 🚀 Projeyi Yerelde Kurma ve Çalıştırma

Bu kaynak kodları kendi bilgisayarınızda çalıştırmak, emülatörde veya gerçek cihazda test etmek için aşağıdaki adımları sırasıyla uygulayınız:

### Ön Gereksinimler
* Bilgisayarınızda **Flutter SDK**'nın (v3.0.0 veya üzeri) kurulu olduğundan emin olun.
* **Android Studio** veya **VS Code** üzerinde Flutter eklentilerinin aktif olduğundan emin olun.

### Çalıştırma Adımları

1. **Projeyi bilgisayarınıza klonlayın veya indirin:**
   ```bash
   git clone [https://github.com/KULLANICI_ADIN/REPO_ADIN.git](https://github.com/KULLANICI_ADIN/REPO_ADIN.git)

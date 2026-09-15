-- Tekrar tekrar hatasız çalıştırabilmek için önce tabloları temizle
PRAGMA foreign_keys = OFF;
DROP TABLE IF EXISTS odunc;
DROP TABLE IF EXISTS kitaplar;
DROP TABLE IF EXISTS uyeler;

PRAGMA foreign_keys = ON;

CREATE TABLE uyeler (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    ad TEXT NOT NULL,
    yas INTEGER CHECK (yas > 13),
    sehir TEXT DEFAULT 'Erzincan',
    kayit_ani DATETIME DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE kitaplar (
	ad TEXT UNIQUE NOT NULL,
	id INTEGER PRIMARY KEY AUTOINCREMENT
);

CREATE TABLE odunc (
    uye_id INTEGER,
    kitap_id INTEGER,
    PRIMARY KEY (uye_id, kitap_id),
    FOREIGN KEY (uye_id) REFERENCES uyeler(id) ON DELETE CASCADE,
    FOREIGN KEY (kitap_id) REFERENCES kitaplar(id)
);
-- Kitap silinmeye çalışılırsa ne olur: Kitap şu an birinde ödünçte kayıtlı olduğu için veritabanı kural gereği silme işlemini engeller ve hata verir.
-- Neden ON DELETE CASCADE tercih edilmemiştir: Kitap silindiğinde ödünç kaydının da otomatik silinmesi, o kitabın kimde kaldığı bilgisini yok edeceği için bu tercih edilmez.

ALTER TABLE odunc ADD COLUMN gun INTEGER; --- Gün sayısını tutmak için sonradan eklenen sütun

-- 1. kitaplar tablosuna 5 kitap ekleme
INSERT INTO kitaplar (ad) VALUES 
('Suç ve Ceza'),
('Öfke Dansı'),
('Simyacı'),
('Beyaz Zambaklar Ülkesinde'),
('Tutunamayanlar');

-- 2. uyeler tablosuna 10 üye ekleme (bazılarında sehir belirtilmedi)
INSERT INTO uyeler (ad, yas, sehir) VALUES ('Ahmet Yılmaz', 22, 'İstanbul');
INSERT INTO uyeler (ad, yas) VALUES ('Ayşe Kaya', 19); -- sehir: 'Erzincan' (varsayılan)
INSERT INTO uyeler (ad, yas, sehir) VALUES ('Mehmet Demir', 28, 'Ankara');
INSERT INTO uyeler (ad, yas) VALUES ('Fatma Çelik', 24); -- sehir: 'Erzincan' (varsayılan)
INSERT INTO uyeler (ad, yas, sehir) VALUES ('Can Öztürk', 16, 'İzmir');
INSERT INTO uyeler (ad, yas) VALUES ('Zeynep Aydın', 21); -- sehir: 'Erzincan' (varsayılan)
INSERT INTO uyeler (ad, yas, sehir) VALUES ('Burak Şahin', 30, 'Bursa');
INSERT INTO uyeler (ad, yas) VALUES ('Elif Arslan', 25); -- sehir: 'Erzincan' (varsayılan)
INSERT INTO uyeler (ad, yas, sehir) VALUES ('Emre Koç', 27, 'Antalya');
INSERT INTO uyeler (ad, yas) VALUES ('Selin Doğan', 20); -- sehir: 'Erzincan' (varsayılan)

-- 3. Yaşı 10 olan bir üye ekleme denemesi (AÇIKLAMA AMAÇLI - script hatasız çalışsın diye yorum satırı yapıldı)
-- INSERT INTO uyeler (ad, yas) VALUES ('Ali Can', 10);
-- Açıklama: Bu satır çalıştırılırsa "CHECK constraint failed: yas > 13" hatası döner. 
-- Çünkü tabloda yaşın 13'ten büyük olması kuralı (CHECK) tanımlanmıştır.

-- 4. Olmayan bir uye_id (ör. 99) ile ödünç kaydı denemesi (AÇIKLAMA AMAÇLI - script hatasız çalışsın diye yorum satırı yapıldı)
-- INSERT INTO odunc (uye_id, kitap_id, gun) VALUES (99, 1, 14);
-- Açıklama: Bu satır çalıştırılırsa "FOREIGN KEY constraint failed" hatası döner. 
-- Çünkü PRAGMA foreign_keys = ON açıkken uyeler tablosunda id=99 olan bir kayıt bulunmadığından referans bütünlüğü bozulur.

-- 5. Her üyeye en az iki kitap ödünç kaydı girme (gun: 3-45 arası)
INSERT INTO odunc (uye_id, kitap_id, gun) VALUES
(1, 1, 15), (1, 2, 7),
(2, 2, 21), (2, 3, 10),
(3, 3, 30), (3, 4, 14),
(4, 4, 5),  (4, 5, 45),
(5, 5, 12), (5, 1, 3),
(6, 1, 18), (6, 3, 25),
(7, 2, 40), (7, 4, 8),
(8, 3, 16), (8, 5, 22),
(9, 4, 11), (9, 1, 35),
(10, 5, 28), (10, 2, 9);

--- 1. Üye adı, kitap adı ve gün sayısını tek tabloda gösterme
SELECT u.ad,k.ad,o.gun FROM odunc o JOIN uyeler u ON o.uye_id = u.id JOIN kitaplar k ON o.kitap_id = k.id;

--- 2. Aynı sorguya 30 günden fazla tutulan koşulu ekleme
SELECT u.ad,k.ad,o.gun FROM odunc o JOIN uyeler u ON o.uye_id = u.id JOIN kitaplar k ON o.kitap_id = k.id WHERE o.gun > 30;

--- 3. Hiç kitap almamış kişilerin de görünmesi
SELECT ad FROM uyeler WHERE id NOT IN (SELECT uye_id FROM odunc);

--- Ortalama max kitap sayısı
SELECT u.ad,AVG(o.gun) AS ortalama_sure,COUNT(o.kitap_id) AS toplam_kitap,MAX(o.gun) AS en_uzun_sure FROM uyeler u JOIN odunc o ON u.id = o.uye_id GROUP BY u.id, u.ad;

--- Ortalamsı 20 günün üzerinde olanlar 
SELECT u.ad, AVG(o.gun) AS ortalama_sure FROM uyeler u JOIN odunc o ON u.id = o.uye_id GROUP BY u.id, u.ad HAVING AVG(o.gun) > 20;

--- Kitap bazlı ödünç sayısı
SELECT k.ad, COUNT(o.kitap_id) AS odunc_sayisi FROM kitaplar k JOIN odunc o ON k.id = o.kitap_id GROUP BY k.id, k.ad;

--- Şehirlere göre üye sayısı
SELECT sehir, COUNT(*) AS uye_sayisi
FROM uyeler
GROUP BY sehir
ORDER BY uye_sayisi DESC;

--- En az bir kitabı 30 günden fazla tutmuş olanlar
SELECT ad FROM uyeler WHERE id IN (SELECT uye_id FROM odunc WHERE gun > 30);

--- Hiç ödünç alınmamış kitaplar
SELECT ad FROM kitaplar WHERE id NOT IN (SELECT DISTINCT kitap_id FROM odunc);

--- Genel ortalamanın üzerinde süre tutulan tüm kayıtlar
SELECT u.ad AS uye_adi, k.ad AS kitap_adi, o.gun FROM odunc o JOIN uyeler u ON o.uye_id = u.id JOIN kitaplar k ON o.kitap_id = k.id WHERE o.gun > (SELECT AVG(gun) FROM odunc);

--- CASE
SELECT uye_id, kitap_id, gun, CASE WHEN gun > 30 THEN 'Gecikmiş' WHEN gun >= 15 THEN 'Uyarı' ELSE 'Normal' END AS durum FROM odunc;

SELECT ad, yas, CASE WHEN yas <= 18 THEN 'Genç' ELSE 'Yetişkin' END AS yas_grubu FROM uyeler;

SELECT CASE WHEN gun > 30 THEN 'Gecikmiş' WHEN gun >= 15 THEN 'Uyarı' ELSE 'Normal' END AS durum, COUNT(*) AS kayit_sayisi FROM odunc GROUP BY durum;

--- INDEX
CREATE INDEX idx_uyeler_ad ON uyeler(ad);

ALTER TABLE uyeler ADD COLUMN eposta TEXT;

CREATE UNIQUE INDEX idx_uyeler_eposta ON uyeler(eposta);

UPDATE uyeler SET eposta = 'test1@gmail.com' WHERE id = 1;

UPDATE uyeler SET eposta = 'test2@gmail.com' WHERE id = 2;

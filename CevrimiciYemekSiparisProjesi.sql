-- VTYS-1 DÖNEM PROJESİ: ÇEVRİMİÇİ YEMEK SİPARİŞ PLATFORMU VERİTABANI TASARIMI

USE master;
GO

-- Varsa eski veritabanlarını temizliyoruz
IF EXISTS (SELECT * FROM sys.databases WHERE name = 'CevrimiciYemekSiparisDB')
BEGIN
    ALTER DATABASE CevrimiciYemekSiparisDB SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE CevrimiciYemekSiparisDB;
END
GO

CREATE DATABASE CevrimiciYemekSiparisDB;
GO

USE CevrimiciYemekSiparisDB;
GO

-- ===================================================================================
-- BÖLÜM 1: VERİ TANIMLAMA VE KISITLAMALAR (DDL & CONSTRAINTS)
-- ===================================================================================

CREATE TABLE Kullanicilar (
    KullaniciID INT IDENTITY(1,1) PRIMARY KEY,
    Ad NVARCHAR(50) NOT NULL,
    Soyad NVARCHAR(50) NOT NULL,
    Eposta NVARCHAR(100) NOT NULL UNIQUE,
    Telefon NVARCHAR(20) NOT NULL UNIQUE,
    SifreHash NVARCHAR(256) NOT NULL,
    IsVerifiedNeedy BIT NOT NULL DEFAULT 0,
    IsActive BIT NOT NULL DEFAULT 1
);
GO

CREATE TABLE Restoranlar (
    RestoranID INT IDENTITY(1,1) PRIMARY KEY,
    RestoranAdi NVARCHAR(100) NOT NULL,
    Telefon NVARCHAR(20) NOT NULL,
    Adres NVARCHAR(255) NOT NULL,
    RestoranPuani DECIMAL(3,2) DEFAULT 5.00,
    ToplamCiro DECIMAL(18,2) NOT NULL DEFAULT 0.00,
    IsActive BIT NOT NULL DEFAULT 1,
    CONSTRAINT CHK_RestoranPuani CHECK (RestoranPuani BETWEEN 1.00 AND 5.00) -- CHECK 1
);
GO

CREATE TABLE Urunler (
    UrunID INT IDENTITY(1,1) PRIMARY KEY,
    RestoranID INT NOT NULL,
    UrunAdi NVARCHAR(100) NOT NULL,
    Aciklama NVARCHAR(255),
    Fiyat DECIMAL(10,2) NOT NULL,
    IsActive BIT NOT NULL DEFAULT 1,
    CONSTRAINT FK_Urunler_Restoranlar FOREIGN KEY (RestoranID) REFERENCES Restoranlar(RestoranID),
    CONSTRAINT CHK_UrunFiyat CHECK (Fiyat > 0.00) -- CHECK 2
);
GO

CREATE TABLE AskidaYemekHavuzu (
    BagisID INT IDENTITY(1,1) PRIMARY KEY,
    BagisciKullaniciID INT NULL,
    BagisTarihi DATETIME NOT NULL DEFAULT GETDATE(),
    BagisTutari DECIMAL(10,2) NOT NULL,
    KalanTutar DECIMAL(10,2) NOT NULL,
    IsAnonymous BIT NOT NULL DEFAULT 0,
    CONSTRAINT FK_AskidaHavuz_Kullanicilar FOREIGN KEY (BagisciKullaniciID) REFERENCES Kullanicilar(KullaniciID),
    CONSTRAINT CHK_BagisTutari CHECK (BagisTutari > 0.00)
);
GO

CREATE TABLE Siparisler (
    SiparisID INT IDENTITY(1,1) PRIMARY KEY,
    KullaniciID INT NOT NULL,
    RestoranID INT NOT NULL,
    SiparisTarihi DATETIME NOT NULL DEFAULT GETDATE(),
    SiparisDurumu NVARCHAR(50) NOT NULL DEFAULT 'Hazırlanıyor',
    ToplamTutar DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    IsAskidaSiparis BIT NOT NULL DEFAULT 0,
    IsActive BIT NOT NULL DEFAULT 1,
    CONSTRAINT FK_Siparisler_Kullanicilar FOREIGN KEY (KullaniciID) REFERENCES Kullanicilar(KullaniciID),
    CONSTRAINT FK_Siparisler_Restoranlar FOREIGN KEY (RestoranID) REFERENCES Restoranlar(RestoranID)
);
GO

CREATE TABLE SiparisDetaylari (
    SiparisDetayID INT IDENTITY(1,1) PRIMARY KEY,
    SiparisID INT NOT NULL,
    UrunID INT NOT NULL,
    Adet INT NOT NULL DEFAULT 1,
    BirimFiyat DECIMAL(10,2) NOT NULL,
    CONSTRAINT FK_SiparisDetay_Siparisler FOREIGN KEY (SiparisID) REFERENCES Siparisler(SiparisID),
    CONSTRAINT FK_SiparisDetay_Urunler FOREIGN KEY (UrunID) REFERENCES Urunler(UrunID),
    CONSTRAINT CHK_SiparisAdet CHECK (Adet > 0)
);
GO


-- ===================================================================================
-- BÖLÜM 2: VERİ MANİPÜLASYONU (DML - MOCK DATA)
-- ===================================================================================

-- 20 Kullanıcı (Son 5'i onaylı ihtiyaç sahibi)
INSERT INTO Kullanicilar (Ad, Soyad, Eposta, Telefon, SifreHash, IsVerifiedNeedy) VALUES
('Ahmet', 'Yılmaz', 'ahmet@mail.com', '05551112233', 'hash123', 0),
('Mehmet', 'Kaya', 'mehmet@mail.com', '05552223344', 'hash123', 0),
('Ayşe', 'Demir', 'ayse@mail.com', '05553334455', 'hash123', 0),
('Fatma', 'Çelik', 'fatma@mail.com', '05554445566', 'hash123', 0),
('Ali', 'Öztürk', 'ali@mail.com', '05555556677', 'hash123', 0),
('Zeynep', 'Arslan', 'zeynep@mail.com', '05556667788', 'hash123', 0),
('Mustafa', 'Yıldız', 'mustafa@mail.com', '05557778899', 'hash123', 0),
('Emine', 'Şahin', 'emine@mail.com', '05558889900', 'hash123', 0),
('Can', 'Aydın', 'can@mail.com', '05559990011', 'hash123', 0),
('Burak', 'Özkan', 'burak@mail.com', '05550001122', 'hash123', 0),
('Merve', 'Kılıç', 'merve@mail.com', '05551113344', 'hash123', 0),
('Selin', 'Taş', 'selin@mail.com', '05552224455', 'hash123', 0),
('Gökhan', 'Bulut', 'gokhan@mail.com', '05553335566', 'hash123', 0),
('Derya', 'Güneş', 'derya@mail.com', '05554446677', 'hash123', 0),
('Hakan', 'Acar', 'hakan@mail.com', '05555557788', 'hash123', 0),
('Gariban', 'Tekin', 'gariban1@mail.com', '05556668899', 'hash123', 1),
('Yoksul', 'Yılmaz', 'yoksul2@mail.com', '05557779900', 'hash123', 1),
('Fakir', 'Fukara', 'fakir3@mail.com', '05558880011', 'hash123', 1),
('Mazlum', 'Çokgezer', 'mazlum4@mail.com', '05559991122', 'hash123', 1),
('Garip', 'Uysal', 'garip5@mail.com', '05550002233', 'hash123', 1);

-- 5 Restoran
INSERT INTO Restoranlar (RestoranAdi, Telefon, Adres, RestoranPuani) VALUES
('Lezzet Kebap Salonu', '02121112233', 'Beşiktaş, İstanbul', 4.5),
('Burger Sarayı', '02122223344', 'Kişikli, Üsküdar', 4.2),
('Pizzacım İtaliano', '02123334455', 'Kadıköy, İstanbul', 4.7),
('Anne Eli Ev Yemekleri', '02124445566', 'Mecidiyeköy, İstanbul', 4.8),
('Yeşil Salata & Diyet', '02125556677', 'Şişli, İstanbul', 3.9);

-- 50 Ürün
INSERT INTO Urunler (RestoranID, UrunAdi, Aciklama, Fiyat) VALUES
(1, 'Adana Kebap', 'Acılı zırh kebabı', 220.00), (1, 'Urfa Kebap', 'Acısız zırh kebabı', 220.00), (1, 'Tavuk Şiş', 'Marine edilmiş tavuk göğsü', 180.00), (1, 'Beyti Sarma', 'Soslu yoğurtlu kebap', 260.00), (1, 'Lahmacun', 'Çıtır Antep lahmacunu', 60.00), (1, 'Mercimek Çorbası', 'Krutonlu çorba', 70.00), (1, 'Gavurdağı Salatası', 'Cevizli nar ekşili', 90.00), (1, 'Künefe', 'Hatay usulü sıcak', 120.00), (1, 'Ayran', 'Yayık ayranı', 30.00), (1, 'Şalgam Suyu', 'Acılı/Acısız seçenekli', 30.00),
(2, 'Klasik Burger', '150gr köfte, marul, turşu', 190.00), (2, 'Cheeseburger', 'Cheddar peynirli', 210.00), (2, 'Double Burger', '300gr çift köfte', 290.00), (2, 'Tavuk Burger', 'Çıtır tavuk filosu', 160.00), (2, 'Mantar Burger', 'Karamelize mantarlı', 220.00), (2, 'Patates Kızartması', 'Büyük boy', 60.00), (2, 'Soğan Halkası', '8li çıtır halka', 50.00), (2, 'Mozaik Pasta', 'Ev yapımı dilim', 80.00), (2, 'Kutu Kola', 'Orijinal tat', 40.00), (2, 'Fanta', 'Portakallı', 40.00),
(3, 'Margarita Pizza', 'Mozerella ve fesleğen', 180.00), (3, 'Karışık Pizza', 'Sucuk, sosis, mısır, zeytin', 240.00), (3, 'Pepperoni Pizza', 'Bol pepperoni ve kekik', 250.00), (3, 'Dört Peynirli Pizza', 'Özel peynir soslu', 260.00), (3, 'Vejetaryen Pizza', 'Mevsim sebzeleri ile', 210.00), (3, 'Sarımsaklı Ekmek', '4 adet dilim', 70.00), (3, 'Akdeniz Salatası', 'Beyaz peynirli, zeytinli', 95.00), (3, 'Tiramisu', 'Hakiki İtalyan tarifi', 110.00), (3, 'Maden Suyu', 'Doğal mineralleri', 25.00), (3, 'Soğuk Çay', 'Şeftalili', 40.00),
(4, 'Kuru Fasulye', 'Erzincan dermason fasulye', 110.00), (4, 'Pirinç Pilavı', 'Tereyağlı baldo pilav', 70.00), (4, 'Yaprak Sarma', 'Zeytinyağlı ev usulü', 100.00), (4, 'İmambayıldı', 'Zeytinyağlı patlıcan', 120.00), (4, 'Mantı', 'Kayseri usulü bol soslu', 170.00), (4, 'Mercimek Köftesi', 'Marul eşliğinde 6 adet', 85.00), (4, 'Cacık', 'Salatalıklı ve naneli', 45.00), (4, 'Sütlaç', 'Fırınlanmış anne usulü', 75.00), (4, 'Ev Yapımı Limonata', 'Nane yapraklı taze', 50.00), (4, 'Yayık Yoğurdu', 'Doğal kasede', 45.00),
(5, 'Izgara Tavuklu Salata', 'Diyet sos ile', 180.00), (5, 'Ton Balıklı Salata', 'Mısırlı ve yeşillikli', 200.00), (5, 'Kinoa Salatası', 'Avokado dilimli', 220.00), (5, 'Sezar Salata', 'Kruton ekmekli sezar soslu', 190.00), (5, 'Mercimek Salatası', 'Protein deposu', 150.00), (5, 'Meyve Tabağı', 'Mevsim meyveleri karışık', 110.00), (5, 'Sebze Çorbası', 'Yağsız unsuz taze', 75.00), (5, 'Chia Puding', 'Çilekli ve hindistan cevizli', 90.00), (5, 'Yeşil Çay', 'Demleme fincan', 35.00), (5, 'Detoks Suyu', 'Salatalık ve limon özlü', 45.00);

-- Askıda Yemek Havuzunu Doldurma
INSERT INTO AskidaYemekHavuzu (BagisciKullaniciID, BagisTutari, KalanTutar, IsAnonymous) VALUES
(1, 1000.00, 1000.00, 0), (2, 2500.00, 2500.00, 1), (3, 1500.00, 1500.00, 0), (4, 3000.00, 3000.00, 1), (5, 500.00, 500.00, 0);

-- 105 Adet Sipariş Hareketi (Döngü ile)
DECLARE @i INT = 1;
DECLARE @KullaniciID INT;
DECLARE @RestoranID INT;
DECLARE @Tutar DECIMAL(10,2);
DECLARE @Askida BIT;
WHILE @i <= 105
BEGIN
    SET @KullaniciID = (@i % 20) + 1;
    SET @RestoranID = (@i % 5) + 1;
    SET @Tutar = 120.00 + (@i * 2.5);
    IF @KullaniciID >= 16 SET @Askida = 1; ELSE SET @Askida = 0;

    INSERT INTO Siparisler (KullaniciID, RestoranID, SiparisTarihi, SiparisDurumu, ToplamTutar, IsAskidaSiparis)
    VALUES (@KullaniciID, @RestoranID, DATEADD(day, -(@i % 28), GETDATE()), CASE WHEN @i % 12 = 0 THEN 'Yolda' WHEN @i % 18 = 0 THEN 'Hazırlanıyor' ELSE 'Teslim Edildi' END, @Tutar, @Askida);
    SET @i = @i + 1;
END;

-- 105 Siparişin Detay Satırları
DECLARE @j INT = 1;
DECLARE @UrunBaseID INT;
WHILE @j <= 105
BEGIN
    SET @UrunBaseID = (((@j % 5) * 10) + 1);
    INSERT INTO SiparisDetaylari (SiparisID, UrunID, Adet, BirimFiyat) VALUES (@j, @UrunBaseID, 1, 100.00 + (@j * 0.5));
    INSERT INTO SiparisDetaylari (SiparisID, UrunID, Adet, BirimFiyat) VALUES (@j, @UrunBaseID + 4, 2, 25.00);
    SET @j = @j + 1;
END;
GO


-- ===================================================================================
-- BÖLÜM 3: VERİTABANI PROGRAMLANABİLİRLİĞİ (GELİŞMİŞ NESNELER - ESKİ 4. ADIM)
-- ===================================================================================

CREATE VIEW vw_AktifRestoranMenuleri AS
SELECT R.RestoranID, R.RestoranAdi, R.RestoranPuani, U.UrunID, U.UrunAdi, U.Fiyat
FROM Restoranlar R INNER JOIN Urunler U ON R.RestoranID = U.RestoranID WHERE R.IsActive = 1 AND U.IsActive = 1;
GO

CREATE VIEW vw_AskidaYemekHavuzDurumu AS
SELECT SUM(BagisTutari) AS [Toplam Toplanan Bagis (TL)], SUM(BagisTutari - KalanTutar) AS [Harcanan Miktar (TL)], SUM(KalanTutar) AS [Havuzda Kalan Anlik Bakiye (TL)], COUNT(BagisID) AS [Toplam Bagis Islemi Sayisi]
FROM AskidaYemekHavuzu;
GO

CREATE TRIGGER trg_SiparisTeslimEdildiCiroGuncelle ON Siparisler AFTER UPDATE AS
BEGIN
    IF UPDATE(SiparisDurumu)
    BEGIN
        UPDATE R SET R.ToplamCiro = R.ToplamCiro + I.ToplamTutar FROM Restoranlar R
        INNER JOIN inserted I ON R.RestoranID = I.RestoranID INNER JOIN deleted D ON I.SiparisID = D.SiparisID
        WHERE I.SiparisDurumu = 'Teslim Edildi' AND D.SiparisDurumu <> 'Teslim Edildi';
    END
END;
GO

CREATE TRIGGER trg_AskidaSiparisBakiyeDus ON Siparisler AFTER INSERT AS
BEGIN
    DECLARE @SiparisTutar DECIMAL(10,2), @IsAskida BIT, @EnEskiBagisID INT;
    SELECT @SiparisTutar = ToplamTutar, @IsAskida = IsAskidaSiparis FROM inserted;
    IF @IsAskida = 1
    BEGIN
        SELECT TOP 1 @EnEskiBagisID = BagisID FROM AskidaYemekHavuzu WHERE KalanTutar > 0 ORDER BY BagisTarihi ASC;
        IF @EnEskiBagisID IS NOT NULL UPDATE AskidaYemekHavuzu SET KalanTutar = KalanTutar - @SiparisTutar WHERE BagisID = @EnEskiBagisID;
    END
END;
GO

CREATE NONCLUSTERED INDEX IX_Kullanicilar_Eposta ON Kullanicilar (Eposta);
CREATE NONCLUSTERED INDEX IX_Siparisler_SiparisTarihi ON Siparisler (SiparisTarihi);
GO


-- ===================================================================================
-- BÖLÜM 4: İLERİ DÜZEY SORGULAR (DQL & ANALİTİK - ESKİ 3. ADIM)
-- (Hocanın isteği üzerine dosyanın en altında rapor olarak yer almaktadır)
-- ===================================================================================

-- Sorgu 1: 3 Tablolu Detaylı Sipariş Fişi Listesi
SELECT S.SiparisID AS [Fiş No], K.Ad + ' ' + K.Soyad AS [Müşteri], R.RestoranAdi AS [Restoran], S.SiparisTarihi AS [Tarih], S.SiparisDurumu AS [Durum], S.ToplamTutar AS [Tutar], CASE WHEN S.IsAskidaSiparis = 1 THEN 'Askıdan' ELSE 'Nakit' END AS [Tür]
FROM Siparisler S INNER JOIN Kullanicilar K ON S.KullaniciID = K.KullaniciID INNER JOIN Restoranlar R ON S.RestoranID = R.RestoranID ORDER BY S.SiparisID DESC;

-- Sorgu 2: Son 1 Ayda 5'ten Fazla Sipariş Alan Restoranlar ve Ortalama Sepetleri
SELECT R.RestoranAdi AS [Restoran Adı], COUNT(S.SiparisID) AS [Sipariş Sayısı], SUM(S.ToplamTutar) AS [Toplam Ciro], AVG(S.ToplamTutar) AS [Ortalama Sepet]
FROM Siparisler S INNER JOIN Restoranlar R ON S.RestoranID = R.RestoranID WHERE S.SiparisTarihi >= DATEADD(month, -1, GETDATE()) GROUP BY R.RestoranAdi HAVING COUNT(S.SiparisID) > 5;

-- Sorgu 3: Hiç Bağış Yapmamış Ama Sipariş Vermiş Aktif Müşteriler
SELECT DISTINCT K.KullaniciID, K.Ad + ' ' + K.Soyad AS [Müşteri], K.Eposta FROM Kullanicilar K INNER JOIN Siparisler S ON K.KullaniciID = S.KullaniciID
WHERE NOT EXISTS (SELECT 1 FROM AskidaYemekHavuzu A WHERE A.BagisciKullaniciID = K.KullaniciID) AND K.IsVerifiedNeedy = 0;
GO
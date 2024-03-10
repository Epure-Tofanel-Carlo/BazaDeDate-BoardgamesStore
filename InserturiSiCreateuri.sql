
-- Crearea tabelului Furnizori

CREATE TABLE Furnizori (
    FurnizorID NUMBER PRIMARY KEY,
    NumeFurnizor VARCHAR2(255),
    Adresa VARCHAR2(255),
    Telefon VARCHAR2(15)
);

-- Crearea tabelului Joc_de_Masa
CREATE TABLE Joc_de_Masa (
    JocID NUMBER PRIMARY KEY,
    NumeJoc VARCHAR2(255),
    Gen VARCHAR2(255),
    Pret NUMBER,
    VarstaRecomandata NUMBER,
    Rating_Medie NUMBER,
    Durata_Joc NUMBER
);


-- Crearea tabelului Comanda
CREATE TABLE Comanda (
    ComandaID NUMBER PRIMARY KEY,
    ClientID NUMBER,
    DataComanda DATE,
    TotalPret NUMBER,
    Status VARCHAR2(50)
);

-- Crearea tabelului Client
CREATE TABLE Client (
    ClientID NUMBER PRIMARY KEY,
    NumeClient VARCHAR2(255),
    Email VARCHAR2(255),
    Telefon VARCHAR2(15),
    AdresaLivrare VARCHAR2(255)
);

-- Crearea tabelului Stock
CREATE TABLE Stock (
    StockID NUMBER PRIMARY KEY,
    FurnizorID NUMBER REFERENCES Furnizori(FurnizorID),
    JocID NUMBER REFERENCES Joc_de_Masa(JocID),
    Cantitate NUMBER,
    DataAprovizionare DATE
);

-- Crearea tabelului Inchiriaza
CREATE TABLE Inchiriaza (
    InchiriazaID NUMBER PRIMARY KEY,
    JocID NUMBER REFERENCES Joc_de_Masa(JocID),
    ClientID NUMBER REFERENCES Client(ClientID),
    DataInchiriere DATE,
    DurataInchiriere NUMBER -- aici m-am gandit ca ar fi mai util sa am nr de zile, decat DataExpirare desi cred
                            -- ca ar ingreuna cu niste calcule extra
);

-- Crearea tabelului Comanda_Joc
CREATE TABLE Comanda_Joc (
    ComandaJocID NUMBER PRIMARY KEY,
    ComandaID NUMBER REFERENCES Comanda(ComandaID),
    JocID NUMBER REFERENCES Joc_de_Masa(JocID),
    CantitateJoc NUMBER,
    Subtotal NUMBER
);

-- Crearea tabelului Review
CREATE TABLE Review (
    ReviewID NUMBER PRIMARY KEY,
    JocID NUMBER REFERENCES Joc_de_Masa(JocID),
    ClientID NUMBER REFERENCES Client(ClientID),
    Title VARCHAR2(255),
    DataReview DATE NOT NULL,
    Rating NUMBER(2) CHECK (Rating >= 1 AND Rating <= 10),
    Continut VARCHAR2(1000),
    LastEdited DATE,
    Likeuri NUMBER NOT NULL
);

-- Crearea tabelului Wishlist
CREATE TABLE Wishlist (
    ClientID NUMBER PRIMARY KEY REFERENCES Client(ClientID),
    DataCreare DATE NOT NULL,
    LastUpdated DATE
);


-- Crearea tabelului Shopping_Cart
CREATE TABLE Shopping_Cart (
    ClientID NUMBER PRIMARY KEY REFERENCES Client(ClientID),
    DataCreare DATE NOT NULL,
    LastUpdated DATE,
    CartDiscount NUMBER,    
    TotalBeforeDiscount NUMBER, 
    TotalAfterDiscount NUMBER  
);

-- Crearea tabelului Wishlist_Items
CREATE TABLE Wishlist_Items (
    ClientID NUMBER NOT NULL REFERENCES Wishlist(ClientID),
    JocID NUMBER NOT NULL REFERENCES Joc_de_Masa(JocID),
    DataAdaugare DATE NOT NULL,
    PRIMARY KEY (ClientID, JocID)
);


-- Crearea tabelului Shopping_Cart_Items
CREATE TABLE Shopping_Cart_Items (
    CartItemID NUMBER PRIMARY KEY,
    ClientID NUMBER NOT NULL REFERENCES Shopping_Cart(ClientID),
    JocID NUMBER NOT NULL REFERENCES Joc_de_Masa(JocID),
    Cantitate NUMBER NOT NULL CHECK (Cantitate > 0),
    Subtotal NUMBER NOT NULL CHECK (Subtotal >= 0)
);





INSERT INTO Furnizori VALUES (1, 'Furnizor1', 'Strada A', '0123456789');
INSERT INTO Furnizori VALUES (2, 'Furnizor2', 'Strada B', '0123456781');
INSERT INTO Furnizori VALUES (3, 'Furnizor3', 'Strada C', '0123456782');
INSERT INTO Furnizori VALUES (4, 'Furnizor4', 'Strada D', '0123456783');
INSERT INTO Furnizori VALUES (5, 'Furnizor5', 'Strada E', '0123456784');

INSERT INTO Furnizori VALUES (6, 'Furnizor6', 'Strada F', '0123456790');
INSERT INTO Furnizori VALUES (7, 'Furnizor7', 'Strada G', '0123456791');
INSERT INTO Furnizori VALUES (8, 'Furnizor8', 'Strada H', '0123456792');
INSERT INTO Furnizori VALUES (9, 'Furnizor9', 'Strada I', '0123456793');
INSERT INTO Furnizori VALUES (10, 'Furnizor10', 'Strada J', '0123456794');



INSERT INTO Joc_de_Masa VALUES (1, 'Dune', 'Strategie', 150, 14,0, 200);
INSERT INTO Joc_de_Masa VALUES (2, 'Hive', 'Strategie', 90, 6, 0, 15 );
INSERT INTO Joc_de_Masa VALUES (3, 'FeedTheKraken', 'Party', 120, 8, 0, 180);
INSERT INTO Joc_de_Masa VALUES (4, 'Coup', 'RPG', 200, 16, 0, 90);
INSERT INTO Joc_de_Masa VALUES (5, 'Turncoats', 'Strategie', 100, 12, 0, 30);

INSERT INTO Joc_de_Masa VALUES (6, 'TheCrew', 'Strategie', 50, 6, 0, 60);
INSERT INTO Joc_de_Masa VALUES (7, 'Bang!', 'Party', 80, 8, 0, 90);
INSERT INTO Joc_de_Masa VALUES (8, 'Calico', 'Strategie', 160, 10, 0, 120);
INSERT INTO Joc_de_Masa VALUES (9, 'Wingspan', 'Familie', 140, 8, 0, 180);
INSERT INTO Joc_de_Masa VALUES (10, 'NotEnoughMana', 'DrinkingGame', 110, 12, 0, 60);


INSERT INTO Client VALUES (1, 'Ion Popescu', 'ion.popescu@email.com', '0712345678', 'Strada A, Nr. 1');
INSERT INTO Client VALUES (2, 'Maria Ionescu', 'maria.ionescu@email.com', '0712345679', 'Strada B, Nr. 2');
INSERT INTO Client VALUES (3, 'Andrei Vasile', 'andrei.vasile@email.com', '0712345670', 'Strada C, Nr. 3');
INSERT INTO Client VALUES (4, 'Elena Mihai', 'elena.mihai@email.com', '0712345671', 'Strada D, Nr. 4');
INSERT INTO Client VALUES (5, 'Geroge Radu', 'george.radu@email.com', '0712345672', 'Strada E, Nr. 5');
INSERT INTO Client VALUES (6, 'Epure Carlo', 'epure.carlo@email.com', '0712345123', 'Strada Petra, Nr. 6');

INSERT INTO Client VALUES (7, 'Petra Rusu', 'petra.rusu@email.com', '0712345680', 'Strada Carlo, Nr. 7');
INSERT INTO Client VALUES (8, 'Bogdan Ionescu', 'bogdan.ionescu@email.com', '0712345681', 'Strada F, Nr. 8');
INSERT INTO Client VALUES (9, 'Sorin Parcalab', 'sorin.parcalab@email.com', '0712345682', 'Strada G, Nr. 9');
INSERT INTO Client VALUES (10, 'Diana Preda', 'diana.preda@email.com', '0712345683', 'Strada H, Nr. 10');
INSERT INTO Client VALUES (11, 'Mihai Georgescu', 'mihai.georgescu@email.com', '0712345684', 'Strada I, Nr. 11');


INSERT INTO Comanda VALUES (1, 1, SYSDATE, 250, 'Livrata');
INSERT INTO Comanda VALUES (2, 2, SYSDATE, 300, 'In curs de livrare');
INSERT INTO Comanda VALUES (3, 3, SYSDATE, 200, 'Anulata');
INSERT INTO Comanda VALUES (4, 4, SYSDATE, 400, 'Livrat');
INSERT INTO Comanda VALUES (5, 5, SYSDATE, 150, 'In curs de livrare');

INSERT INTO Comanda VALUES (6, 6, SYSDATE, 350, 'Livrata');
INSERT INTO Comanda VALUES (7, 7, SYSDATE, 280, 'In curs de livrare');
INSERT INTO Comanda VALUES (8, 8, SYSDATE, 220, 'Anulata');
INSERT INTO Comanda VALUES (9, 9, SYSDATE, 460, 'Livrata');
INSERT INTO Comanda VALUES (10, 10, SYSDATE, 310, 'In curs de livrare');




INSERT INTO Stock VALUES (1, 1, 1, 10, SYSDATE);
INSERT INTO Stock VALUES (2, 2, 2, 8, SYSDATE);
INSERT INTO Stock VALUES (3, 3, 3, 5, SYSDATE);
INSERT INTO Stock VALUES (4, 4, 4, 12, SYSDATE);
INSERT INTO Stock VALUES (5, 5, 5, 7, SYSDATE);

INSERT INTO Stock VALUES (6, 6, 6, 15, SYSDATE);
INSERT INTO Stock VALUES (7, 7, 7, 20, SYSDATE);
INSERT INTO Stock VALUES (8, 8, 8, 12, SYSDATE);
INSERT INTO Stock VALUES (9, 9, 9, 9, SYSDATE);
INSERT INTO Stock VALUES (10, 10, 10, 8, SYSDATE);


INSERT INTO Inchiriaza VALUES (1, 1, 1, SYSDATE, 7);
INSERT INTO Inchiriaza VALUES (2, 2, 2, SYSDATE, 14);
INSERT INTO Inchiriaza VALUES (3, 3, 3, SYSDATE, 30);
INSERT INTO Inchiriaza VALUES (4, 4, 4, SYSDATE, 21);
INSERT INTO Inchiriaza VALUES (5, 5, 5, SYSDATE, 10);

INSERT INTO Inchiriaza VALUES (6, 6, 6, SYSDATE, 5);
INSERT INTO Inchiriaza VALUES (7, 7, 7, SYSDATE, 3);
INSERT INTO Inchiriaza VALUES (8, 8, 8, SYSDATE, 10);
INSERT INTO Inchiriaza VALUES (9, 9, 9, SYSDATE, 15);
INSERT INTO Inchiriaza VALUES (10, 10, 10, SYSDATE, 7);


INSERT INTO Comanda_Joc VALUES (1, 1, 1, 2, 200);
INSERT INTO Comanda_Joc VALUES (2, 2, 2, 3, 450);
INSERT INTO Comanda_Joc VALUES (3, 3, 3, 1, 100);
INSERT INTO Comanda_Joc VALUES (4, 4, 4, 4, 800);
INSERT INTO Comanda_Joc VALUES (5, 5, 5, 5, 90);

INSERT INTO Comanda_Joc VALUES (6, 1, 2, 1, 150);
INSERT INTO Comanda_Joc VALUES (7, 2, 3, 2, 240);
INSERT INTO Comanda_Joc VALUES (8, 3, 4, 1, 200);
INSERT INTO Comanda_Joc VALUES (9, 4, 5, 3, 300);
INSERT INTO Comanda_Joc VALUES (10, 5, 1, 2, 300);



INSERT INTO Review VALUES (1, 1, 1, 'O inovatie!', SYSDATE, 5, 'Foarte bun!', NULL, 0);
INSERT INTO Review VALUES (2, 2, 2, 'Abatere prea mare de la uzual', SYSDATE, 2, 'Interesant intr-un mod neplacut!', NULL, 0);
INSERT INTO Review VALUES (3, 3, 3, 'Habar n-am', SYSDATE, 3, 'Nu m-am prins cum se joaca!', NULL, 0);
INSERT INTO Review VALUES (4, 4, 4, 'CUM EXISTA SA CEVA', SYSDATE, 2, 'Nu mi-a pl?cut!', NULL, 0);
INSERT INTO Review VALUES (5, 5, 5, 'Un joc draugut', SYSDATE, 5, 'Recomand!', NULL, 0);
INSERT INTO Review VALUES (6, 5, 6, 'Multumesc SupergiantGames', SYSDATE, 5, 'Recomand! partea 2', NULL, 0);

INSERT INTO Review VALUES (7, 2, 1, 'Cel mai bun retailer!', SYSDATE, 4, 'Bun joc cu multa strategie.', NULL, 0);
INSERT INTO Review VALUES (8, 3, 2, 'RECOMAND', SYSDATE, 5, 'Recomand! 2 electric bogaloo', NULL, 0);
INSERT INTO Review VALUES (9, 4, 3, 'Vii des pe aici?', SYSDATE, 3, 'Ok, dar poate fi mai bun.', NULL, 0);
INSERT INTO Review VALUES (10, 5, 4, 'Genial', SYSDATE, 4, 'Foarte distractiv!', NULL, 0);
INSERT INTO Review VALUES (11, 1, 5, 'Universal placubil', SYSDATE, 2, 'Nu e pe gustul meu acest tip de joc, dar pana si mie mi-a placut', NULL, 0);


INSERT INTO Wishlist (ClientID, DataCreare) VALUES (1, SYSDATE);
INSERT INTO Wishlist (ClientID, DataCreare) VALUES (2, SYSDATE);
INSERT INTO Wishlist (ClientID, DataCreare) VALUES (3, SYSDATE);
INSERT INTO Wishlist (ClientID, DataCreare) VALUES (4, SYSDATE);
INSERT INTO Wishlist (ClientID, DataCreare) VALUES (5, SYSDATE);

INSERT INTO Wishlist (ClientID, DataCreare) VALUES (6, SYSDATE);
INSERT INTO Wishlist (ClientID, DataCreare) VALUES (7, SYSDATE);
INSERT INTO Wishlist (ClientID, DataCreare) VALUES (8, SYSDATE);
INSERT INTO Wishlist (ClientID, DataCreare) VALUES (9, SYSDATE);
INSERT INTO Wishlist (ClientID, DataCreare) VALUES (10, SYSDATE);



INSERT INTO Shopping_Cart (ClientID, DataCreare) VALUES (1, SYSDATE);
INSERT INTO Shopping_Cart (ClientID, DataCreare) VALUES (2, SYSDATE);
INSERT INTO Shopping_Cart (ClientID, DataCreare) VALUES (3, SYSDATE);
INSERT INTO Shopping_Cart (ClientID, DataCreare) VALUES (4, SYSDATE);
INSERT INTO Shopping_Cart (ClientID, DataCreare) VALUES (5, SYSDATE);

INSERT INTO Shopping_Cart (ClientID, DataCreare) VALUES (6, SYSDATE);
INSERT INTO Shopping_Cart (ClientID, DataCreare) VALUES (7, SYSDATE);
INSERT INTO Shopping_Cart (ClientID, DataCreare) VALUES (8, SYSDATE);
INSERT INTO Shopping_Cart (ClientID, DataCreare) VALUES (9, SYSDATE);
INSERT INTO Shopping_Cart (ClientID, DataCreare) VALUES (10, SYSDATE);




INSERT INTO Wishlist_Items (ClientID, JocID, DataAdaugare) VALUES (1, 2, SYSDATE);
INSERT INTO Wishlist_Items (ClientID, JocID, DataAdaugare) VALUES (1, 3, SYSDATE);
INSERT INTO Wishlist_Items (ClientID, JocID, DataAdaugare) VALUES (2, 4, SYSDATE);
INSERT INTO Wishlist_Items (ClientID, JocID, DataAdaugare) VALUES (2, 5, SYSDATE);
INSERT INTO Wishlist_Items (ClientID, JocID, DataAdaugare) VALUES (3, 1, SYSDATE);

INSERT INTO Wishlist_Items (ClientID, JocID, DataAdaugare) VALUES (4, 1, SYSDATE);
INSERT INTO Wishlist_Items (ClientID, JocID, DataAdaugare) VALUES (5, 2, SYSDATE);
INSERT INTO Wishlist_Items (ClientID, JocID, DataAdaugare) VALUES (6, 3, SYSDATE);
INSERT INTO Wishlist_Items (ClientID, JocID, DataAdaugare) VALUES (7, 4, SYSDATE);
INSERT INTO Wishlist_Items (ClientID, JocID, DataAdaugare) VALUES (8, 5, SYSDATE);



INSERT INTO Shopping_Cart_Items (CartItemID, ClientID, JocID, Cantitate, Subtotal) VALUES (1, 1, 1, 1, 150);
INSERT INTO Shopping_Cart_Items (CartItemID, ClientID, JocID, Cantitate, Subtotal) VALUES (2, 2, 2, 2, 180);
INSERT INTO Shopping_Cart_Items (CartItemID, ClientID, JocID, Cantitate, Subtotal) VALUES (3, 3, 3, 1, 200);
INSERT INTO Shopping_Cart_Items (CartItemID, ClientID, JocID, Cantitate, Subtotal) VALUES (4, 4, 4, 2, 400);
INSERT INTO Shopping_Cart_Items (CartItemID, ClientID, JocID, Cantitate, Subtotal) VALUES (5, 5, 5, 1, 100);


INSERT INTO Shopping_Cart_Items (CartItemID, ClientID, JocID, Cantitate, Subtotal) VALUES (6, 2, 3, 2, 240);
INSERT INTO Shopping_Cart_Items (CartItemID, ClientID, JocID, Cantitate, Subtotal) VALUES (7, 3, 4, 1, 200);
INSERT INTO Shopping_Cart_Items (CartItemID, ClientID, JocID, Cantitate, Subtotal) VALUES (8, 4, 5, 3, 300);
INSERT INTO Shopping_Cart_Items (CartItemID, ClientID, JocID, Cantitate, Subtotal) VALUES (9, 5, 1, 2, 300);
INSERT INTO Shopping_Cart_Items (CartItemID, ClientID, JocID, Cantitate, Subtotal) VALUES (10, 1, 2, 1, 90);













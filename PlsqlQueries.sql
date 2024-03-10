-- ex6
CREATE OR REPLACE PROCEDURE RecomandariJocuri (p_ClientID IN NUMBER) IS
    TYPE t_Array IS TABLE OF NUMBER INDEX BY PLS_INTEGER;
    TYPE t_Joc IS RECORD (JocID NUMBER, NumeJoc VARCHAR2(255));
    TYPE t_NestedTable IS TABLE OF t_Joc;
    TYPE t_Vector IS VARRAY(10) OF VARCHAR2(255); -- Vector pentru recomandari

    v_Wishlist t_Array;
    v_Cumparate t_Array;
    v_Jocuri t_NestedTable;
    v_Recomandari t_Vector := t_Vector();

BEGIN
    -- Popularea wishlist-ului clientului
    SELECT JocID BULK COLLECT INTO v_Wishlist
    FROM Wishlist_Items
    WHERE ClientID = p_ClientID;

    -- Popularea listei de jocuri cumparate
    SELECT cj.JocID BULK COLLECT INTO v_Cumparate
    FROM Comanda_Joc cj
    JOIN Comanda c ON c.ComandaID = cj.ComandaID
    WHERE c.ClientID = p_ClientID;

    -- Colectarea tuturor jocurilor
    SELECT JocID, NumeJoc BULK COLLECT INTO v_Jocuri
    FROM Joc_de_Masa;

    -- Identificarea jocurilor care nu sunt în wishlist sau cumparate
    FOR i IN 1..v_Jocuri.COUNT LOOP
        IF NOT v_Wishlist.EXISTS(v_Jocuri(i).JocID) AND NOT v_Cumparate.EXISTS(v_Jocuri(i).JocID) THEN
            IF v_Recomandari.COUNT < v_Recomandari.LIMIT THEN
                v_Recomandari.EXTEND;
                v_Recomandari(v_Recomandari.COUNT) := v_Jocuri(i).NumeJoc;
            END IF;
        END IF;
    END LOOP;

    -- Returnarea recomandarilor
    FOR i IN 1..v_Recomandari.COUNT LOOP
        DBMS_OUTPUT.PUT_LINE('Recomandare: ' || v_Recomandari(i));
    END LOOP;
END RecomandariJocuri;

Declare 
Begin
RecomandariJocuri(1);
End;

------------------------------------------------------------------------------------------------------------------------------------
--ex 7
CREATE OR REPLACE PROCEDURE AnalizaPerformantaJocuri IS
    CURSOR c_Jocuri IS
        SELECT JocID, NumeJoc
        FROM Joc_de_Masa;

    CURSOR c_DetaliiJoc (p_JocID Joc_de_Masa.JocID%TYPE) IS
        SELECT AVG(Rating) AS RatingMediu, COUNT(ReviewID) AS NrRecenzii, SUM(CantitateJoc) AS UnitatiSpreVanzare
        FROM Review
        JOIN Comanda_Joc ON Review.JocID = Comanda_Joc.JocID
        WHERE Review.JocID = p_JocID
        GROUP BY Review.JocID;

    v_RatingMediu NUMBER;
    v_NrRecenzii NUMBER;
    v_UnitatiSpreVanzare NUMBER;
BEGIN
    FOR joc IN c_Jocuri LOOP
        OPEN c_DetaliiJoc(joc.JocID);
        FETCH c_DetaliiJoc INTO v_RatingMediu, v_NrRecenzii, v_UnitatiSpreVanzare;
        CLOSE c_DetaliiJoc;

        DBMS_OUTPUT.PUT_LINE('Joc: ' || joc.NumeJoc || ' | Rating Mediu: ' || v_RatingMediu || ' | Numar Recenzii: ' || v_NrRecenzii || ' | UnitatiSpreVanzare: ' || v_UnitatiSpreVanzare);
    END LOOP;
END AnalizaPerformantaJocuri;

BEGIN
    AnalizaPerformantaJocuri;
END;

------------------------------------------------------------------------------------------------------------------
--ex 8

CREATE OR REPLACE FUNCTION ValoareaTotalaComenzi(p_ClientID IN NUMBER)
RETURN VARCHAR2 IS
    v_ValoareTotala NUMBER;
    v_TotalJocuri NUMBER;
    v_MaxJocuriInComanda NUMBER;

    FaraComenzi EXCEPTION;
    ClientValoroas EXCEPTION;
    ComandaExcesiva EXCEPTION;
    PRAG_VALOROS CONSTANT NUMBER := 499; -- Pragul pentru un client valoros
    MAX_JOCURI_COMANDA CONSTANT NUMBER := 50; -- Pragul pentru numarul maxim de jocuri intr-o comanda

BEGIN
    -- Interogatia cu 3 tabele pt informatii 
    SELECT SUM(co.TotalPret), SUM(cj.CantitateJoc), MAX(cj.CantitateJoc)
    INTO v_ValoareTotala, v_TotalJocuri, v_MaxJocuriInComanda
    FROM Client cl
    JOIN Comanda co ON cl.ClientID = co.ClientID
    JOIN Comanda_Joc cj ON co.ComandaID = cj.ComandaID
    WHERE cl.ClientID = p_ClientID
    GROUP BY cl.ClientID;

    IF v_MaxJocuriInComanda > MAX_JOCURI_COMANDA THEN
        RAISE ComandaExcesiva;
    ELSIF v_ValoareTotala > PRAG_VALOROS THEN
        RAISE ClientValoroas; 
    END IF;

    RETURN 'Valoare totala comenzi: ' || v_ValoareTotala || 
           ', Total jocuri comandate: ' || v_TotalJocuri;
EXCEPTION
    WHEN ComandaExcesiva THEN
        RETURN 'Clientul a plasat o comanda excesiva: ' || p_ClientID || 
               ' cu ' || v_MaxJocuriInComanda || ' jocuri într-o comanda';
    WHEN ClientValoroas THEN
        RETURN 'Clientul este considerat valoros: ' || p_ClientID || 
               ' cu o valoare totala a comenzilor de ' || v_ValoareTotala;
    WHEN OTHERS THEN
        RETURN 'Eroare neasteptata';
END ValoareaTotalaComenzi;


BEGIN
   dbms_output.put_line(ValoareaTotalaComenzi(3));
END;
BEGIN
   dbms_output.put_line(ValoareaTotalaComenzi(5)); -- excesiv
END;
BEGIN
   dbms_output.put_line(ValoareaTotalaComenzi(2)); -- valoros
END;

---------------------------------------------------------------------------------------------------------------
-- ex9

CREATE OR REPLACE PROCEDURE RaportFurnizoriVanzari(vandute in number) IS
    v_NumeFurnizor VARCHAR2(255);
    v_IDJoc NUMBER;

    e_FurnizoriMultipli EXCEPTION;
    e_FaraFurnizoriUnici EXCEPTION;
    e_AltEroare EXCEPTION;
BEGIN
    -- Interogarea cu 5 tabele pentru a obtine informatiile necesare
    SELECT f.NumeFurnizor, s.JocID
    INTO v_NumeFurnizor, v_IDJoc
    FROM Furnizori f
    JOIN Stock s ON f.FurnizorID = s.FurnizorID
    JOIN Joc_de_Masa j ON s.JocID = j.JocID
    JOIN Comanda_Joc cj ON j.JocID = cj.JocID
    JOIN Comanda c ON cj.ComandaID = c.ComandaID
    GROUP BY f.NumeFurnizor, s.JocID
    HAVING COUNT(s.JocID) = vandute;

    DBMS_OUTPUT.PUT_LINE('Furnizor: ' || v_NumeFurnizor || ', ID Joc Unic: ' || v_IDJoc);
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Nu exista furnizori care au vandut numarul asta de jocuri de masa  ' || vandute );
    WHEN TOO_MANY_ROWS THEN
        DBMS_OUTPUT.PUT_LINE('Exista mai multi furnizori care au vandut nr asta de jocuri de masa ' || vandute  );
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('s-a produs alta eroare ');
   END RaportFurnizoriVanzari;


BEGIN
    RaportFurnizoriVanzari(3);
END;

BEGIN
    RaportFurnizoriVanzari(4);
END;


---------------------------------------------------
-- ex10
CREATE OR REPLACE TRIGGER Joc_De_Masa_Weekend_Trigger
BEFORE INSERT ON Joc_De_Masa
DECLARE
    e_Weekend EXCEPTION;
BEGIN
    IF TO_CHAR(SYSDATE, 'DY') IN ('THU', 'SUN') THEN -- l am testat joi
        RAISE e_Weekend;
    END IF;
EXCEPTION
    WHEN e_Weekend THEN
        RAISE_APPLICATION_ERROR(-20001, 'Nu se pot adauga jocuri in weekend');
END;

INSERT INTO Joc_de_Masa VALUES (69, 'NotEnoughManaaaaa', 'Mister', 110, 12, 0, 60);

-----------------------------------------------------------
-- ex11


CREATE OR REPLACE TRIGGER Update_CartDiscount_Trigger
FOR INSERT ON Comanda
COMPOUND TRIGGER
     type counts is table of number;
    v_ComandaCount counts;
    
    BEFORE statement  IS
    BEGIN
    SELECT COUNT(*)
     bulk collect INTO v_ComandaCount
        FROM Comanda
        Group by ClientID;
    END BEFORE statement;
    BEFORE EACH ROW IS
    BEGIN
        IF v_ComandaCount(:NEW.ClientID) >= 5 THEN
            UPDATE Shopping_Cart
            SET CartDiscount = 10
            WHERE ClientID = :NEW.ClientID;
        END IF;
    END BEFORE each row;

END Update_CartDiscount_Trigger;


----------------------------------------------------------
-- ex12
CREATE TABLE Schema_Change_Logs (
    Event_Type VARCHAR2(50),
    Object_Type VARCHAR2(50),
    Object_Name VARCHAR2(255),
    Event_Time TIMESTAMP
);

CREATE OR REPLACE TRIGGER Schema_Change_Log_Trigger
AFTER CREATE OR ALTER OR DROP ON SCHEMA
DECLARE
BEGIN
    INSERT INTO Schema_Change_Logs (Event_Type, Object_Type, Object_Name, Event_Time)
    VALUES (ORA_SYSEVENT, ORA_DICT_OBJ_TYPE, ORA_DICT_OBJ_NAME, SYSDATE);
END;

SELECT * from Schema_Change_Logs;



-----------------------------------------------------
-- ex13

Create or replace package Pachet is 
procedure RecomandariJocuri(p_ClientID IN NUMBER);
procedure AnalizaPerformantaJocuri;
FUNCTION ValoareaTotalaComenzi(p_ClientID IN NUMBER) RETURN VARCHAR2;
procedure RaportFurnizoriVanzari(vandute in number);
end Pachet;

create or replace package body Pachet is 
PROCEDURE RecomandariJocuri (p_ClientID IN NUMBER) IS
    TYPE t_Array IS TABLE OF NUMBER INDEX BY PLS_INTEGER;
    TYPE t_Joc IS RECORD (JocID NUMBER, NumeJoc VARCHAR2(255));
    TYPE t_NestedTable IS TABLE OF t_Joc;
    TYPE t_Vector IS VARRAY(10) OF VARCHAR2(255); -- Vector pentru recomandari

    v_Wishlist t_Array;
    v_Cumparate t_Array;
    v_Jocuri t_NestedTable;
    v_Recomandari t_Vector := t_Vector();

BEGIN
    -- Popularea wishlist-ului clientului
    SELECT JocID BULK COLLECT INTO v_Wishlist
    FROM Wishlist_Items
    WHERE ClientID = p_ClientID;

    -- Popularea listei de jocuri cumparate
    SELECT cj.JocID BULK COLLECT INTO v_Cumparate
    FROM Comanda_Joc cj
    JOIN Comanda c ON c.ComandaID = cj.ComandaID
    WHERE c.ClientID = p_ClientID;

    -- Colectarea tuturor jocurilor
    SELECT JocID, NumeJoc BULK COLLECT INTO v_Jocuri
    FROM Joc_de_Masa;

    -- Identificarea jocurilor care nu sunt în wishlist sau cumparate
    FOR i IN 1..v_Jocuri.COUNT LOOP
        IF NOT v_Wishlist.EXISTS(v_Jocuri(i).JocID) AND NOT v_Cumparate.EXISTS(v_Jocuri(i).JocID) THEN
            IF v_Recomandari.COUNT < v_Recomandari.LIMIT THEN
                v_Recomandari.EXTEND;
                v_Recomandari(v_Recomandari.COUNT) := v_Jocuri(i).NumeJoc;
            END IF;
        END IF;
    END LOOP;

    -- Returnarea recomandarilor
    FOR i IN 1..v_Recomandari.COUNT LOOP
        DBMS_OUTPUT.PUT_LINE('Recomandare: ' || v_Recomandari(i));
    END LOOP;
END RecomandariJocuri;
PROCEDURE AnalizaPerformantaJocuri IS
    CURSOR c_Jocuri IS
        SELECT JocID, NumeJoc
        FROM Joc_de_Masa;

    CURSOR c_DetaliiJoc (p_JocID Joc_de_Masa.JocID%TYPE) IS
        SELECT AVG(Rating) AS RatingMediu, COUNT(ReviewID) AS NrRecenzii, SUM(CantitateJoc) AS UnitatiSpreVanzare
        FROM Review
        JOIN Comanda_Joc ON Review.JocID = Comanda_Joc.JocID
        WHERE Review.JocID = p_JocID
        GROUP BY Review.JocID;

    v_RatingMediu NUMBER;
    v_NrRecenzii NUMBER;
    v_UnitatiSpreVanzare NUMBER;
BEGIN
    FOR joc IN c_Jocuri LOOP
        OPEN c_DetaliiJoc(joc.JocID);
        FETCH c_DetaliiJoc INTO v_RatingMediu, v_NrRecenzii, v_UnitatiSpreVanzare;
        CLOSE c_DetaliiJoc;

        DBMS_OUTPUT.PUT_LINE('Joc: ' || joc.NumeJoc || ' | Rating Mediu: ' || v_RatingMediu || ' | Numar Recenzii: ' || v_NrRecenzii || ' | UnitatiSpreVanzare: ' || v_UnitatiSpreVanzare);
    END LOOP;
END AnalizaPerformantaJocuri;

FUNCTION ValoareaTotalaComenzi(p_ClientID IN NUMBER)
RETURN VARCHAR2 IS
    v_ValoareTotala NUMBER;
    v_TotalJocuri NUMBER;
    v_MaxJocuriInComanda NUMBER;

    FaraComenzi EXCEPTION;
    ClientValoroas EXCEPTION;
    ComandaExcesiva EXCEPTION;
    PRAG_VALOROS CONSTANT NUMBER := 499; -- Pragul pentru un client valoros
    MAX_JOCURI_COMANDA CONSTANT NUMBER := 50; -- Pragul pentru numarul maxim de jocuri intr-o comanda

BEGIN
    
    SELECT SUM(co.TotalPret), SUM(cj.CantitateJoc), MAX(cj.CantitateJoc)
    INTO v_ValoareTotala, v_TotalJocuri, v_MaxJocuriInComanda
    FROM Client cl
    JOIN Comanda co ON cl.ClientID = co.ClientID
    JOIN Comanda_Joc cj ON co.ComandaID = cj.ComandaID
    WHERE cl.ClientID = p_ClientID
    GROUP BY cl.ClientID;

    IF v_MaxJocuriInComanda > MAX_JOCURI_COMANDA THEN
        RAISE ComandaExcesiva;
    ELSIF v_ValoareTotala > PRAG_VALOROS THEN
        RAISE ClientValoroas; 
    END IF;

    RETURN 'Valoare totala comenzi: ' || v_ValoareTotala || 
           ', Total jocuri comandate: ' || v_TotalJocuri;
EXCEPTION
    WHEN ComandaExcesiva THEN
        RETURN 'Clientul a plasat o comanda excesiva: ' || p_ClientID || 
               ' cu ' || v_MaxJocuriInComanda || ' jocuri intr-o comanda';
    WHEN ClientValoroas THEN
        RETURN 'Clientul este considerat valoros: ' || p_ClientID || 
               ' cu o valoare totala a comenzilor de ' || v_ValoareTotala;
    WHEN OTHERS THEN
        RETURN 'Eroare neasteptata';
END ValoareaTotalaComenzi;
PROCEDURE RaportFurnizoriVanzari(vandute in number) IS
    v_NumeFurnizor VARCHAR2(255);
    v_IDJoc NUMBER;

    e_FurnizoriMultipli EXCEPTION;
    e_FaraFurnizoriUnici EXCEPTION;
    e_AltEroare EXCEPTION;
BEGIN
   
    SELECT f.NumeFurnizor, s.JocID
    INTO v_NumeFurnizor, v_IDJoc
    FROM Furnizori f
    JOIN Stock s ON f.FurnizorID = s.FurnizorID
    JOIN Joc_de_Masa j ON s.JocID = j.JocID
    LEFT JOIN Comanda_Joc cj ON j.JocID = cj.JocID
    LEFT JOIN Comanda c ON cj.ComandaID = c.ComandaID
    GROUP BY f.NumeFurnizor, s.JocID
    HAVING COUNT(s.JocID) = vandute;

    DBMS_OUTPUT.PUT_LINE('Furnizor: ' || v_NumeFurnizor || ', ID Joc Unic: ' || v_IDJoc);
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Nu exista furnizori care au vandut numarul asta de jocuri de masa  ' || vandute );
    WHEN TOO_MANY_ROWS THEN
        DBMS_OUTPUT.PUT_LINE('Exista mai multi furnizori care au vandut nr asta de jocuri de masa ' || vandute  );
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('s-a produs alta eroare ');
   END RaportFurnizoriVanzari;
end Pachet;

----------------------------------------------------------------------------
BEGIN
    Pachet.RecomandariJocuri(1);
END;
----------------------------------------------------------------------------
BEGIN
    Pachet.AnalizaPerformantaJocuri;
END;
----------------------------------------------------------------------------
DECLARE
    result VARCHAR2(4000);
BEGIN
    result := Pachet.ValoareaTotalaComenzi(1); 
    DBMS_OUTPUT.PUT_LINE(result);
END;

DECLARE
    result VARCHAR2(4000);
BEGIN
    result := Pachet.ValoareaTotalaComenzi(3); 
    DBMS_OUTPUT.PUT_LINE(result);
END;

DECLARE
    result VARCHAR2(4000);
BEGIN
    result := Pachet.ValoareaTotalaComenzi(5); 
    DBMS_OUTPUT.PUT_LINE(result);
END;
----------------------------------------------------------------------------
BEGIN
    Pachet.RaportFurnizoriVanzari(5); 
END;

BEGIN
    Pachet.RaportFurnizoriVanzari(1); 
END;











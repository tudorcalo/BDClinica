CREATE OR REPLACE PROCEDURE PR_ISTORIC_PACIENT(p_id_pacient NUMBER) IS
    v_pacient PR_PACIENTI%ROWTYPE;
    CURSOR c_istoric IS
        SELECT ID_PROGRAMARE, DATA_ORA, STARE_PROGRAMARE
        FROM PR_PROGRAMARI
        WHERE ID_PACIENT = p_id_pacient;
BEGIN
    SELECT * INTO v_pacient FROM PR_PACIENTI WHERE ID_PACIENT = p_id_pacient;
    DBMS_OUTPUT.PUT_LINE('Pacient: ' || v_pacient.NUME || ' ' || v_pacient.PRENUME);

    FOR r IN c_istoric LOOP
        DBMS_OUTPUT.PUT_LINE('ID: ' || r.ID_PROGRAMARE || ' | Data: ' || r.DATA_ORA || ' | Stare: ' || r.STARE_PROGRAMARE);
    END LOOP;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Eroare: Pacientul nu a fost gasit.');
END;
/

CREATE OR REPLACE PROCEDURE PR_ANULEAZA_PROGRAMARI(p_id_pacient NUMBER) IS
BEGIN
    UPDATE PR_PROGRAMARI
    SET STARE_PROGRAMARE = 'Anulata'
    WHERE ID_PACIENT = p_id_pacient AND STARE_PROGRAMARE = 'Programata';

    IF SQL%FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Au fost anulate ' || SQL%ROWCOUNT || ' programari.');
        COMMIT;
    ELSE
        DBMS_OUTPUT.PUT_LINE('Nu exista programari active pentru acest pacient.');
    END IF;
END;
/

CREATE OR REPLACE PROCEDURE PR_MARESTE_SALARIU_SPEC(p_id_spec NUMBER, p_procent NUMBER) IS
BEGIN
    IF p_procent <= 0 THEN
        RAISE_APPLICATION_ERROR(-20002, 'Procentul trebuie sa fie pozitiv.');
    END IF;

    UPDATE PR_PERSONAL_CLINICA
    SET SALARIU = SALARIU * (1 + p_procent / 100)
    WHERE ID_SPECIALITATE = p_id_spec;

    IF SQL%FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Salarii actualizate pentru ' || SQL%ROWCOUNT || ' angajati.');
        COMMIT;
    ELSE
        DBMS_OUTPUT.PUT_LINE('Nu au fost gasiti angajati in aceasta specialitate.');
    END IF;
END;
/

CREATE OR REPLACE PROCEDURE PR_RAPORT_SERVICII IS
    TYPE r_raport IS RECORD (
        nume_cat      PR_SERVICII_MEDICALE.CATEGORIE%TYPE,
        total_valoare NUMBER
    );
    v_linie r_raport;
    CURSOR c_servicii IS
        SELECT CATEGORIE, SUM(PRET_LISTA)
        FROM PR_SERVICII_MEDICALE
        GROUP BY CATEGORIE;
BEGIN
    OPEN c_servicii;
    LOOP
        FETCH c_servicii INTO v_linie.nume_cat, v_linie.total_valoare;
        EXIT WHEN c_servicii%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE('Categorie: ' || NVL(v_linie.nume_cat, 'Generala') || ' | Total: ' || v_linie.total_valoare);
    END LOOP;
    CLOSE c_servicii;
END;
/

CREATE OR REPLACE PROCEDURE PR_ADAUGA_ROL(p_id NUMBER, p_nume VARCHAR2, p_sal_min NUMBER) IS
BEGIN
    INSERT INTO PR_ROLURI_PERSONAL (ID_ROL, DENUMIRE_ROL, SALARIU_MIN)
    VALUES (p_id, p_nume, p_sal_min);
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Rol adaugat cu succes.');
EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN
        DBMS_OUTPUT.PUT_LINE('Eroare: Exista deja un rol cu acest ID sau denumire.');
END;
/

CREATE OR REPLACE PROCEDURE PR_DETALII_RETETA_PACIENT(p_id_reteta NUMBER) IS
    v_gasit BOOLEAN := FALSE;
    CURSOR c_med IS
        SELECT m.DENUMIRE_COMERCIALA, d.CANTITATE, d.DOZAJ
        FROM PR_DETALII_RETETA d
        JOIN PR_MEDICAMENTE m ON d.ID_MEDICAMENT = m.ID_MEDICAMENT
        WHERE d.ID_RETETA = p_id_reteta;
BEGIN
    FOR r IN c_med LOOP
        v_gasit := TRUE;
        DBMS_OUTPUT.PUT_LINE(r.DENUMIRE_COMERCIALA || ' | Cantitate: ' || r.CANTITATE || ' | Dozaj: ' || r.DOZAJ);
    END LOOP;

    IF NOT v_gasit THEN
        DBMS_OUTPUT.PUT_LINE('Nu exista medicamente inregistrate pe reteta ' || p_id_reteta);
    END IF;
END;
/
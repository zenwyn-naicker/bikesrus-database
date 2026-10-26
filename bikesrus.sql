/*Author: Zenwyn Naicker*/

/*Code Attribution: */
/**************************************************************************************************************
 * Author: The IIE
 * Date: 2025
 * Title: INFORMATION SYSTEMS 2C INSY7213 ADVANCED DATABASES ADDB6311/ ADDB7311 MODULE MANUAL 2025
 * Type: [Source Code]
 **************************************************************************************************************/
 
-- Question 1: 

-- VOLUNTEER table
CREATE TABLE VOLUNTEER (
    VOL_ID VARCHAR2(10) PRIMARY KEY,
    VOL_FNAME VARCHAR2(50) NOT NULL,
    VOL_SNAME VARCHAR2(50) NOT NULL,
    CONTACT VARCHAR2(15) NOT NULL,
    ADDRESS VARCHAR2(100) NOT NULL,
    EMAIL VARCHAR2(100) NOT NULL
);

-- DONOR table
CREATE TABLE DONOR (
    DONOR_ID VARCHAR2(10) PRIMARY KEY,
    DONOR_FNAME VARCHAR2(50) NOT NULL,
    DONOR_LNAME VARCHAR2(50) NOT NULL,
    CONTACT_NO VARCHAR2(15) NOT NULL,
    EMAIL VARCHAR2(100) NOT NULL
);

-- BIKE table
CREATE TABLE BIKE (
    BIKE_ID VARCHAR2(10) PRIMARY KEY,
    DESCRIPTION VARCHAR2(100) NOT NULL,
    BIKE_TYPE VARCHAR2(50) NOT NULL,
    MANUFACTURER VARCHAR2(50) NOT NULL
);

-- DONATION table
CREATE TABLE DONATION (
    DONATION_ID NUMBER(5) PRIMARY KEY,
    DONOR_ID VARCHAR2(10) NOT NULL REFERENCES DONOR(DONOR_ID),
    BIKE_ID VARCHAR2(10) NOT NULL REFERENCES BIKE(BIKE_ID),
    VALUE NUMBER(10,2) NOT NULL,
    VOLUNTEER_ID VARCHAR2(10) NOT NULL REFERENCES VOLUNTEER(VOL_ID),
    DONATION_DATE DATE NOT NULL
);

-- Display tables
SELECT * FROM VOLUNTEER;
SELECT * FROM DONOR;
SELECT * FROM BIKE;
SELECT * FROM DONATION;

-- Question 2: 

SELECT 
    D.DONOR_ID AS "Donor ID",
    B.BIKE_TYPE AS "Bike Type",
    B.DESCRIPTION AS "Bike Description",
    'R ' || D.VALUE AS "Bike Value"
FROM DONATION D
JOIN BIKE B ON D.BIKE_ID = B.BIKE_ID
WHERE D.VALUE > 1500
ORDER BY D.DONOR_ID;

-- Question 3: 

SET SERVEROUTPUT ON;
DECLARE
    c_VAT_RATE CONSTANT NUMBER := 0.15;
    v_description BIKE.DESCRIPTION%TYPE;
    v_manufacturer BIKE.MANUFACTURER%TYPE;
    v_bike_type BIKE.BIKE_TYPE%TYPE;
    v_value DONATION.VALUE%TYPE;
    v_vat NUMBER(10,2);
    v_total NUMBER(10,2);  
    CURSOR cur_road_bikes IS
        SELECT B.DESCRIPTION, B.MANUFACTURER, B.BIKE_TYPE, D.VALUE
        FROM BIKE B
        JOIN DONATION D ON B.BIKE_ID = D.BIKE_ID
        WHERE B.BIKE_TYPE = 'Road Bike';
BEGIN
    OPEN cur_road_bikes; 
    LOOP
        FETCH cur_road_bikes INTO v_description, v_manufacturer, v_bike_type, v_value;
        EXIT WHEN cur_road_bikes%NOTFOUND;     
        v_vat := v_value * c_VAT_RATE;
        v_total := v_value + v_vat;      
        DBMS_OUTPUT.PUT_LINE('BIKE DESCRIPTION:        ' || v_description);
        DBMS_OUTPUT.PUT_LINE('BIKE MANUFACTURER:       ' || v_manufacturer);
        DBMS_OUTPUT.PUT_LINE('BIKE TYPE:               ' || v_bike_type);
        DBMS_OUTPUT.PUT_LINE('VALUE:                   R' || v_value);
        DBMS_OUTPUT.PUT_LINE('VAT:                     R ' || v_vat);
        DBMS_OUTPUT.PUT_LINE('TOTAL AMNT:              R' || v_total);
        DBMS_OUTPUT.PUT_LINE('--------------------------------------------------------------------------');      
    END LOOP;  
    CLOSE cur_road_bikes;
END;

-- Question 4: 

-- Create the view
CREATE OR REPLACE VIEW vwBikeRUs AS
SELECT 
    DN.DONOR_FNAME || ',' || DN.DONOR_LNAME AS DONOR_NAME,
    DN.CONTACT_NO,
    B.BIKE_TYPE,
    D.DONATION_DATE
FROM DONATION D
JOIN DONOR DN ON D.DONOR_ID = DN.DONOR_ID
JOIN BIKE B ON D.BIKE_ID = B.BIKE_ID
WHERE D.VOLUNTEER_ID = 'vol105';

-- Run the view
SELECT * FROM vwBikeRUs;

/*
Benefits of the View:

Simplified Access:
    Views enable database users to display only specific records that they require from a 
    huge data set (The IIE, 2025). This makes data retrieval more efficient (The IIE, 2025).

Improved Security:
    Database users can only access and view specific information from tables (The IIE, 2025). 
    This protects sensitive information that the outlet may have from unauthorized access (The IIE, 2025).
*/

-- Question 5: 

-- Create the procedure
CREATE OR REPLACE PROCEDURE spDonorDetails (
    p_bike_id IN BIKE.BIKE_ID%TYPE
) AS
    -- Declare variables to store retrieved data
    v_donor_name VARCHAR2(100);
    v_contact_no DONOR.CONTACT_NO%TYPE;
    v_volunteer_fname VOLUNTEER.VOL_FNAME%TYPE;
    v_bike_description BIKE.DESCRIPTION%TYPE;
    v_donation_date DONATION.DONATION_DATE%TYPE;
BEGIN
    -- Query to retrieve donor and donation details
    SELECT 
        DN.DONOR_FNAME || ' ' || DN.DONOR_LNAME,
        DN.CONTACT_NO,
        V.VOL_FNAME,
        B.DESCRIPTION,
        D.DONATION_DATE
    INTO v_donor_name, v_contact_no, v_volunteer_fname, v_bike_description, v_donation_date
    FROM DONATION D
    JOIN DONOR DN ON D.DONOR_ID = DN.DONOR_ID
    JOIN VOLUNTEER V ON D.VOLUNTEER_ID = V.VOL_ID
    JOIN BIKE B ON D.BIKE_ID = B.BIKE_ID
    WHERE D.BIKE_ID = p_bike_id;
    
    -- Display the results
    DBMS_OUTPUT.PUT_LINE('ATTENTION: ' || v_donor_name || ' assisted by: ' || 
                         v_volunteer_fname || ' ,donated the  ' || v_bike_description || 
                         ' on the ' || TO_CHAR(v_donation_date, 'DD/MON/YY'));
                         
EXCEPTION
    -- Exception handling: When no data is found for the given bike ID
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('ERROR: No donation found for Bike ID ' || p_bike_id);
        
    -- Exception handling: For any other unexpected errors
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('ERROR: An unexpected error occurred - ' || SQLERRM);
END spDonorDetails;

-- Run the procedure
SET SERVEROUTPUT ON;
EXECUTE spDonorDetails('B004');

-- Question 6:

-- Creates the function to calculate total donation value handled by a volunteer
CREATE OR REPLACE 
FUNCTION fnVolunteerDonationTotal(vol_id IN VOLUNTEER.VOL_ID%TYPE) 
RETURN VARCHAR2 
IS
    details VARCHAR2(200);
    v_volunteer_name VARCHAR2(100);
    v_total_value NUMBER(10,2);
    v_donation_count NUMBER;
    
    -- Cursor to retrieve volunteer details and calculate total donation value
    CURSOR c1 IS
        SELECT V.VOL_FNAME || ' ' || V.VOL_SNAME,
               SUM(D.VALUE),
               COUNT(D.DONATION_ID)
        FROM VOLUNTEER V
        JOIN DONATION D ON UPPER(V.VOL_ID) = UPPER(D.VOLUNTEER_ID)
        WHERE UPPER(V.VOL_ID) = UPPER(vol_id)
        GROUP BY V.VOL_FNAME, V.VOL_SNAME;
BEGIN
    -- Open cursor and fetch volunteer donation statistics
    OPEN c1;
    FETCH c1 INTO v_volunteer_name, v_total_value, v_donation_count;
    
    -- Check if volunteer data exists
    IF c1%NOTFOUND THEN
        details := 'No volunteer information found for ID: ' || vol_id;
    ELSE
        -- Format the output message with volunteer statistics
        details := v_volunteer_name || ' handled ' || v_donation_count || 
                   ' donation(s) with a total value of R' || v_total_value;
    END IF;
    
    CLOSE c1;
    RETURN details;
    
EXCEPTION
    -- Handle any unexpected errors
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20001, 'An error was encountered - ' || 
                               SQLCODE || ' -ERROR- ' || SQLERRM);
END fnVolunteerDonationTotal;

-- Run the function with a valid volunteer ID
SELECT fnVolunteerDonationTotal('vol103')
FROM DUAL;

-- Question 7: 

SET SERVEROUTPUT ON;
DECLARE
    bike_id BIKE.BIKE_ID%TYPE;
    bike_type BIKE.BIKE_TYPE%TYPE;
    bike_manufacturer BIKE.MANUFACTURER%TYPE;
    bike_value DONATION.VALUE%TYPE;
    bike_status VARCHAR2(10);   
    CURSOR bike_status_cursor IS
        SELECT B.BIKE_ID, B.BIKE_TYPE, B.MANUFACTURER, D.VALUE
        FROM BIKE B, DONATION D
        WHERE B.BIKE_ID = D.BIKE_ID
        ORDER BY B.BIKE_ID;
BEGIN
    FOR rec IN bike_status_cursor
    LOOP
        bike_id := rec.BIKE_ID;
        bike_type := rec.BIKE_TYPE;
        bike_manufacturer := rec.MANUFACTURER;
        bike_value := rec.VALUE;      
        IF bike_value > 3000 THEN
            bike_status := '* * *';
        ELSIF bike_value > 1500 THEN
            bike_status := '* *';
        ELSE
            bike_status := '*';
        END IF;    
        DBMS_OUTPUT.PUT_LINE('BIKE ID:            ' || bike_id);
        DBMS_OUTPUT.PUT_LINE('BIKE TYPE:          ' || bike_type);
        DBMS_OUTPUT.PUT_LINE('BIKE MANUFACTURER:  ' || bike_manufacturer);
        DBMS_OUTPUT.PUT_LINE('BIKE VALUE:         ' || bike_value);
        DBMS_OUTPUT.PUT_LINE('STATUS:             ' || bike_status);
        DBMS_OUTPUT.PUT_LINE('---------------------------------------');
    END LOOP;
END;

-- Question 8: 

SELECT 
    B.BIKE_ID AS "BIK...",
    B.BIKE_TYPE,
    B.MANUFACTURER,
    D.VALUE,
    CASE 
        WHEN D.VALUE > 3000 THEN '* * *'
        WHEN D.VALUE > 1500 THEN '* *'
        ELSE '*'
    END AS STATUS
FROM 
    BIKE B,
    DONATION D
WHERE 
    B.BIKE_ID = D.BIKE_ID
ORDER BY 
    B.BIKE_ID;
    
-- Question 9: 

-- 9.1: 

-- Create the trigger
CREATE OR REPLACE TRIGGER trg_prevent_donation_delete
BEFORE DELETE ON DONATION
FOR EACH ROW
BEGIN
    RAISE_APPLICATION_ERROR(-20001, 'Deletion from DONATION table is not allowed.');
END;

-- Delete statement
DELETE FROM DONATION 
WHERE DONATION_ID = 1;

-- 9.2:

-- Create the trigger
CREATE OR REPLACE TRIGGER trg_validate_bike_value
BEFORE UPDATE ON DONATION
FOR EACH ROW
BEGIN
    IF :NEW.VALUE <= 0 THEN
        RAISE_APPLICATION_ERROR(-20002, 'Invalid bike value. Value must be greater than 0.');
    END IF;
END;

-- Update statement (valid)
UPDATE DONATION 
SET VALUE = 2000 
WHERE DONATION_ID = 1;

-- Update statement (invalid)
UPDATE DONATION 
SET VALUE = 0 
WHERE DONATION_ID = 1;

-- Display
SELECT * FROM DONATION WHERE DONATION_ID = 1;

-- Undo update
ROLLBACK;

-- Question 10: 

-- Integrity example 

-- Create a sequence to generate unique Donation IDs
CREATE SEQUENCE donation_seq
START WITH 1
INCREMENT BY 1
NOCACHE
NOCYCLE;

-- Create the DONATION table with Primary Key constraint
CREATE TABLE DONATION2 (
    DONATION_ID NUMBER(5) PRIMARY KEY,
    DONOR_ID VARCHAR2(10) NOT NULL REFERENCES DONOR(DONOR_ID),
    BIKE_ID VARCHAR2(10) NOT NULL REFERENCES BIKE(BIKE_ID),
    VALUE NUMBER(10,2) NOT NULL,
    VOLUNTEER_ID VARCHAR2(10) NOT NULL REFERENCES VOLUNTEER(VOL_ID),
    DONATION_DATE DATE NOT NULL
);

-- Insert data using the sequence for automatic ID generation
INSERT INTO DONATION2 (DONATION_ID, DONOR_ID, BIKE_ID, VALUE, VOLUNTEER_ID, DONATION_DATE)
VALUES (donation_seq.NEXTVAL, 'DID11', 'B001', 1500, 'vol101', SYSDATE);

-- display table
SELECT * FROM DONATION2;

-- Confidentiality example

-- Create user accounts for different volunteer roles
CREATE USER sales_volunteer IDENTIFIED BY SecurePassword1;
CREATE USER donations_volunteer IDENTIFIED BY SecurePassword2;
CREATE USER manager_user IDENTIFIED BY SecurePassword3;

-- Grant limited privileges to sales volunteers
GRANT CONNECT TO sales_volunteer;
GRANT SELECT ON BIKE TO sales_volunteer;
GRANT SELECT ON DONATION TO sales_volunteer;
GRANT SELECT, INSERT, UPDATE ON VOLUNTEER TO sales_volunteer;

-- Grant privileges to donations volunteers
GRANT CONNECT TO donations_volunteer;
GRANT SELECT, INSERT ON DONOR TO donations_volunteer;
GRANT SELECT, INSERT ON BIKE TO donations_volunteer;
GRANT SELECT, INSERT ON DONATION TO donations_volunteer;

-- Grant all privileges to manager
GRANT CONNECT, RESOURCE TO manager_user;
GRANT ALL PRIVILEGES ON VOLUNTEER TO manager_user;
GRANT ALL PRIVILEGES ON DONOR TO manager_user;
GRANT ALL PRIVILEGES ON BIKE TO manager_user;
GRANT ALL PRIVILEGES ON DONATION TO manager_user;




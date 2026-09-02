/*
=========================================================================================
Stored Procedure: Load Bronze Layer (Source -> Bronze)
=========================================================================================
Script Purpose:
	This stored procedure loads data into 'bronze' schema from external csv files.
	It performs the following actions:
	 - Uses the 'BULK INSERT'  command to load the data from csv files to bronze tables.

Paarameters:
	None.
  This stored procedure does not accept any parameters or return any values.

Usage Example:
	EXEC bronze.load_bronze;
=========================================================================================
*/

CREATE OR ALTER PROCEDURE bronze.load_bronze AS
BEGIN
    DECLARE @batch_start_time DATETIME,
            @batch_end_time DATETIME;

    BEGIN TRY

        PRINT '===========================================================';
        PRINT 'Loading bronze Layer';
        PRINT '===========================================================';

        SET @batch_start_time = GETDATE();

        -- Categories
        PRINT 'Loading bronze.categories...';

        TRUNCATE TABLE bronze.categories;

        BULK INSERT bronze.categories
        FROM 'C:\Users\Bikash chetry\OneDrive\Desktop\Ecommerce Project\categories.csv'
        WITH
        (
            FIRSTROW=2,
            FIELDTERMINATOR=',',
            ROWTERMINATOR = '0x0a',
            TABLOCK
        );


        -- Customers
        PRINT 'Loading bronze.customers...';

        TRUNCATE TABLE bronze.customers;

        BULK INSERT bronze.customers
        FROM 'C:\Users\Bikash chetry\OneDrive\Desktop\Ecommerce Project\customers.csv'
        WITH
        (
            FIRSTROW=2,
            FIELDTERMINATOR=',',
            ROWTERMINATOR = '0x0a',
            TABLOCK
        );


        -- Order Items
        PRINT 'Loading bronze.order_items...';

        TRUNCATE TABLE bronze.order_items;

        BULK INSERT bronze.order_items
        FROM 'C:\Users\Bikash chetry\OneDrive\Desktop\Ecommerce Project\order_items.csv'
        WITH
        (
            FIRSTROW=2,
            FIELDTERMINATOR=',',
            ROWTERMINATOR = '0x0a',
            TABLOCK
        );


        -- Orders
        PRINT 'Loading bronze.orders...';

        TRUNCATE TABLE bronze.orders;

        BULK INSERT bronze.orders
        FROM 'C:\Users\Bikash chetry\OneDrive\Desktop\Ecommerce Project\orders.csv'
        WITH
        (
            FIRSTROW=2,
            FIELDTERMINATOR=',',
            ROWTERMINATOR = '0x0a',
            TABLOCK
        );


        -- Payments
        PRINT 'Loading bronze.payments...';

        TRUNCATE TABLE bronze.payments;

        BULK INSERT bronze.payments
        FROM 'C:\Users\Bikash chetry\OneDrive\Desktop\Ecommerce Project\payments.csv'
        WITH
        (
            FIRSTROW=2,
            FIELDTERMINATOR=',',
            ROWTERMINATOR = '0x0a',
            TABLOCK
        );


        -- Products
        PRINT 'Loading bronze.products...';

        TRUNCATE TABLE bronze.products;

        BULK INSERT bronze.products
        FROM 'C:\Users\Bikash chetry\OneDrive\Desktop\Ecommerce Project\products.csv'
        WITH
        (
            FIRSTROW=2,
            FIELDTERMINATOR=',',
            ROWTERMINATOR = '0x0a',
            TABLOCK   
         );


        -- Sellers
        PRINT 'Loading bronze.sellers...';

        TRUNCATE TABLE bronze.sellers;

        BULK INSERT bronze.sellers
        FROM 'C:\Users\Bikash chetry\OneDrive\Desktop\Ecommerce Project\sellers.csv'
        WITH
        (
            FIRSTROW=2,
            FIELDTERMINATOR=',',
            ROWTERMINATOR = '0x0a',
            TABLOCK
        );


        -- Shipments
        PRINT 'Loading bronze.shipments...';

        TRUNCATE TABLE bronze.shipments;

        BULK INSERT bronze.shipments
        FROM 'C:\Users\Bikash chetry\OneDrive\Desktop\Ecommerce Project\shipments.csv'
        WITH
        (
            FIRSTROW=2,
            FIELDTERMINATOR=',',
            ROWTERMINATOR = '0x0a',
            TABLOCK
        );


        SET @batch_end_time = GETDATE();

        PRINT '===========================================================';
        PRINT 'bronze Layer Loading Completed Successfully';
        PRINT 'Loading Complete Time: '
              + CAST(DATEDIFF(SECOND, @batch_start_time, @batch_end_time) AS VARCHAR(20))
              + 'seconds';
        PRINT '===========================================================';

    END TRY

    BEGIN CATCH

        PRINT '===========================================================';
        PRINT 'ERROR OCCURRED WHILE LOADING bronze LAYER';
        PRINT 'Error Message: ' + ERROR_MESSAGE();
        PRINT 'Error Number: ' + CAST(ERROR_NUMBER() AS VARCHAR(20));
        PRINT 'Error Line: ' + CAST(ERROR_LINE() AS VARCHAR(20));
        PRINT '===========================================================';

        THROW;

    END CATCH
END;


EXECUTE bronze.load_bronze;

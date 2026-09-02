/*
===========================================================
Create Database and Schemas
===========================================================
Script Purpose:
	This Scrip creates a new database named-'e_commerce' after checking if it already exists.
	If the database exists, it is dropped and recreate. Additionally the script sets up the schema
	within the database : 'bronze'.

WARNING:
	Running this script will drop the entire 'e_commerce' database  if it exists.
	All data in the database will be permanently deleted. Proceed with caution 
	and ensure you have proper backupn before running the script.
*/


--Drop and Recreate Database 'e_commerce'--
IF EXISTS (SELECT 1 FROM sys.databases WHERE name='e_commerce')
BEGIN
	ALTER DATABASE e_commerce SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
	DROP DATABASE e_commerce;
END;
GO
CREATE DATABASE e_commerce;
USE e_commerce;
GO 
CREATE SCHEMA bronze;
GO 



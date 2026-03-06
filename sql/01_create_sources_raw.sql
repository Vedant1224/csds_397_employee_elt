-- @author Vedant Gupta
-- Step 1: create the raw sources table for ELT.
-- Load the CSV into this table exactly as-is first. Cleaning and type fixes happen later.

CREATE DATABASE IF NOT EXISTS sources;
CREATE DATABASE IF NOT EXISTS staging;

USE sources;

DROP TABLE IF EXISTS employee_raw;

CREATE TABLE employee_raw (
  employee_id         TEXT,
  name                TEXT,
  age                 TEXT,
  department          TEXT,
  date_of_joining     TEXT,
  years_of_experience TEXT,
  country             TEXT,
  salary              TEXT,
  performance_rating  TEXT,
  total_sales         TEXT,
  support_rating      TEXT
);
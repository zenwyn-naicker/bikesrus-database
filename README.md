# BikesRUs Database

An Oracle database for BikesRUs, a not-for-profit outlet that receives donated bicycles and resells them to underprivileged communities. The schema tracks volunteers, donors, bikes and donations, and the script builds reporting on top of it with SQL queries, a view, a stored procedure, a function, cursors and triggers.

Built for INSY7213 at Emeris Durban North (2025).

## Features

- **Relational schema:** `VOLUNTEER`, `DONOR`, `BIKE` and `DONATION` tables linked by primary and foreign keys.
- **Reporting queries:** joins, filters and a `CASE`-based value rating for donated bikes.
- **View:** `vwBikeRUs` lists donor names, contact numbers, bike types and donation dates for a volunteer's donations.
- **Stored procedure:** `spDonorDetails` reports the donor, volunteer, bike and date for a given bike, with exception handling when no donation exists.
- **Function:** `fnVolunteerDonationTotal` returns the number and total value of donations a volunteer handled.
- **Cursors:** reports for road bikes with VAT calculated, and a status rating for every bike.
- **Triggers:** `trg_prevent_donation_delete` blocks deletes from `DONATION`, and `trg_validate_bike_value` rejects updates with a value of zero or less.
- **Integrity example:** a sequence that generates unique donation IDs.

## Tech stack

| Area | Technologies |
| --- | --- |
| Database | Oracle Database |
| Language | SQL, PL/SQL |
| Tooling | Oracle SQL Developer |

## Getting started

### Prerequisites

- An Oracle Database instance and an account that can create tables
- A SQL client such as Oracle SQL Developer

### Run locally

1. Connect to a disposable schema.
2. Run the table definitions at the top of `bikesrus.sql`, then insert your own volunteer, donor, bike and donation rows.
3. Run the remaining sections in order. Enable `SET SERVEROUTPUT ON` to see the PL/SQL output.

## Project structure

```text
bikesrus.sql   Schema, queries, view, procedure, function, cursors, triggers and sequence
```

## Acknowledgements

Course material used for this project is credited in the comments at the top of `bikesrus.sql`.

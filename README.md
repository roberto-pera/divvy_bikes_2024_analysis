# Divvy Bikes Insights 2024 — When, Where, and How People Ride

*Optimizing bike-share operations through ridership analytics*

---

## Overview

This project analyzes 2024 ridership data from **Divvy Bikes**, Chicago’s public bike-share system, to uncover key behavioral patterns of users.

The goal was to identify **when, where, and how** members and casual riders use the service — providing data-driven insights to support operational decisions and enhance user engagement.

The analysis was conducted using **SQLite** for data preparation and **Tableau** for visualization and dashboard design.

**Interactive Dashboard:** [View on Tableau Public]([https://public.tableau.com/your-dashboard-link](https://public.tableau.com/views/divvy_bikes_2024_analysis/Dashboard2?:language=de-DE&publish=yes&:sid=&:redirect=auth&:display_count=n&:origin=viz_share_link))

**Data Source:** [Divvy Trip Data — Official Repository (Lyft)](https://divvy-tripdata.s3.amazonaws.com/index.html)

---

![Divvy Bikes 2024 Dashboard Overview](dashboard/divvy_dashboard_preview.png)

*Interactive Tableau dashboard visualizing ridership trends, trip durations, and station usage.*

---

## Dataset Overview

The analysis is based on the official **Divvy Trip Data 2024**, consisting of 12 monthly CSV files (January–December 2024), each sharing the same schema:

| Column | Description |
| --- | --- |
| `ride_id` | Unique identifier for each trip |
| `rideable_type` | Type of bike used (classic / electric) |
| `started_at` | Start timestamp of the ride |
| `ended_at` | End timestamp of the ride |
| `start_station_name` | Name of the starting station |
| `start_station_id` | ID of the starting station |
| `end_station_name` | Name of the ending station |
| `end_station_id` | ID of the ending station |
| `start_lat` | Start latitude |
| `start_lng` | Start longitude |
| `end_lat` | End latitude |
| `end_lng` | End longitude |
| `member_casual` | Rider type (`member` or `casual`) |

Additional derived fields were created in SQLite for the analysis:

| Derived Field | Description |
| --- | --- |
| `trip_duration_minutes` | Ride duration calculated from start and end timestamps |
| `start_hour` | Hour of day when the ride started (0–23) |
| `day_of_week` | Day of week extracted from start timestamp |
| `month_source` | Month label identifying the data source (Jan–Dec) |

All monthly datasets were combined into a single database using a SQL `UNION ALL` operation.

---

## Tools & Workflow

**Tools Used**

- **SQLite:** Data preparation, cleaning, and aggregation across monthly datasets
- **Tableau:** Interactive dashboard for visualization, exploration, and storytelling

**Process Overview**

1. **Data Preparation**
    - Combined monthly Divvy datasets (Jan–Dec 2024) using `UNION ALL`
    - Created derived fields for duration, day, hour, and month
    - Aggregated metrics for total rides, average trip duration, and member vs. casual share
2. **Visualization & Dashboard Design**
    - Developed KPIs summarizing overall ridership and usage trends
    - Built charts and maps to analyze temporal and spatial patterns
    - Added interactive filters for User Type, Month, Day of Week, Start Hour, and Start Station

**Example SQL Snippet**

```sql
SELECT
    member_casual,
    strftime('%m', started_at) AS month,
    COUNT(DISTINCT ride_id) AS total_rides,
    AVG((julianday(ended_at) - julianday(started_at)) * 24 * 60) AS avg_trip_duration
FROM divvy_2024
GROUP BY member_casual, month;
```

---

## Dashboard Features

### KPIs

- **Total Rides** — Overall number of recorded trips
- **Avg. Trip Duration** — Average ride time in minutes
- **Peak Start Hour** — Most common hour of ride start
- **Peak Day of Week** — Most popular day for riding
- **% Rides by Member** — Share of total rides by subscribed members

### Visuals

| Chart | Description |
| --- | --- |
| **Rides by Day of Week** | Displays the shift from weekday commuting to weekend leisure activity |
| **Trip Duration Distribution** | Shows how members tend to take shorter, commute-oriented rides, while casual users account for a higher share of longer leisure rides |
| **Riding Patterns by Hour and Weekday (Heatmaps)** | Identifies weekday commuting peaks (7–8 AM, 4–6 PM) and weekend leisure peaks (12–4 PM) |
| **Top 10 Start Stations (Map)** | Highlights the most frequented starting points, revealing geographic preferences of both user groups |

---

## Key Insights

1. **Seasonality & User Composition**
    - Ridership increases significantly during summer months.
    - The share of **casual users** rises with warmer weather, reflecting tourism and leisure activity.
2. **Spatial Behavior**
    - **Casual riders** predominantly start near **Lake Michigan** and recreational areas.
    - **Members** start more often in the **downtown core**, consistent with daily commutes and point-to-point mobility.
3. **Trip Duration Distribution**
    - **Members:** Mostly short rides (under 15 minutes), typical for quick commutes.
    - **Casual riders:** More long trips (20+ minutes), reflecting leisure and sightseeing usage.
    - Confirms a clear behavioral split between **commute-driven vs. leisure-driven riding**.
4. **Temporal Patterns**
    - **Weekdays:** Distinct peaks at **7–8 AM** and **4–6 PM**, matching commuter traffic.
    - **Weekends:** Activity shifts to **midday and early afternoon (12–4 PM)**, indicating leisure-focused usage.

---

## Recommendations

- **Targeted Membership Campaigns**
    
    Encourage casual users to convert during summer months via short-term memberships or “weekend passes.”
    
- **Operational Optimization**
    
    Increase bike and dock availability near **lakefront stations** during peak leisure hours.
    
    Maintain higher capacity in **downtown areas** during weekday commute periods.
    
- **User Experience Enhancements**
    
    Introduce tailored pricing and ride suggestions — e.g., flexible commuter plans vs. scenic route recommendations.
    

---

## Repository Structure

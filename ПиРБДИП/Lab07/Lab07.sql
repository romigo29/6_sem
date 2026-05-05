WITH months AS (
    SELECT LEVEL AS month_num
    FROM dual
    CONNECT BY LEVEL <= 12
),
current_license AS (
    SELECT l.Location_ID, COUNT(*) AS cnt
    FROM Locations l 
    JOIN Devices d ON l.Location_ID = d.Location_ID
    JOIN Installations i ON i.Device_ID   = d.Device_ID
    GROUP BY l.Location_ID
),
obsolete_by_month AS (
    SELECT d.Location_ID,
           EXTRACT(MONTH FROM ADD_MONTHS(d.Purchase_Date, d.Service_Life_Months)) AS month_num,
           COUNT(*) AS cnt
    FROM Devices d
    JOIN Installations i ON d.Device_ID = i.Device_ID
    WHERE EXTRACT(YEAR FROM ADD_MONTHS(d.Purchase_Date, d.Service_Life_Months)) 
        = EXTRACT(YEAR FROM SYSDATE) + 1
    GROUP BY d.Location_ID,
             EXTRACT(MONTH FROM ADD_MONTHS(d.Purchase_Date, d.Service_Life_Months))
)
SELECT Location_ID, month_num, current_licenses, growth, obsolete_cnt, planned_licenses
FROM (
    SELECT l.Location_ID,
           m.month_num,
           NVL(cl.cnt, 0) AS current_licenses,
           ROUND(l.Planned_Growth_Seats / 12, 2) AS growth,
           NVL(ob.cnt, 0) AS obsolete_cnt
    FROM Locations l
    CROSS JOIN months m
    LEFT JOIN current_license cl ON cl.Location_ID = l.Location_ID
    LEFT JOIN obsolete_by_month ob ON ob.Location_ID = l.Location_ID
    AND ob.month_num   = m.month_num
)
MODEL
    PARTITION BY (Location_ID)
    DIMENSION BY (month_num)
    MEASURES (
        current_licenses,
        growth,
        obsolete_cnt,
        0 AS planned_licenses
    )
    RULES (
        planned_licenses[FOR month_num FROM 1 TO 12 INCREMENT 1] =
            NVL(planned_licenses[CV(month_num) - 1], current_licenses[CV(month_num)])
          + growth[CV(month_num)]
          - obsolete_cnt[CV(month_num)]
    )
ORDER BY Location_ID, month_num;
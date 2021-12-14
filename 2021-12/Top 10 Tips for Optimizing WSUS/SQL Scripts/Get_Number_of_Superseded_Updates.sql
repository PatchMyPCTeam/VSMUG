-- Find the number of superseded updates
Select COUNT(UpdateID) from vwMinimalUpdate where IsSuperseded=1 and Declined=0
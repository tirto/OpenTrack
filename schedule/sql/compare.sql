select *   
   from classmeetingproj c1, classmeetingproj c2   
   where c1.term = c2.term   
     and c1.department <> c2.department   
     and c1.codenumber <> c2.codenumber   
     and c1.section <> c2.section   
     and c1.days like '%M%'   
     and c2.days like '%M%'   
     and c1.building = c2.building   
     and c1.roomnumber = c2.roomnumber   
     and not ((c2.starttime >= c1.stoptime) or (c2.stoptime <= c1.starttime))
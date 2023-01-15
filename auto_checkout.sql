CREATE DEFINER=`anan`@`%` PROCEDURE `auto_checkout`( )
BEGIN 
-- 	#Routine body goes here...

	DECLARE _date_check DATETIME ;
	DECLARE aten_id BIGINT(20) ; 
	DECLARE em_id VARCHAR(255)  ;
	DECLARE cret_id  timestamp ;
	DECLARE updte_id timestamp ;
	DECLARE reg VARCHAR(255) ; 
  DECLARE today DATE;
	DECLARE _break_out  TIME;
	DECLARE _now TIME ; 
	DECLARE curs CURSOR FOR  select id,employee_id , created_at , updated_at , registered  from  attendances 
           where DATE_FORMAT(created_at, '%Y-%m-%d') =  DATE(CONVERT_TZ(NOW(), @@session.time_zone, '+07:00')) and registered = 'half' and created_at = updated_at  
           and shift =  1 ; 
					 

   
   OPEN curs;
   read_loop: LOOP
      FETCH curs INTO aten_id , em_id , cret_id , updte_id , reg  ; 
			select  emp_attendanceprofile.break_out into _break_out from emp_attendanceprofile 
			   where attendanceprofile_id = ( select  employees.attendanceprofile_id from employees where employees.id = em_id )   ;
			 SELECT TIME(CONVERT_TZ(NOW(), @@session.time_zone, '+07:00')) into _now;
		  IF (  _break_out <  _now  ) THEN
		      	update attendances set registered = 'yes' ,
					  	updated_at = CONVERT_TZ(NOW(), @@session.time_zone, '+07:00')  , 
						 	exit_location = 'Auto checkout by (TAMS) Time Attendance Management System ' 
		       	where id = aten_id  and employee_id = em_id ; 
			END IF; 
--       select _break_out , _now  ; 
   END LOOP;
   
   CLOSE curs;

END

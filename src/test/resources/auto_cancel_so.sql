-- [/Formatter] Formatted with Sybase T-SQL Formatter(version: 1.5.1.14696) at 01/20/2016 17:16:42 08:00:00[Formatter/]
IF OBJECT_ID('auto_cancel_so') IS NOT NULL
BEGIN
	DROP PROCEDURE auto_cancel_so

	IF OBJECT_ID('auto_cancel_so') IS NOT NULL
		PRINT '<<< FAILED DROPPING PROCEDURE auto_cancel_so >>>'
	ELSE
		PRINT '<<< DROPPED PROCEDURE auto_cancel_so >>>'
END
GO

CREATE proc auto_cancel_so
AS
DECLARE @ret_code int
	,@ret_msg varchar(100)
	,@order_type int
	,@order_no int
	,@cancel_reason char(2)
	,@sub_cancel_rea char(2)
	,@reason_comm varchar(120)
	,@rows int
	,@servername varchar(32)
	,@begin_time datetime
	,@end_time datetime
	,@db_name varchar(32)
	,@sales_flag char(1)
	,@company_no int
	,@cancel_so_cnt int

SELECT @cancel_so_cnt = 0

SELECT @sales_flag = (
		CASE
			WHEN sales > 0
				THEN 'Y'
			ELSE 'N'
			END
		)
FROM dw_calendar
WHERE date_flag = convert(varchar, getdate(), 101)

/* NO SO Hold for Back order */
DELETE order_profile
WHERE profile_type = 'SO_HOLD'
	AND order_type = 8

/* End of type 8 SO HOLD */
IF @sales_flag = 'N'
BEGIN
	print 'Today is not a sales day, stop'

	print "*** Cron Standardize *** total_cancel_so_cnt= %1!"
		,0

	RETURN 0
END

SELECT @begin_time = getdate()
	,@servername = @@servername
	,@db_name = db_name()

print "STATUS: Begin auto_cancel_so at %1!"
	,@begin_time

print "STATUS: server name: '%1!', database: '%2!'."
	,@servername
	,@db_name

SELECT @company_no = parameter_value
FROM parameters
WHERE parameter_name = 'COMPANY_NO'

CREATE TABLE #hold_orders(
	order_no int
	,entry_id int NULL
	,sales_terr int NULL
	,entry_datetime datetime NULL
	,days int NULL
	,hold_type varchar(30) NULL
	,need_email char(1) NULL
	)

/*
    insert #hold_orders (
     order_no, entry_id, sales_terr, entry_datetime, days, hold_type, need_email
    )
    select op.order_no, oh.entry_id, oh.sales_terr,
           op.entry_datetime, days = op.profile_f * (isnull(op.profile_i, 0) + 1),
           (case when op.profile_c like 'BOSO%' then 'Auto BO-SO'
                 else 'NL'
             end),
            (case when op.profile_c like 'NL%' then 'N'
                                           else 'Y'
              end)
    from order_profile op,
    	order_header oh
    where op.order_type = oh.order_type
        and op.order_no = oh.order_no
        and op.order_type = 1
        and oh.delete_date = null
        and oh.sales_rel_date = null
        and oh.credit_rel_date = null
        --and oh.from_loc_no !=98 -- Exclude MSO and Ship Order
        and oh.ship_date = null
    	and op.profile_type = 'SO_HOLD'
        and op.active = 'Y'
    	and op.profile_d = null
        and op.entry_datetime <> null
	*/
INSERT #hold_orders(
	order_no
	,entry_id
	,sales_terr
	,entry_datetime
	,days
	,hold_type
	,need_email
	)
SELECT op.order_no
	,oh.entry_id
	,oh.sales_terr
	,op.entry_datetime
	,days = op.profile_f * (isnull(op.profile_i, 0) + 1)
	,(
		CASE
			WHEN op.profile_c like 'BOSO%'
				THEN 'Auto BO-SO'
			ELSE 'NL'
			EN
		)
	,(
		CASE
			WHEN op.profile_c like 'NL%'
				THEN 'N'
			ELSE 'Y'
			END
		)
FROM order_profile op
INNER JOIN sales_que oh
	ON op.order_type = oh.order_type
		AND op.order_no = oh.order_no
WHERE op.order_type = 1
	AND oh.rule_id = 14
	AND oh.delete_date IS NULL
	AND oh.approval IS NULL
	AND op.profile_type = 'SO_HOLD'
	AND op.profile_d IS NULL
	AND op.entry_datetime IS not NULL

/* Take out exempted Order in US */
IF @company_no = 1
BEGIN
	/* division#16 is exempted - Add by Rex Liu 09/21/2012 requirement from Erik Cai and confirm with Leon Gu*/
	DELETE #hold_orders
	FROM #hold_orders ho
	INNER JOIN order_header oh
		ON ho.order_no = oh.order_no
	INNER JOIN v_hierarchy_by_cust v
		ON oh.to_acct_no = v.cust_no
	WHERE v.division = 16
		AND oh.order_type = 1

	/* territorys is exempted - Add by Rex Liu 10/30/2012 requirement from Erik Cai */
	/* territorys is exempted<User want to  set up all the accounts under Shaw Tate and Clint Bartley> -
		 * Add by Rex Liu 6/11/2013 requirement from Erik Cai */
	DELETE #hold_orders
	WHERE sales_terr IN (508, 715, 716, 719, 750, 752, 754, 755, 3290, 4402, 4412, 4413, 4453)
END

/* End of Take out exempted Order in US case */
/*Do not auto cancle SSO with ship_qty>0 */
DELETE #hold_orders
FROM #hold_orders a
INNER JOIN order_detail b
	ON a.order_no = b.order_no
WHERE isnull(b.ship_qty, 0) > 0
	AND b.order_type = 1

UPDATE #hold_orders
SET need_email = 'Y'
FROM #hold_orders t
INNER JOIN order_profile p
	ON t.order_no = p.order_no
WHERE p.order_type = 1
	AND p.profile_type = 'NL_APPR'

CREATE TABLE #orders(
	hold_type varchar(30) NULL
	,order_no int NULL
	,entry_id int NULL
	,sales_terr int NULL
	,life_days int NULL
	,status char(1) NULL
	,need_email char(1) NULL
	)

INSERT INTO #orders
SELECT o.hold_type
	,o.order_no
	,o.entry_id
	,o.sales_terr
	,o.days - datediff(dd, o.entry_datetime, getdate()) + sum(sign((1 - cal.weekday) + cal.holiday))
	,convert(char(1), NULL)
	,need_email
FROM #hold_orders o
INNER JOIN dw_calendar cal
	ON cal.date_flag >= dateadd(dd, - 1, o.entry_datetime)
WHERE cal.date_flag < getdate()
GROUP BY o.order_no
	,o.hold_type

DROP TABLE #hold_orders

SELECT hold_type
	,order_no
	,entry_id
	,sales_terr
	,life_days
	,status
	,need_email
FROM #orders

/* Alert reps for 1 day orders of the deleting next day */
/* No grace period, if the life day is less than a day, no alert */
INSERT customer_email_log(
	email_type
	,ref_no
	,ref_type
	,from_addr
	,email_subject
	,email_body
	,to_addr
	,entry_datetime
	,status
	)
SELECT 'NL'
	,order_no
	,1
	,'zhihongt@synnex.com'
	,hold_type + ' order#' + convert(varchar, order_no) + ' expires'
	,'Your order #' + convert(varchar, order_no) + ' will be deleted the next working day night if not released by then.'
	,e1.email + ',' + e2.email + ',' + e3.email + ',' + e4.email + ',' + e5.email + ',' + e6.email + ',' + e7.email + ',' + e8.email
	,getdate()
	,'P'
FROM #orders t
	,employee_contacts e1
	,employee_contacts e2
	,employee_contacts e3
	,employee_contacts e4
	,employee_contacts e5
	,employee_contacts e6
	,employee_contacts e7
	,employee_contacts e8
	,territory tr
WHERE life_days = 1
	AND t.sales_terr = tr.sales_terr
	AND t.need_email = 'Y'
	AND tr.primary_id *= e1.user_id
	AND tr.backup_id1 *= e2.user_id
	AND tr.backup_id2 *= e3.user_id
	AND tr.backup_id3 *= e4.user_id
	AND tr.backup_id4 *= e5.user_id
	AND tr.backup_id5 *= e6.user_id
	AND tr.backup_id6 *= e7.user_id
	AND tr.backup_id7 *= e8.user_id
	/* If alert was sent out within the last 84 hours, don't send again */
	AND not EXISTS (
		SELECT 1
		FROM customer_email_log log
		WHERE log.ref_no = t.order_no
			AND log.email_type = 'NL'
			AND datediff(hh, log.entry_datetime, getdate()) <= 84
		)

/* End of alert */
/* For NULL life day, it can't be determined if we should delete or not, leave it alone*/
DELETE #orders
FROM #orders o
WHERE isnull(life_days, 1) >= 1

SELECT @rows = count(1)
FROM #orders

IF (@rows <= 0)
BEGIN
	print "No orders to be processed."

	print "*** Cron Standardize *** total_cancel_so_cnt= %1!"
		,0

	RETURN 0
END

SELECT @cancel_reason = 'O'
	,@sub_cancel_rea = '0'
	,@reason_comm = 'SO_HOLD time expired.'

SELECT @order_no = min(order_no)
FROM #orders
WHERE status IS NULL

SELECT @rows = @@rowcount

WHILE (
		@rows > 0
		AND @order_no > 1
		)
BEGIN
	EXEC cancel_by_header 1
		,@order_no
		,@cancel_reason
		,@sub_cancel_rea
		,@reason_comm
		,@ret_code OUTPUT
		,@ret_msg OUTPUT

	IF (@ret_code = 0)
	BEGIN
		UPDATE #orders
		SET status = 'C'
		WHERE order_no = @order_no

		-----------------------------
		INSERT customer_email_log(
			email_type
			,ref_no
			,ref_type
			,entry_datetime
			,status
			)
		SELECT 'NL-D'
			,@order_no
			,1
			,getdate()
			,NULL
		FROM order_header
		WHERE order_type = 1
			AND order_no = @order_no

		----------------------------
		COMMIT TRAN

		print "Order %1! has been cancelled."
			,@order_no

		SELECT @cancel_so_cnt = @cancel_so_cnt + 1
	END
	ELSE
	BEGIN
		UPDATE #orders
		SET status = 'F'
		WHERE order_no = @order_no

		ROLLBACK TRAN

		COMMIT

		print "Order %1! was not able to be cancelled. '%2!'"
			,@order_no
			,@ret_msg
	END

	SELECT @order_no = isnull(min(order_no), - 1)
	FROM #orders
	WHERE status IS NULL

	SELECT @rows = @@rowcount
END

SELECT @end_time = getdate()

print "STATUS: Finish auto_cancel_so at %1!"
	,@end_time

print "*** Cron Standardize *** total_cancel_so_cnt= %1!"
	,@cancel_so_cnt

SELECT order_no
	,life_days
	,current_status = CASE status
		WHEN 'C'
			THEN 'Cancelled'
		WHEN 'F'
			THEN 'Failed to cancel'
		ELSE 'Not processed'
		END
FROM #orders

RETURN 1
GO

GRANT EXECUTE
	ON auto_cancel_so
	TO public
GO

IF OBJECT_ID('auto_cancel_so') IS NOT NULL
	PRINT '<<< CREATED PROCEDURE auto_cancel_so >>>'
ELSE
	PRINT '<<< FAILED CREATING PROCEDURE auto_cancel_so >>>'
GO

EXEC sp_procxmode 'auto_cancel_so'
	,'unchained'
GO
create table AccountInfor
(
	AccountNumber int auto_increment
		primary key,
	Amount float null,
	AmountReciprocal float null,
	AccountName varchar(255) null,
	AmountBegin float null,
	CurrentAmount float null,
	CurrentAmountReciprocal float null,
	DebtAmountBegin float null
)
;

create table `Order`
(
	id int(10) unsigned auto_increment
		primary key,
	product_code varchar(100) null,
	action_id int null,
	customer_id varchar(50) null,
	staff_id varchar(50) null,
	bill_number varchar(50) null,
	voucher_number varchar(50) null,
	bill_date datetime null,
	account varchar(50) null,
	account_reciprocal varchar(50) null,
	type_account varchar(50) null,
	amount double null,
	amount_reciprocal double null,
	over_amount double null,
	over_amount_reciprocal double null,
	created_timestamp datetime null,
	updated_timestamp datetime null,
	tax double null,
	discount double null,
	apply_date datetime null,
	price double null,
	transaction_value double null,
	total_value double null,
	description varchar(250) null,
	group_order_id varchar(250) null,
	transaction_value_reciprocal double null,
	order_code varchar(50) null,
	order_type int null,
	warehouse_code varchar(50) null
)
;

create table Product
(
	id int(10) unsigned auto_increment
		primary key,
	product_code varchar(100) null,
	product_name varchar(100) null,
	product_category_id varchar(100) null,
	created_timestamp datetime null,
	updated_timestamp datetime null,
	description varchar(500) null,
	product_unit varchar(10) null,
	product_price float null,
	volume float null,
	warehouse_code varchar(255) null,
	account varchar(255) null
)
;

create table T1
(
	ID1 int null,
	Ten varchar(100) null
)
;

create table T2
(
	ID2 int null,
	Email varchar(100) null
)
;

create table Warehouse
(
	id int auto_increment
		primary key,
	warehouseCode varchar(128) null,
	warehouseName varchar(128) null,
	address varchar(128) null,
	created_timestamp datetime null,
	updated_timestamp datetime null,
	warehouse_code varchar(128) null,
	warehouse_name varchar(128) null
)
;

create table account
(
	ID int auto_increment
		primary key,
	AccountName varchar(255) null,
	AccountNumber int null,
	DetailName varchar(255) null,
	IdParent int null,
	AmountBegin float null,
	DebtAmountBegin float null
)
;

create procedure LoadAccount ()  
BEGIN
  declare v_Account int;
        declare v_Amount float;
        declare v_AmountReciprocal float;
  declare account_cur cursor for select AccountNumber from account;
        DROP TABLE IF EXISTS account_infor;
        CREATE TEMPORARY TABLE account_infor(AccountNumber INT, Amount FLOAT, AmountReciprocal FLOAT);
        open account_cur;
   BLOCK_ACCOUNT:BEGIN
    DECLARE EXIT HANDLER FOR NOT FOUND BEGIN END;
    LOOP_ACCOUNT:LOOP
     fetch account_cur into v_Account;
                    select IFNULL(sum(amount), 0) into v_Amount from `order` where `order`.account = v_Account;
                    select IFNULL(sum(amount_reciprocal), 0) into v_AmountReciprocal from `order` where `order`.account = v_Account;
     insert into account_infor (AccountNumber, Amount, AmountReciprocal)
     values (v_Account, v_Amount, v_AmountReciprocal);

                    set v_Account = 0;
                    set v_Amount = 0;
                    set v_AmountReciprocal = 0;
    END LOOP LOOP_ACCOUNT;
   END BLOCK_ACCOUNT;

  CLOSE account_cur;

  SELECT * FROM account_infor;

    END;

create procedure LoadAccount12 ()  
BEGIN
		declare v_Account int;
        declare v_Amount float;
        declare v_AmountBegin float;
        declare v_DebtAmountBegin float;
        declare v_AccountName varchar(200);
        declare v_AmountReciprocal float;
		declare account_cur cursor for select AccountNumber,AccountName,AmountBegin,DebtAmountBegin from account;
        DROP TABLE IF EXISTS account_infor;
        CREATE TEMPORARY TABLE account_infor(AccountNumber INT,
											AccountName varchar(200),
                                            DebtAmountBegin FLOAT,
                                            AmountBegin FLOAT, 
                                            Amount FLOAT, 
                                            AmountReciprocal FLOAT,
                                            CurrentAmount FLOAT, 
                                            CurrentAmountReciprocal FLOAT);
        open account_cur;
			BLOCK_ACCOUNT:BEGIN
				DECLARE EXIT HANDLER FOR NOT FOUND BEGIN END;
				LOOP_ACCOUNT:LOOP
					fetch account_cur into v_Account,v_AccountName,v_AmountBegin,v_DebtAmountBegin;
                    select IFNULL(sum(total_value), 0) into v_Amount from `order` where `order`.account = v_Account and type_account = 'N';
                    select IFNULL(sum(total_value), 0) into v_AmountReciprocal from `order` where `order`.account = v_Account and type_account = 'C';
					insert into account_infor (AccountNumber,
											AccountName,
                                            DebtAmountBegin,
                                            AmountBegin, 
                                            Amount, 
                                            AmountReciprocal,
                                            CurrentAmount, 
                                            CurrentAmountReciprocal)
					values (v_Account,
							v_AccountName,
                            v_DebtAmountBegin, -- no
                            v_AmountBegin, -- co
							v_Amount, -- no
                            v_AmountReciprocal, -- co
                            v_Amount + v_DebtAmountBegin - v_AmountReciprocal - v_AmountReciprocal, -- no
                            v_AmountReciprocal + v_AmountBegin - v_Amount - v_DebtAmountBegin); -- co
                    
                    set v_Account = 0;
                    set v_Amount = 0;
                    set v_AmountReciprocal = 0;
                    set v_DebtAmountBegin = 0;
                    set v_AmountBegin = 0;
                    set v_AccountName = '';
				END LOOP LOOP_ACCOUNT;
			END BLOCK_ACCOUNT;

		CLOSE account_cur;
    
		SELECT * FROM account_infor;
    
    END;


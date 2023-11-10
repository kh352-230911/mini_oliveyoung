-- 계정 생성
alter session set "_oracle_script" = true;
create user oliveyoung
identified by oliveyoung
default tablespace users;
grant connect, resource to oliveyoung;
alter user oliveyoung quota unlimited on users;

select * from tb_user;
--drop table tb_user;
select * from user_constraints where table_name = 'TB_USER';

create table tb_user (
    user_id varchar2(20)
    , user_name varchar2(20) not null
    , password varchar2(20) not null
    , birthday timestamp not null
    , skin_type varchar2(20)
    , constraints pk_user_user_id primary key(user_id)
);
alter table tb_user add created_at timestamp default systimestamp;
alter table tb_user add mileage number default 0;

select * from category;
--drop table category;
select * from user_constraints where table_name = 'CATEGORY';

create table category (
    category_name varchar2(100) not null
    , category_code varchar2(20) not null
    , constraints pk_category_category primary key(category_code)
);

select * from product;
--drop table product;
select * from user_constraints where table_name = 'PRODUCT';

create table product (
    product_name varchar2(100) not null
    , product_code varchar2(10) not null
    , category_code varchar2(10) not null
    , brand_name varchar2(50) not null
    , price number not null
    , constraints pk_product_product primary key(product_code)
    , constraints fk_product_category_code foreign key(category_code) references category(category_code)
);
alter table product add stock number;
update product set stock = 100;

select * from ingredient;
--drop table ingredient;
select * from user_constraints where table_name = 'INGREDIENT';

create table ingredient (
    ingredient_name varchar2(100)
    , ingredient_code varchar2(10)
    , ingredient_script varchar2(300)
    , constraints pk_ingredient_ingredient_code primary key(ingredient_code)
);
alter table ingredient add constraints fk_effect_code foreign key(effect_code) references skin_effect(skin_effect_code);
alter table ingredient rename constraints fk_effect_code to fk_ingredient_effect_code;

select * from product_ingredient;
--drop table product_ingredient;
select * from user_constraints where table_name = 'PRODUCT_INGREDIENT';

create table product_ingredient (
    product_code varchar2(10) not null
    , ingredient_code varchar2(10) not null
    , constraints fk_product_ingredient_product_code foreign key(product_code) references product(product_code)
    , constraints fk_product_ingredient_ingredient_code foreign key(ingredient_code) references ingredient(ingredient_code)
);
alter table product_ingredient drop constraints fk_product_ingredient_product_code ;
alter table product_ingredient add constraints fk_product_ingredient_product_code foreign key(product_code) references product(product_code) on delete cascade;

select * from skin_effect;
--drop table skin_effect;
select * from user_constraints where table_name = 'SKIN_EFFECT';

create table skin_effect (
    skin_effect_code varchar(10)
    , skin_effect_kor varchar(100)
    , skin_effect_eng varchar(100)
    , constraints pk_ingredient_effect_effect_name primary key(skin_effect_code)
);

select * from review;
--drop table review;
select * from user_constraints where table_name = 'REVIEW';
create sequence seq_review_no;

create table review (
    no number not null
    , product_code varchar2(10) not null
    , score number not null
    , user_id varchar2(20) not null
    , title varchar2(1000) not null
    , contents varchar2(4000)
    , created_at timestamp default systimestamp
    , constraints pk_review_no primary key(no)
    , constraints fk_review_product_code foreign key(product_code) references product(product_code)
    , constraints fk_user_user_id foreign key(user_id) references tb_user(user_id) on delete set null
);
alter table review modify product_code null;
alter table review modify user_id null;
alter table review add constraints fk_review_purchase_no foreign key(purchase_no) references purchase_list(no) on delete set null;

select * from purchase_list;
--drop table purchase_list;
select * from user_constraints where table_name = 'PURCHASE_LIST';
create sequence seq_purchase_list_no;

create table purchase_list (
    no varchar2(20),
    user_id varchar2(20) not null,
    product_code varchar2(10) not null,
    count number default 1 not null,
    purchased_at timestamp default systimestamp
);
alter table purchase_list add constraints pk_purchase_list_no primary key(no);
alter table purchase_list add constraints fk_purchase_list_user_id foreign key(user_id) references tb_user(user_id) on delete set null;
alter table purchase_list add constraints fk_purchase_list_product_code foreign key(product_code) references product(product_code);
alter table purchase_list add pay_price number;
alter table purchase_list modify product_code null;
alter table purchase_list modify user_id null;
alter table purchase_list add using_mileage number default 0;

select * from cart_list;
--drop table cart_list;
select * from user_constraints where table_name = 'CART_LIST';
create sequence seq_cart_list_no;

create table cart_list (
    no varchar2(20),
    user_id varchar2(20) not null,
    product_code varchar2(10) not null,
    count number default 1 not null,
    carted_at timestamp default systimestamp
);
alter table cart_list add constraints pk_cart_list_no primary key(no);
alter table cart_list add constraints fk_cart_list_user_id foreign key(user_id) references tb_user(user_id) on delete cascade;
alter table cart_list add constraints fk_cart_list_product_code foreign key(product_code) references product(product_code);

select * from tb_user_log_del;
--drop table tb_user_log_del;
select * from user_constraints where table_name = 'TB_USER_LOG_DEL';
create sequence seq_tb_user_log_del_no;

create table tb_user_log_del (
    no number
    , user_id varchar2(20)
    , user_name varchar2(20)
    , created_at date
    , del_at date default sysdate
    , constraints pk_tb_user_log_del_no primary key(no)
);
alter table tb_user_log_del modify del_at timestamp default systimestamp;

------------------------------------------------------------------------------

set serveroutput on;

grant create trigger to oliveyoung;

CREATE OR REPLACE TRIGGER trig_user_purchase
AFTER INSERT ON purchase_list
FOR EACH ROW
BEGIN
    IF INSERTING THEN
        -- 새 레코드 삽입 시 처리
        UPDATE product
        SET stock = stock - :new.count
        WHERE 
            product_code = :new.product_code;
    END IF;
END;
/


create or replace trigger trig_tb_user_log_del
    after
    delete on tb_user
    for each row
begin
    if deleting then
        insert into
            tb_user_log_del
        values(
            seq_tb_user_log_del_no.nextval
            , :old.user_id
            , :old.user_name
            , :old.created_at
            , default
        );
    end if;
end;
/

commit;




















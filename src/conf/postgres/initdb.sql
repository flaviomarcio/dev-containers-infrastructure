create database kong_db;
create database konga_db;

create user kong with password '${STACK_SERVICE_DEFAULT_PASS}';
grant connect on database kong_db to kong;
alter user kong with superuser;
grant usage on schema public to kong;
grant select, insert, update, delete on all tables in schema public TO kong;


create user konga with password '${STACK_SERVICE_DEFAULT_PASS}';
grant connect on database konga_db to konga;
alter user kong with superuser;
grant usage on schema public to konga;
grant select, insert, update, delete on all tables in schema public TO konga;

--drop database kong_db;
--drop database konga_db;
--REVOKE ALL ON SCHEMA public from kong;
--DROP ROLE kong;
--REVOKE ALL ON SCHEMA public from konga;
--DROP ROLE konga;
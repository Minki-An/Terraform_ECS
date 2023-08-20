select host, user from mysql.user;
CREATE USER minkianuser@'%' IDENTIFIED BY 'minkianEncP';
GRANT ALL ON minkianapp.* TO minkianuser@'%' WITH GRANT OPTION;
CREATE USER migrate@'%' IDENTIFIED BY 'minkianMigrate';
GRANT ALL ON minkianapp.* TO migrate@'%' WITH GRANT OPTION;
GRANT ALL ON `prisma_migrate_shadow_db%`.* TO migrate@'%' WITH GRANT OPTION;
CREATE DATABASE minkianapp;
select host, user from mysql.user;


export DB_USERNAME=migrate
export DB_PASSWORD=minkianMigrate
export DB_HOST=aurora-cluster-minkian.cluster-cyn8k5e7vtzs.ap-northeast-2.rds.amazonaws.com
export DB_NAME=minkianapp

cd awsc/
git checkout main
npm run migrate:dev

select host, user from mysql.user;
CREATE USER sbcntruser@'%' IDENTIFIED BY 'sbcntrEncP';
GRANT ALL ON sbcntrapp.* TO sbcntruser@'%' WITH GRANT OPTION;
CREATE USER migrate@'%' IDENTIFIED BY 'sbcntrMigrate';
GRANT ALL ON sbcntrapp.* TO migrate@'%' WITH GRANT OPTION;
GRANT ALL ON `prisma_migrate_shadow_db%`.* TO migrate@'%' WITH GRANT OPTION;
select host, user from mysql.user;

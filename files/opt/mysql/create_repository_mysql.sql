CREATE DATABASE IF NOT EXISTS `%PREFIX%hibernate` DEFAULT CHARACTER SET latin1;

USE %PREFIX%hibernate;

GRANT ALL ON %PREFIX%hibernate.* TO '%PREFIX%hibuser'@'localhost' identified by '%PASSWORD%'; 
GRANT ALL ON %PREFIX%hibernate.* TO '%PREFIX%hibuser'@'%' identified by '%PASSWORD%'; 

commit;

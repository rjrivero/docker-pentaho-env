
CREATE DATABASE IF NOT EXISTS `%PREFIX%jackrabbit` DEFAULT CHARACTER SET latin1;

grant all on %PREFIX%jackrabbit.* to '%PREFIX%jcr_user'@'localhost' identified by '%PASSWORD%';
grant all on %PREFIX%jackrabbit.* to '%PREFIX%jcr_user'@'%' identified by '%PASSWORD%';

commit;

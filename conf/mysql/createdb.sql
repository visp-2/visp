use mysql
GRANT ALL PRIVILEGES ON *.* TO 'adminmysql'@localhost IDENTIFIED BY 'mot2passe' WITH GRANT OPTION;
FLUSH PRIVILEGES;
create database lxc;
GRANT ALL PRIVILEGES ON lxc.* TO 'moderator'@172.16.1.254 identified by 'test1234=';
GRANT ALL PRIVILEGES ON lxc.* TO 'moderator'@172.16.1.1 identified by 'test1234=';
use lxc
CREATE TABLE users (id INT not null AUTO_INCREMENT, username VARCHAR(50) not null , password VARCHAR(50) not null , mail VARCHAR(100) not null, phone VARCHAR(
25), mailbox VARCHAR(50), active VARCHAR(3), PRIMARY KEY (id));
CREATE TABLE domains (id INT not null AUTO_INCREMENT, domain VARCHAR(100) not null , active VARCHAR(3) not null, PRIMARY KEY (id));
CREATE TABLE aliases (id INT not null AUTO_INCREMENT, service VARCHAR(50) not null, active VARCHAR(3) not null, PRIMARY KEY (id));

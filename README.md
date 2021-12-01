# Born2beRoot

Сабжект: https://cdn.intra.42.fr/pdf/pdf/31621/en.subject.pdf

Цель проекта - настроить виртуальную машину VirtualBox под управлением Debian или CentOS и реализовать некоторые базовые вещи, такие как ssh и sudo. Скрипт bash, который вы можете увидеть в репозитории, предназначен для отслеживания состояния систем.

## ЧАСТЬ I
#### Виртуальная машина VirtualBox + создаем структуру под бонусную часть:

Инструкция по VirtualBox:
- На русском : https://hackware.ru/?p=3727
- Оригинал   : https://www.virtualbox.org/manual/ch01.html

Oracle VM VirtualBox-это кроссплатформенное приложение для виртуализации. Что это значит? Во-первых, он устанавливается на ваши существующие компьютеры на базе Intel или AMD, независимо от того, работают ли они под управлением операционных систем Windows, Mac OS X, Linux или Oracle Solaris (операционные системы). Во-вторых, это расширяет возможности вашего существующего компьютера, так что он может одновременно запускать несколько операционных систем внутри нескольких виртуальных машин. Например, вы можете запускать Windows и Linux на своем Mac, запускать Windows Server 2016 на своем сервере Linux, запускать Linux на своем ПК с Windows и так далее, все вместе с существующими приложениями. Вы можете установить и запустить столько виртуальных машин, сколько захотите. Единственными практическими ограничениями являются дисковое пространство и память.

Почему виртуализация полезна?
- Запуск нескольких операционных систем одновременно.
- Более простая установка программного обеспечения.
- Тестирование и аварийное восстановление.
- Консолидация инфраструктуры.

Легче скачать и использовать Debian, чем CentOS (если нет опыта);
Скачать последнюю версию Debian можно тут: https://www.debian.org/distrib/

- Создаем структуру под бонусную часть:
Начало работы :
1. смотрим видео на ютубе https://www.youtube.com/watch?v=13YBlD0SOJo
2. в ВМ создаем общий диск на 30,8Gb (это важно)
3. sda1 на 525Мb, форматим его в ext4, он у нас первичный. Точка монтирования - /boot.
4. sda5 на вecь оставшийся объем. Он у нас первый логический, потому и пятый. (но для LVM- а он физический, логический он для таблицы разделов MBR)
5. Создаём зашифрованный раздел из sda5.
6. Создаём группу томов (LVMGroup), в которую добавляем один лишь зашифрованный раздел sda5.
7. Создаём все необходимые по сабжу логические тома и указываем их размер: root, swap, home, var-log(дефис один) и т.д. логические тома - это наши будущие директории. То, что мы их так назвали, ничего не значит. Сами они не смонтируются.

![image](https://user-images.githubusercontent.com/58044383/142226522-6c2dc1dc-e93a-42e4-b71e-595865602df6.png)

8. Монтируем наши логические тома к файловой структуре дебиана - тут все по наитию. Сначала выбираем тип ФС, которая должна быть у логического тома (для всех, кроме swap, - ext4), потом выбираем точку монтирования (для var-log вручную вписываем var/log).
9. Подтверждаем, что всё ок и запускаем установку дебиана.

10. На шаге с "Software selection" убираем установку графики, оставляем ssh-server и standard system utilities, иначе бан.
GRUB добавляем в главную загрузочную запись.
Затем GRUB устанавливаем на наш единственный диск - sda.

11. Ребутаемся и выбираем первый варик загрузки, вводим Encryption Passphrase. (вводимые символы никак не отображаются на экране, даже ****. пишем и надеемся, что пишем правильно)
12. Вводим логин и пароль пока единственного пользователя. Для меня - einterdi. Пароль 111.
13. Должeн загрузиться терминал.
14. В терминале вводим команду lsblk и проверяем что у нас все сходится

![image](https://user-images.githubusercontent.com/58044383/142226866-eb8f6f47-5244-40ac-a29f-d3cad7cf9323.png)



## ЧАСТЬ II
#### Создаем root и т.д.

Начало работы:
- https://baigal.medium.com/born2beroot-e6e26dfb50ac
- https://www.higithub.com/GuillaumeOz/repo/Born2beroot

Общие термины:

	Aptitude - это менеджер пакетов высокого уровня, который может использовать менеджеры пакетов низкого уровня, такие как apt-get;
	AppArmor - защитный модуль Linus Kernel, который позволяет системному администратору ограничивать возможности программ с помощью профилей программ;
	SSH (Secure Shell или Secure Socket Shell) - это сетевой протокол, который дает пользователям, особенно системным администраторам, безопасный способ доступа к компьютеру по     незащищенной сети;
	Sudo - это альтернатива su для выполнения команд с правами суперпользователя (root).
	Cron — это хронологический демон-планировщик задач, работающий в операционных системах типа Unix, включая дистрибутивы Linux.

#### 1. SUDO.
	Для этого переходим в режим суперпользователя "su -". далее:
	apt update
	apt upgrade
	apt install sudo


 AppArmor
https://help.ubuntu.ru/wiki/руководство_по_ubuntu_server/безопасность/apparmor AppArmor - это реализация Модуля безопасности линукс по управлению доступом на основе имен. AppArmor ограничивает отдельные программы набором перечисленных файлов и возможностями в соответствии с правилами Posix 1003.1e

Проверить статус AppArmor sudo apparmor_status или /usr/sbin/aa-status

#### 2.	НАСТРОЙКА SSH

	// правим конфиг ssh
	$nano /etc/ssh/sshd_config
	// Меняем строки
	#Port 22 => Port 4242
	// чтобы запретить авторизацию от имени суперпользователя
	#PermitRootLogin prohibit-password => PermitRootLogin no
	// Проверяем что ssh включен
	sudo service ssh status
	systemctl status ssh

#### 3. 	ROOT-ПРАВА ПОЛЬЗОВАТЕЛЮ

	// добавляем пользователя
	$usermod -aG sudo <your_username>
	// проверяем что пользователь добавлен в группу
	groups <your_username>
	getent group sudo
	// бэкапим конфиг sudo
	$cp /etc/sudoers /etc/sudoers.backup
	// правим конфиг sudo
	$nano /etc/sudoers
	// или
	$ sudo visudo
	добавляем строку с именем пользователя
	<user>    ALL=(ALL:ALL) ALL
	// перезагружаемся
	$reboot

#### 4.	ДОСТУП ЧЕРЕЗ ТЕРМИНАЛ
	Проброс портов в virtualbox
	$ssh <user>@localhost -p 4242
	если не получается возможно проблема из-за множества виртуальных машин на которых мы разворачивали систему
	тогда на маке в файле /Users/einterdi/.ssh/known_hosts коментим последине записи наычинающиеся на localhost или 127.0.0.1


#### 5.	ФАЙЕРВОЛ
	// устанавливаем ufw
	$apt install ufw
	// убеждаемся, что он не работает
	$ufw status
	// запускаем файервол
	$ufw enable
	// убеждаемся, что он работает
	$sudo ufw status
	sudo ufw status numbered
	// разрешаем наш порт ssh
	$ufw allow 4242
	// удаляем порт 22
	sudo ufw delete (номер строки ненужного порта)

#### 6.	НАСТРОЙКА ВХОДА ПОД SUDO
	// логинимся под рутом
	$su -
	// проверяем группы пользователей
	$groups root
	$groups <user>
	// проверяем и/или меняем имя машины
	$nano /etc/hostname
	// проверяем имя хоста
	$nano /etc/hosts
	// ещё раз правим конфиг судо
	$nano /etc/sudoers
	// меняем фразу при неудачном вводе
	Defaults  badpass_message="Password is wrong, please try again!Do you understand?"
	// Устанавливаем количество попыток ввода
	Defaults        passwd_tries=3
	// прописываем путь где будет фиксироваться все команды с sudo
	Defaults        logfile="/var/log/sudo/sudo.log"
	Defaults        log_input, log_output
	Defaults        requiret
	// создаем папку sudo и в ней файл sudo.log

#### 7. ПОЛЬЗОВАТЕЛИ
	// Посмотреть всех пользователей
	sudo cut -d: -f1 /etc/passwd
	lastlog
	// Создать пользователя
	sudo adduser <user> //
	sudo useradd <user> // создает пользователя без папки в директории /home
	// Посмотреть в каких группах пользователь
	id -Gn <user>
	grops <user>
	// Удалить пользователя
	sudo deluser <user>
	sudo userdel <user>
	// удалить пользователя из группы
	sudo gpasswd -d <user> <group>

#### 8. ГРУППЫ
	// Создать группу
	groupadd <you_group>
	// Посмотреть группы
	getent group
	// добаваить пользователя в группу
	usermod -aG <you_group> <you_user>
	// удалить пользователя из группы
	gpasswd -d <you_user> <you_group>
	// добавить кошку
	adduser cat
	//поместить кошку в дом
	adduser cat home
	
#### 9.	ПОЛИТИКА ПАРОЛЕЙ
	// устанавливаем утилиту политики
	$apt-get install libpam-pwquality
	// правим файл политики паролей
	%nano /etc/login.defs
	// меняем значения строк как здесь:
	PASS_MAX_DAYS 30
	PASS_MIN_DAYS 2
	PASS_WARN_AGE 7
	// на всякий пожарный бэкапим конфиг
	$cp /etc/pam.d/common-password /etc/pam.d/common-password.backup
	// правим конфиг
	$nano /etc/pam.d/common-password
	// дописываем в эту строку следующим образом:
	password        requisite	pam_pwquality.so retry=3 maxrepeat=3 minlen=10 dcredit=-1 ucredit=-1 lcredit=-1 usercheck=1 difok=7
	password        requisite	pam_pwquality.so retry=3 maxrepeat=3 minlen=10 dcredit=-1 ucredit=-1 lcredit=-1 enforce_for_root
	// меняем пароли пользователей в соответствии с политикой
	$passwd user
	$passwd root	
	
#### 9.	СМЕНА ИМЕНИ ХОСТА
	// в этих файлах меняем 
	$nano /etc/hosts
	$nano /etc/hostname

## ЧАСТЬ III 
#### СКРИПТ

#### 1. СОЗДАНИЕ СКРИПТА
	// для утилиты netstat
	$apt install net-tools
	$su -
	$cd /usr/local/bin/
	$touch monitoring.sh
	$chmod +x ./monitoring.sh
	$nano monitoring.sh
	// скрипт c командами файле monitoring.sh

#### 2. СКРИПТ
	#!/bin/bash
	wall $'#Architecture:' `uname -a` \
	$'\n#CPU physical : '`nproc` \
	$'\n#vCPU :' `cat /proc/cpuinfo | grep processor | wc -l` \
	$'\n#Memory Usage:' `free -m | grep Mem | awk '{printf "%d/%d (%.1f%%)", $3, $2, $3*100/$2}'` \
	$'\n#Disk Usage: '`df -h | grep root | awk '{print $3"/"$2" ("$5")"}'` \
	$'\n#CPU load: '`cat /proc/loadavg | awk '{printf "%.1f%%", $1}'` \
	$'\n#Last boot:' `who -b | awk '{print $3" "$4}'` \
	$'\n#LVM use:' `lsblk |grep lvm | awk '{if ($1) {print "yes";exit;} else {print "no"} }'` \
	$'\n#Connection TCP:' `netstat -an | grep ESTABLISHED |  wc -l` "ESTABLISHED" \
	$'\n#User log:' `who | wc -l` \
	$'\nNetwork: IP' `hostname -I`"("`ip a | grep link/ether | awk '{print $2}'`")" \
	$'\n#Sudo :' `cat /var/log/sudo/sudo.log | grep COMMAND | wc -l` "cmd"


#### 3. НАСТРОЙКА CRON
	// добавляем скрипт в расписание (кадые 10 мин)
	$crontab -e
	*/10 * * * *  /usr/local/bin/monitoring.sh
	// если чере 30 сек то
	#* * * * * /usr/local/bin/monitoring.sh
	#* * * * * ( sleep 30 ; /usr/local/bin/monitoring.sh )
  
   ## ЧАСТЬ IV
  #### БOНУСЫ
  	
#### 1.	УСТАНОВКА СЕРВЕРА
	$apt install lighttpd
	// смотрим порты
	$nano /etc/lighttpd/lighttpd.conf
	// разрешаем доступ по порту сервера
	$ufw allow 80
	$ufw allow 8080
	Пробрасываем порты в virtualbox
	Заходим в браузере по ip
	127.0.0.1

#### 1.	УСТАНОВКА БАЗЫ ДАННЫХ
	// входим под рутом
	$su -
	// настраиваем MariaDB:
	$apt install mariadb-server - установка
	$mysql_secure_installation - настройка (везде yes, кроме установки пароля рута и в первом запросе нажать Enter)
	// входим в оболочку MariaDB
	$mariadb
	// создаём базу
	>CREATE DATABASE wordpress;
	// создаём пользователия для дб
	>CREATE USER '<user>'@'localhost' IDENTIFIED BY 'password';
	// предоставляем пользователю полные привелегии для дб
	>GRANT ALL ON wordpress.* TO '<user>'@'localhost';
	>FLUSH PRIVILEGES;
	>exit
	// проверка юзера
	$mariadb -u <user> -p
	// проверка бд
	>SHOW DATABASES;

#### 3.	УСТАНОВКА PHP
	// ставим php
	$apt install php php-cgi php-mysql
	// запускам север в режиме fastcgi
	$lighty-enable-mod fastcgi
	// подключаем к сереверу php
	$lighty-enable-mod fastcgi-php
	// перезагружаем сервис
	$service lighttpd force-reload


#### 4.	УСТАНОВКА WORDPRESS
	// заходим под рут
	$su -
	// скачиваем вордпресс
	$wget https://ru.wordpress.org/latest-ru_RU.tar.gz
	// копируем его в папку сервера
	$cp latest-ru_RU.tar.gz /var/www/html/
	// перехдим в папку /var/www/html/ и там распаковываем
	$tar -xvzf latest-ru_RU.tar.gz

#### 5.	ПРАВА ПАПКАМ
	// меняем владельца папки с вордпрессом
	$chown -R www-data:www-data /var/www/html/wordpress
	// применяем правильные права для всех папок и файлов
	$find /var/www/html/wordpress -type d -exec chmod 750 {} \;
	$find /var/www/html/wordpress -type f -exec chmod 640 {} \;

#### 6.	УСТАНОВКА WP
	// заходим через браузер:
	http://127.0.0.1/wordpress
	// настраиваем и наслаждаемся)

#### 7.	ДОПОЛНИТЕЛЬНЫЙ СЕРВИС: VSFTPD
	// устанавливаем
	$apt install vsftpd
	// останавливаем
	$service vsftpd stop
	// правим конфиг
	$nano /etc/vsftpd.conf
	// раскомментировать
	write_enable=YES
	chroot_local_user=YES
	// разрешаем порт
	$ufw allow 20
	// пробрасываем порт 20
	// запускаем ftp-сервер:
	$service vsftpd start
	// проверяем что всё получилось:
	$service vsftpd status
  
  ## ЧАСТЬ V
  #### ПОЛЕЗНОЕ
  	service --status-all	// - показывает работу всех сервисов
	passwd -S <user>	// - посмотреть политику паролей для данного пользователя
	chage -l <user>		// - посмотреть политику паролей для данного пользователя
	aa-status		// - статус AppArmor
	htop			// - красивое визуализация работы компьютера
	aptitude		// - Aptitude (aptitude moo / aptitude -v moo / - пасхалки для Aptitude)
  
  ## ЧАСТЬ VI
  #### ЗАЩИТА
  
1) Как работает виртуальная машина.
2) Выбор операционки.
3) Базовые отличия между CentOS и Debian.
4) Смысл (цель) использования виртуальных машин.
5) Отличия apt и aptitude, что такое APPArmor
6) Во время защиты должен вылезать скрипт каждые 10 минут.

7) Убедиться, что нет графического интерфейса при запуске машины
8) При подключении к машине должен быть затребован пароль
9) К машине нужно подключиться под каким-то пользователем, который не root -- check
10) Проверить, что пароли соответствуют политике паролей.
11) Проверить, что UFW запущен
12) Проверить, что SSH запущен
13) Проверить, что это дебиан или центос

14) Проверить, что пользователь с именем einterdi есть и входит в группы sudo и einterdi42
(у меня не было, поэтому: 
sudo groupadd einterdi42
sudo usermod -a -G einterdi42 einterdi)
15) Проверить корректную настройку политики паролей, выполнив следующие шаги:
а) Создайте нового пользователя с паролем, удовлетворяющем сабджект. Тут надо объяснить, как конфигурируется политика паролей. (Обычно нужно отредактировать один или два файла для этого)
б) Когда новый пользователь создан, создать группу evaluating и добавить в неё пользователя. Проверить, что пользователь присутствует в этой группе.
16) Объяснить преимущества политики паролей.

17) Проверить, что хостнейм - einterdi42
18) Изменить хотстнейм на логин_проверяющего_42 и ребутнуться, проверив, что хостнейм сменился. 
либо	sudo hostname <новое_имя_хоста>
		sudo nano /etc/hostname
		sudo nano /etc/hosts
либо без первой строчки и ребутаемся
19) Можно вернуть старый хостнейм
20) Проверить разбивку на разделы и сравнить с сабджектом.
21) Тут ещё надо затереть про LVM: что это и как с ней работать.

22) Проверить, что судо установлена на машине
23) Добавить какого-нибудь пользователя в группу судо
24) Объяснить, как работает судо.
25) Сгонять в папку /ver/log/sudo, проверить что она вообще есть, и что в ней есть файлы, проверить их содержимое. Проверить, что при выполнении какой-либо команды от судо логгируется в журнал.

26) Проверить, что UFW корректно установлена на машине
27) Проверить, что UFW работает
28) Объяснить, что это за зверь и зачем его юзать.
29) Вывести все активные правила в UFW и убедиться, что там есть правило для порта 4242
30) Добавить новое правило для порта 8080 и проверить, что оно добавилось
31) Удалить это правило

32) Проверить, что SSH правильно установлен на машине
33) Проверить, что он норм работает
34) Объяснить, что такое SSH и зачем он нужен.
35) Убедиться, что SSH слушает только 4242 порт.
36) Зайти на сервак через ssh как новый пользователь (которого создали при проверке)
37) Проверить, что нельзя зайти на сервак под рутом.

38) Показать код скрипта и объяснить его
39) Объяснить, что такое cron 
40) Рассказать, как запускать скрипт каждые 10 минут
41) Сделать так, чтоб скрипт запускался каждую минуту
42) Сделать так, чтоб скрипт не запускался каждую минут после перезагрузки сервака.

Бонусная часть

43) Проверить, что разбиение на разделы корректное
44) Проверить работу вордпресса, что он юзает только lighty, MariaDB, Php
45) Проверить, что установлен ещё какой-то сервис и он робит. Объяснить, как он робит и почему он полезный.




Preliminaries
If cheating is suspected, the evaluation stops here. Use the "Cheat" flag to report it. Take this decision calmly, wisely, and please, use this button with caution.

Preliminary tests
- Defense can only happen if the student being evaluated or group is present.
This way everybody learns by sharing knowledge with each other.
- If no work has been submitted (or wrong files, wrong directory, or
wrong filenames), the grade is 0, and the evaluation process ends.
- For this project, you have to clone their Git repository on their
station.
General instructions
General instructions
- During the defense, as soon as you need help to verify a point, the student
evaluated must help you.
- Ensure that the "signature.txt" file is present at the root of the cloned
repository.
- Check that the signature contained in "signature.txt" is identical
to that of the ".vdi" file of the virtual machine to be evaluated. A simple
"diff" should allow you to compare the two signatures. If necessary, ask the
student being evaluated where their ".vdi" file is located.
- As a precaution, you can duplicate the initial virtual machine in order
to keep a copy.
- Start the virtual machine to be evaluated.
- If something doesn't work as expected or the two signatures differ,
the evaluation stops here.
Mandatory part
The project consists of creating and configuring a virtual machine following strict rules. The student being evaluated will have to help you during the defense. Make sure that all of the following points are observed.

Project overview
- The student being evaluated should explain to you simply:
- How a virtual machine works.
- Their choice of operating system.
- The basic differences between CentOS and Debian.
- The purpose of virtual machines.
- If the evaluated student chose CentOS: what SELinux and DNF are.
- If the evaluated student chose Debian: the difference between
aptitude and apt, and what APPArmor is.
During the defense, a script must display information all
every 10 minutes. Its operation will be checked in detail later.
If the explanations are not clear, the evaluation stops here.
Simple setup
Remember: Whenever you need help checking something, the student being evaluated
should be able to help you.
- Ensure that the machine does not have a graphical environment at launch.
A password will be requested before attempting to connect to this machine.
Finally, connect with a user with the help of the student being evaluated.
This user must not be root.
Pay attention to the password chosen, it must follow the rules imposed in the subject.
- Check that the UFW service is started with the help of the evaluator.
- Check that the SSH service is started with the help of the evaluator.
- Check that the chosen operating system is Debian or CentOS with the help of the evaluator.
If something does not work as expected or is not clearly explained,
the evaluation stops here.
User

Remember: Whenever you need help checking something, the student being evaluated
should be able to help you.

The subject requests that a user with the login of the student being evaluated is present
on the virtual machine. Check that it has been added and that it belongs to the
"sudo" and "user42" groups.

Make sure the rules imposed in the subject concerning the password policy have been put in place by
following the following steps.

First, create a new user. Assign it a password of your choice, respecting the subject rules. The
student being evaluated must now explain to you how they were able to set up the rules requested
in the subject on their virtual machine.
Normally there should be one or two modified files. If there is any problem, the evaluation stops here.

- Now that you have a new user, ask the student being evaluated to create a group named "evaluating" in
front of you and assign it to this user. Finally, check that this user belongs to the "evaluating" group.

- Finally, ask the student being evaluated to explain the advantages of this password policy, as well as the
advantages and disadvantages of its implementation. Of course, answering that it is because the subject asks
for it does not count.

If something does not work as expected or is not clearly explained, the evaluation stops here.
Hostname and partitions
Remember: Whenever you need help checking something, the student being evaluated
should be able to help you.

- Check that the hostname of the machine is correctly formatted as follows:
login42 (login of the student being evaluated).
- Modify this hostname by replacing the login with yours, then restart the machine.
If on restart, the hostname has not been updated, the evaluation stops here.
- You can now restore the machine to the original hostname.
- Ask the student being evaluated how to view the partitions for this virtual machine.
- Compare the output with the example given in the subject. Please note: if the
student evaluated makes the bonuses, it will be necessary to refer to the bonus example.

This part is an opportunity to discuss the scores! The student being evaluated should
give you a brief explanation of how LVM works and what it is all about.
If something does not work as expected or is not clearly explained,
the evaluation stops here.
SUDO
Remember: Whenever you need help checking something, the student being evaluated
should be able to help you.

- Check that the "sudo" program is properly installed on the virtual machine.
- The student being evaluated should now show assigning your new user to the "sudo" group.
- The subject imposes strict rules for sudo. The student being evaluated must first explain the
value and operation of sudo using examples of their choice.
In a second step, it must show you the implementation of the rules imposed by the subject.
- Verify that the "/var/log/sudo/" folder exists and has at least one file. Check the contents
of the files in this folder, You should see a history of the commands used with sudo.
Finally, try to run a command via sudo. See if the file (s) in the "/var/log/sudo/" folder
have been updated.
If something does not work as expected or is not clearly explained, the evaluation stops here.
UFW
Remember: Whenever you need help checking something, the student being evaluated
should be able to help you.

- Check that the "UFW" program is properly installed on the virtual machine.
- Check that it is working properly.
- The student being evaluated should explain to you basically what UFW is and the
value of using it.
- List the active rules in UFW. A rule must exist for port 4242.
- Add a new rule to open port 8080. Check that this one has been added by listing the active rules.
- Finally, delete this new rule with the help of the student being evaluated.
If something does not work as expected or is not clearly explained, the evaluation stops here.
SSH
Remember: Whenever you need help checking something, the student being evaluated
should be able to help you.

- Check that the SSH service is properly installed on the virtual machine.
- Check that it is working properly.
- The student being evaluated must be able to explain to you basically what SSH is and
the value of using it.
- Verify that the SSH service only uses port 4242.
- The student being evaluated should help you use SSH in order to log in with the newly created user.
To do this, you can use a key or a simple password. It will depend on the student being evaluated.
Of course, you have to make sure that you cannot use SSH with the "root" user as stated in the subject.
If something does not work as expected or is not clearly explained, the evaluation stops here.
Script monitoring
Remember: Whenever you need help checking something, the student being evaluated
should be able to help you.

The student being evaluated should explain to you simply:
- How their script works by showing you the code.
- What "cron" is.
- How the student being evaluated set up their script so that it runs every 10 minutes
from when the server starts.
Once the correct functioning of the script has been verified, the student being evaluated
should ensure that this script runs every minute. You can run whatever you want
to make sure the script runs with dynamic values correctly. Finally, the student being evaluated
should make the script stop running when the server has started up, but without
modifying the script itself. To check this point, you will have to restart
the server one last time. At startup, it will be necessary to check that the script
still exists in the same place, that its rights have remained unchanged, and that it
has not been modified.
If something does not work as expected or is not clearly explained, the evaluation stops here.
Bonus
Evaluate the bonus part if, and only if, the mandatory part has been entirely and perfectly done, and the error management handles unexpected or bad usage. In case all the mandatory points were not passed during the defense, bonus points must be totally ignored.

Bonus
Check, with the help of the subject and the student being evaluated, the bonus
points authorized for this project:
- Setting up partitions is worth 2 points.
- Setting up WordPress, only with the services required by the subject,
is worth 2 points.
- The free choice service is worth 1 point.
Verify and test the proper functioning and implementation of each extra
service.
For the free choice service, the student being evaluated has to give you a
simple explanation about how it works and why they think it is useful.
Please note that NGINX and Apache2 are prohibited.

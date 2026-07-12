# نفذ هذا الأمر في التيرمينال وأخبرني هل يظهر لك رقم طويل مثل 1:0:1...؟
wget -qO- http://127.0.0.1/web/getcurrent | grep -o '1:0:1:.*:0:0:0'
wget -qO- http://127.0.0.1/web/getcurrent | grep -o '1:0:1:.*:0:0:0' | head -n 1
REF="1:0:1:596:FFDC:1:DC00000:0:0:0"
echo $(echo $REF | tr ':' '_').png
ls /media/hdd/picons/ | head -n 5
cat /proc/stb/info/model
ls /tmp/.listen.port
grep "p:1:0" /etc/enigma2/userbouquet.favourites.tv | head -n 1
cat /tmp/cur.info 2>/dev/null
# أو هذا الأمر إذا كان الأول فارغاً
cat /tmp/currentservice 2>/dev/null
cat /tmp/picon_debug.log
Connecting to 192.168.1.12 port 23, please wait...
Welcome to openATV for novaler4kse
openatv 7.6.0 novaler4kse
cat /tmp/picon_debug.log
sh /usr/script/khaled_watcher.sh
ls /tmp/picon_debug.log
chmod 755 /usr/script/khaled_watcher.sh
(crontab -l 2>/dev/null | grep -v "khaled_watcher"; echo "* * * * * /usr/script/khaled_watcher.sh") | crontab -
ls /media/hdd/picon/
# 1. إيقاف أي سكربت قديم
crontab -l | grep -v "khaled_watcher" | crontab -
# 2. إنشاء الرابط الرمزي (هذا يجعل الجهاز يرى محتويات picons داخل picon وكأنهما واحد)
rm -rf /media/hdd/picon
ln -s /media/hdd/picons /media/hdd/picon
ls -l /media/hdd/picon
# حذف الربط القديم
rm -rf /media/hdd/picon
# إنشاء مجلد جديد ليكون هو "الوسيط"
mkdir -p /media/hdd/picon_cloud
ln -s /media/hdd/picon_cloud /media/hdd/picon
rm -rf /media/hdd/picon
mkdir -p /media/hdd/picon_cloud
ln -s /media/hdd/picon_cloud /media/hdd/picon
chmod 755 /usr/script/khaled_watcher.sh
# إضافة السكربت للـ Cron ليعمل كل دقيقة
(crontab -l 2>/dev/null | grep -v "khaled_watcher"; echo "* * * * * /usr/script/khaled_watcher.sh") | crontab -
/etc/init.d/cron restart
/etc/init.d/crond restart
crontab -r
/usr/script/khaled_watcher.sh &
chmod +x /usr/script/khaled_watcher.sh
sh /usr/script/khaled_watcher.sh &
ps aux | grep khaled_watcher
REF=$(wget -qO- http://127.0.0.1/web/getcurrent | grep -o '1:0:[0-9A-Fa-f]*:[0-9A-Fa-f]*:[0-9A-Fa-f]*:[0-9A-Fa-f]*:0:0:0' | head -n 1); NAME=$(echo $REF | tr ':' '_').png; wget "https://raw.githubusercontent.com/KhaledAli65/picon/main/$NAME" -O "/media/hdd/picon/$NAME"
wget -qO- http://127.0.0.1/web/getcurrent | grep -o '1:0:[0-9A-Fa-f]*:[0-9A-Fa-f]*:[0-9A-Fa-f]*:[0-9A-Fa-f]*:0:0:0' | head -n 1
cat /tmp/curinfo.txt
cat /tmp/eldon.info
rm -rf /usr/lib/enigma2/python/Plugins/Extensions/OPDBoot/__pycache__
rm -rf /usr/lib/enigma2/python/Plugins/Extensions/OPDBoot
grep -oE '[0-9]+:[0-9]+:[0-9]+:[0-9]+:[0-9]+:[0-9]+:[0-9]+' /media/hdd/Script_NewEdition/channels.xml | head -n 5
grep -oE '[0-9]+:[0-9]+:[0-9]+:[0-9]+:[0-9]+:[0-9]+:[0-9]+' /media/hdd/Script_NewEdition/channels.xml | head -n 5
grep -oE '[0-9]+:[0-9]+:[0-9]+:[0-9]+:[0-9]+:[0-9]+:[0-9]+' /media/hdd/Script_NewEdition/channels.xml | head -n 5
grep -oE '[0-9]+:[0-9]+:[0-9]+:[0-9]+:[0-9]+:[0-9]+:[0-9]+' /media/hdd/Script_New_Edition/channels.xml | head -n 5

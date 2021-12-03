#!/bin/bash
mysqldump --dump-slave --databases wordpress -uroot -p3993 > /root/`date +%Y-%m-%d`_wordpress.db

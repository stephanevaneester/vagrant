#  ___ _____ ___ _  ___  _____ 
# / __|_   _| __| |/ / |/ / __|
# \__ \ | | | _|| ' <| ' <| _| 
# |___/ |_| |___|_|\_\_|\_\___|
#
# SQL DEFAULT SETUP

# Create an external user with privileges on all databases in mysql so
# that a connection can be made from the local machine without an SSH tunnel
GRANT ALL PRIVILEGES ON *.* TO 'external'@'%' IDENTIFIED BY 'external' WITH GRANT OPTION;

# Create CBA wordpress database ID55288_cbawp
CREATE DATABASE IF NOT EXISTS `ID55288_cbawp`;
GRANT ALL PRIVILEGES ON `ID55288_cbawp`.* TO 'ID55288_cbawp'@'localhost' IDENTIFIED BY 'ID55288_cbawp';
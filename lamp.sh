function new-lamp {
  echo $1

  cd ~/Development/sites
  git clone https://github.com/sprintcube/docker-compose-lamp.git $1
  cd $1
  git fetch --all

  #which version of php?
  echo "Which version of php do you want to use?"
  select 123 in "5.6.x" "7.1.x" "7.2.x"; do
    case $123 in
        5.6.x ) git checkout 5.6.x; break;;
        7.1.x ) git checkout 7.1.x; break;;
        7.2.x ) git checkout 7.2.x; break;;
    esac
  done

  rm -rf .git

  sed -i -e "s/x-webserver/x-$1-webserver/g" docker-compose.yml
  sed -i -e "s/-mysql/-$1-mysql/g" docker-compose.yml
  sed -i -e "s/-phpmyadmin/-$1-phpmyadmin/g" docker-compose.yml
  sed -i -e "s/-redis/-$1-redis/g" docker-compose.yml

  docker-compose build
  docker-compose up -d

# cat <<EOF > config/php/php.ini
#   [xdebug]
#   xdebug.remote_enable = 1
#   xdebug.remote_autostart = 1
#   xdebug.remote_connect_back = 1
#   xdebug.remote_log="/tmp/xdebug.log"
# EOF;

  #add wordpress
  echo "Would you like to install Wordpress?"
  select yn in "Yes" "No"; do
    case $yn in
        Yes ) cd www; \n
          wget http://wordpress.org/latest.tar.gz; \n
          tar xfz latest.tar.gz; \n
          mv wordpress/* ./; \n
          rm -rf wordpress; \n
          rm -rf latest.tar.gz; \n
          cp wp-config-sample.php wp-config.php; \n
          echo "What's the name of your database?"; \n
          read db; \n
          sed -i -e "s/database_name_here/$db/g" wp-config.php; \n
          sed -i -e "s/username_here/root/g" wp-config.php; \n
          sed -i -e "s/password_here/tiger/g" wp-config.php; \n
          sed -i -e "s/localhost/mysql/g" wp-config.php; \n
          cd ../; \n
          echo "Wordpress has been installed. You may need to create a new mysql database."; \n
          break;;
        No )  break;;
    esac
  done

  # Add to wp-config for installing plugins
  # define( 'FS_METHOD', 'direct' );

  echo "All done. You can run your webserver by running the command docker-compose up -d"
  echo "phpmyadmin: http://localhost:8080"
  echo "user: root"
  echo "pass: tiger"

}

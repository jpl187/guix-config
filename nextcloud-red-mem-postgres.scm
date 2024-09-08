(use-modules (gnu) (gnu services) (gnu services web) (gnu services databases)
             (gnu services memcached) (gnu services redis) (gnu services php)
             (gnu services ssh) (gnu services networking))

(operating-system
  (host-name "nextcloud-container")
  (timezone "Europe/Berlin")

  (locale "de_DE.utf8")

  (file-systems (cons (file-system
                       (mount-point "/")
                       (device "/dev/vda1")
                       (type "ext4"))
                      %base-file-systems))

  (packages
    (append (list
              postgresql
              php
              php-fpm
              php-opcache
              php-pgsql
              php-memcached
              redis
              memcached
              nginx
              nextcloud)
            %base-packages))
  (services
    (append
     (list
      (service postgresql-service-type
               (postgresql-configuration
                (postgresql postgresql)))
      (service redis-service-type)
      (service memcached-service-type)
      (service php-fpm-service-type
               (php-fpm-configuration
                (user "nginx")
                (group "nginx")
                (php-config (list
                             (php-extension 'opcache)
                             (php-extension 'memcached)))))

      (service nginx-service-type
               (nginx-configuration
                (server-blocks
                 (list
                  (nginx-server-configuration
                   (server-name "localhost")
                   (root "/var/www/nextcloud")
                   (locations
                    (list (nginx-location-configuration
                           (uri "/")
                           (body
                            (nginx-fastcgi-configuration
                             (socket "/var/run/php-fpm.sock")
                             (fastcgi-params
                              '((SCRIPT_FILENAME . "$document_root$fastcgi_script_name")))))))))))))))

     %base-services)))



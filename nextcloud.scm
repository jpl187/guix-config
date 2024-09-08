(use-modules (gnu) 
             (gnu services web)
             (gnu services databases)
             (gnu services php)
             (gnu services ssh)
             (gnu packages php)
             (gnu packages web)
             (gnu packages databases))

(define %nextcloud-container
  (container
    (inherit (base-container))

    (services
     (list
      (service networking-service-type)

      (service
       mariadb-service-type
       (mariadb-configuration
        (data-directory "/var/lib/mysql")))

      (service
       php-fpm-service-type
       (php-configuration
        (extensions
         (list php-mysql php-gd php-curl php-zip php-dom php-json php-mbstring php-opcache php-fileinfo))))

      (service
       nginx-service-type
       (nginx-configuration
        (server-blocks
         (list
          (nginx-server-configuration
           (listen '("80"))
           (server-name "localhost")
           (root "/var/www/nextcloud")
           (index '("index.php" "index.html"))
           (locations
            (list
             (nginx-location-configuration
              (uri "/")
              (root "/var/www/nextcloud")
              (try-files '("$uri" "$uri/" "/index.php?$query_string")))
             (nginx-location-configuration
              (uri "~ \\.php$")
              (fastcgi-split-path-info "\\.php$")
              (fastcgi-pass "unix:/var/run/php-fpm.sock")
              (fastcgi-index "index.php")
              (fastcgi-params
               `(("SCRIPT_FILENAME" . "$document_root$fastcgi_script_name")
                 ("QUERY_STRING" . "$query_string")
                 ("REQUEST_METHOD" . "$request_method")
                 ("CONTENT_TYPE" . "$content_type")
                 ("CONTENT_LENGTH" . "$content_length")))))))))))

      (service syslog-service-type)

      (service openssh-service-type)))))



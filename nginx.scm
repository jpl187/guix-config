(define %nginx-configuration
  (simple-service 'nginx
                  (lambda (config)
                    (list
                     (shepherd-service
                      (provision '(nginx))
                      (start #~(make-forkexec-constructor
                                (list #$(file-append nginx "/bin/nginx")
                                      "-c" "/etc/nginx/nginx.conf")))
                      (stop #~(make-kill-destructor)))))))

(define (nginx-config)
  #~(begin
      (use-modules (guix build utils))
      (mkdir-p "/etc/nginx")
      (call-with-output-file "/etc/nginx/nginx.conf"
        (lambda (port)
          (display "worker_processes 1;\n" port)
          (display "events {\n" port)
          (display "  worker_connections 1024;\n" port)
          (display "}\n" port)
          (display "http {\n" port)
          (display "  server {\n" port)
          (display "    listen 80;\n" port)
          (display "    location / {\n" port)
          (display "      root /var/www/html;\n" port)
          (display "      index index.html;\n" port)
          (display "    }\n" port)
          (display "  }\n" port)
          (display "}\n" port)))))

(define (nginx-container)
  (container
    (inherit (base-container))
    (packages (list nginx))
    (services (list %nginx-configuration))
    (setup (nginx-config))))


(use-modules (srfi srfi-1) ; for 'remove' - https://guix.gnu.org/manual/en/html_node/X-Window.html
             (gnu)
             (guix)
             (gnu system keyboard)
             (gnu system pam))

(use-service-modules admin
                     base
                     networking
                     ssh
                     auditd
                     desktop
                     xorg
                     docker
                     messaging
                     pm)

(use-package-modules emacs
                     emacs-xyz
                     compression
                     curl
                     fonts
                     fontutils
                     ghostscript
                     gnuzilla
                     ;guile
                     package-management
                     password-utils
                     scheme
                     wm
                     video
                     certs
                     terminals
                     disk
                     xdisorg
                     web-browsers
                     version-control)

(define my-log-files
  ;; Log files that I want to rotate
  '("/var/log/mcron.log" "/var/log/slim-vt7.log"))

(define my-users
  ;; I enjoy naming my user user
  (cons* (user-account
                    (name "user")
                    (comment "user")
                    (group "users")
                    (home-directory "/home/user")
                    (supplementary-groups
                      '("docker" "wheel" "uucp" "netdev" "audio" "video" "lp")))
                  %base-user-accounts))

(define my-packages
  (append
   (list

  ;;; Fonts
    fontconfig
    gs-fonts
    font-dejavu
    font-google-noto
    font-gnu-freefont-ttf

  ;;; Emacs
    emacs
                                        ;emacs-all-the-icons
                                        ;emacs-use-package
                                        ;emacs-doom-themes
                                        ;emacs-doom-modeline
                                        ;emacs-guix
                                        ;emacs-next
                                        ;emacs-vterm
  ;;; Compilers and interpreters
    ;guile-3.0

  ;;; Window Manager
    sway
    swaybg
    swayidle
    swaylock
    bemenu

  ;;; Internet
    icecat

  ;;; Misc
    curl
    git
    keepassxc
    sicp ; https://guix.gnu.org/cookbook/en/guix-cookbook.html
    stow
    unzip
    alacritty
    ranger
    termite
    luakit
    youtube-dl
    mpv
    git

  ;;; For https access
    (specification->package "nss-certs")) 
   %base-packages))

;(define my-swap-devices
;  (swap-devices (list "/dev/sda1")))

(define my-keyboard-layout
  (keyboard-layout "gb"
                   #:model "thinkpad"
                   #:options '("ctrl:nocaps"))) ; for the console

(define my-bootloader-configuration
   (bootloader-configuration
    (bootloader grub-bootloader)
    (target "/dev/sda")
                                        ;(keyboard-layout my-keyboard-layout)
    ))

(define my-file-systems
  (cons* (file-system
           (mount-point "/")
           (device
             (uuid "84d53b85-ed03-48b1-a0dc-f49e7d88d173"
                   'ext4))
           (type "ext4"))
         %base-file-systems))

(operating-system
 (host-name "wreck-it")
 (timezone "Europe/London")
 (locale "en_GB.utf8")
 (keyboard-layout my-keyboard-layout)
 (users my-users)
 (name-service-switch %mdns-host-lookup-nss)
 (packages my-packages)
 (bootloader my-bootloader-configuration)
 (file-systems my-file-systems)
 ;(swap-devices my-swap-devices)

 (services
  (cons*
   (simple-service 'editor-config-service session-environment-service-type '(("EDITOR" . "emacsclient"))) ; https://wikemacs.org/wiki/Emacs_server
   (simple-service 'rotate-my-stuff
                   rottlog-service-type
                   (list (log-rotation
                          (frequency 'daily)
                          (files my-log-files))))
   (service openssh-service-type)
   (bluetooth-service #:auto-enable? #t)
   (service bitlbee-service-type (bitlbee-configuration
                                  (interface "127.0.0.1")
                                  (port 6667)
                                  (plugins '())))
   (service docker-service-type)
   (service singularity-service-type)
   (service auditd-service-type)
   (service thermald-service-type)
   (service tlp-service-type
            (tlp-configuration
             (tlp-enable? #t)
             (cpu-scaling-governor-on-ac (list "ondemand"))
             (cpu-scaling-governor-on-bat (list "powersave"))
             (energy-perf-policy-on-ac "performance")
             (energy-perf-policy-on-bat "powersave")
             (sched-powersave-on-ac? #t)
             (sched-powersave-on-bat? #t)))
   (service tor-service-type
            (tor-configuration
             (config-file (plain-file "tor-config"
                                      "SocksPort 127.0.0.1:9050\nHTTPTunnelPort 127.0.0.1:9250"))))
   (remove (lambda (service)
             (eq? (service-kind service) gdm-service-type))
           %desktop-services))))

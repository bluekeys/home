;; Modules

;; [[file:guix.org::*Modules][Modules:1]]
(use-modules (gnu)
             (guix))

(use-modules (srfi srfi-1) ; for 'remove' - https://guix.gnu.org/manual/en/html_node/X-Window.html
             (gnu services)
             (gnu services auditd)
             (gnu services desktop)
             (gnu services xorg)
             (gnu services docker)
             (gnu services messaging)
             (gnu services pm)
             (gnu system pam)
             (gnu system keyboard))

(use-package-modules emacs
                     emacs-xyz
                     compression
                     curl
                     fonts
                     fontutils
                     ghostscript
                     gnuzilla
                     guile
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
;; Modules:1 ends here

;; Service Modules

;; [[file:guix.org::*Service Modules][Service Modules:1]]
(use-service-modules admin base networking ssh)
;; Service Modules:1 ends here

;; Log files

;; [[file:guix.org::*Log files][Log files:1]]
(define my-log-files
  ;; Log files that I want to rotate
  '("/var/log/mcron.log" "/var/log/slim-vt7.log"))
;; Log files:1 ends here

;; Users

;; [[file:guix.org::*Users][Users:1]]
(define my-users
  ;; I enjoy naming my user user
  (cons* (user-account
                    (name "user")
                    (comment "user")
                    (group "users")
                    (home-directory "/home/user")
                    (supplementary-groups
                      '("docker" "wheel" "netdev" "audio" "video" "lp")))
                  %base-user-accounts))
;; Users:1 ends here

;; Packages

;; [[file:guix.org::*Packages][Packages:1]]
(define my-packages
  (append
   (list
    sway
    swaybg
    swayidle
    swaylock
    bemenu
    vim
    ranger
    termite
    luakit
    youtube-dl
    mpv
    nss-certs
    git

  ;;; Fonts
    fontconfig
    gs-fonts
    font-dejavu
    font-google-noto
    font-gnu-freefont-ttf
  ;;; Emacs
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
    emacs
    ;;emacs-exwm
    ;;emacs-xelb
    ;;arandr
    ;;xrandr
  ;;; Compositor
                                        ;     picom
  ;;; Internet
    icecat
    ;;ungoogled-chromium
  ;;; Misc
    ;;curl
    ;;git
    ;;keepassxc
    ;;sicp ; https://guix.gnu.org/cookbook/en/guix-cookbook.html
    ;;stow
    ;;unzip
  ;;; For https access
    (specification->package "nss-certs")) 
   %base-packages))
;; Packages:1 ends here

;; Bootloader

;; [[file:guix.org::*Bootloader][Bootloader:1]]
(bootloader
  (bootloader-configuration
    (bootloader grub-bootloader)
    (target "/dev/sda")
    (keyboard-layout keyboard-layout))) ; for grub
;; Bootloader:1 ends here

;; Swap

;; [[file:guix.org::*Swap][Swap:1]]
(swap-devices (list "/dev/sda1"))
;; Swap:1 ends here

;; Filesystem

;; [[file:guix.org::*Filesystem][Filesystem:1]]
(file-systems
  (cons* (file-system
           (mount-point "/")
           (device
             (uuid "84d53b85-ed03-48b1-a0dc-f49e7d88d173"
                   'ext4))
           (type "ext4"))
         %base-file-systems)))
;; Filesystem:1 ends here

;; Operating system definition

;; [[file:guix.org::*Operating system definition][Operating system definition:1]]
(operating-system
  (host-name "wreck-it")
  (timezone "Europe/London")
  (locale "en_GB.utf8")
  (keyboard-layout (keyboard-layout "gb"
                   #:model "thinkpad"
                   #:options '("ctrl:nocaps"))) ; for the console

  ;;(keyboard-layout (keyboard-layout "gb"))
  ;; (skeletons
  ;;  `((".bashrc" ,(plain-file "bashrc" "echo Hello\n"))
  ;;                (".guile" ,(plain-file "guile"
  ;;                                       "(use-modules (ice-9 readline))
  ;;                                        (activate-readline)"))))

  (users my-users)

  (name-service-switch %mdns-host-lookup-nss)

  (packages my-packages)


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
     ;(service slim-service-type (slim-configuration
                                 ;(display ":0")
                                 ;(vt "vt7")
                                 ;(xorg-configuration (xorg-configuration (keyboard-layout keyboard-layout))) ; https://issues.guix.info/37422
                                 ;(auto-login? #t)
                                 ;(default-user "user")
                                 ;))
     ;; (service slim-service-type (slim-configuration
     ;; 				 (display ":1")
     ;; 				 (vt "vt8")
     ;; 				 (xorg-configuration (xorg-configuration (keyboard-layout keyboard-layout))) ; https://issues.guix.info/37422
     ;; 				 (auto-login? #t)
     ;; 				 (default-user "user")
     ;; 				 ))
     ;; (set-xorg-configuration
     ;;  (xorg-configuration
     ;;   (keyboard-layout keyboard-layout)))
     (service tor-service-type
              (tor-configuration
               (config-file (plain-file "tor-config"
                                        "SocksPort 127.0.0.1:9050\nHTTPTunnelPort 127.0.0.1:9250"))))
     ;; (modify-services %base-services
     ;; 		      (guix-service-type
     ;; 		       config => (guix-configuration
     ;; 				  (inherit config)
     ;; 				  ;; ci.guix.gnu.org's Onion service
     ;; 				  (substitute-urls "https://bp7o7ckwlewr4slm.onion")
     ;; 				  (http-proxy "http://localhost:9250"))))
     (remove (lambda (service)
               (eq? (service-kind service) gdm-service-type))
             %desktop-services)))
  ;; (services
  ;;   (append
  ;;     (list ;;; (service mate-desktop-service-type)
  ;; 	    (simple-service 'editor-config-service session-environment-service-type '(("EDITOR" . "emacsclient"))) ; https://wikemacs.org/wiki/Emacs_server

  ;;           ;; (service tor-service-type (tor-configuration (config-file (plain-file "tor-config"
  ;;           ;;                              "HTTPTunnelPort 127.0.0.1:9050"))))

  ;; 	    ; https://unix.stackexchange.com/questions/617858/how-to-enable-bluetooth-in-guix

  ;; 	    ; (session-environment-service-type ()) ;under gnu system pam, currently undocumented
  ;;           (service openssh-service-type)
  ;; 	    (bluetooth-service #:auto-enable? #t)
  ;; 	    (service slim-service-type (slim-configuration
  ;; 					(display ":0")
  ;; 					(vt "vt7")))
  ;; 	    (service slim-service-type (slim-configuration
  ;; 					(display ":1")
  ;; 					(vt "vt8")))
  ;;           (set-xorg-configuration
  ;;             (xorg-configuration
  ;;              (keyboard-layout keyboard-layout))))
  ;;     %desktop-services))
;; Operating system definition:1 ends here

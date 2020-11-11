(setq user-mail-address	"aaron@madlon-kay.com"
	  user-full-name "Aaron Madlon-Kay")

(setq gnus-select-method
      '(nnimap "gmail"
	           (nnimap-address "imap.googlemail.com")
	           (nnimap-server-port "imaps")
	           (nnimap-stream ssl)))

(setq smtpmail-smtp-server "smtp.googlemail.com"
      smtpmail-smtp-service 587
      gnus-ignored-newsgroups "^to\\.\\|^[0-9. ]+\\( \\|$\\)\\|^[\"]\"[#'()]")

;; ibrowse-core.el --- Interact with your browser from Emacs -*- lexical-binding: t -*-

;; Copyright © 2022 Nicolas Graves <ngraves@ngraves.fr>

;; Author: Nicolas Graves <ngraves@ngraves.fr>
;; Version: 0.0.0
;; Package-Requires: ((emacs "24.3") (let-alist "1.0.4") (seq "1.11") (dash "2.12.1"))
;; Keywords: browser, tabs, switch
;; URL: https://git.sr.ht/~ngraves/ibrowse.el

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.
;;
;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <https://www.gnu.org/licenses/>.

;;; Commentary:
;; Interact with your browser from Emacs

;;; Code:

;;; Variables

(defconst ibrowse--cdp-remote-debugging-port
  "9222")

(defun ibrowse--cdp-url (query)
  "Returns the url of the chromium json list of tabs."
  (format "http://localhost:%s/json/%s"
          ibrowse--cdp-remote-debugging-port
          query))

;; Change this variable to use another profile.
(defvar ibrowse-default-folder-name "Default")

(defvar ibrowse-chromium-base-folder-list
  '("~/.config/google-chrome"
    "~/.config/chromium"
    "$LOCALAPPDATA/Google/Chrome/User Data"
    "$LOCALAPPDATA/Chromium/User Data"
    "$USERPROFILE/Local Settings/Application Data/Google/Chrome/User Data"
    "$USERPROFILE/Local Settings/Application Data/Chromium/User Data"
    "$LOCALAPPDATA/Microsoft/Edge/User Data"
    "$USERPROFILE/Local Settings/Application Data/Microsoft/Edge/User Data"
    "~/Library/Application Support/Google/Chrome"
    "~/Library/Application Support/Chromium"
    "~/.config/vivaldi"
    "$LOCALAPPDATA/Vivaldi/User Data"
    "$USERPROFILE/Local Settings/Application Data/Vivaldi/User Data"
    "~/Library/Application Support/Vivaldi"
    "~/AppData/Local/Google/Chrome/User Data/Default/"))

(defun ibrowse-guess-default-folder ()
  (car
   (seq-sort
    #'file-newer-than-file-p
    (seq-filter
     (lambda (p)
       (substitute-in-file-name
        (concat p "/" ibrowse-default-folder-name "/History")))
     ibrowse-chromium-default-folder-list))))

(defvar ibrowse-chromium-default-folder (ibrowse-guess-default-folder)
  "Chromium-based browsers profile folder.")

;;; Functions

(defun ibrowse--file-check (filename)
  "Check if the ibrowse-history-file exists."
  (pcase (concat ibrowse-chromium-default-folder filename)
    ('nil (user-error "`ibrowse-history-file' is not set"))
    ((pred file-exists-p) nil)
    (f (user-error "'%s' doesn't exist, please reset `ibrowse-history-file'" f))))

(defun ibrowse-action--first->third (selected candidates &rest _)
  (caddr (assoc selected candidates)))

(defun ibrowse-action--first->second (selected candidates &rest _)
  (cadr (assoc selected candidates)))

(defun ibrowse-action-open-url (url)
  (url-retrieve-synchronously (ibrowse--cdp-url (concat "new?" url))))

(defun ibrowse-action-item-by-name (prompt get-candidates convert action)
  "Call the function ACTION on the id selected from the function
GET-CANDIDATES."
  (let* ((candidates    (funcall get-candidates))
         (selected-name (completing-read prompt candidates))
         (selected-id   (funcall convert selected-name candidates)))
    (funcall action selected-id)))

(provide 'ibrowse-core)
;;; ibrowse-core.el ends here

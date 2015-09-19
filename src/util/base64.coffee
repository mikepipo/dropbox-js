# Modern browsers and Web workers.

# NOTE: atob/btoa will crash in some browsers if not called on window
Dropbox.Util.atob = (string) -> Dropbox.Env.global.atob string
Dropbox.Util.btoa = (base64) -> Dropbox.Env.global.btoa base64

# OAuth driver that uses a Electron InAppBrowser to complete the flow.
class Dropbox.AuthDriver.Electron extends Dropbox.AuthDriver.BrowserBase
  # Sets up an OAuth driver for Electron applications.
  #
  # @param {Object} options (optional) one of the settings below
  # @option options {String} scope embedded in the localStorage key that holds
  #   the authentication data; useful for having multiple OAuth tokens in a
  #   single application
  # @option options {Boolean} rememberUser if false, the user's OAuth tokens
  #   are not saved in localStorage; true by default
  constructor: (options) ->
    super options

# URL of the page that the user will be redirected to.
#
# @return {String} a page on the Dropbox site that will not redirect; this is
#   not a new point of failure, because the OAuth flow already depends on
#   the Dropbox site being up and reachable
# @see Dropbox.AuthDriver#url
  url: ->
    'https://www.dropbox.com/1/oauth2/redirect_receiver'

# Shows the authorization URL in a pop-up, waits for it to send a message.
#
# @see Dropbox.AuthDriver#doAuthorize
  doAuthorize: (authUrl, stateParam, client, callback) ->
    closed = false
    win = window.require('electron').remote.app.openWindow({
      show: false,
      webPreferences: {
        nodeIntegration: false,
        webSecurity: false,
        allowDisplayingInsecureContent: true,
        allowRunningInsecureContent: true
      }
    })
    win.loadURL(authUrl)
    win.show()
    win.webContents.on 'did-finish-load', =>
      url = win.webContents.getURL()
      if @locationStateParam(url) is stateParam
        return if closed
        closed = true
        win.close()
        callback Dropbox.Util.Oauth.queryParamsFromUrl(url)
    win.on 'closed', () =>
      win = null
      return if closed
      callback new Dropbox.AuthError({ error: 'access_denied', error_description: 'User closed browser window' })


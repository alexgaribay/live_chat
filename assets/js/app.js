// We need to import the CSS so that webpack will load it.
// The MiniCssExtractPlugin is used to separate it out into
// its own CSS file.
import css from "../css/app.css"

// webpack automatically bundles all modules in your
// entry points. Those entry points can be configured
// in "webpack.config.js".
//
// Import dependencies
//
import "phoenix_html"

// Import local files
//
// Local files can be imported directly using relative paths, for example:
// import socket from "./socket"
import EmojiConvertor from "emoji-js"
import LiveSocket from "phoenix_live_view"

let Hooks = {}
Hooks.NewMessage = {
  mounted(){
    let messages = document.querySelector(".main")
    if((messages.scrollTop + messages.offsetHeight + this.el.offsetHeight) >= messages.scrollHeight){
      messages.scrollTop = messages.scrollHeight;
    }
    this.emojify()
  },
  updated(){
    this.emojify()
  },
  emojify(){
    let emoji = new EmojiConvertor
    emoji.addAliases({
      'thinking' : '1f914'
    });
    // Emojify on mount hook
    let messageHTML = this.el.getElementsByTagName("p")[0]
    if (messageHTML) {
      messageHTML.innerHTML = emoji.replace_colons(messageHTML.innerHTML)
    }
  }
}
let liveSocket = new LiveSocket("/live", {hooks: Hooks})
liveSocket.connect()

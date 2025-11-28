import {Socket} from "phoenix"

// This file is not needed for the LiveView integration ate the moment, ive set it up with hooks instead

let socket = new Socket("/socket", {
  params: {token: window.userToken},
  logger: (kind, msg, data) => { console.log(`${kind}: ${msg}`, data) }
})

socket.connect()

export default socket
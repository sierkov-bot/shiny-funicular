// NOTE: The contents of this file will only be executed if
// you uncomment its entry in "assets/js/app.js".

// Bring in Phoenix channels client library:
import {Socket} from "phoenix"

// And connect to the path in "lib/tilewars_web/endpoint.ex". We pass the
// token for authentication. Read below how it should be used.
let socket = new Socket("/ws", {params: {}})

// When you connect, you'll often need to authenticate the client.
// For example, imagine you have an authentication plug, `MyAuth`,
// which authenticates the session and assigns a `:current_user`.
// If the current user exists you can assign the user's token in
// the connection for use in the layout.
//
// In your "lib/tilewars_web/router.ex":
//
//     pipeline :browser do
//       ...
//       plug MyAuth
//       plug :put_user_token
//     end
//
//     defp put_user_token(conn, _) do
//       if current_user = conn.assigns[:current_user] do
//         token = Phoenix.Token.sign(conn, "user socket", current_user.id)
//         assign(conn, :user_token, token)
//       else
//         conn
//       end
//     end
//
// Now you need to pass this token to JavaScript. You can do so
// inside a script tag in "lib/tilewars_web/templates/layout/app.html.heex":
//
//     <script>window.userToken = "<%= assigns[:user_token] %>";</script>
//
// You will need to verify the user token in the "connect/3" function
// in "lib/tilewars_web/channels/user_socket.ex":
//
//     def connect(%{"token" => token}, socket, _connect_info) do
//       # max_age: 1209600 is equivalent to two weeks in seconds
//       case Phoenix.Token.verify(socket, "user socket", token, max_age: 1_209_600) do
//         {:ok, user_id} ->
//           {:ok, assign(socket, :user, user_id)}
//
//         {:error, reason} ->
//           :error
//       end
//     end
//
// Finally, connect to the socket:
socket.connect()

const nameInput = document.querySelector("#nameInput_name")
const joinButton = document.querySelector("#join")

joinButton.addEventListener("click", event => {
    channel.push("spawn", nameInput.value)
    window.location = "/game/"+nameInput.value
})

let channel = socket.channel("game:lobby", {})
channel.join()
    .receive("ok", resp => { console.log("Joined successfully", resp) })
    .receive("error", resp => { console.log("Unable to join", resp) })

// channel.on("spawn", payload => nameInput.value)

channel.on("state", (response) => {
    // update grid
    drawPlayers(response);
    drawWalls(response["walls"]);
})

const container = document.getElementById("grid");

function bindKeys() {
    document.addEventListener("keydown", function(event) {
        if (event.key === "d") {
            channel.push("move", {name: nameInput.value, direction: 0})
        }
        if (event.key === "h") {
            channel.push("move", {name: nameInput.value, direction: 1})
        }
        if (event.key === "s") {
            channel.push("move", {name: nameInput.value, direction: 2})
        }
        if (event.key === "a") {
            channel.push("move", {name: nameInput.value, direction: 3})
        }
        if (event.key === "t") {
            channel.push("attack", nameInput.value)
        }

    })
}

function makeRows(rows, cols) {
  container.style.setProperty('--grid-rows', rows);
  container.style.setProperty('--grid-cols', cols);
  for (c = 0; c < (rows * cols); c++) {
    let cell = document.createElement("div");
    cell.innerText = " ";
    container.appendChild(cell).className = "grid-item";
  };
    bindKeys();
};

function drawWalls(walls) {
    let grid = document.getElementById("grid")
    let divs = document.querySelectorAll(".wall").forEach(el => el.remove())
    walls.forEach((w) => {
        const wall = document.createElement("div")
        wall.className = 'wall'
        let position = ++w[0]+(w[1]*10)
        let cell = document.querySelector(".grid-item:nth-child("+position+")")
        cell.appendChild(wall)
    })


}

function despawn() {
    channel.push("terminate", nameInput.value)
}

function drawPlayers(players) {
    let grid = document.getElementById("grid")
    let divs = document.getElementsByClassName("player")
    document.querySelectorAll(".player").forEach(el => el.remove())
    for (let p in players["players"]) {
        let grid = document.querySelector("#grid")
        let plr = players["players"][p]
        let name = plr.name
        let status = plr.status
        let pos = plr.position
        let me = nameInput.value
        let self = plr.name === me ? " self" : ""
        const plrDiv = document.createElement("div")
        plrDiv.style.width = ''
        plrDiv.textContent = plr.name
        plrDiv.className = 'player ' + plr.status + self
        let position = ++pos[0]+(pos[1]*10)
        let cell = document.querySelector(".grid-item:nth-child("+position+")")
        cell.appendChild(plrDiv)
    }
};

if (container) {
    makeRows(10, 10);
    let quitbutton = document.getElementById("quitButton")
    quitbutton.addEventListener("click", event => {
        despawn()
    })
}

export default socket

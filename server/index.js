var app = require('http').createServer()

app.listen(8900)
console.log("Listening on 8900")

function Player(socket) {
    var self = this
    this.socket = socket
    this.name = ""
    this.game = {}

    this.socket.on('disconnect', function () {
        console.log(self.name+' disconnected')
        self.game.nullPlayer(self);
    });

    this.socket.on('chatMessage', function (msg, name) {
        self.game.sendMessage(msg, name);
    })

    this.socket.on("playerMove", function (x, y, dx, dy) {
        self.game.playerMove(self, x, y, dx, dy)
    })
}

Player.prototype.joinGame = function (game) {
    this.game = game
}

function Game() {
    this.io = require('socket.io')(app)
    // this.board = [
    //     ["", "", ""],
    //     ["", "", ""],
    //     ["", "", ""]
    // ]
    this.playerBottom = null
    this.playerTop = null
    this.currentTurn = "bottom"
    this.moveCount = 0
    this.started = false
    this.addHandlers()
}

Game.prototype.addHandlers = function () {
    var game = this

    this.io.sockets.on("connection", function (socket) {
        game.addPlayer(new Player(socket))
    })
}

Game.prototype.addPlayer = function (player) {
    if (this.playerBottom === null) {
        this.playerBottom = player
        this.playerBottom["game"] = this
        this.playerBottom["name"] = "bottom"
        console.log("Connected player bottom")
        this.playerBottom.socket.emit("name", "bottom")
    } else if (this.playerTop === null) {
        this.playerTop = player
        this.playerTop["game"] = this
        this.playerTop["name"] = "top"
        console.log("Connected player top")
        this.playerTop.socket.emit("name", "top")
        this.startGame()
    }
}

Game.prototype.announceWin = function (player) {
    if (this.playerBottom === player) {
        if (![null,undefined].includes(this.playerBottom)) {
            this.playerBottom.socket.emit("win")
        }
        if (![null,undefined].includes(this.playerTop)) {
            this.playerTop.socket.emit("lose")
        }
    } else if (this.playerTop === player) {
        if (![null,undefined].includes(this.playerBottom)) {
            this.playerBottom.socket.emit("lose")
        }
        if (![null,undefined].includes(this.playerTop)) {
            this.playerTop.socket.emit("win")
        }
    }
    this.playerBottom = null
    this.playerTop = null
}

Game.prototype.nullPlayer = function(player) {
    if (this.playerBottom === player) {
        this.announceWin(this.playerTop)
    } else if (this.playerTop === player) {
        this.announceWin(this.playerBottom)
    }
}

Game.prototype.gameOver = function () {
    this.playerBottom.socket.emit("gameOver")
    this.playerTop.socket.emit("gameOver")
}

Game.prototype.sendMessage = function (msg, name) {
    this.playerBottom.socket.emit('chatMessage', msg, name);
    this.playerTop.socket.emit('chatMessage', msg, name);
}

Game.prototype.playerMove = function (player, originX, originY, destinyX, destinyY) {
    if (player["name"] !== this.currentTurn) { //|| x >= 3 || y >= 3) {
        return
    }
    
    if (player["name"] === "bottom") {
        this.playerTop.socket.emit("playerMove", player["name"], originX, originY, destinyX, destinyY)
    } else {
        this.playerBottom.socket.emit("playerMove", player["name"], originX, originY, destinyX, destinyY)
    }
  
    this.moveCount++

    if (player["name"] === "bottom") {
        this.currentTurn = "top"
        this.playerBottom.socket.emit("currentTurn", "top")
        this.playerTop.socket.emit("currentTurn", "top")
    } else {
        this.currentTurn = "bottom"
        this.playerBottom.socket.emit("currentTurn", "bottom")
        this.playerTop.socket.emit("currentTurn", "bottom")
    }
}

Game.prototype.startGame = function () {
    this.playerBottom.socket.emit("startGame")
    this.playerTop.socket.emit("startGame")
}

// Start the game server
var game = new Game()

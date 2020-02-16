var app = require('http').createServer()

app.listen(8900)
console.log("Listening on 8900")

function Player(socket) {
    var self = this
    this.socket = socket
    this.name = ""
    this.game = {}

    this.socket.on('disconnect', function () {
        console.log('disconnected')
        // self.game.disconnectPlayers();
    });

    this.socket.on('chatMessage', function (msg, name) {
        self.game.sendMessage(msg, name);
    })

    this.socket.on("playerMove", function (x, y) {
        self.game.playerMove(self, x, y)
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
        console.log('Connection!')
        game.addPlayer(new Player(socket))
    })
}

Game.prototype.addPlayer = function (player) {
    console.log("adding player")
    if (this.playerBottom === null) {
        this.playerBottom = player
        this.playerBottom["game"] = this
        this.playerBottom["name"] = "bottom"
        this.playerBottom.socket.emit("name", "bottom")
    } else if (this.playerTop === null) {
        this.playerTop = player
        this.playerTop["game"] = this
        this.playerTop["name"] = "top"
        this.playerTop.socket.emit("name", "top")
        this.startGame()
    }
}

Game.prototype.announceWin = function (player, type) {
    this.playerBottom.socket.emit("win", player["name"], type)
    this.playerTop.socket.emit("win", player["name"], type)
    this.resetGame()
}

// Game.prototype.disconnectPlayers = function() {
//     this.playerBottom = null
//     this.playerTop = null
// }

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

    this.playerBottom.socket.emit("playerMove", player["name"], originX, originY, destinyX, destinyY)
    this.playerTop.socket.emit("playerMove", player["name"], originX, originY, destinyX, destinyY)
    //this.board[originX][originY] = player["name"]

    // var n = 3
    //     //check row
    // for (var i = 0; i < n; i++) {
    //     if (this.board[x][i] !== player["name"]) {
    //         break
    //     }

    //     if (i === n - 1) {
    //         this.announceWin(player, {
    //             type: "row",
    //             num: x
    //         })
    //         return
    //     }
    // }

    // // Check col
    // for (var i = 0; i < n; i++) {
    //     if (this.board[i][y] !== player["name"]) {
    //         break
    //     }

    //     if (i === n - 1) {
    //         this.announceWin(player, {
    //             type: "col",
    //             num: y
    //         })
    //         return
    //     }
    // }

    // // Check diags
    // if (x === y) {
    //     for (var i = 0; i < n; i++) {
    //         if (this.board[i][i] !== player["name"]) {
    //             break
    //         }

    //         if (i == n - 1) {
    //             this.announceWin(player, {
    //                 type: "diag",
    //                 coord: {
    //                     x: x,
    //                     y: y
    //                 },
    //                 anti: false
    //             })
    //             return
    //         }
    //     }
    // }

    // for (var i = 0; i < n; i++) {
    //     if (this.board[i][(n - 1) - i] !== player["name"]) {
    //         break
    //     }

    //     if (i === n - 1) {
    //         this.announceWin(player, {
    //             type: "diag",
    //             coord: {
    //                 x: x,
    //                 y: y
    //             },
    //             anti: true
    //         })
    //         return
    //     }
    // }

    // if (this.moveCount === (Math.pow(n, 2) - 1)) {
    //     this.playerBottom.socket.emit("draw")
    //     this.playerTop.socket.emit("draw")
    //     this.resetGame()
    //     return
    // }

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

Game.prototype.resetGame = function () {
    var self = this
    var player1Ans = null
    var player2Ans = null

    var reset = function () {
        if (player1Ans === null || player2Ans === null) {
            return
        } else if ((player1Ans & player2Ans) === 0) {
            self.gameOver()
            process.exit(0)
        }

        self.board = [
            ["", "", ""],
            ["", "", ""],
            ["", "", ""]
        ]
        self.moveCount = 0

        if (self.playerBottom["name"] === "X") {
            self.playerBottom["name"] = "O"
            self.playerBottom.socket.emit("name", "O")
            self.playerTop["name"] = "X"
            self.playerTop.socket.emit("name", "X")
        } else {
            self.playerBottom["name"] = "X"
            self.playerBottom.socket.emit("name", "X")
            self.playerTop["name"] = "O"
            self.playerTop.socket.emit("name", "O")
        }

        self.startGame()
    }

    this.playerBottom.socket.emit("gameReset", function (ans) {
        player1Ans = ans
        reset()
    })
    this.playerTop.socket.emit("gameReset", function (ans) {
        player2Ans = ans
        reset()
    })
}

Game.prototype.startGame = function () {
    this.playerBottom.socket.emit("startGame")
    this.playerTop.socket.emit("startGame")
}

// Start the game server
var game = new Game()

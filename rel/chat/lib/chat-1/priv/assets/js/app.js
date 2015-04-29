/*globals $, document, window*/
function disruptApp(document, window, $) {

    var input = document.getElementById('input'),
        output = document.getElementById('output'),
        nickInput = document.getElementById('nick'),
        send = document.getElementById('send'),

        connection;

    // send message
    function sendMessage(text) {
        connection.send(getName() + ': ' + text);
    }

    function onSendButton() {
        var text = input.value.trim();

        if (text !== '') {
            sendMessage(text);
        }

        input.value = '';
    }

    function getName() {
        var nick = nickInput.value.trim();

        if (nick === '') {
            return 'anonymous';
        } else {
            return nick;
        }
    }

    function notify(text) {
        var date = (new Date()).toLocaleString();
        output.innerHTML = output.innerHTML + '[' + date + '] ' + text + '\n';
    }

    function onData(data) {
        notify(data);
    }

    send.addEventListener('click', onSendButton);

    function start(url, options, notify, onData) {
        var connection = $.bullet(url, options);

        // Connection established
        connection.onopen = function(){
            notify('Welcome ' + getName());
        };

        // Connection closed
        connection.onclose = connection.ondisconnect = function(){
            notify('Disconnected');
        };

        // Message received
        connection.onmessage = function(e){
            if (e.data !== 'ping responce') {
                onData(e.data);
            }
        };

        // ping request --> ping responce should received
        connection.onheartbeat = function(){
            connection.send('ping');
        };

        return connection;
    }

    connection = start('ws://localhost:8000/chat', {}, notify, onData);
}

document.addEventListener("DOMContentLoaded", function() {
    disruptApp(document, window, $);
});
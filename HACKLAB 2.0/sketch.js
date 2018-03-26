var talk = new p5.Speech();
var listen = new p5.SpeechRec;

var bot; //variable to hold the chat box
var a,b,q;

function setup(){
  createCanvas(600,600);
  background(0);

b= select('#submit');
q= select('#user');
a= select('#response');
b.mousePressed(chatBot); //when button pressed run the chatbot function

bot = new RiveScript();
bot.loadFile("./brain.rive",botReady,botError); //2 functions

talk.speak("Hello, you are talking to your mum"); //say something to begin
listen.continuous = true; //constant listen
listen.onResult = showResult;
listen.start();
}

function botReady(){
  bot.sortReplies();
  }

function botError(){
  }

  function chatBot(){
    var question = q.value(); //get what is written in that
    var reply = bot.reply('local-user',question);

    a.value(reply);
    talk.speak(reply);
  }

function draw (){
  fill( random(255), random(255), random(255),random(255));
  rect(mouseX,mouseY,50,50);
}

function showResult(){
  //output what we just said to the console or the window
  console.log(listen.resultString);

  q.value(listen.resultString);
  chatBot();
}

function keyPressed(){
}

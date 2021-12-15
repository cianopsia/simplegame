/** Alva Vidal
* Credits:
* Class and arrayList made based on aadebdeb de Processing Forum y OpenProcessing, attribution open license
* Icono de jugador principal retirado de https://www.flaticon.com/authors/smashicons 
* Icono de enemigo retirado de https://www.flaticon.com/authors/smalllikeart
* Code commentaries in spanish.
*/


PImage imgM; 
PImage imgE;
Myself myself; //Declaramos el objeto myself de una clase creada por nosotros
ArrayList<Enemy> enemies; //Declaramos los invasores que irán apareciendo en el juego como elementos de un un arrayList (dinámico y con elementos que se añaden y quitan facilmente
ArrayList<Bullet> myBullets; //Declaramos nuestros disparos al enemigo como elementos de un arrayList
ArrayList<Bullet> eneBullets; //Declaramos los disparos del enemigo como elementos de un arrayList

//INICIALIZACIÓN

void setup(){
  size(640, 640); //Definimos la escena
  rectMode(CENTER);
  imgM = loadImage("myself.png");
  imgE = loadImage("enemy.png");
  myself = new Myself(); //Llamamos al objeto que contiene nuestro jugador
  enemies = new ArrayList<Enemy>(); //y una instancia nueva de cada uno de los demás arrays
  myBullets = new ArrayList<Bullet>();
  eneBullets = new ArrayList<Bullet>(); 
}

//PROGRAMA
void draw(){
  background(0);
  myself.display(); //mostramos nuestro jugador por pantalla usando la función display() que definiremos más adelante
  for(Enemy enemy: enemies){ //Iteramos sobre el arrayList "Enemy" con un enhanced loop - idéntico a usar un for loop normal y marcar el índice [i]
    enemy.display(); //mostramos el elemento
  }
  for(Bullet bullet: myBullets){ //Hacemos lo mismo con los demás arrays
    bullet.display();
  }
  for(Bullet bullet: eneBullets){
    bullet.display();
  }

  myself.update(); //llamamos la función update() que definiremos más adelante
  
  ArrayList<Enemy> nextEnemies = new ArrayList<Enemy>(); //creamos un nuevo objeto para los enemigos nuevos que se van creando
  for(Enemy enemy: enemies){  //Creamos el bucle que itera sobre los enemigos, actualiza el estado de los elementos
    enemy.update();
    if(!enemy.isDead){ //y continúa añadiendo nuevos enemigos mientras el enemigo no está en estado isDead = true
      nextEnemies.add(enemy);
    }
  }
  enemies = nextEnemies; //Asignamos el nuevo arrayList de siguientes enemigos como valor del arrayList base creado para los enemigos
  
  ArrayList<Bullet> nextMyBullets = new ArrayList<Bullet>(); //Procedemos de la misma forma con los disparos del jugador principal
  for(Bullet bullet: myBullets){ 
    bullet.update();
    if(!bullet.isDead){ 
      nextMyBullets.add(bullet); 
    }
  }
  myBullets = nextMyBullets;
  
  ArrayList<Bullet> nextEneBullets = new ArrayList<Bullet>(); //Procedemos de la misma forma con los disparos de los enemigos
  for(Bullet bullet: eneBullets){
    bullet.update();
    if(!bullet.isDead){
      nextEneBullets.add(bullet);
    }
  }
  eneBullets = nextEneBullets;
  if(random(1) < 0.02){ //Controlamos la frecuencia en la que añadimos enemigos (podemos añadir más dificultad al juego reduciendo el 1 a un real menor)
    enemies.add(new Enemy()); 
  }
}



//CLASE JUGADOR PRINCIPAL (MYSELF)
class Myself{
  
  //Añadimos un objeto PVector (muy usado en shooting games o en ejemplos de Forum Processing para describir posición, velocidad o aceleración) 
  PVector loc; //Aquí lo usamos como varible que contiene la localización
  float size; //declaramos una variable para el tamaño
  int coolingTime; //una variable para controlar el tiempo que tenemos para volver a disparar despues de recibir un disparo del enemigo
  boolean isDead; //y una variable de valor booleano para controlar el estado de algunos elementos como los enemigos o los disparos
  float R = random(80); //Creamos variables para almacenar valores aleatorios RGB
  float G = random (155);
  float B = random (155); 
  
  Myself(){ //Definimos el objeto Myself
    size = 25; 
    loc = new PVector(width / 2, height - size / 2 - 10);
    coolingTime = 0; 
    isDead = false; //inicializamos su estado como "not dead"
  }
  
  //FUNCIÓN MOSTRAR
  void display(){ //En la función mostrar definimos los atributos gráficos 
    if(isDead){ //Y el mensaje mostrado en pantalla si el estado cambia a muerto
      fill(255, 0, 0);
      stroke(255, 0, 0);
      ellipse(loc.x, loc.y, 40, 40);
      textSize(50);
      text("OUCH",300,300); //mensaje de que hemos sido disparados
    } else {
      fill(R,G,B);
      stroke(0, 255, 0);
    }
    image(imgM, loc.x-17,loc.y-15); //Creamos la forma de nuestro jugador llamando a la imagen previamente subida
    imgM.resize(35,35);
    
  }
  
  void update(){ //en la función Update definimos el comportamiento del jugador
    isDead = false; //iniciamos isDead con el valor false; el jugador está libre de impacto por defecto
    float dmx = mouseX - loc.x; //Creamos una variable para hacer que la figura del jugador se mueva con la posición del mouse
    dmx = constrain(dmx, -15, 15); //Aquí definimos el delay en el que la figura se mueve en relación al movimiento del mouse
    loc.x += dmx;
    coolingTime++; //Incrementamos el cooling time
    if(mousePressed && coolingTime >= 50){ //Definimos que si intentamos disparar(mousePressed) y el cooling time ya ha pasado, podemos realizar más disparos
      myBullets.add(new Bullet());
      coolingTime = 0; //Y reiniciamos el cooling time
    }
    for(Bullet b: eneBullets){
      if((loc.x - size / 2 <= b.loc.x && b.loc.x <= loc.x + size / 2) //Definimos que cada vez que los disparos impacten en donde se encuentra el jugador, se cambie el valor de isDead a true
         && (loc.y - size / 2 <= b.loc.y && b.loc.y <= loc.y + size / 2)){
        isDead = true;
        b.isDead = true;
        break;
      }
    }
    for(Enemy e: enemies){ //Lo mismo para Enemies
      if(abs(loc.x - e.loc.x) < size / 2 + e.size / 2 && abs(loc.y - e.loc.y) < size / 2 + e.size / 2){
        isDead = true;
        e.isDead = true;
        break;
      }
    }
  }
}

//CLASE DISPARO
class Bullet{
  
  //Definimos las variables
  PVector loc;  //loc para localización
  float vel; //para velocidad
  boolean isMine; //dos booleanos para controlar el estado
  boolean isDead;
  
  //Definimos el disparo del jugador
  Bullet(){
    loc = new PVector(myself.loc.x, myself.loc.y); //Con un vector que se inicia en donde se encuentra en lugador
    vel = -12; //definimos la velocidad
    isMine = true; //la asignamos como nuestra (del jugador)
  }
  
  //Definimos el disparo del enemigo
  Bullet(Enemy enemy){ 
    loc = new PVector(enemy.loc.x, enemy.loc.y); //Que es lanzada desde donde se encuentra cada enemigo
    vel = 6; //Definimos una velocidad más lenta de sus disparos
    isMine = false; //La asignamos al enemigo mediante la variable isMine
  }
  
  void display(){ //Cambiamos el aspecto de los disparos en función de si son del enemigo o nuestras
    if(isMine){ 
      stroke(0, 0, 255); //si son del jugador las hacemos azules
    } else {
      stroke(255, 0, 0); //y si no las hacemos rojas
    }
    line(loc.x, loc.y, loc.x, loc.y + vel);    //las dibujamos como una línea vertical con propiedades definidas por las variables de localización y velocidad definidas anteriormente
  }

  void update(){ //definimos algunos aspectos del comportamiento del disparo
    loc.y += vel; 
    if((vel > 0 && loc.y > height) || (vel < 0 && loc.y < 0)){ 
      isDead = true; //cambiamos el estado a muerto 
    }
  }  
}

//CLASE ENEMIGO
class Enemy{
  
  //Definimos al enemigo siguiendo la misma pauta que al jugador principal 
  PVector loc;
  float vel;
  float size;
  int coolingTime;
  boolean isDead;
  
  Enemy(){ //Definimos sus aspectos básicos
    size = 25;
    loc = new PVector(random(size / 2, width - size / 2), -size / 2);
    vel = 3;
    coolingTime = int(random(60));
    isDead = false;
  }
  
  void display(){ //definimos su apariencia
    image(imgE, loc.x-17,loc.y-15); //Creamos la forma de los enemigos llamando a la imagen previamente subida
    imgE.resize(40,40);
  }

  void update(){ //Definimos su comportamiento
    loc.y += vel;
    if(loc.y > height){ 
      isDead = true; //cambiamos el estado cuando el enemigo ha llegado a la base de la imagen sin haber sido disparado por el jugador
    }
    coolingTime++; //incrementamos el cooling time
    if(coolingTime >= 60){ //Definimos la frecuencia de disparo
      eneBullets.add(new Bullet(this)); //si ya ha pasado el cooling time, creamos un nuevo disparo
      coolingTime = 0; //y reiniciamos el contador de cooling time
    }
    for(Bullet b: myBullets){
      if((loc.x - size / 2 <= b.loc.x && b.loc.x <= loc.x + size / 2)
         && (loc.y - size / 2 <= b.loc.y && b.loc.y <= loc.y + size / 2)){ //Si los disparos del jugador llegan al enemigo
        fill(0,0,255);
        textSize(50);
        text("SHOT!",280,300); //Mostramos el mensaje de enemigo disparado
        isDead = true; //y cambiamos el estado a muerto
        b.isDead = true;
        break;
      }
    }
  }    
}




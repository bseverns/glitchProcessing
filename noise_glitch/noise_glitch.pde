//noise glitch
//created by Myrto Amorgianou
PImage img;
PImage otherImage;
String name = "smallsnarl"; //file name
int count;
String type = "jpg"; //file type

void setup(){
 size(800,800); 
  img=loadImage("smallsnarl.jpg");
  
}

void draw(){
  image(img,0,0,800,800); //set the initial image
       delay(1000);

  for (int x=0; x<800;x+=1){
    
   otherImage=img.get(int(random(0,200)),int(random(600,800)),200,200); //get a random piece of the initial image
    
    //   otherImage=img.get(x*50, x*130,200,200); //get a random piece of the initial image
    // image(otherImage,random(0,800),random(0,800),20,20); //put the generated image randomly - small squares
     img.copy(img,int(random(0,800)),int(random(0,600)),int(random(0,800)),int(random(0,800)),int(random(0,800)),int(random(0,800)),int(random(0,200)),int(random(0,200)));
       image(otherImage,random(0,800),random(0,800),200,200); //put the generated image randomly - big squares
    println(x);
     count = int(random(666));
  }
}
  
 // export
void keyPressed() {
  if (key == 's') {
    save(name + "_" + count + "." + type);
    println("export");
  }
}
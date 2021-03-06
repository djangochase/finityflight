primaryLaserCannon <- null;

class GiantLaser
{
	name="";
	owner=null;
	x=0;
	y=0;
	r=0;
	beaconNum = 0;
	
	weaponActive = true;
	
	cooldown = 0;
	secondaryCooldown = 0;
	refire = 1.00;
	currentLaserTime = 0.0;
	textureCounter = 0.0;
	laserRadius = 40.0;

	damage = 10.0;
	laserLifespan = 0.6;
	laserLength = 2000;
	
	
	constructor(name,x,y,r)
	{
		this.name = name;
		this.x = x;
		this.y = y;
		this.r = r;
	}

	function update(t)
	{
	
		if(::primaryLaserCannon == this)
		{
			::primaryLaserCannon = null;
		}
		cooldown -= t;
		if(cooldown<0)
			cooldown = 0;
		secondaryCooldown -= t;
		if(secondaryCooldown < 0)
			secondaryCooldown = 0;
		currentLaserTime -= t;
		if(currentLaserTime < 0)
			currentLaserTime = 0;	
	
		if(currentLaserTime > 0)	//If true, laser is firing.
		{
			local laserStartPos = add2(owner.pos, rotateDegrees2([this.x, this.y-30], r + owner.r));
			local laserDirection = setDegrees2(r + owner.r);
			
			local collidesList = ::level.friends.collides(0, laserStartPos, laserDirection, laserLength, laserRadius);
			foreach(node in collidesList)
			{
				local dyne = node.dyne;
				if(node.collType == 1)
				{
					dyne.mods[4]["shield"].damage(damage, 2);
				}
				else
				{
					local dir = scale2(laserDirection,damage*3);
					dyne.mods[1]["ship"].damage(damage,dir);
				}
			}
		}
			
		return true;
	}

	function draw(t)
	{
		if (currentLaserTime > 0)
		{
			local laserStartPos = [this.x, this.y-30];
			local laserForward = setDegrees2(r);
			local laserEndPos = scale2(laserForward, laserLength);
			local laserRight = quarterCW2(laserForward);
			local laserDrawRadius = scale2(laserRight,laserRadius*2);
			local laserExpand = laserLength / 300.0;
			
			local br = add2(laserStartPos,laserDrawRadius);
			local bl = sub2(laserStartPos,laserDrawRadius);
			local tr = add2(laserEndPos,laserDrawRadius);
			local tl = sub2(laserEndPos,laserDrawRadius);
			
			
			additiveBlending(true);
			image(getArcadePrefix("FinityFlight")+"data/Laser.png",1,1);
			local alpha = 1;
			if(currentLaserTime<0.2) {
				alpha = currentLaserTime/0.2;
			}
			//fillColor(0.9,0.8,1,alpha*0.6);
			fillColor(0.7,0.9,0.3,alpha);
			
			beginTriangles();
			textureCoord(0,textureCounter);
			vertex(br[0],br[1]);
			textureCoord(1,textureCounter);
			vertex(bl[0],bl[1]);
			textureCoord(1,textureCounter+4);
			vertex(tl[0],tl[1]);
			
			textureCoord(0,0+textureCounter);
			vertex(br[0],br[1]);
			textureCoord(1,textureCounter+4);
			vertex(tl[0],tl[1]);
			textureCoord(0,textureCounter+4);
			vertex(tr[0],tr[1]);
			endTriangles();
			
			textureCounter-= 5.0 * t;
			
			local imageSize = image(getArcadePrefix("FinityFlight")+"data/flare.png",1,1);
			modifyWindow(this.x, this.y-30,imageSize[0],imageSize[1],4,-owner.r,false);
			fillColor(0.7,0.9,0.3,alpha);
			rect(0,0,imageSize[0],imageSize[1]);
			revertWindow();
			
			modifyWindow(this.x, this.y-30,imageSize[0],imageSize[1],12,-owner.r,false);
			fillColor(0.7,0.9,0.3,alpha*0.4);
			rect(0,0,imageSize[0],imageSize[1]);
			revertWindow();
		}
	}

	function fire()
	{
		if(cooldown<=0 && secondaryCooldown<=0 && weaponActive)
		{
				currentLaserTime = laserLifespan;
				cooldown = refire;
				sound(getArcadePrefix("FinityFlight")+"data/laser.wav",0,0)
		}
	}
	
	function secondaryFire()
	{
		if (weaponActive)
		{
			local beacon = Dyne(this.name + "laserBeacon"+beaconNum,owner.pos[0],owner.pos[1],0,1,25);
			beacon.addMod(LaserBeacon(beacon.name+"beaconMod", ::level.friends.dynes["player"]), 1);
			beacon.push(scale2(owner.vel, 0.8));
			beaconNum++;
			::level.friendsShots.addDyne(beacon);
			
			secondaryCooldown = 0.5;
		}
	}
}

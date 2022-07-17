antiElevator(state)
{
	self.antiElevator = state;
}

setPlayerSpeed(speed)
{
	self.speed = int(ceil(speed * (self.spawnSpeed / 190)));
	self setMoveSpeed(self.speed);
}

setPlayerSpeedScale(moveSpeedScale)
{
	self.moveSpeedScale = moveSpeedScale * (self.spawnMoveSpeedScale / 1.0);
	self setMoveSpeedScale(self.moveSpeedScale);
}

setPlayerGravity(gravity)
{
	self.gravity = int(ceil(gravity * (self.spawnGravity / 800)));
	self setGravity(self.gravity);
}

setPlayerJumpHeight(jumpHeight)
{
	self.jumpHeight = int(ceil(jumpHeight * (self.spawnJumpHeight / 39)));
	self setJumpHeight(self.jumpHeight);
}

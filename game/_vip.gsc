#include sr\sys\_events;
#include sr\fx\_trail;

main()
{
	event("spawn", ::vip);
}

vip()
{
	self.statusicon = "vip_status";
	self trail();
}

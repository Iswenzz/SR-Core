#include sr\sys\_dvar;
#include sr\sys\_events;

main()
{
	addDvar("pi_hm", "plugin_hitmarker_enable", 1, 0, 1, "int");
	addDvar("pi_hm_av", "plugin_hitmarker_armorvest", 1, 0, 1, "int");

	if (!level.dvar["pi_hm"])
		return;

	event("damage", ::onDamage);
}

onDamage(eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, timeOffset)
{
	if (!isDefined(eInflictor) || !isPlayer(eInflictor) || !isDefined(eAttacker) || !isPlayer(eAttacker) || eAttacker == eInflictor)
		return;

	armor = eInflictor hasPerk("specialty_armorvest") && level.dvar["pi_hm_av"];
	eAttacker thread maps\mp\gametypes\_damagefeedback::updateDamageFeedback(armor);
}

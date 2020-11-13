self: super: rec
{
  lightcord = super.callPackage ./lightcord {};
  goosemod-discord = super.callPackage ./goosemod-discord {};
}

# RSFX

Reticle Special Effects - A crosshair that doesn't rely on bright colours for visibility.


## WHAT:

This ReShade shader builds on the excellent xhair.fx, allowing the player to select from a dot, circle/ring, cross or T-shape, with various parameters to get the right size and shape for your needs.
As enhancement, players are able to apply an inversion effect (and soon™, other effects) to the game, rather than simply overlaying a colour.

### Needs work?
Over time, I'll be adding other effects as games demand it or as players request them.... So, if this isn't working how you'd like, do let me know, and I'll get to souping it up for you.



## WHY:

FPS games usually give us some kind of indicator as to the centre of the screen, since that's where the bullets go. Unfortunately, they usually leave a lot to be desired.
One of the biggest issues is that they become lost in the background. A white crosshair is fine until you're in a white cloud of smoke, and then it's invisible. 

The traditional method to deal with this, is to select a crosshair colour which is unlikely to be similar to the image behind it. So, we see a lot of neon green or pink crosshairs.
That's functionally not too bad (although pink blends well with fire, and green on grass....) but it's aesthetically awful.

The approach to solving this here, is to use the background image to control the colour of the crosshair. 
Initially, this means inversion - If the background is white, we have a black crosshair; if it's black, we have a white crosshair; if red, then cyan, etc, etc.
The effect of this is that instead of subconsciously searching for the (let's say) neon green dot which should be in the place you want to find, you just go looking in that place where there's always the dot ....

In other words, instead of training you to look for the constant object, it trains you to look to the constant position. 

**It's not teaching you to look for the known thing in the unknown place, but to look for the unknown thing in the known place.**

So, it actually trains your screen centre awareness.



## HOW:

For now, it's just the .fx files. ReShade has recently added facilties for sharing plugins better than this, so I'll get on it....... I'll write installation instructions up when I have that done.
Honestly, I kinda wrote this for myself, and have been sending copies to mates for long enough that I figure it's time to share it properly. It walks talks and quacks like it was made without usability in mind. I'll be working on that.
For now, be sure to set the 'Opacity' to a low number (0 works) and 'Filter Background' to a high number (1 works), to see the inversion effect.
You only need RSFX.fx for a crosshair. RSFX_Alt.fx is there to provide a second set of the configuration parameters, which can be used as an alternate crosshair. This is helpful for having one crosshair when in hipfire and another when ADS.

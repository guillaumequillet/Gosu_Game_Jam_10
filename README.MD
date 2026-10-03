## GOSU GAME JAM 10

Theme : don't stop moving

This game was made using Gosu and opengl-bindings only. The goal is to reach the end of the road and deliver your pizza.

You must always keep moving to be on time !

The move meter starts decreasing as soon as you're not riding near your top speed. If it gets empty, it's game over ! Grab some fuel jerrycans on the road to give it a boost.

Be careful with those drivers, they're not good ones and may wiggle a little. Every hit makes you spin and costs you some move meter. Do not hesitate to brake if needed, it's better than taking a hit.

### Controls

- WASD / Arrow keys : accelerate, brake and turn
- Escape : quit

### How to run

You need Ruby with the `gosu` (1.4.6) and `opengl-bindings` gems, then :

```
ruby init.rb
```

Note : the 2.0 pre-release of Gosu doesn't display the 3D scene, stick to 1.4.6.

Enjoy !

### Credits

Music
- music/pop_punk_magpie.mp3 : "Pop Punk Rock" by MagpieMusic
  Pixabay Content License - https://pixabay.com/music/punk-pop-punk-rock-179615/

Sounds
- sfx/scooter_vespa.wav : reworked extract of "Vespa Driving" by freesound_community
  Pixabay Content License - https://pixabay.com/sound-effects/city-vespa-driving-68859/
- sfx/brake_chrysler.wav : extract of "Chrysler LHS tire squeal 02" by audible-edge (Freesound), via freesound_community
  Pixabay Content License - https://pixabay.com/sound-effects/city-chrysler-lhs-tire-squeal-02-04-25-2009wav-14764/
- sfx/crash_car.wav : extract of "Car Crash Sound" by DRAGON-STUDIO
  Pixabay Content License - https://pixabay.com/sound-effects/film-special-effects-car-crash-sound-376882/
- sfx/bonus.wav : "Video Game - Bonus" by Universfield
  Pixabay Content License - https://pixabay.com/sound-effects/film-special-effects-video-game-bonus-323603/

Graphics
- 3D models (scooter, driver, cars, road, buildings, jerrycan) : made for the project with Blender
- Color palette : "Lospec 500" by the Lospec community
  https://lospec.com/palette-list/lospec500

Tech
- Gosu (https://www.libgosu.org)
- opengl-bindings (https://github.com/vaiorabbit/ruby-opengl)

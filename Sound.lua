require "common/class"

Sound = buildClass()


--Constructor--

function Sound:_init( )
  
  self.sounds = {}
  self.sounds.stomp = love.audio.newSource("aud/stomp.wav", "static")
  self.sounds.playerDamage = love.audio.newSource("aud/playerdmg.wav", "static")
  self.sounds.playerDeath = love.audio.newSource("aud/death_withDMG.wav", "static")
  
  self.music = love.audio.newSource("aud/music.wav")
  self.music:setLooping(true)
end


function Sound:play(sound)
  assert(sound ~= nil, "sound source cannot be nil")
  local soundToPlay = sound:clone()
  soundToPlay:play()
end
  
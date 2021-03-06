local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Knit)
local Soundly = require(ReplicatedStorage.Soundly)
local SoundProperties = require(ReplicatedStorage.SoundProperties)

local SoundController = Knit.CreateController {
    Name = "SoundController",
    CharacterSounds = {},
    CachedSounds = {}
}

function SoundController:Map(value, minA, maxA, minB, maxB)
    return (maxB - minB) * (value - minA) / (maxA - minA) + minB;
end

function SoundController:SilenceCharacter()
    self.CharacterSounds.Breathing:Stop()
    self.CharacterSounds.Heartbeat:Stop()
end

function SoundController:PlayCharacterSounds()
    self.CharacterSounds.Breathing:Play()
    self.CharacterSounds.Heartbeat:Play()
end

function SoundController:CacheSound(name, soundlySound)
    self.CachedSounds[name] = soundlySound
end

function SoundController:RemoveSound(name)
    if self.CachedSounds[name] then
        self.CachedSounds[name]:Destroy()
    end
    self.CachedSounds[name] = nil
end

function SoundController:GetSound(name)
    return self.CachedSounds[name]
end

function SoundController:KnitStart()
    local StateController = Knit.Controllers.StateController
    local BreathingSoundProps = SoundProperties.CharacterBreathing
    local HeartbeatSoundProps = SoundProperties.CharacterHeartbeat

    BreathingSoundProps.Volume = Soundly.CreateBinding(function()
        local stamina = StateController.Store:getState().Stamina
        return self:Map(stamina, 100, 0, 0.05, 0.7)
    end)

    BreathingSoundProps.PlaybackSpeed = Soundly.CreateBinding(function()
        local stamina = StateController.Store:getState().Stamina
        return self:Map(stamina, 100, 0, 0.7, 1.1)
    end)

    HeartbeatSoundProps.Volume = Soundly.CreateBinding(function()
        local stamina = StateController.Store:getState().Stamina
        return self:Map(stamina, 100, 0, 0.05, 0.5)
    end)

    HeartbeatSoundProps.PlaybackSpeed = Soundly.CreateBinding(function()
        local stamina = StateController.Store:getState().Stamina
        return self:Map(stamina, 100, 0, 0.5, 1.1)
    end)

    self.CharacterSounds.Breathing = Soundly.CreateSound(workspace.GameSounds, BreathingSoundProps)
    self.CharacterSounds.Heartbeat = Soundly.CreateSound(workspace.GameSounds, HeartbeatSoundProps)
    self.CharacterSounds.Breathing:Play()
    self.CharacterSounds.Heartbeat:Play()
end

return SoundController
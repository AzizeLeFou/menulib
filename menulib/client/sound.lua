Audio = {
    UpDown = {
        audioName = "HUD_FRONTEND_DEFAULT_SOUNDSET",
        audioRef = "NAV_UP_DOWN",
    },
    LeftRight = {
        audioName = "HUD_FRONTEND_DEFAULT_SOUNDSET",
        audioRef = "NAV_LEFT_RIGHT",
    },
    Select = {
        audioName = "HUD_FRONTEND_DEFAULT_SOUNDSET",
        audioRef = "SELECT",
    },
    Back = {
        audioName = "HUD_FRONTEND_DEFAULT_SOUNDSET",
        audioRef = "BACK",
    },
    Error = {
        audioName = "HUD_FRONTEND_DEFAULT_SOUNDSET",
        audioRef = "ERROR",
    },
    Slider = {
        audioName = "HUD_FRONTEND_DEFAULT_SOUNDSET",
        audioRef = "CONTINUOUS_SLIDER",
        Id = nil
    },
}

function PlaySound(menulibrary, Sound)

    local audioId
    if not audioId then
        Citizen.CreateThread(function()
            audioId = GetSoundId()
            PlaySoundFrontend(audioId, Sound, menulibrary, true)
            Citizen.Wait(0.01)
            StopSound(audioId)
            ReleaseSoundId(audioId)
            audioId = nil
        end)
    end

end
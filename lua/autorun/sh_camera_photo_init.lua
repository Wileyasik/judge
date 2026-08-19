-- lua/autorun/sh_camera_photo_init.lua
-- Self-contained photo camera system (no dependency on investigation_system addon)

HgCamera = HgCamera or {}

HgCamera.Settings = {
    CooldownTime = 2,
    CaptureWidth = 512,
    CaptureHeight = 512,
    JpegQuality = 70,
    ChunkSize = 60000,
    FlashDuration = 0.15,
    FlashColor = Color(255, 255, 255, 220),
    PhotoEntitySize = 10,
    PhotoBorderColor = Color(240, 240, 235, 255),
    PhotoShadowColor = Color(0, 0, 0, 80),
}

HgCamera.Utils = {}

function HgCamera.Utils.GeneratePhotoID()
    return string.format("hgphoto_%s_%d", os.time(), math.random(100000, 999999))
end

function HgCamera.Utils.CompressData(data)
    return util.Compress(data)
end

function HgCamera.Utils.DecompressData(data)
    return util.Decompress(data)
end

HgCamera.NetStrings = {
    "HgCam_CameraFlash",
    "HgCam_RequestRender",
    "HgCam_PhotoDataChunk",
    "HgCam_PhotoMaterial",
}

if SERVER then
    for _, str in ipairs(HgCamera.NetStrings) do
        util.AddNetworkString(str)
    end

    AddCSLuaFile("camera/cl_camera_capture.lua")

    include("camera/sv_camera_photo.lua")
else
    include("camera/cl_camera_capture.lua")
end
